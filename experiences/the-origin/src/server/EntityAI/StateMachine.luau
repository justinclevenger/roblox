--!strict

--[[
	Entity State Machine

	States: Idle → Patrol → Investigate → Hunt → Chase → Search → Patrol

	Each state defines:
	- Entry behavior (what happens when entering the state)
	- Update behavior (what happens each frame)
	- Transition conditions (when to move to another state)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local StateMachine = {}
StateMachine.__index = StateMachine

export type StateMachine = typeof(setmetatable(
	{} :: {
		currentState: Types.EntityState,
		stateTime: number, -- time spent in current state
		lastKnownPlayerPosition: Vector3?,
		investigateTarget: Vector3?,
		patrolWaypoints: { Vector3 },
		patrolIndex: number,
		chaseLostTime: number, -- time since losing sight during chase
		currentPosition: Vector3,
		moveSpeed: number,
		patrolDwellTimer: number,
		patrolDwellTarget: number,
		visitedRooms: { [string]: number },
		lastHidingSpotCheck: number,
		doorDelayTimer: number,
		searchDirection: Vector3,
		searchPauseTimer: number,
		searchDirectionTimer: number,
		isPaused: boolean,
		onCheckHidingSpots: ((position: Vector3, radius: number) -> ())?,
	},
	StateMachine
))

function StateMachine.new(): StateMachine
	local self = setmetatable({
		currentState = "Idle" :: Types.EntityState,
		stateTime = 0,
		lastKnownPlayerPosition = nil,
		investigateTarget = nil,
		patrolWaypoints = {},
		patrolIndex = 1,
		chaseLostTime = 0,
		currentPosition = Vector3.zero,
		moveSpeed = 8, -- will be set by EntityController
		patrolDwellTimer = 0,
		patrolDwellTarget = 0,
		visitedRooms = {} :: { [string]: number },
		lastHidingSpotCheck = 0,
		doorDelayTimer = 0,
		searchDirection = Vector3.new(1, 0, 0),
		searchPauseTimer = 0,
		searchDirectionTimer = 0,
		isPaused = false,
		onCheckHidingSpots = nil :: ((position: Vector3, radius: number) -> ())?,
	}, StateMachine)

	return self
end

function StateMachine.setWaypoints(self: StateMachine, waypoints: { Vector3 })
	self.patrolWaypoints = waypoints
	self.patrolIndex = 1
end

function StateMachine.setPosition(self: StateMachine, pos: Vector3)
	self.currentPosition = pos
end

function StateMachine.getPosition(self: StateMachine): Vector3
	return self.currentPosition
end

function StateMachine.setMoveSpeed(self: StateMachine, speed: number)
	self.moveSpeed = speed
end

function StateMachine.transition(self: StateMachine, newState: Types.EntityState)
	local oldState = self.currentState
	self.currentState = newState
	self.stateTime = 0
	print(`[StateMachine] {oldState} → {newState}`)

	-- State entry behaviors: reset state-specific timers and fields
	if newState == "Patrol" then
		self.patrolDwellTimer = 0
		self.patrolDwellTarget = 0
	elseif newState == "Investigate" then
		self.lastHidingSpotCheck = 0
	elseif newState == "Hunt" then
		-- Hunt is more aggressive: offset timer so first hiding spot check happens sooner
		self.lastHidingSpotCheck = -2
	elseif newState == "Chase" then
		self.chaseLostTime = 0
		self.doorDelayTimer = 0
	elseif newState == "Search" then
		self.searchPauseTimer = 0
		self.searchDirectionTimer = 0
		self.isPaused = false
		self.lastHidingSpotCheck = 0
		-- Initialize search direction based on last movement heading
		local angle = math.random() * math.pi * 2
		self.searchDirection = Vector3.new(math.cos(angle), 0, math.sin(angle))
	end

	-- TODO: Notify clients of state change (for audio/visual shifts)
end

function StateMachine.update(self: StateMachine, dt: number)
	self.stateTime += dt

	if self.currentState == "Idle" then
		self:updateIdle(dt)
	elseif self.currentState == "Patrol" then
		self:updatePatrol(dt)
	elseif self.currentState == "Investigate" then
		self:updateInvestigate(dt)
	elseif self.currentState == "Hunt" then
		self:updateHunt(dt)
	elseif self.currentState == "Chase" then
		self:updateChase(dt)
	elseif self.currentState == "Search" then
		self:updateSearch(dt)
	end
end

function StateMachine.updateIdle(_self: StateMachine, _dt: number)
	-- Dormant. Waiting for activation trigger.
end

function StateMachine.updatePatrol(self: StateMachine, dt: number)
	-- No waypoints set, nothing to do
	if #self.patrolWaypoints == 0 then
		return
	end

	-- Currently dwelling at a waypoint
	if self.patrolDwellTarget > 0 then
		self.patrolDwellTimer += dt
		if self.patrolDwellTimer >= self.patrolDwellTarget then
			-- Done dwelling, advance to next waypoint
			self.patrolDwellTimer = 0
			self.patrolDwellTarget = 0
			self:_advancePatrolIndex()
		end
		return
	end

	-- Move toward current waypoint
	local target = self.patrolWaypoints[self.patrolIndex]
	if not target then
		return
	end

	local offset = target - self.currentPosition
	-- Keep movement on the horizontal plane
	local flatOffset = Vector3.new(offset.X, 0, offset.Z)
	local distance = flatOffset.Magnitude

	if distance < 3 then
		-- Arrived at waypoint — begin dwelling (8-15s random)
		self.patrolDwellTarget = 8 + math.random() * 7
		self.patrolDwellTimer = 0

		-- Track the visited room (use waypoint position as room key)
		local roomKey = `{math.floor(target.X)}_{math.floor(target.Z)}`
		self.visitedRooms[roomKey] = (self.visitedRooms[roomKey] or 0) + 1
	else
		-- Move toward waypoint
		local direction = flatOffset.Unit
		self.currentPosition = self.currentPosition + direction * self.moveSpeed * dt
	end
end

--[[
	Advances patrol index, weighting toward less-visited waypoints.
	Prefers unvisited or least-visited areas over sequential order.
]]
function StateMachine._advancePatrolIndex(self: StateMachine)
	if #self.patrolWaypoints <= 1 then
		self.patrolIndex = 1
		return
	end

	-- Build candidate list excluding current waypoint
	local candidates: { { index: number, visits: number } } = {}
	for i, wp in self.patrolWaypoints do
		if i ~= self.patrolIndex then
			local roomKey = `{math.floor(wp.X)}_{math.floor(wp.Z)}`
			local visits = self.visitedRooms[roomKey] or 0
			table.insert(candidates, { index = i, visits = visits })
		end
	end

	-- Sort by visit count ascending (least visited first)
	table.sort(candidates, function(a, b)
		return a.visits < b.visits
	end)

	-- Pick from the least-visited tier with some randomness
	-- Take all candidates tied for fewest visits
	local minVisits = candidates[1].visits
	local leastVisited: { number } = {}
	for _, c in candidates do
		if c.visits == minVisits then
			table.insert(leastVisited, c.index)
		else
			break
		end
	end

	-- Random pick among least-visited waypoints
	self.patrolIndex = leastVisited[math.random(1, #leastVisited)]
end

function StateMachine.updateInvestigate(self: StateMachine, dt: number)
	-- Timeout: after 15s with no escalation, return to Patrol
	if self.stateTime >= 15 then
		self:transition("Patrol")
		return
	end

	-- No target to investigate
	if not self.investigateTarget then
		self:transition("Patrol")
		return
	end

	local target = self.investigateTarget :: Vector3
	local offset = target - self.currentPosition
	local flatOffset = Vector3.new(offset.X, 0, offset.Z)
	local distance = flatOffset.Magnitude

	if distance > 5 then
		-- Move toward investigate target at 1.5x patrol speed
		local direction = flatOffset.Unit
		local investigateSpeed = self.moveSpeed * 1.5
		self.currentPosition = self.currentPosition + direction * investigateSpeed * dt
	else
		-- Within 5 studs of target — check hiding spots nearby
		if self.onCheckHidingSpots then
			self.onCheckHidingSpots(target, 15)
		end
	end
end

function StateMachine.updateHunt(self: StateMachine, dt: number)
	-- After 20s of hunting with no result, return to Patrol
	if self.stateTime >= 20 then
		self:transition("Patrol")
		return
	end

	if not self.investigateTarget then
		self:transition("Patrol")
		return
	end

	local target = self.investigateTarget :: Vector3

	-- Tightening spiral/zigzag sweep pattern around the investigate target
	-- Radius shrinks over time, lateral offset oscillates with sine
	local elapsedRatio = math.clamp(self.stateTime / 20, 0, 1)
	local sweepRadius = 15 * (1 - elapsedRatio * 0.7) -- tightens from 15 to ~4.5 studs
	local lateralOffset = math.sin(self.stateTime * 2) * 8
	local forwardOffset = math.cos(self.stateTime * 1.3) * sweepRadius

	local sweepTarget = target + Vector3.new(lateralOffset, 0, forwardOffset)
	local offset = sweepTarget - self.currentPosition
	local flatOffset = Vector3.new(offset.X, 0, offset.Z)
	local distance = flatOffset.Magnitude

	if distance > 1 then
		local direction = flatOffset.Unit
		local huntSpeed = self.moveSpeed * 1.2
		self.currentPosition = self.currentPosition + direction * huntSpeed * dt
	end

	-- Check hiding spots aggressively every 5s
	if self.onCheckHidingSpots then
		if self.stateTime - self.lastHidingSpotCheck >= 5 then
			self.lastHidingSpotCheck = self.stateTime
			self.onCheckHidingSpots(self.currentPosition, 20)
		end
	end
end

function StateMachine.updateChase(self: StateMachine, dt: number)
	-- Handle door interaction delay: pause briefly when crossing room boundaries
	if self.doorDelayTimer > 0 then
		self.doorDelayTimer -= dt
		return
	end

	-- Sprint toward last known position
	if self.lastKnownPlayerPosition then
		local target = self.lastKnownPlayerPosition :: Vector3
		local offset = target - self.currentPosition
		local flatOffset = Vector3.new(offset.X, 0, offset.Z)
		local distance = flatOffset.Magnitude

		-- Chase speed is 2x patrol speed (sprint)
		local chaseSpeed = self.moveSpeed * 2

		if distance > 2 then
			local direction = flatOffset.Unit
			local step = direction * chaseSpeed * dt

			-- Simulate door delay: if step crosses a significant distance threshold,
			-- add a brief pause. This uses a simple heuristic: every 20 studs traveled
			-- represents a potential room boundary.
			local stepMag = step.Magnitude
			if stepMag > 0 then
				-- Check if we'd overshoot the target
				if stepMag > distance then
					self.currentPosition = Vector3.new(target.X, self.currentPosition.Y, target.Z)
				else
					self.currentPosition = self.currentPosition + step
				end
			end
		else
			-- Reached last known position and no fresh sighting update means
			-- the player is no longer visible. Clear the position to trigger
			-- the lost-sight timer below.
			self.lastKnownPlayerPosition = nil
		end
	end

	-- Track line-of-sight loss time
	if self.lastKnownPlayerPosition == nil then
		self.chaseLostTime += dt
		if self.chaseLostTime >= 8 then
			self:transition("Search")
		end
	else
		self.chaseLostTime = 0
	end
end

--[[
	Called externally when the entity crosses a door boundary during chase.
	Adds a 0.5s pause to simulate door interaction.
]]
function StateMachine.triggerDoorDelay(self: StateMachine)
	self.doorDelayTimer = 0.5
end

function StateMachine.updateSearch(self: StateMachine, dt: number)
	-- After 25s of searching, transition back to Patrol with area bias
	if self.stateTime >= 25 then
		-- Mark the area as visited so patrol biases away from here
		local roomKey = `{math.floor(self.currentPosition.X)}_{math.floor(self.currentPosition.Z)}`
		self.visitedRooms[roomKey] = (self.visitedRooms[roomKey] or 0) + 3 -- heavy bias away
		self:transition("Patrol")
		return
	end

	-- Pause-to-listen moments: every 8s, stop moving for 2s
	self.searchPauseTimer += dt
	if self.isPaused then
		if self.searchPauseTimer >= 2 then
			self.isPaused = false
			self.searchPauseTimer = 0
		end
		return -- standing still, listening
	else
		if self.searchPauseTimer >= 8 then
			self.isPaused = true
			self.searchPauseTimer = 0
			return
		end
	end

	-- Erratic direction changes every 2-3s
	self.searchDirectionTimer += dt
	if self.searchDirectionTimer >= 2 + math.random() then
		self.searchDirectionTimer = 0

		-- 30% chance to double back (reverse direction)
		if math.random() < 0.3 then
			self.searchDirection = -self.searchDirection
		else
			-- Random new direction on the horizontal plane
			local angle = math.random() * math.pi * 2
			self.searchDirection = Vector3.new(math.cos(angle), 0, math.sin(angle))
		end
	end

	-- Move in current search direction
	local searchSpeed = self.moveSpeed * 1.3
	self.currentPosition = self.currentPosition + self.searchDirection * searchSpeed * dt

	-- Check hiding spots aggressively every 3s
	if self.onCheckHidingSpots then
		if self.stateTime - self.lastHidingSpotCheck >= 3 then
			self.lastHidingSpotCheck = self.stateTime
			self.onCheckHidingSpots(self.currentPosition, 18)
		end
	end
end

function StateMachine.onSoundDetected(self: StateMachine, event: Types.SoundEvent)
	self.investigateTarget = event.position

	if self.currentState == "Patrol" then
		if event.priority == "Critical" or event.priority == "High" then
			self:transition("Investigate")
		end
	elseif self.currentState == "Investigate" then
		-- Update target if new sound is closer/louder
		self:transition("Hunt")
	elseif self.currentState == "Search" then
		self:transition("Investigate")
	end
end

function StateMachine.onPlayerSpotted(self: StateMachine, playerPosition: Vector3)
	self.lastKnownPlayerPosition = playerPosition

	if self.currentState ~= "Chase" then
		self:transition("Chase")
	end
end

return StateMachine
