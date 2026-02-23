--!strict

--[[
	Adaptive Behavior System

	Tracks player patterns and adjusts entity behavior per run:
	- Hiding spot memory: repeated use of same spots increases check probability
	- Route memory: repeated escape routes get patrolled
	- Escalation: entity becomes more aggressive over time
	- De-escalation: rubber banding after repeated deaths
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local AdaptiveBehavior = {}
AdaptiveBehavior.__index = AdaptiveBehavior

export type AdaptiveBehavior = typeof(setmetatable(
	{} :: {
		memory: Types.AdaptiveMemory,
		escalationModifier: number, -- multiplier that increases over time
		deescalationActive: boolean,
	},
	AdaptiveBehavior
))

function AdaptiveBehavior.new(): AdaptiveBehavior
	local self = setmetatable({
		memory = {
			hidingSpotUses = {},
			escapeRoutes = {},
			timeSinceStart = 0,
			playerDeaths = 0,
		},
		escalationModifier = 1.0,
		deescalationActive = false,
	}, AdaptiveBehavior)

	return self
end

function AdaptiveBehavior.update(self: AdaptiveBehavior, dt: number)
	self.memory.timeSinceStart += dt

	-- Escalation: increase modifier over time
	-- Caps at 1.5x after ~10 minutes
	if not self.deescalationActive then
		self.escalationModifier = math.min(1.5, 1.0 + self.memory.timeSinceStart / 600)
	end
end

function AdaptiveBehavior.recordHidingSpotUse(self: AdaptiveBehavior, spotId: string)
	local current = self.memory.hidingSpotUses[spotId] or 0
	self.memory.hidingSpotUses[spotId] = current + 1
end

function AdaptiveBehavior.getHidingSpotCheckChance(self: AdaptiveBehavior, spotId: string): number
	local uses = self.memory.hidingSpotUses[spotId] or 0

	if uses == 0 then
		return 0.1 -- 10% base chance (almost always walks past)
	elseif uses == 1 then
		return 0.5 -- 50/50
	else
		return 0.9 -- Almost certain to check
	end
end

function AdaptiveBehavior.recordEscapeRoute(self: AdaptiveBehavior, routeHash: string)
	local current = self.memory.escapeRoutes[routeHash] or 0
	self.memory.escapeRoutes[routeHash] = current + 1
end

function AdaptiveBehavior.shouldPatrolRoute(self: AdaptiveBehavior, routeHash: string): boolean
	local uses = self.memory.escapeRoutes[routeHash] or 0
	return uses >= 2 -- Start patrolling after player uses same route twice
end

function AdaptiveBehavior.recordPlayerDeath(self: AdaptiveBehavior)
	self.memory.playerDeaths += 1

	-- Activate de-escalation if player has died 3+ times
	if self.memory.playerDeaths >= 3 then
		self.deescalationActive = true
		self.escalationModifier = math.max(0.8, self.escalationModifier - 0.2)
	end
end

function AdaptiveBehavior.getSpeedModifier(self: AdaptiveBehavior): number
	return self.escalationModifier
end

function AdaptiveBehavior.getHearingModifier(self: AdaptiveBehavior): number
	return self.escalationModifier
end

return AdaptiveBehavior
