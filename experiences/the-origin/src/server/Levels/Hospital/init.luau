--!strict

--[[
	Hospital Level Builder (Level 1: St. Maren's Hospital)

	Orchestrates all floor builders and returns combined LevelData
	with hiding spots, patrol waypoints, loot positions, and spawn points.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LevelConfig = require(ReplicatedStorage.Shared.LevelConfig)
local Types = require(ReplicatedStorage.Shared.Types)

local Basement = require(script.Basement)
local Exterior = require(script.Exterior)
local GroundFloor = require(script.GroundFloor)
local Roof = require(script.Roof)
local UpperFloor = require(script.UpperFloor)

local Hospital = {}

function Hospital.build(): (Model, Types.LevelData)
	local levelModel = Instance.new("Model")
	levelModel.Name = "Hospital"

	-- Build all floors
	local groundData = GroundFloor.build(levelModel)
	local basementData = Basement.build(levelModel)
	local upperData = UpperFloor.build(levelModel)
	local roofData = Roof.build(levelModel)
	local exteriorData = Exterior.build(levelModel)

	-- Combine all data
	local hidingSpots: { Types.HidingSpot } = {}
	local waypoints: { Types.PatrolWaypoint } = {}
	local lootPositions: { Types.LootSpawn } = {}

	local function merge(data: { hidingSpots: { any }, waypoints: { any }, lootPositions: { any } })
		for _, spot in data.hidingSpots do
			table.insert(hidingSpots, spot)
		end
		for _, wp in data.waypoints do
			table.insert(waypoints, wp)
		end
		for _, loot in data.lootPositions do
			table.insert(lootPositions, loot)
		end
	end

	merge(groundData)
	merge(basementData)
	merge(upperData)
	merge(roofData)
	merge(exteriorData)

	-- Parent to workspace
	levelModel.Parent = workspace

	local levelData: Types.LevelData = {
		hidingSpots = hidingSpots,
		waypoints = waypoints,
		lootPositions = lootPositions,
		spawnPoint = LevelConfig.PlayerSpawnPosition,
		entitySpawnPositions = LevelConfig.EntitySpawnPositions,
	}

	print(`[Hospital] Built: {#hidingSpots} hiding spots, {#waypoints} waypoints, {#lootPositions} loot positions`)

	return levelModel, levelData
end

function Hospital.cleanup(levelModel: Model)
	if levelModel then
		levelModel:Destroy()
	end
end

return Hospital
