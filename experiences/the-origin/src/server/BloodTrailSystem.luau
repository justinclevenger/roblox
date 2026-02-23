--!strict

--[[
	Blood Trail System

	Manages bleeding state for injured players and creates persistent blood
	trail decals on the ground. The entity AI uses these trails to track
	wounded players. Trails expire after BLEED_TRAIL_DURATION seconds.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local TRAIL_DROP_INTERVAL = 0.5 -- seconds between trail points

local BloodTrailSystem = {}
BloodTrailSystem.__index = BloodTrailSystem

export type BloodTrailSystem = typeof(setmetatable(
	{} :: {
		bleedingPlayers: { [Player]: boolean },
		trails: { [Player]: { Types.BloodTrailPoint } },
		trailParts: { [Player]: { Part } },
		trailTimers: { [Player]: number },
	},
	BloodTrailSystem
))

function BloodTrailSystem.new(): BloodTrailSystem
	local self = setmetatable({
		bleedingPlayers = {},
		trails = {},
		trailParts = {},
		trailTimers = {},
	}, BloodTrailSystem)
	return self
end

function BloodTrailSystem.startBleeding(self: BloodTrailSystem, player: Player)
	self.bleedingPlayers[player] = true

	if not self.trails[player] then
		self.trails[player] = {}
	end

	if not self.trailParts[player] then
		self.trailParts[player] = {}
	end

	self.trailTimers[player] = 0

	print(`[BloodTrailSystem] {player.Name} started bleeding`)
end

function BloodTrailSystem.stopBleeding(self: BloodTrailSystem, player: Player)
	self.bleedingPlayers[player] = nil

	print(`[BloodTrailSystem] {player.Name} stopped bleeding (trails persist for {Constants.BLEED_TRAIL_DURATION}s)`)
end

function BloodTrailSystem.update(self: BloodTrailSystem, dt: number)
	-- Drop new trail points for bleeding players
	for player, _ in self.bleedingPlayers do
		self.trailTimers[player] = (self.trailTimers[player] or 0) + dt

		if self.trailTimers[player] >= TRAIL_DROP_INTERVAL then
			self.trailTimers[player] = 0

			local character = player.Character
			if character then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if humanoidRootPart then
					local hrpPos = humanoidRootPart.Position
					-- Place trail point roughly at ground level beneath the player
					local groundPosition = Vector3.new(hrpPos.X, hrpPos.Y - 2.5, hrpPos.Z)

					local trailPoint: Types.BloodTrailPoint = {
						position = groundPosition,
						timestamp = os.clock(),
					}

					table.insert(self.trails[player], trailPoint)

					local part = self:createTrailPart(groundPosition, player)
					table.insert(self.trailParts[player], part)
				end
			end
		end
	end

	-- Expire old trail points across all players
	local now = os.clock()
	for player, points in self.trails do
		local parts = self.trailParts[player]
		local i = 1

		while i <= #points do
			if now - points[i].timestamp > Constants.BLEED_TRAIL_DURATION then
				-- Remove expired point
				table.remove(points, i)

				-- Destroy and remove the corresponding visual part
				if parts and parts[i] then
					parts[i]:Destroy()
					table.remove(parts, i)
				end
			else
				-- Points are chronological, so once we find a valid one
				-- all subsequent ones are also valid
				break
			end
		end

		-- Clean up empty trail tables for non-bleeding players
		if #points == 0 and not self.bleedingPlayers[player] then
			self.trails[player] = nil
			self.trailParts[player] = nil
			self.trailTimers[player] = nil
		end
	end
end

function BloodTrailSystem.createTrailPart(self: BloodTrailSystem, position: Vector3, player: Player): Part
	local part = Instance.new("Part")
	part.Name = "BloodTrail"
	part.Size = Vector3.new(0.8 + math.random() * 0.4, 0.05, 0.8 + math.random() * 0.4)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.fromRGB(80 + math.random(0, 20), 10, 10)
	part.Parent = workspace

	if not self.trailParts[player] then
		self.trailParts[player] = {}
	end

	return part
end

function BloodTrailSystem.getTrailsNear(
	self: BloodTrailSystem,
	position: Vector3,
	radius: number
): { { position: Vector3, time: number } }
	local results: { { position: Vector3, time: number } } = {}
	local radiusSq = radius * radius

	for _, points in self.trails do
		for _, point in points do
			local delta = point.position - position
			local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z

			if distSq <= radiusSq then
				table.insert(results, {
					position = point.position,
					time = point.timestamp,
				})
			end
		end
	end

	return results
end

function BloodTrailSystem.getAllTrails(self: BloodTrailSystem): { { position: Vector3, time: number } }
	local results: { { position: Vector3, time: number } } = {}

	for _, points in self.trails do
		for _, point in points do
			table.insert(results, {
				position = point.position,
				time = point.timestamp,
			})
		end
	end

	return results
end

function BloodTrailSystem.removePlayer(self: BloodTrailSystem, player: Player)
	self.bleedingPlayers[player] = nil

	-- Destroy all visual trail parts for this player
	local parts = self.trailParts[player]
	if parts then
		for _, part in parts do
			part:Destroy()
		end
	end

	-- Clean up all tables
	self.trails[player] = nil
	self.trailParts[player] = nil
	self.trailTimers[player] = nil

	print(`[BloodTrailSystem] Cleaned up trails for {player.Name}`)
end

function BloodTrailSystem.cleanup(self: BloodTrailSystem)
	-- Destroy all trail parts across all players
	for _, parts in self.trailParts do
		for _, part in parts do
			part:Destroy()
		end
	end

	-- Clear all state
	table.clear(self.bleedingPlayers)
	table.clear(self.trails)
	table.clear(self.trailParts)
	table.clear(self.trailTimers)

	print("[BloodTrailSystem] Full cleanup complete")
end

return BloodTrailSystem
