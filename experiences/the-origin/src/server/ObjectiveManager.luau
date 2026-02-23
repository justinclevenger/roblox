--!strict

--[[
	Objective Manager

	Tracks objective state per level. Objectives are sequential steps
	the player must complete to reach extraction.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local ObjectiveManager = {}
ObjectiveManager.__index = ObjectiveManager

export type ObjectiveManager = typeof(setmetatable(
	{} :: {
		objectives: { Types.ObjectiveStep },
		currentStep: number,
		levelName: string?,
		generatorState: string?, -- "empty" | "filled" | "starting" | "running" | "complete"
		beaconActive: boolean,
		beaconTimer: number,
		onEntityAggressionSpike: (() -> ())?,
		onRoundComplete: ((success: boolean) -> ())?,
	},
	ObjectiveManager
))

function ObjectiveManager.new(): ObjectiveManager
	local self = setmetatable({
		objectives = {},
		currentStep = 1,
		levelName = nil,
		generatorState = "empty",
		beaconActive = false,
		beaconTimer = 0,
		onEntityAggressionSpike = nil,
		onRoundComplete = nil,
	}, ObjectiveManager)

	self:connectRemotes()

	return self
end

function ObjectiveManager.loadLevel(self: ObjectiveManager, levelName: string)
	self.levelName = levelName
	self.currentStep = 1

	if levelName == "st-marens-hospital" then
		self.objectives = {
			{
				id = "find_flashlight",
				description = "Find a flashlight",
				completed = false,
				requiredItems = nil,
			},
			{
				id = "find_fuel",
				description = "Find the fuel canister",
				completed = false,
				requiredItems = nil,
			},
			{
				id = "fill_generator",
				description = "Fill the generator with fuel",
				completed = false,
				requiredItems = { "FuelCanister" },
			},
			{
				id = "start_generator",
				description = "Start the generator",
				completed = false,
				requiredItems = nil,
			},
			{
				id = "survive_generator",
				description = "Survive while the generator powers up",
				completed = false,
				requiredItems = nil,
			},
			{
				id = "reach_rooftop",
				description = "Get to the rooftop",
				completed = false,
				requiredItems = nil,
			},
			{
				id = "activate_beacon",
				description = "Activate the extraction beacon",
				completed = false,
				requiredItems = nil,
			},
			{
				id = "survive_extraction",
				description = "Survive until the helicopter arrives",
				completed = false,
				requiredItems = nil,
			},
		}
	end

	-- Replicate objectives to clients for UI
	local Remotes = require(script.Remotes)
	if Remotes.ObjectivesLoaded then
		Remotes.ObjectivesLoaded:FireAllClients(self.objectives)
	end
end

function ObjectiveManager.completeStep(self: ObjectiveManager, stepId: string): boolean
	for i, step in self.objectives do
		if step.id == stepId and not step.completed then
			step.completed = true
			self.currentStep = i + 1
			print(`[Objectives] Completed: {step.description}`)

			-- Replicate to clients
			local Remotes = require(script.Remotes)
			if Remotes.ObjectiveUpdated then
				local currentObj = self:getCurrentObjective()
				Remotes.ObjectiveUpdated:FireAllClients(currentObj)
			end

			-- Trigger entity aggression spike on objective completion
			if self.onEntityAggressionSpike then
				self.onEntityAggressionSpike()
			end

			return true
		end
	end
	return false
end

function ObjectiveManager.getCurrentObjective(self: ObjectiveManager): Types.ObjectiveStep?
	if self.currentStep <= #self.objectives then
		return self.objectives[self.currentStep]
	end
	return nil
end

function ObjectiveManager.isComplete(self: ObjectiveManager): boolean
	for _, step in self.objectives do
		if not step.completed then
			return false
		end
	end
	return true
end

function ObjectiveManager.connectRemotes(self: ObjectiveManager)
	local Remotes = require(script.Remotes)
	-- Generator interaction
	if Remotes.GeneratorInteract then
		Remotes.GeneratorInteract.OnServerEvent:Connect(function(player: Player, action: string)
			self:handleGeneratorInteract(player, action)
		end)
	end

	-- Beacon activation
	if Remotes.BeaconActivated then
		Remotes.BeaconActivated.OnServerEvent:Connect(function(player: Player)
			self:handleBeaconActivated(player)
		end)
	end
end

function ObjectiveManager.handleGeneratorInteract(self: ObjectiveManager, player: Player, action: string)
	local Remotes = require(script.Remotes)
	local Constants = require(ReplicatedStorage.Shared.Constants)

	if action == "fill" then
		-- Step 1: Fill generator with fuel
		if self.generatorState ~= "empty" then
			return
		end

		-- Validate player has FuelCanister (this should be checked by PlayerStateManager)
		-- The client should only send this if they have the item
		self.generatorState = "filled"

		-- Complete the fill_generator objective
		self:completeStep("fill_generator")

		-- Fire state update
		if Remotes.GeneratorStateUpdate then
			Remotes.GeneratorStateUpdate:FireAllClients("filled")
		end

		print("[Objectives] Generator filled with fuel")
	elseif action == "pull" then
		-- Step 2: Pull cord to start generator
		if self.generatorState ~= "filled" then
			return
		end

		-- Fire sound event (generator pull is LOUD - 60 stud radius)
		if Remotes.SoundEvent then
			-- Get player position for sound origin
			local character = player.Character
			if character then
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if hrp then
					Remotes.SoundEvent:FireAllClients({
						position = hrp.Position,
						radius = Constants.SOUND_GENERATOR_PULL,
						priority = "Critical",
					})
				end
			end
		end

		-- Random chance to succeed (average 4-5 pulls)
		local pullSuccess = math.random() < 0.25 -- ~25% chance per pull

		if pullSuccess then
			self.generatorState = "starting"
			self:completeStep("start_generator")

			if Remotes.GeneratorStateUpdate then
				Remotes.GeneratorStateUpdate:FireAllClients("starting")
			end

			-- Entity enters HUNT toward basement
			if self.onEntityAggressionSpike then
				self.onEntityAggressionSpike()
			end

			-- 30 second boot timer
			task.delay(Constants.GENERATOR_BOOT_TIME, function()
				if self.generatorState == "starting" then
					self.generatorState = "running"
					self:completeStep("survive_generator")

					if Remotes.GeneratorStateUpdate then
						Remotes.GeneratorStateUpdate:FireAllClients("running")
					end

					print("[Objectives] Generator fully powered — rooftop unlocked")
				end
			end)

			print("[Objectives] Generator started — 30s boot sequence")
		else
			-- Failed pull — just sound, try again
			if Remotes.GeneratorStateUpdate then
				Remotes.GeneratorStateUpdate:FireAllClients("pull_failed")
			end
		end
	end
end

function ObjectiveManager.handleBeaconActivated(self: ObjectiveManager, _player: Player)
	if self.beaconActive then
		return
	end
	if self.generatorState ~= "running" then
		return
	end

	self.beaconActive = true
	self:completeStep("activate_beacon")

	local Remotes = require(script.Remotes)
	local Constants = require(ReplicatedStorage.Shared.Constants)

	-- Determine extraction time based on player count
	local playerCount = #Players:GetPlayers()
	local extractionTime = Constants.EXTRACTION_BEACON_SOLO
	if playerCount == 2 then
		extractionTime = Constants.EXTRACTION_BEACON_DUO
	elseif playerCount >= 3 then
		extractionTime = Constants.EXTRACTION_BEACON_SQUAD
	end

	print(`[Objectives] Beacon activated — extraction in {extractionTime}s`)

	-- Entity aggression spike
	if self.onEntityAggressionSpike then
		self.onEntityAggressionSpike()
	end

	-- Countdown timer
	self.beaconTimer = extractionTime
	task.spawn(function()
		while self.beaconTimer > 0 do
			task.wait(1)
			self.beaconTimer -= 1

			-- Send periodic updates to clients (every 10s or last 10s)
			if self.beaconTimer % 10 == 0 or self.beaconTimer <= 10 then
				if Remotes.ObjectiveUpdated then
					Remotes.ObjectiveUpdated:FireAllClients({
						id = "survive_extraction",
						description = `Survive until extraction ({self.beaconTimer}s)`,
						completed = false,
					})
				end
			end
		end

		-- Extraction complete!
		self:completeStep("survive_extraction")

		if self.onRoundComplete then
			self.onRoundComplete(true)
		end
	end)
end

function ObjectiveManager.cleanup(self: ObjectiveManager)
	self.objectives = {}
	self.currentStep = 1
	self.levelName = nil
	self.generatorState = "empty"
	self.beaconActive = false
	self.beaconTimer = 0
end

return ObjectiveManager
