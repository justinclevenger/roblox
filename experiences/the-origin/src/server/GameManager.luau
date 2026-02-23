--!strict

--[[
	Game Manager

	Owns the full round lifecycle: player join/leave, data persistence,
	level loading, loot spawning, objective tracking, entity activation,
	and round start/end orchestration. All subsystems are created and
	managed internally.
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local BloodTrailSystem = require(script.BloodTrailSystem)
local EntityController = require(script.EntityAI)
local HidingSystem = require(script.HidingSystem)
local Hospital = require(script.Levels.Hospital)
local LootSpawner = require(script.LootSpawner)
local ObjectiveManager = require(script.ObjectiveManager)
local PlayerStateManager = require(script.PlayerStateManager)
local Remotes = require(script.Remotes)

local playerStore = DataStoreService:GetDataStore("PlayerData")

local GameManager = {}
GameManager.__index = GameManager

export type GameManager = typeof(setmetatable(
	{} :: {
		players: { [Player]: boolean },
		playerData: { [Player]: Types.PlayerSaveData },
		currentLevel: string?,
		roundActive: boolean,
		roundStartTime: number,
		levelModel: Model?,
		levelData: Types.LevelData?,
		playerStateManager: PlayerStateManager.PlayerStateManager,
		lootSpawner: LootSpawner.LootSpawner,
		objectiveManager: ObjectiveManager.ObjectiveManager,
		hidingSystem: HidingSystem.HidingSystem,
		bloodTrailSystem: BloodTrailSystem.BloodTrailSystem,
		entityController: EntityController.EntityController,
	},
	GameManager
))

function GameManager.new(): GameManager
	local psm = PlayerStateManager.new()
	local lootSpawner = LootSpawner.new()
	local objectiveManager = ObjectiveManager.new()
	local hidingSystem = HidingSystem.new()
	local bloodTrailSystem = BloodTrailSystem.new()
	local entityController = EntityController.new()

	-- Wire loot pickup to PlayerStateManager
	lootSpawner.onPickupCallback = function(player: Player, item: Types.InventoryItem): boolean
		return psm:addItem(player, item)
	end

	local self = setmetatable({
		players = {},
		playerData = {},
		currentLevel = nil,
		roundActive = false,
		roundStartTime = 0,
		levelModel = nil,
		levelData = nil,
		playerStateManager = psm,
		lootSpawner = lootSpawner,
		objectiveManager = objectiveManager,
		hidingSystem = hidingSystem,
		bloodTrailSystem = bloodTrailSystem,
		entityController = entityController,
	}, GameManager)

	return self
end

--[[
	Called when a player joins the server.
	Loads their saved progression from DataStore, falling back to defaults
	if the load fails or no data exists.
]]
function GameManager.onPlayerJoin(self: GameManager, player: Player)
	self.players[player] = true

	-- Load player data from DataStore (pcall-wrapped; DataStore calls can fail)
	local success, data = pcall(function()
		return playerStore:GetAsync(`player_{player.UserId}`)
	end)

	local saveData: Types.PlayerSaveData = if success and data
		then data :: Types.PlayerSaveData
		else {
			levelsUnlocked = { "st-marens-hospital" },
			loreFound = {},
			xp = 0,
			perks = {},
		}

	self.playerData[player] = saveData

	print(
		`[GameManager] {player.Name} joined — loaded save data (XP: {saveData.xp}, levels: {#saveData.levelsUnlocked})`
	)
end

--[[
	Called when a player's character spawns (including respawns).
	Initializes player state and teleports to the level spawn if a round is active.
]]
function GameManager.onPlayerSpawn(self: GameManager, player: Player)
	self.playerStateManager:initPlayer(player)

	-- If a round is active, teleport the player to the level's spawn point
	if self.roundActive and self.levelData then
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if humanoidRootPart then
				humanoidRootPart.CFrame = CFrame.new(self.levelData.spawnPoint)
				print(`[GameManager] Teleported {player.Name} to level spawn`)
			end
		end
	end
end

--[[
	Called when a player leaves the server.
	Saves their data to DataStore and cleans up all subsystem state.
]]
function GameManager.onPlayerLeave(self: GameManager, player: Player)
	-- Save player data to DataStore using UpdateAsync (safe against race conditions)
	local saveData = self.playerData[player]
	if saveData then
		local success, err = pcall(function()
			playerStore:UpdateAsync(`player_{player.UserId}`, function(_oldData)
				return saveData
			end)
		end)

		if success then
			print(`[GameManager] Saved data for {player.Name}`)
		else
			warn(`[GameManager] Failed to save data for {player.Name}: {err}`)
		end
	end

	-- Clean up all subsystem state for this player
	self.playerStateManager:removePlayer(player)
	self.hidingSystem:removePlayer(player)
	self.bloodTrailSystem:removePlayer(player)

	-- Remove from tracking tables
	self.players[player] = nil
	self.playerData[player] = nil
end

--[[
	Start a new round for the given level.
	Builds geometry, spawns loot, loads objectives, registers hiding spots,
	configures entity waypoints, and schedules entity activation.
]]
function GameManager.startRound(self: GameManager, levelName: string)
	self.currentLevel = levelName
	self.roundActive = true
	self.roundStartTime = os.clock()

	local playerCount = self:getPlayerCount()

	-- Determine entity activation delay based on player count
	local activationDelay = Constants.ENTITY_ACTIVATION_DELAY_SOLO
	if playerCount == 2 then
		activationDelay = Constants.ENTITY_ACTIVATION_DELAY_DUO
	elseif playerCount >= 3 then
		activationDelay = Constants.ENTITY_ACTIVATION_DELAY_SQUAD
	end

	-- Build level geometry
	self.levelModel, self.levelData = Hospital.build()

	-- Load and spawn loot
	self.lootSpawner:loadLevelLoot(levelName)
	self.lootSpawner:spawnAll(playerCount)

	-- Load objectives
	self.objectiveManager:loadLevel(levelName)

	-- Register hiding spots with the hiding system
	if self.levelData then
		self.hidingSystem:registerSpots(self.levelData.hidingSpots)

		-- Set entity patrol waypoints (StateMachine expects { Vector3 })
		local waypointPositions: { Vector3 } = {}
		for _, waypoint in self.levelData.waypoints do
			table.insert(waypointPositions, waypoint.position)
		end
		self.entityController.stateMachine:setWaypoints(waypointPositions)
	end

	-- Notify all clients that the round has started
	if Remotes.RoundStarted then
		Remotes.RoundStarted:FireAllClients({ level = levelName })
	end

	-- Send objectives to all clients
	if Remotes.ObjectivesLoaded then
		Remotes.ObjectivesLoaded:FireAllClients(self.objectiveManager.objectives)
	end

	-- Schedule entity activation after the appropriate delay
	task.delay(activationDelay, function()
		if not self.roundActive then
			return
		end

		if self.levelData and #self.levelData.entitySpawnPositions > 0 then
			local spawnPositions = self.levelData.entitySpawnPositions
			local spawnPos = spawnPositions[math.random(1, #spawnPositions)]
			self.entityController:activate(spawnPos)
			print(`[GameManager] Entity activated at {spawnPos} after {activationDelay}s delay`)
		end
	end)

	print(`[GameManager] Round started: {levelName} with {playerCount} players, entity in {activationDelay}s`)
end

--[[
	End the current round.
	Deactivates the entity, optionally awards XP and unlocks, fires
	round-end remotes, and cleans up all subsystems.
]]
function GameManager.endRound(self: GameManager, success: boolean)
	self.roundActive = false

	-- Deactivate the entity
	self.entityController:deactivate()

	if success then
		-- Award XP and unlock next level for all players
		local currentLevelIndex = 0
		for i, levelName in Constants.LEVELS do
			if levelName == self.currentLevel then
				currentLevelIndex = i
				break
			end
		end

		local nextLevel: string? = if currentLevelIndex > 0 and currentLevelIndex < #Constants.LEVELS
			then Constants.LEVELS[currentLevelIndex + 1]
			else nil

		for player in self.players do
			local saveData = self.playerData[player]
			if saveData then
				-- Award XP for completing the round
				saveData.xp += 100

				-- Unlock next level if there is one
				if nextLevel then
					local alreadyUnlocked = false
					for _, unlocked in saveData.levelsUnlocked do
						if unlocked == nextLevel then
							alreadyUnlocked = true
							break
						end
					end

					if not alreadyUnlocked then
						table.insert(saveData.levelsUnlocked, nextLevel)
						print(`[GameManager] {player.Name} unlocked: {nextLevel}`)
					end
				end
			end
		end

		print("[GameManager] Round complete — extraction successful")
	else
		print("[GameManager] Round failed — all players eliminated")
	end

	-- Fire round-ended remote to all clients
	if Remotes.RoundEnded then
		Remotes.RoundEnded:FireAllClients({
			success = success,
			level = self.currentLevel,
			duration = os.clock() - self.roundStartTime,
		})
	end

	-- Cleanup all subsystems
	self.lootSpawner:cleanup()
	self.hidingSystem:cleanup()
	self.bloodTrailSystem:cleanup()

	-- Cleanup level geometry
	if self.levelModel then
		Hospital.cleanup(self.levelModel)
		self.levelModel = nil
	end

	self.levelData = nil
	self.currentLevel = nil
end

--[[
	Called during server shutdown (via game:BindToClose).
	Rapidly saves all player data using UpdateAsync.
]]
function GameManager.onServerShutdown(self: GameManager)
	print("[GameManager] Server shutting down — saving all player data")

	for player in self.players do
		local saveData = self.playerData[player]
		if saveData then
			local success, err = pcall(function()
				playerStore:UpdateAsync(`player_{player.UserId}`, function(_oldData)
					return saveData
				end)
			end)

			if success then
				print(`[GameManager] Saved data for {player.Name}`)
			else
				warn(`[GameManager] Failed to save data for {player.Name}: {err}`)
			end
		end
	end

	print("[GameManager] Shutdown save complete")
end

--[[
	Return the number of players currently tracked by the game manager.
]]
function GameManager.getPlayerCount(self: GameManager): number
	local count = 0
	for _ in self.players do
		count += 1
	end
	return count
end

return GameManager
