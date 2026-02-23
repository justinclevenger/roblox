--!strict

--[[
	LevelConfig - Coordinate system constants and room definitions for the Hospital level.
	All positions are in studs. The hospital is centered at X=0, Z=0.
]]

export type RoomDef = {
	position: Vector3,
	size: Vector3,
	name: string,
}

-- Floor heights (Y coordinate of the floor surface)
local GROUND_FLOOR_Y: number = 0
local UPPER_FLOOR_Y: number = 13
local BASEMENT_Y: number = -12
local ROOF_Y: number = 26

-- Structural constants
local ROOM_HEIGHT: number = 12
local WALL_THICKNESS: number = 1
local FLOOR_THICKNESS: number = 1
local DOOR_WIDTH: number = 5
local DOOR_HEIGHT: number = 8

------------------------------------------------------------------------
-- Room Definitions
------------------------------------------------------------------------

local GroundFloorRooms: { RoomDef } = {
	{
		position = Vector3.new(0, GROUND_FLOOR_Y, -30),
		size = Vector3.new(20, ROOM_HEIGHT, 20),
		name = "Reception",
	},
	{
		position = Vector3.new(20, GROUND_FLOOR_Y, -30),
		size = Vector3.new(16, ROOM_HEIGHT, 16),
		name = "WaitingRoom",
	},
	{
		position = Vector3.new(-30, GROUND_FLOOR_Y, -20),
		size = Vector3.new(14, ROOM_HEIGHT, 14),
		name = "SecurityOffice",
	},
	{
		position = Vector3.new(30, GROUND_FLOOR_Y, 0),
		size = Vector3.new(20, ROOM_HEIGHT, 24),
		name = "EmergencyWard",
	},
	{
		position = Vector3.new(-25, GROUND_FLOOR_Y, 10),
		size = Vector3.new(14, ROOM_HEIGHT, 14),
		name = "Pharmacy",
	},
	{
		position = Vector3.new(-25, GROUND_FLOOR_Y, -40),
		size = Vector3.new(14, ROOM_HEIGHT, 16),
		name = "Chapel",
	},
	{
		position = Vector3.new(25, GROUND_FLOOR_Y, 20),
		size = Vector3.new(12, ROOM_HEIGHT, 12),
		name = "Restrooms",
	},
	{
		position = Vector3.new(0, GROUND_FLOOR_Y, 0),
		size = Vector3.new(60, ROOM_HEIGHT, 6),
		name = "GroundCorridor_EastWest",
	},
	{
		position = Vector3.new(0, GROUND_FLOOR_Y, -20),
		size = Vector3.new(6, ROOM_HEIGHT, 40),
		name = "GroundCorridor_NorthSouth",
	},
}

local UpperFloorRooms: { RoomDef } = {
	{
		position = Vector3.new(-10, UPPER_FLOOR_Y, -25),
		size = Vector3.new(10, ROOM_HEIGHT, 10),
		name = "Room201",
	},
	{
		position = Vector3.new(0, UPPER_FLOOR_Y, -25),
		size = Vector3.new(10, ROOM_HEIGHT, 10),
		name = "Room202",
	},
	{
		position = Vector3.new(10, UPPER_FLOOR_Y, -25),
		size = Vector3.new(10, ROOM_HEIGHT, 10),
		name = "Room203",
	},
	{
		position = Vector3.new(-30, UPPER_FLOOR_Y, -20),
		size = Vector3.new(10, ROOM_HEIGHT, 10),
		name = "Room204",
	},
	{
		position = Vector3.new(-30, UPPER_FLOOR_Y, -10),
		size = Vector3.new(10, ROOM_HEIGHT, 10),
		name = "Room205",
	},
	{
		position = Vector3.new(-30, UPPER_FLOOR_Y, 0),
		size = Vector3.new(10, ROOM_HEIGHT, 10),
		name = "Room206",
	},
	{
		position = Vector3.new(0, UPPER_FLOOR_Y, 0),
		size = Vector3.new(24, ROOM_HEIGHT, 20),
		name = "OperatingTheater",
	},
	{
		position = Vector3.new(25, UPPER_FLOOR_Y, 10),
		size = Vector3.new(14, ROOM_HEIGHT, 12),
		name = "StaffBreakRoom",
	},
	{
		position = Vector3.new(35, UPPER_FLOOR_Y, 0),
		size = Vector3.new(20, ROOM_HEIGHT, 30),
		name = "PsychWard",
	},
	{
		position = Vector3.new(0, UPPER_FLOOR_Y, -10),
		size = Vector3.new(50, ROOM_HEIGHT, 6),
		name = "UpperHallway_EastWest",
	},
	{
		position = Vector3.new(-20, UPPER_FLOOR_Y, 0),
		size = Vector3.new(6, ROOM_HEIGHT, 30),
		name = "UpperHallway_NorthSouth",
	},
}

local BasementRooms: { RoomDef } = {
	{
		position = Vector3.new(-25, BASEMENT_Y, -20),
		size = Vector3.new(20, ROOM_HEIGHT, 20),
		name = "Morgue",
	},
	{
		position = Vector3.new(0, BASEMENT_Y, -20),
		size = Vector3.new(16, ROOM_HEIGHT, 16),
		name = "GeneratorRoom",
	},
	{
		position = Vector3.new(25, BASEMENT_Y, -10),
		size = Vector3.new(20, ROOM_HEIGHT, 24),
		name = "StorageMaze",
	},
	{
		position = Vector3.new(-25, BASEMENT_Y, 10),
		size = Vector3.new(16, ROOM_HEIGHT, 16),
		name = "BoilerRoom",
	},
	{
		position = Vector3.new(25, BASEMENT_Y, 20),
		size = Vector3.new(14, ROOM_HEIGHT, 14),
		name = "Laundry",
	},
	{
		position = Vector3.new(30, BASEMENT_Y, 30),
		size = Vector3.new(8, ROOM_HEIGHT, 8),
		name = "SubBasementDoor",
	},
	{
		position = Vector3.new(0, BASEMENT_Y, 0),
		size = Vector3.new(60, ROOM_HEIGHT, 6),
		name = "BasementCorridor",
	},
}

local ExteriorAreas: { RoomDef } = {
	{
		position = Vector3.new(0, GROUND_FLOOR_Y, -70),
		size = Vector3.new(24, ROOM_HEIGHT, 16),
		name = "AmbulanceBay",
	},
	{
		position = Vector3.new(0, GROUND_FLOOR_Y, 40),
		size = Vector3.new(30, ROOM_HEIGHT, 20),
		name = "Courtyard",
	},
}

local RoofAreas: { RoomDef } = {
	{
		position = Vector3.new(0, ROOF_Y, 0),
		size = Vector3.new(20, 1, 20),
		name = "Helipad",
	},
}

------------------------------------------------------------------------
-- Spawn Positions
------------------------------------------------------------------------

-- Player spawns at the Ambulance Bay entrance
local PlayerSpawnPosition: Vector3 = Vector3.new(0, GROUND_FLOOR_Y + 3, -70)

-- Entity spawn options
local EntitySpawnPositions: { Vector3 } = {
	Vector3.new(0, BASEMENT_Y + 3, 0), -- Basement corridor
	Vector3.new(0, UPPER_FLOOR_Y + 3, -10), -- Upper hallway
	Vector3.new(-25, BASEMENT_Y + 3, -20), -- Morgue
}

------------------------------------------------------------------------
-- Stairwell
------------------------------------------------------------------------

local StairwellPosition: Vector3 = Vector3.new(0, 0, 0)
local StairwellSize: Vector3 = Vector3.new(10, ROOM_HEIGHT * 3 + FLOOR_THICKNESS * 2, 10)

------------------------------------------------------------------------
-- Multiplayer Scaling
------------------------------------------------------------------------

export type ScalingEntry = {
	players: number,
	entityCount: number,
	lootMultiplier: number,
	entitySpeedMultiplier: number,
}

local MultiplayerScaling: { ScalingEntry } = {
	{ players = 1, entityCount = 1, lootMultiplier = 1.0, entitySpeedMultiplier = 1.0 },
	{ players = 2, entityCount = 1, lootMultiplier = 1.3, entitySpeedMultiplier = 1.05 },
	{ players = 3, entityCount = 2, lootMultiplier = 1.5, entitySpeedMultiplier = 1.1 },
	{ players = 4, entityCount = 2, lootMultiplier = 1.7, entitySpeedMultiplier = 1.15 },
}

------------------------------------------------------------------------
-- Exported Config Table
------------------------------------------------------------------------

local LevelConfig = {
	-- Floor heights
	GROUND_FLOOR_Y = GROUND_FLOOR_Y,
	UPPER_FLOOR_Y = UPPER_FLOOR_Y,
	BASEMENT_Y = BASEMENT_Y,
	ROOF_Y = ROOF_Y,

	-- Structural constants
	ROOM_HEIGHT = ROOM_HEIGHT,
	WALL_THICKNESS = WALL_THICKNESS,
	FLOOR_THICKNESS = FLOOR_THICKNESS,
	DOOR_WIDTH = DOOR_WIDTH,
	DOOR_HEIGHT = DOOR_HEIGHT,

	-- Room definitions by floor
	GroundFloorRooms = GroundFloorRooms,
	UpperFloorRooms = UpperFloorRooms,
	BasementRooms = BasementRooms,
	ExteriorAreas = ExteriorAreas,
	RoofAreas = RoofAreas,

	-- Spawn positions
	PlayerSpawnPosition = PlayerSpawnPosition,
	EntitySpawnPositions = EntitySpawnPositions,

	-- Stairwell
	StairwellPosition = StairwellPosition,
	StairwellSize = StairwellSize,

	-- Multiplayer scaling
	MultiplayerScaling = MultiplayerScaling,
}

return LevelConfig
