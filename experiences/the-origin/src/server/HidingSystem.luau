--!strict

--[[
	Hiding System

	Manages hiding spots throughout the level. Players can enter and exit
	hiding spots to avoid entity detection. The entity AI uses this system
	to check spots based on adaptive behavior (learned player patterns).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local HidingSystem = {}
HidingSystem.__index = HidingSystem

export type HidingSystem = typeof(setmetatable(
	{} :: {
		spots: { [string]: Types.HidingSpot },
		playerSpots: { [Player]: string }, -- maps player -> spotId they're in
		spotOccupants: { [string]: Player? }, -- maps spotId -> player in it
	},
	HidingSystem
))

local PROXIMITY_RADIUS = 10

function HidingSystem.new(): HidingSystem
	local self = setmetatable({
		spots = {},
		playerSpots = {},
		spotOccupants = {},
	}, HidingSystem)

	self:connectRemotes()

	return self
end

function HidingSystem.connectRemotes(self: HidingSystem)
	local Remotes = require(script.Remotes)

	if Remotes.HidingEntered then
		Remotes.HidingEntered.OnServerEvent:Connect(function(player: Player, spotId: string)
			self:enterSpot(player, spotId)
		end)
	end

	if Remotes.HidingExited then
		Remotes.HidingExited.OnServerEvent:Connect(function(player: Player)
			self:exitSpot(player)
		end)
	end
end

function HidingSystem.registerSpots(self: HidingSystem, hidingSpots: { Types.HidingSpot })
	-- Clear any existing spots and reset occupancy
	table.clear(self.spots)
	table.clear(self.playerSpots)
	table.clear(self.spotOccupants)

	for _, spot in hidingSpots do
		spot.isOccupied = false
		self.spots[spot.id] = spot
	end

	print(`[HidingSystem] Registered {#hidingSpots} hiding spots`)
end

function HidingSystem.enterSpot(self: HidingSystem, player: Player, spotId: string)
	-- Validate: spot must exist
	local spot = self.spots[spotId]
	if not spot then
		warn(`[HidingSystem] {player.Name} tried to enter invalid spot: {spotId}`)
		return
	end

	-- Validate: spot must not already be occupied
	if spot.isOccupied then
		warn(`[HidingSystem] {player.Name} tried to enter occupied spot: {spotId}`)
		return
	end

	-- Validate: player must not already be hiding
	if self.playerSpots[player] then
		warn(`[HidingSystem] {player.Name} is already hiding in spot: {self.playerSpots[player]}`)
		return
	end

	-- Validate proximity: player character must be within range of spot position
	local character = player.Character
	if not character then
		warn(`[HidingSystem] {player.Name} has no character`)
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not rootPart then
		warn(`[HidingSystem] {player.Name} has no HumanoidRootPart`)
		return
	end

	local distance = (rootPart.Position - spot.position).Magnitude
	if distance > PROXIMITY_RADIUS then
		warn(`[HidingSystem] {player.Name} is too far from spot {spotId} ({string.format("%.1f", distance)} studs)`)
		return
	end

	-- Mark spot as occupied
	spot.isOccupied = true
	self.playerSpots[player] = spotId
	self.spotOccupants[spotId] = player

	-- Fire confirmation back to the requesting client
	local Remotes = require(script.Remotes)
	if Remotes.HidingEntered then
		Remotes.HidingEntered:FireClient(player, spotId)
	end

	print(`[HidingSystem] {player.Name} entered hiding spot: {spotId} ({spot.spotType})`)
end

function HidingSystem.exitSpot(self: HidingSystem, player: Player)
	-- Validate: player must actually be hiding
	local spotId = self.playerSpots[player]
	if not spotId then
		warn(`[HidingSystem] {player.Name} tried to exit but is not hiding`)
		return
	end

	-- Get the spot and mark it as unoccupied
	local spot = self.spots[spotId]
	if spot then
		spot.isOccupied = false
	end

	-- Remove from tracking tables
	self.playerSpots[player] = nil
	self.spotOccupants[spotId] = nil

	-- Fire confirmation back to client
	local Remotes = require(script.Remotes)
	if Remotes.HidingExited then
		Remotes.HidingExited:FireClient(player)
	end

	print(`[HidingSystem] {player.Name} exited hiding spot: {spotId}`)
end

function HidingSystem.getSpotsNear(self: HidingSystem, position: Vector3, radius: number): { Types.HidingSpot }
	local nearbySpots: { Types.HidingSpot } = {}

	for _, spot in self.spots do
		local distance = (spot.position - position).Magnitude
		if distance <= radius then
			table.insert(nearbySpots, spot)
		end
	end

	return nearbySpots
end

function HidingSystem.entityCheckSpot(self: HidingSystem, spotId: string): Player?
	local occupant = self.spotOccupants[spotId]
	if not occupant then
		return nil
	end

	-- Fire dread effect to the hidden player
	local Remotes = require(script.Remotes)
	if Remotes.HidingSpotChecked then
		Remotes.HidingSpotChecked:FireClient(occupant, spotId)
	end

	print(`[HidingSystem] Entity checked spot {spotId} — found {occupant.Name}`)
	return occupant
end

function HidingSystem.getCheckChance(_self: HidingSystem, spotId: string, adaptiveBehavior: any): number
	return adaptiveBehavior:getHidingSpotCheckChance(spotId)
end

function HidingSystem.recordUse(_self: HidingSystem, spotId: string, adaptiveBehavior: any)
	adaptiveBehavior:recordHidingSpotUse(spotId)
end

function HidingSystem.isPlayerHiding(self: HidingSystem, player: Player): boolean
	return self.playerSpots[player] ~= nil
end

function HidingSystem.getPlayerSpot(self: HidingSystem, player: Player): string?
	return self.playerSpots[player]
end

function HidingSystem.removePlayer(self: HidingSystem, player: Player)
	-- If the player was hiding, exit their spot first
	if self.playerSpots[player] then
		local spotId = self.playerSpots[player]
		local spot = self.spots[spotId]
		if spot then
			spot.isOccupied = false
		end
		self.spotOccupants[spotId] = nil
		self.playerSpots[player] = nil
	end
end

function HidingSystem.cleanup(self: HidingSystem)
	table.clear(self.spots)
	table.clear(self.playerSpots)
	table.clear(self.spotOccupants)
end

return HidingSystem
