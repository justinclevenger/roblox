-- Example: NPC with wandering + dynamic smooth pathfinding
-- States: WANDER (roam randomly) → PURSUE (path to target) → WANDER (lost target)
-- Place this as a Script inside an NPC model in workspace

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Pathfinding = require(ReplicatedStorage:WaitForChild("Pathfinding"))

local npc = script.Parent
local humanoid = npc:WaitForChild("Humanoid")
local rootPart = npc:WaitForChild("HumanoidRootPart")

-- ── Configuration ──────────────────────────────────────────────────────────
local DETECTION_RANGE = 60    -- How far the NPC can detect a target (studs)
local LOSE_RANGE = 80         -- Distance at which the NPC loses the target
local ARRIVAL_DISTANCE = 5    -- How close counts as "reached" a waypoint
local STUCK_TIMEOUT = 3       -- Seconds before the NPC considers itself stuck
local PATH_CHECK_INTERVAL = 0.25
local TARGET_MOVE_THRESHOLD = 4

-- Wander settings
local WANDER_MIN_RADIUS = 15  -- Minimum wander distance
local WANDER_MAX_RADIUS = 40  -- Maximum wander distance
local WANDER_PAUSE_MIN = 1    -- Min seconds to pause between wanders
local WANDER_PAUSE_MAX = 3    -- Max seconds to pause between wanders
local WANDER_SPEED = 8
local PURSUE_SPEED = 16

-- ── State ──────────────────────────────────────────────────────────────────
local State = { WANDER = "Wander", PURSUE = "Pursue" }
local currentState = State.WANDER

local currentPath: { Vector3 }? = nil
local currentWaypointIndex = 1
local needsRepath = true
local currentTarget: BasePart? = nil

-- ── Target Detection ───────────────────────────────────────────────────────
-- Finds the closest player character within detection range
local function findTarget(): BasePart?
	local closest: BasePart? = nil
	local closestDist = DETECTION_RANGE

	for _, player in game:GetService("Players"):GetPlayers() do
		local character = player.Character
		if not character then continue end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local hum = character:FindFirstChild("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then continue end

		local dist = (hrp.Position - rootPart.Position).Magnitude
		if dist < closestDist then
			closestDist = dist
			closest = hrp
		end
	end

	return closest
end

-- Check if the current target is still valid
local function isTargetValid(): boolean
	if not currentTarget then return false end
	if not currentTarget.Parent then return false end

	local character = currentTarget.Parent
	local hum = character:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then return false end

	local dist = (currentTarget.Position - rootPart.Position).Magnitude
	return dist <= LOSE_RANGE
end

-- ── Map Change Detection ───────────────────────────────────────────────────
local function onMapChanged()
	if currentPath and currentWaypointIndex <= #currentPath then
		if not Pathfinding.isPathValid(currentPath, currentWaypointIndex) then
			needsRepath = true
		end
	end
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BasePart") and descendant.CanCollide then
		task.defer(onMapChanged)
	end
end)

workspace.DescendantRemoving:Connect(function(descendant)
	if descendant:IsA("BasePart") and descendant.CanCollide then
		task.defer(onMapChanged)
	end
end)

-- ── Background Validation Loop ─────────────────────────────────────────────
local lastTargetPosition: Vector3? = nil

task.spawn(function()
	while true do
		task.wait(PATH_CHECK_INTERVAL)

		-- Check if target moved significantly while pursuing
		if currentState == State.PURSUE and currentTarget then
			if lastTargetPosition then
				local targetMoved = (currentTarget.Position - lastTargetPosition).Magnitude > TARGET_MOVE_THRESHOLD
				if targetMoved then
					lastTargetPosition = currentTarget.Position
					needsRepath = true
				end
			end
		end

		-- Validate the remaining path is still clear
		if currentPath and currentWaypointIndex <= #currentPath then
			if not Pathfinding.isPathValid(currentPath, currentWaypointIndex) then
				needsRepath = true
			end
		end
	end
end)

-- ── Path Calculation ───────────────────────────────────────────────────────
local function calculatePathTo(targetPos: Vector3): boolean
	local rawPath = Pathfinding.findPath(rootPart.Position, targetPos)

	if not rawPath then
		currentPath = nil
		return false
	end

	-- Smooth the path for natural movement
	currentPath = Pathfinding.smoothPath(rawPath, 4)
	currentWaypointIndex = 1
	needsRepath = false

	Pathfinding.visualize(currentPath, 3)
	return true
end

-- ── Walk Along Path ────────────────────────────────────────────────────────
-- Walks one waypoint at a time, returns true if the whole path was completed
local function walkPath(): boolean
	while currentPath and currentWaypointIndex <= #currentPath do
		if needsRepath then return false end

		local waypoint = currentPath[currentWaypointIndex]
		humanoid:MoveTo(waypoint)

		local startTime = tick()
		local reached = false

		while not reached and not needsRepath do
			if tick() - startTime > STUCK_TIMEOUT then
				needsRepath = true
				return false
			end

			local dist = (rootPart.Position - waypoint).Magnitude
			if dist < ARRIVAL_DISTANCE then
				reached = true
			end

			task.wait(0.1)
		end

		if not reached then return false end
		currentWaypointIndex += 1
	end

	-- Finished all waypoints
	currentPath = nil
	return true
end

-- ── Wander Behavior ────────────────────────────────────────────────────────
local function doWander()
	humanoid.WalkSpeed = WANDER_SPEED

	-- Pick a random walkable spot
	local wanderTarget = Pathfinding.getRandomWalkablePosition(
		rootPart.Position,
		WANDER_MIN_RADIUS,
		WANDER_MAX_RADIUS
	)

	if not wanderTarget then
		-- Couldn't find a spot, pause then try again
		task.wait(1)
		return
	end

	if calculatePathTo(wanderTarget) then
		walkPath()
	end

	-- Pause between wanders for a natural feel
	local pause = WANDER_PAUSE_MIN + math.random() * (WANDER_PAUSE_MAX - WANDER_PAUSE_MIN)
	task.wait(pause)
end

-- ── Pursue Behavior ────────────────────────────────────────────────────────
local function doPursue()
	humanoid.WalkSpeed = PURSUE_SPEED

	if not currentTarget then return end

	lastTargetPosition = currentTarget.Position

	if needsRepath or not currentPath then
		if not calculatePathTo(currentTarget.Position) then
			task.wait(0.5)
			return
		end
	end

	walkPath()

	-- Check if we reached the target
	if currentTarget and currentTarget.Parent then
		local dist = (rootPart.Position - currentTarget.Position).Magnitude
		if dist <= ARRIVAL_DISTANCE then
			-- Arrived at target — you can add attack/interact logic here
			task.wait(0.5)
		end
	end
end

-- ── Main State Machine ─────────────────────────────────────────────────────
while true do
	if currentState == State.WANDER then
		-- Check for a target to pursue
		local found = findTarget()
		if found then
			currentTarget = found
			currentState = State.PURSUE
			needsRepath = true
			currentPath = nil
		else
			doWander()
		end

	elseif currentState == State.PURSUE then
		-- Check if we lost the target
		if not isTargetValid() then
			currentTarget = nil
			currentState = State.WANDER
			needsRepath = true
			currentPath = nil
		else
			doPursue()
		end
	end

	task.wait()
end
