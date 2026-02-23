--!strict

--[[
	Entity Sensory System

	Handles hearing, vision, and trail detection.
	All checks run server-side using raycasts and distance calculations.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Types = require(ReplicatedStorage.Shared.Types)

local Senses = {}
Senses.__index = Senses

export type Senses = typeof(setmetatable(
	{} :: {
		config: Types.EntitySenses,
		detectionProgress: { [Player]: number }, -- 0 to 1, awareness ramp per player
		excludeInstances: { Instance },
	},
	Senses
))

function Senses.new(config: Types.EntitySenses): Senses
	local self = setmetatable({
		config = config,
		detectionProgress = {},
		excludeInstances = {},
	}, Senses)

	return self
end

function Senses.canHearSound(_self: Senses, entityPosition: Vector3, event: Types.SoundEvent): boolean
	local PathfindingService = game:GetService("PathfindingService")

	-- First quick check: if straight-line distance is > 2x radius, definitely can't hear
	local straightDist = (entityPosition - event.position).Magnitude
	if straightDist > event.radius * 2 then
		return false
	end

	-- Try PathfindingService for acoustic propagation distance
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
	})

	local success, _err = pcall(function()
		path:ComputeAsync(entityPosition, event.position)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Calculate total path length (acoustic distance through corridors)
		local waypoints = path:GetWaypoints()
		local totalDist = 0
		for i = 2, #waypoints do
			totalDist += (waypoints[i].Position - waypoints[i - 1].Position).Magnitude
		end
		return totalDist <= event.radius
	else
		-- Fallback to straight-line if pathfinding fails
		return straightDist <= event.radius
	end
end

function Senses.checkVision(
	self: Senses,
	entityPosition: Vector3,
	entityLookDirection: Vector3,
	targetPosition: Vector3,
	isTargetLit: boolean,
	isTargetFlashlightOn: boolean
): "None" | "Partial" | "Full"
	local toTarget = targetPosition - entityPosition
	local distance = toTarget.Magnitude
	local direction = toTarget.Unit

	-- Check flashlight detection first (longest range, ignores cone)
	if isTargetFlashlightOn and distance <= self.config.flashlightDetectRange then
		-- Flashlight is visible from any angle
		if self:hasLineOfSight(entityPosition, targetPosition) then
			return "Partial" -- Sees the light, not necessarily the player
		end
	end

	-- Determine vision range based on lighting
	local visionRange = if isTargetLit then self.config.visionRangeLit else self.config.visionRangeDark

	-- Check distance
	if distance > visionRange then
		return "None"
	end

	-- Check cone angle
	local angle = math.deg(math.acos(math.clamp(entityLookDirection:Dot(direction), -1, 1)))
	if angle > self.config.visionCone / 2 then
		return "None"
	end

	-- Check line of sight (raycast)
	if not self:hasLineOfSight(entityPosition, targetPosition) then
		return "None"
	end

	return "Full"
end

function Senses.hasLineOfSight(self: Senses, from: Vector3, to: Vector3): boolean
	local direction = to - from
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = self.excludeInstances

	local result = Workspace:Raycast(from, direction, raycastParams)

	if result then
		-- Hit something — check if it's close enough to the target
		local distanceToHit = (result.Position - from).Magnitude
		local distanceToTarget = direction.Magnitude
		return distanceToHit >= distanceToTarget * 0.95
	end

	-- No hit means clear line of sight
	return true
end

function Senses.setExcludeInstances(self: Senses, instances: { Instance })
	self.excludeInstances = instances
end

function Senses.updateDetection(
	self: Senses,
	player: Player,
	visionResult: "None" | "Partial" | "Full",
	dt: number
): boolean
	local current = self.detectionProgress[player] or 0

	if visionResult == "Full" then
		current += dt / self.config.detectionRamp
	elseif visionResult == "Partial" then
		current += dt / (self.config.detectionRamp * 2)
	else
		current -= dt * 0.5 -- Slowly decay awareness
	end

	current = math.clamp(current, 0, 1)
	self.detectionProgress[player] = current

	return current >= 1 -- Fully detected
end

function Senses.checkBleedTrail(
	_self: Senses,
	entityPosition: Vector3,
	trails: { { position: Vector3, time: number } }
): Vector3?
	-- TODO: Find nearest blood trail point within detection range
	-- Return the trail point position for the entity to follow
	local closestTrail: Vector3? = nil
	local closestDist = math.huge

	for _, trail in trails do
		local dist = (entityPosition - trail.position).Magnitude
		if dist < closestDist and dist <= 20 then
			closestDist = dist
			closestTrail = trail.position
		end
	end

	return closestTrail
end

return Senses
