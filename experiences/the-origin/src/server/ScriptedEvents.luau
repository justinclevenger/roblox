--!strict

--[[
	ScriptedEvents

	Manages one-shot environmental events triggered by player actions.
	Events only fire on first playthrough (tracked per player).
	Each event has a trigger zone (position + radius) and a callback
	that executes once per player when they enter the zone.

	Some events are zone-triggered (player walks into area), others
	are manually triggered via triggerEvent() (item pickup, tape play, etc.).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LevelConfig = require(ReplicatedStorage.Shared.LevelConfig)

local Remotes = require(script.Parent.Remotes)

local ScriptedEvents = {}
ScriptedEvents.__index = ScriptedEvents

export type TriggerZone = {
	position: Vector3,
	radius: number,
	callback: (player: Player) -> (),
}

export type ScriptedEvents = typeof(setmetatable(
	{} :: {
		levelName: string?,
		levelModel: Model?,
		triggeredEvents: { [Player]: { [string]: boolean } },
		triggerZones: { [string]: TriggerZone },
		active: boolean,
		_connections: { RBXScriptConnection },
	},
	ScriptedEvents
))

function ScriptedEvents.new(): ScriptedEvents
	local self = setmetatable({
		levelName = nil,
		levelModel = nil,
		triggeredEvents = {},
		triggerZones = {},
		active = false,
		_connections = {},
	}, ScriptedEvents)
	return self
end

------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------

--[[
	Initialize the scripted events system for a given level.
	Registers all trigger zones and event callbacks for the level.
]]
function ScriptedEvents.initialize(self: ScriptedEvents, levelName: string, levelModel: Model)
	self.levelName = levelName
	self.levelModel = levelModel
	self.active = true

	if levelName == "st-marens-hospital" then
		self:_initHospitalEvents()
	end

	print(`[ScriptedEvents] Initialized for level: {levelName}`)
end

--[[
	Called each frame (from Heartbeat). Checks all trigger zones against
	all player positions and fires one-shot callbacks on first entry.
]]
function ScriptedEvents.update(self: ScriptedEvents, _dt: number)
	if not self.active then
		return
	end

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then
			continue
		end
		local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hrp then
			continue
		end

		for eventId, zone in self.triggerZones do
			-- Initialize player tracking table if needed
			if not self.triggeredEvents[player] then
				self.triggeredEvents[player] = {}
			end

			-- Skip events already triggered for this player
			if self.triggeredEvents[player][eventId] then
				continue
			end

			local dist = (hrp.Position - zone.position).Magnitude
			if dist <= zone.radius then
				self.triggeredEvents[player][eventId] = true
				task.spawn(function()
					zone.callback(player)
				end)
			end
		end
	end
end

--[[
	Manually trigger a named event for a specific player.
	Used for events driven by item pickup, interaction, etc.
	Returns false if the event was already triggered or does not exist.
]]
function ScriptedEvents.triggerEvent(self: ScriptedEvents, player: Player, eventId: string): boolean
	if not self.active then
		return false
	end

	if not self.triggeredEvents[player] then
		self.triggeredEvents[player] = {}
	end

	-- Already triggered for this player
	if self.triggeredEvents[player][eventId] then
		return false
	end

	local zone = self.triggerZones[eventId]
	if not zone then
		warn(`[ScriptedEvents] Unknown event: {eventId}`)
		return false
	end

	self.triggeredEvents[player][eventId] = true
	task.spawn(function()
		zone.callback(player)
	end)
	return true
end

--[[
	Remove all tracking data for a player who has left the game.
]]
function ScriptedEvents.removePlayer(self: ScriptedEvents, player: Player)
	self.triggeredEvents[player] = nil
end

--[[
	Clean up all state: trigger zones, tracking tables, connections, and
	any spawned props that are children of the level model.
]]
function ScriptedEvents.cleanup(self: ScriptedEvents)
	self.active = false
	self.levelName = nil
	self.levelModel = nil

	-- Disconnect any lingering connections (e.g., ProximityPrompt)
	for _, connection in self._connections do
		connection:Disconnect()
	end
	table.clear(self._connections)

	table.clear(self.triggeredEvents)
	table.clear(self.triggerZones)

	print("[ScriptedEvents] Cleaned up")
end

------------------------------------------------------------------------
-- Hospital (Level 1) — St. Maren's Hospital
------------------------------------------------------------------------

--[[
	Register all scripted events for the first level.
	Zone-triggered events use spatial proximity; manual events are fired
	by external systems calling triggerEvent().
]]
function ScriptedEvents._initHospitalEvents(self: ScriptedEvents)
	local levelModel = self.levelModel
	if not levelModel then
		warn("[ScriptedEvents] No level model — cannot register hospital events")
		return
	end

	-- Use room positions from LevelConfig for accuracy
	local receptionPos = LevelConfig.GroundFloorRooms[1].position -- Reception
	local upperHallwayPos = LevelConfig.UpperFloorRooms[10].position -- UpperHallway_EastWest
	local room202Pos = LevelConfig.UpperFloorRooms[2].position -- Room202
	local basementCorridorPos = LevelConfig.BasementRooms[7].position -- BasementCorridor
	local morguePos = LevelConfig.BasementRooms[1].position -- Morgue

	------------------------------------------------------------------------
	-- 1. Reception Phone Ring
	--    Trigger: Player enters Reception area.
	--    A phone rings. Answering it yields 2s of static, then a flatline.
	------------------------------------------------------------------------
	self.triggerZones["reception_phone"] = {
		position = receptionPos + Vector3.new(0, 3, 0),
		radius = 15,
		callback = function(_triggerPlayer: Player)
			-- Create a phone prop on the reception desk
			local phone = Instance.new("Part")
			phone.Name = "ReceptionPhone"
			phone.Size = Vector3.new(0.5, 0.3, 0.8)
			phone.Position = receptionPos + Vector3.new(-5, 3.5, 2)
			phone.Anchored = true
			phone.Material = Enum.Material.SmoothPlastic
			phone.Color = Color3.fromRGB(30, 30, 35)
			phone.Parent = levelModel

			-- Phone ring sound (positional)
			if Remotes.SoundEvent then
				Remotes.SoundEvent:FireAllClients({
					soundId = "PhoneRing",
					position = phone.Position,
					radius = 30,
					priority = "Medium",
				})
			end

			-- Proximity prompt to answer the phone
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Answer"
			prompt.ObjectText = "Phone"
			prompt.MaxActivationDistance = 6
			prompt.HoldDuration = 0
			prompt.Parent = phone

			local promptConnection = prompt.Triggered:Connect(function(_interactPlayer: Player)
				-- Disable prompt so it can only be answered once
				prompt.Enabled = false

				-- 2 seconds of static
				if Remotes.SoundEvent then
					Remotes.SoundEvent:FireAllClients({
						soundId = "PhoneStatic",
						position = phone.Position,
						radius = 20,
						priority = "Medium",
					})
				end

				-- After 2s, flatline tone
				task.delay(2, function()
					if Remotes.SoundEvent then
						Remotes.SoundEvent:FireAllClients({
							soundId = "PhoneFlatline",
							position = phone.Position,
							radius = 20,
							priority = "High",
						})
					end
				end)

				-- Clean up prompt after use
				task.delay(5, function()
					prompt:Destroy()
				end)
			end)

			table.insert(self._connections, promptConnection)
		end,
	}

	------------------------------------------------------------------------
	-- 2. Upper Floor Door Slam
	--    Trigger: First time player visits the upper floor.
	--    A door at the end of the hallway slams shut. Nothing is there.
	------------------------------------------------------------------------
	self.triggerZones["upper_floor_door_slam"] = {
		position = upperHallwayPos + Vector3.new(0, 3, 0),
		radius = 10,
		callback = function(_triggerPlayer: Player)
			-- Create a door part at the far end of the upper hallway
			local door = Instance.new("Part")
			door.Name = "SlamDoor"
			door.Size = Vector3.new(LevelConfig.DOOR_WIDTH, LevelConfig.DOOR_HEIGHT, 1)
			door.Anchored = true
			door.Material = Enum.Material.Wood
			door.Color = Color3.fromRGB(80, 50, 30)

			-- Start the door open (rotated)
			local doorEndPos = upperHallwayPos + Vector3.new(20, LevelConfig.DOOR_HEIGHT / 2, 0)
			door.CFrame = CFrame.new(doorEndPos) * CFrame.Angles(0, math.rad(90), 0)
			door.Parent = levelModel

			-- Brief delay, then slam shut
			task.delay(0.3, function()
				-- Snap to closed position (rotate back)
				door.CFrame = CFrame.new(doorEndPos)

				-- Door slam sound
				if Remotes.SoundEvent then
					Remotes.SoundEvent:FireAllClients({
						soundId = "DoorSlam",
						position = doorEndPos,
						radius = 30,
						priority = "High",
					})
				end
			end)

			-- Remove the door after a few seconds so it doesn't block gameplay
			task.delay(8, function()
				if door.Parent then
					door:Destroy()
				end
			end)
		end,
	}

	------------------------------------------------------------------------
	-- 3. Room 202 TV Flash
	--    Trigger: Player enters Room 202.
	--    A TV briefly shows security footage from an impossible angle,
	--    then cuts to static and turns off.
	------------------------------------------------------------------------
	self.triggerZones["room202_tv"] = {
		position = room202Pos + Vector3.new(0, 3, 0),
		radius = 8,
		callback = function(_triggerPlayer: Player)
			-- Create a wall-mounted TV screen
			local tv = Instance.new("Part")
			tv.Name = "TV_Room202"
			tv.Size = Vector3.new(3, 2, 0.2)
			tv.Position = room202Pos + Vector3.new(2, 5, -4)
			tv.Anchored = true
			tv.CanCollide = false

			-- Start dark/off
			tv.Material = Enum.Material.SmoothPlastic
			tv.Color = Color3.fromRGB(20, 20, 25)
			tv.Parent = levelModel

			-- Flicker on after a beat
			task.delay(0.5, function()
				if not tv.Parent then
					return
				end
				-- TV turns on: bright neon glow (security footage)
				tv.Material = Enum.Material.Neon
				tv.Color = Color3.fromRGB(200, 200, 200)

				-- Emit a quiet sound cue
				if Remotes.SoundEvent then
					Remotes.SoundEvent:FireAllClients({
						soundId = "TVStatic",
						position = tv.Position,
						radius = 15,
						priority = "Low",
					})
				end
			end)

			-- After 1s, switch to static (blue-grey)
			task.delay(1.5, function()
				if not tv.Parent then
					return
				end
				tv.Color = Color3.fromRGB(100, 100, 120)
			end)

			-- After 2.5s total, cut to black
			task.delay(2.5, function()
				if not tv.Parent then
					return
				end
				tv.Material = Enum.Material.SmoothPlastic
				tv.Color = Color3.fromRGB(20, 20, 25)
			end)
		end,
	}

	------------------------------------------------------------------------
	-- 4. Basement Gurney Roll
	--    Trigger: First time player enters the basement.
	--    Lights flicker. A gurney rolls across the corridor on its own
	--    and stops at the morgue door.
	------------------------------------------------------------------------
	self.triggerZones["basement_gurney"] = {
		position = basementCorridorPos + Vector3.new(0, 3, 0),
		radius = 12,
		callback = function(triggerPlayer: Player)
			-- Flicker the player's flashlight briefly
			if Remotes.FlashlightFlicker then
				Remotes.FlashlightFlicker:FireClient(triggerPlayer)
			end

			-- Flicker any lights in the basement area
			local basementLights: { { light: PointLight, brightness: number } } = {}
			for _, desc in levelModel:GetDescendants() do
				if desc:IsA("PointLight") then
					local parent = desc.Parent :: BasePart?
					if parent and parent:IsA("BasePart") then
						-- Check if the light is at basement Y level
						if parent.Position.Y < 0 then
							table.insert(basementLights, {
								light = desc :: PointLight,
								brightness = (desc :: PointLight).Brightness,
							})
						end
					end
				end
			end

			-- Quick flicker sequence
			task.spawn(function()
				for _ = 1, 3 do
					for _, data in basementLights do
						data.light.Brightness = 0
					end
					task.wait(0.15)
					for _, data in basementLights do
						data.light.Brightness = data.brightness
					end
					task.wait(0.1)
				end
			end)

			-- Create and animate the gurney after the flicker
			task.delay(0.8, function()
				local gurney = Instance.new("Part")
				gurney.Name = "GhostGurney"
				gurney.Size = Vector3.new(2, 1, 4)
				gurney.Anchored = true
				gurney.Material = Enum.Material.Metal
				gurney.Color = Color3.fromRGB(150, 150, 155)

				-- Start at one end of the basement corridor
				local startPos = basementCorridorPos + Vector3.new(25, 0.5, 0)
				local endPos = morguePos + Vector3.new(10, 0.5 - LevelConfig.BASEMENT_Y, 0) -- near the morgue door
				gurney.Position = startPos
				gurney.Parent = levelModel

				-- Gurney rolling sound
				if Remotes.SoundEvent then
					Remotes.SoundEvent:FireAllClients({
						soundId = "GurneyRoll",
						position = startPos,
						radius = 40,
						priority = "High",
					})
				end

				-- Animate: slide across the corridor over 2 seconds
				local duration = 2
				local elapsed = 0
				while elapsed < duration do
					local dt = task.wait()
					elapsed += dt
					local t = math.clamp(elapsed / duration, 0, 1)
					-- Ease-out: starts fast, decelerates at the morgue door
					local eased = 1 - (1 - t) * (1 - t)
					gurney.Position = startPos:Lerp(endPos, eased)
				end

				-- Final position
				gurney.Position = endPos

				-- Metal impact sound when it stops
				if Remotes.SoundEvent then
					Remotes.SoundEvent:FireAllClients({
						soundId = "MetalImpact",
						position = endPos,
						radius = 25,
						priority = "Medium",
					})
				end
			end)
		end,
	}

	------------------------------------------------------------------------
	-- 5. Patient 31 Chart — All Doors Slam
	--    Trigger: Manual (player picks up the Patient 31 chart).
	--    Every door on the upper floor slams simultaneously.
	--    3 seconds of eerie silence, then back to normal.
	------------------------------------------------------------------------
	self.triggerZones["patient31_chart"] = {
		position = Vector3.zero, -- not zone-triggered; fired via triggerEvent()
		radius = 0,
		callback = function(_triggerPlayer: Player)
			-- Create temporary door parts at all upper floor doorways
			local slamDoors: { Part } = {}

			-- Place doors at each room entry on the upper floor
			for _, room in LevelConfig.UpperFloorRooms do
				-- Skip hallways themselves
				if string.find(room.name, "Hallway") then
					continue
				end

				local doorPos = room.position + Vector3.new(0, LevelConfig.DOOR_HEIGHT / 2, room.size.Z / 2)

				local door = Instance.new("Part")
				door.Name = `SlamDoor_{room.name}`
				door.Size = Vector3.new(LevelConfig.DOOR_WIDTH, LevelConfig.DOOR_HEIGHT, 1)
				door.Position = doorPos
				door.Anchored = true
				door.Material = Enum.Material.Wood
				door.Color = Color3.fromRGB(80, 50, 30)
				door.Parent = levelModel
				table.insert(slamDoors, door)
			end

			-- Simultaneous slam sound (building-wide on upper floor)
			if Remotes.SoundEvent then
				Remotes.SoundEvent:FireAllClients({
					soundId = "DoorSlam",
					position = upperHallwayPos + Vector3.new(0, 3, 0),
					radius = 60,
					priority = "Critical",
				})
			end

			-- 3 seconds of silence, then remove the doors
			task.delay(3, function()
				for _, door in slamDoors do
					if door.Parent then
						door:Destroy()
					end
				end
			end)
		end,
	}

	------------------------------------------------------------------------
	-- 6. Psych Ward Tape — Blackout
	--    Trigger: Manual (player plays the tape in the Psych Ward).
	--    Every light in the hospital cuts out for 5 seconds.
	--    When flashlights return, something in the room has moved.
	------------------------------------------------------------------------
	self.triggerZones["psych_tape"] = {
		position = Vector3.zero,
		radius = 0,
		callback = function(_triggerPlayer: Player)
			-- Flicker all players' flashlights off
			if Remotes.FlashlightFlicker then
				for _, player in Players:GetPlayers() do
					Remotes.FlashlightFlicker:FireClient(player)
				end
			end

			-- Collect and dim every light source in the level
			local savedLights: { { light: Instance, brightness: number } } = {}
			for _, desc in levelModel:GetDescendants() do
				if desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then
					local light = desc :: any
					table.insert(savedLights, {
						light = light,
						brightness = light.Brightness,
					})
					light.Brightness = 0
				end
			end

			-- Blackout sound cue
			if Remotes.SoundEvent then
				Remotes.SoundEvent:FireAllClients({
					soundId = "PowerDown",
					position = Vector3.new(0, 0, 0),
					radius = 200,
					priority = "Critical",
				})
			end

			-- Restore all lights after 5 seconds
			task.delay(5, function()
				for _, data in savedLights do
					if data.light.Parent then
						(data.light :: any).Brightness = data.brightness
					end
				end

				-- Power-up sound
				if Remotes.SoundEvent then
					Remotes.SoundEvent:FireAllClients({
						soundId = "PowerUp",
						position = Vector3.new(0, 0, 0),
						radius = 200,
						priority = "Medium",
					})
				end
			end)

			-- Move an object in the psych ward while lights are off
			-- (something has moved when the player looks back)
			task.delay(1, function()
				local psychWardConfig = LevelConfig.UpperFloorRooms[9] -- PsychWard
				local movedObject = Instance.new("Part")
				movedObject.Name = "MovedChair"
				movedObject.Size = Vector3.new(2, 3, 2)
				movedObject.Position = psychWardConfig.position + Vector3.new(3, 1.5, -5)
				movedObject.Anchored = true
				movedObject.Material = Enum.Material.Wood
				movedObject.Color = Color3.fromRGB(60, 40, 25)
				movedObject.Parent = levelModel
			end)
		end,
	}

	------------------------------------------------------------------------
	-- 7. Generator Start — PA System
	--    Trigger: Manual (generator starts successfully).
	--    Emergency PA crackles to life. A voice reads patient names.
	--    It reads the triggering player's name.
	------------------------------------------------------------------------
	self.triggerZones["generator_pa"] = {
		position = Vector3.zero,
		radius = 0,
		callback = function(triggerPlayer: Player)
			-- PA crackle sound (building-wide)
			if Remotes.SoundEvent then
				Remotes.SoundEvent:FireAllClients({
					soundId = "PACrackle",
					position = Vector3.new(0, 0, 0),
					radius = 200,
					priority = "Critical",
				})
			end

			-- Brief pause before the voice begins
			task.delay(1.5, function()
				-- Voice reading names (sound event with metadata)
				if Remotes.SoundEvent then
					Remotes.SoundEvent:FireAllClients({
						soundId = "PAVoiceNames",
						position = Vector3.new(0, 0, 0),
						radius = 200,
						priority = "Critical",
						metadata = {
							playerName = triggerPlayer.Name,
						},
					})
				end
			end)

			-- Flicker lights briefly during PA broadcast for tension
			task.delay(2, function()
				local flickerLights: { { light: Instance, brightness: number } } = {}
				for _, desc in levelModel:GetDescendants() do
					if desc:IsA("PointLight") then
						local light = desc :: PointLight
						table.insert(flickerLights, {
							light = light,
							brightness = light.Brightness,
						})
					end
				end

				-- Rapid double-flicker
				for _ = 1, 2 do
					for _, data in flickerLights do
						(data.light :: PointLight).Brightness = data.brightness * 0.2
					end
					task.wait(0.1)
					for _, data in flickerLights do
						(data.light :: PointLight).Brightness = data.brightness
					end
					task.wait(0.15)
				end
			end)
		end,
	}

	print(`[ScriptedEvents] Registered {self:_countZones()} hospital events`)
end

------------------------------------------------------------------------
-- Internal helpers
------------------------------------------------------------------------

function ScriptedEvents._countZones(self: ScriptedEvents): number
	local count = 0
	for _ in self.triggerZones do
		count += 1
	end
	return count
end

return ScriptedEvents
