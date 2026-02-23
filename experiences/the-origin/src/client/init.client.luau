--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local PlayerController = require(script.PlayerController)
local ProximityFear = require(script.ProximityFear)

local player = Players.LocalPlayer

-- Client entry point
print(`[Client] {Constants.GAME_NAME} v{Constants.GAME_VERSION} — {player.Name} connected`)

-- Initialize client systems
local proximityFear = ProximityFear.new(player)
local playerController = PlayerController.new(player)

-- Initialize UI (require after creation since directory may be new)
local UI = require(script.UI)
local gameUI = UI.new(player)

-- Wait for Remotes folder
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
if not remotesFolder then
	warn("[Client] Remotes folder not found!")
	return
end

-- Track entity distance for proximity fear
local entityPosition: Vector3? = nil
local _entityState: string? = nil

-- Entity position updates
local entityPosRemote = remotesFolder:WaitForChild("EntityPositionUpdate", 5)
if entityPosRemote then
	(entityPosRemote :: RemoteEvent).OnClientEvent:Connect(function(pos: Vector3, state: string)
		entityPosition = pos
		_entityState = state
	end)
end

-- Entity state changes
local entityStateRemote = remotesFolder:WaitForChild("EntityStateChanged", 5)
if entityStateRemote then
	(entityStateRemote :: RemoteEvent).OnClientEvent:Connect(function(state: string)
		_entityState = state
	end)
end

-- Player damaged
local playerDamagedRemote = remotesFolder:WaitForChild("PlayerDamaged", 5)
if playerDamagedRemote then
	(playerDamagedRemote :: RemoteEvent).OnClientEvent:Connect(function(data: any)
		if data.health then
			gameUI:updateHealth(data.health, Constants.MAX_HEALTH, data.isBleeding or false)
		end
		if data.isBleeding then
			playerController:setInjuryModifier(Constants.SPEED_LIMP_MODIFIER)
		end
	end)
end

-- Player state update (full state sync)
local stateUpdateRemote = remotesFolder:WaitForChild("PlayerStateUpdate", 5)
if stateUpdateRemote then
	(stateUpdateRemote :: RemoteEvent).OnClientEvent:Connect(function(data: any)
		if data.state then
			local state = data.state
			gameUI:updateHealth(state.health, state.maxHealth, state.isBleeding)
			gameUI:updateInventory(state.inventory, state.keyItems)

			-- Update injury modifier based on health
			if state.health <= 2 and state.health > 0 then
				playerController:setInjuryModifier(Constants.SPEED_LIMP_MODIFIER)
			else
				playerController:setInjuryModifier(1.0)
			end

			-- Battery refill
			if data.batteryRefill then
				playerController:refillBattery()
			end
		end
	end)
end

-- Objective updates
local objectiveRemote = remotesFolder:WaitForChild("ObjectiveUpdated", 5)
if objectiveRemote then
	(objectiveRemote :: RemoteEvent).OnClientEvent:Connect(function(objective: any)
		gameUI:updateObjective(objective)
	end)
end

-- Objectives loaded
local objectivesLoadedRemote = remotesFolder:WaitForChild("ObjectivesLoaded", 5)
if objectivesLoadedRemote then
	(objectivesLoadedRemote :: RemoteEvent).OnClientEvent:Connect(function(objectives: any)
		gameUI:loadObjectives(objectives)
	end)
end

-- Item pickup result
local pickupResultRemote = remotesFolder:WaitForChild("ItemPickupResult", 5)
if pickupResultRemote then
	(pickupResultRemote :: RemoteEvent).OnClientEvent:Connect(function(data: any)
		if data.success and data.state then
			gameUI:updateInventory(data.state.inventory, data.state.keyItems)
		end
	end)
end

-- Hiding spot checked (entity is checking your hiding spot!)
local hidingCheckedRemote = remotesFolder:WaitForChild("HidingSpotChecked", 5)
if hidingCheckedRemote then
	(hidingCheckedRemote :: RemoteEvent).OnClientEvent:Connect(function()
		-- Spike dread: force proximity fear to max for a moment
		proximityFear:update(0.016, 5) -- simulate 5 studs distance
	end)
end

-- Flashlight flicker (entity electronic flatline)
local flickerRemote = remotesFolder:WaitForChild("FlashlightFlicker", 5)
if flickerRemote then
	(flickerRemote :: RemoteEvent).OnClientEvent:Connect(function()
		playerController:flickerFlashlight()
	end)
end

-- Round started
local roundStartedRemote = remotesFolder:WaitForChild("RoundStarted", 5)
if roundStartedRemote then
	(roundStartedRemote :: RemoteEvent).OnClientEvent:Connect(function(data: any)
		print(`[Client] Round started: {data.level or "unknown"}`)
	end)
end

-- Round ended
local roundEndedRemote = remotesFolder:WaitForChild("RoundEnded", 5)
if roundEndedRemote then
	(roundEndedRemote :: RemoteEvent).OnClientEvent:Connect(function(data: any)
		print(`[Client] Round ended: {if data.success then "Victory!" else "Defeat"}`)
		entityPosition = nil
		_entityState = nil
	end)
end

-- Main update loop: calculate entity distance and feed to proximity fear
RunService.Heartbeat:Connect(function(dt: number)
	local character = player.Character
	if not character then
		return
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local entityDist: number? = nil
	if entityPosition then
		entityDist = (hrp.Position - entityPosition).Magnitude
	end

	proximityFear:update(dt, entityDist)
	gameUI:updateStamina(playerController.stamina)
end)
