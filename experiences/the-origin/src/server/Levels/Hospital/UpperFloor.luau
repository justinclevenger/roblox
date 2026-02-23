--!strict

--[[
	Upper Floor (Level 1) - St. Maren's Hospital

	Patient rooms 201-206, Operating Theater, Staff Break Room,
	Psychiatric Ward, and connecting L-shaped hallway.

	Floor Y = 13, Ceiling Y = 25, Room height = 12 studs.
]]

local Shared = require(script.Parent.Shared)

type HidingSpotData = Shared.HidingSpotData

export type FloorData = {
	hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } },
}

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------

local FLOOR_Y = 13
local ROOM_HEIGHT = 12
local WALL_THICKNESS = 1
local DOOR_WIDTH = 5
local DOOR_HEIGHT = 8

-- Muted hospital color palette
local COLOR_WALL_STANDARD = Color3.fromRGB(195, 192, 180) -- off-white institutional
local COLOR_PADDED = Color3.fromRGB(180, 175, 160) -- padded cell walls
local COLOR_BLOOD_STAIN = Color3.fromRGB(80, 20, 15) -- dried blood
local COLOR_CLAW_MARK = Color3.fromRGB(60, 55, 50) -- scratches
local COLOR_MOONLIGHT = Color3.fromRGB(180, 200, 220) -- cold moonlight
local COLOR_GLASS = Color3.fromRGB(170, 190, 210) -- reinforced glass
local COLOR_METAL = Color3.fromRGB(120, 120, 125) -- medical equipment
local COLOR_WRITING = Color3.fromRGB(40, 10, 10) -- wall writing

------------------------------------------------------------------------
-- Helper: create a simple colored part
------------------------------------------------------------------------
local function createPart(
	parent: Instance,
	name: string,
	position: Vector3,
	size: Vector3,
	color: Color3?,
	transparency: number?,
	material: Enum.Material?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Color = color or COLOR_WALL_STANDARD
	part.Transparency = transparency or 0
	part.Material = material or Enum.Material.Concrete
	part.Parent = parent
	return part
end

------------------------------------------------------------------------
-- Room builders
------------------------------------------------------------------------

local function buildRoom201(
	parent: Instance,
	hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } }
)
	-- Patient Room 201: standard room with bed, IV stand, side table, closet, bathroom
	local roomPos = Vector3.new(-10, FLOOR_Y, -25)
	local roomSize = Vector3.new(10, ROOM_HEIGHT, 10)

	local room = Shared.createRoom({
		position = roomPos,
		size = roomSize,
		parent = parent,
		name = "Room201",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	-- Door
	local doorZ = roomPos.Z + roomSize.Z / 2
	Shared.createDoor(Vector3.new(roomPos.X, FLOOR_Y + DOOR_HEIGHT / 2, doorZ), nil, room, "Door_201", false, nil)

	-- Furniture
	local bedPos = Vector3.new(roomPos.X + 2, FLOOR_Y + 1, roomPos.Z - 2)
	Shared.createFurniture("bed", bedPos, room)

	-- IV stand (simple pole)
	local ivPos = Vector3.new(roomPos.X + 2, FLOOR_Y + 3, roomPos.Z - 0.5)
	createPart(room, "IVStand", ivPos, Vector3.new(0.3, 6, 0.3), COLOR_METAL, 0, Enum.Material.Metal)

	-- Side table
	local tablePos = Vector3.new(roomPos.X + 2, FLOOR_Y + 0.5, roomPos.Z + 1)
	Shared.createFurniture("table", tablePos, room)

	-- Closet
	local closetPos = Vector3.new(roomPos.X - 3, FLOOR_Y + 1, roomPos.Z - 3)
	Shared.createFurniture("cabinet", closetPos, room)

	-- Bathroom partition (small walled area in corner)
	createPart(
		room,
		"BathroomWall_A",
		Vector3.new(roomPos.X - 3, FLOOR_Y + 4, roomPos.Z + 2),
		Vector3.new(4, 8, WALL_THICKNESS),
		COLOR_WALL_STANDARD
	)
	createPart(
		room,
		"BathroomWall_B",
		Vector3.new(roomPos.X - 4.5, FLOOR_Y + 4, roomPos.Z + 3.5),
		Vector3.new(WALL_THICKNESS, 8, 3),
		COLOR_WALL_STANDARD
	)

	-- Dim fluorescent light
	Shared.createLight(Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 1, roomPos.Z), room, 0.3)

	-- Hiding spots
	Shared.createHidingSpot(closetPos, "Closet", "upper_rm201_closet", room)
	table.insert(hidingSpots, {
		id = "upper_rm201_closet",
		position = closetPos,
		spotType = "Closet",
		isOccupied = false,
	})

	local underBedPos = Vector3.new(bedPos.X, FLOOR_Y + 0.5, bedPos.Z)
	Shared.createHidingSpot(underBedPos, "UnderBed", "upper_rm201_underbed", room)
	table.insert(hidingSpots, {
		id = "upper_rm201_underbed",
		position = underBedPos,
		spotType = "UnderBed",
		isOccupied = false,
	})

	-- Waypoint
	table.insert(waypoints, {
		position = Vector3.new(roomPos.X, FLOOR_Y + 3, roomPos.Z),
		roomId = "Room201",
		dwellTime = 4,
	})

	-- Loot
	table.insert(lootPositions, {
		itemType = "Bandage",
		position = Vector3.new(tablePos.X, tablePos.Y + 1, tablePos.Z),
		chance = 0.5,
		guaranteed = false,
	})
end

local function buildRoom202(
	parent: Instance,
	hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } }
)
	-- Patient Room 202: trashed room, bed flipped, claw marks
	local roomPos = Vector3.new(0, FLOOR_Y, -25)
	local roomSize = Vector3.new(10, ROOM_HEIGHT, 10)

	local room = Shared.createRoom({
		position = roomPos,
		size = roomSize,
		parent = parent,
		name = "Room202",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	-- Door (damaged, hanging open — slightly ajar)
	local doorZ = roomPos.Z + roomSize.Z / 2
	Shared.createDoor(
		Vector3.new(roomPos.X, FLOOR_Y + DOOR_HEIGHT / 2, doorZ),
		CFrame.Angles(0, math.rad(15), 0),
		room,
		"Door_202",
		false,
		nil
	)

	-- Flipped bed (rotated Parts)
	local flippedBedPos = Vector3.new(roomPos.X + 1, FLOOR_Y + 2, roomPos.Z - 1)
	local flippedBed = createPart(
		room,
		"FlippedBed_Frame",
		flippedBedPos,
		Vector3.new(4, 1, 6.5),
		Color3.fromRGB(140, 130, 110),
		0,
		Enum.Material.Metal
	)
	flippedBed.Orientation = Vector3.new(0, 0, 70) -- tipped on its side

	local mattress = createPart(
		room,
		"FlippedBed_Mattress",
		Vector3.new(roomPos.X + 2.5, FLOOR_Y + 0.5, roomPos.Z - 1),
		Vector3.new(3.5, 0.8, 6),
		Color3.fromRGB(150, 140, 120),
		0,
		Enum.Material.Fabric
	)
	mattress.Orientation = Vector3.new(5, 10, 25) -- askew on the floor

	-- Claw marks on walls (dark streaks)
	for i = 1, 5 do
		local markY = FLOOR_Y + 3 + (i * 1.2)
		local markX = roomPos.X - roomSize.X / 2 + 0.6
		createPart(
			room,
			`ClawMark_{i}`,
			Vector3.new(markX, markY, roomPos.Z - 2 + i * 0.4),
			Vector3.new(0.1, 0.4, 2),
			COLOR_CLAW_MARK,
			0,
			Enum.Material.Concrete
		)
	end

	-- Blood stain on floor
	createPart(
		room,
		"BloodStain",
		Vector3.new(roomPos.X, FLOOR_Y + 0.05, roomPos.Z),
		Vector3.new(3, 0.05, 4),
		COLOR_BLOOD_STAIN,
		0.3,
		Enum.Material.Concrete
	)

	-- Desk (overturned but still usable as hiding spot)
	local deskPos = Vector3.new(roomPos.X - 2, FLOOR_Y + 1, roomPos.Z + 2)
	Shared.createFurniture("desk", deskPos, room)

	-- Closet (door hanging off)
	local closetPos = Vector3.new(roomPos.X + 3, FLOOR_Y + 1, roomPos.Z - 3)
	Shared.createFurniture("cabinet", closetPos, room)

	-- Broken fluorescent (flickering)
	Shared.createLight(Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 1, roomPos.Z), room, 0.1)

	-- Hiding spots
	Shared.createHidingSpot(closetPos, "Closet", "upper_rm202_closet", room)
	table.insert(hidingSpots, {
		id = "upper_rm202_closet",
		position = closetPos,
		spotType = "Closet",
		isOccupied = false,
	})

	local underDeskPos = Vector3.new(deskPos.X, FLOOR_Y + 0.5, deskPos.Z)
	Shared.createHidingSpot(underDeskPos, "Desk", "upper_rm202_underdesk", room)
	table.insert(hidingSpots, {
		id = "upper_rm202_underdesk",
		position = underDeskPos,
		spotType = "Desk",
		isOccupied = false,
	})

	-- Waypoint
	table.insert(waypoints, {
		position = Vector3.new(roomPos.X, FLOOR_Y + 3, roomPos.Z),
		roomId = "Room202",
		dwellTime = 5,
	})

	-- Loot (battery among the wreckage)
	table.insert(lootPositions, {
		itemType = "Battery",
		position = Vector3.new(roomPos.X - 1, FLOOR_Y + 0.5, roomPos.Z + 1),
		chance = 0.4,
		guaranteed = false,
	})
end

local function buildRoom203(
	parent: Instance,
	hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } }
)
	-- Patient Room 203: locked, body on bed, documents
	local roomPos = Vector3.new(10, FLOOR_Y, -25)
	local roomSize = Vector3.new(10, ROOM_HEIGHT, 10)

	local room = Shared.createRoom({
		position = roomPos,
		size = roomSize,
		parent = parent,
		name = "Room203",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	-- Locked door (requires Master Key)
	local doorZ = roomPos.Z + roomSize.Z / 2
	Shared.createDoor(
		Vector3.new(roomPos.X, FLOOR_Y + DOOR_HEIGHT / 2, doorZ),
		nil,
		room,
		"Door_203",
		true,
		"MasterKey"
	)

	-- Bed with body
	local bedPos = Vector3.new(roomPos.X + 1, FLOOR_Y + 1, roomPos.Z - 2)
	Shared.createFurniture("bed", bedPos, room)

	-- Body on bed (covered shape)
	createPart(
		room,
		"BodySheet",
		Vector3.new(bedPos.X, bedPos.Y + 1.2, bedPos.Z),
		Vector3.new(2.5, 0.8, 5.5),
		Color3.fromRGB(180, 175, 165),
		0,
		Enum.Material.Fabric
	)

	-- Blood seeping from under the sheet
	createPart(
		room,
		"BodyBlood",
		Vector3.new(bedPos.X + 0.5, bedPos.Y + 0.6, bedPos.Z - 1),
		Vector3.new(1.5, 0.05, 2),
		COLOR_BLOOD_STAIN,
		0.2,
		Enum.Material.Concrete
	)

	-- Documents on side table
	local sideTablePos = Vector3.new(roomPos.X - 2, FLOOR_Y + 0.5, roomPos.Z - 2)
	Shared.createFurniture("table", sideTablePos, room)

	-- Document prop (thin part on table)
	createPart(
		room,
		"Documents",
		Vector3.new(sideTablePos.X, sideTablePos.Y + 1.2, sideTablePos.Z),
		Vector3.new(1.5, 0.05, 2),
		Color3.fromRGB(230, 225, 210),
		0,
		Enum.Material.SmoothPlastic
	)

	-- Closet
	local closetPos = Vector3.new(roomPos.X + 3, FLOOR_Y + 1, roomPos.Z + 2)
	Shared.createFurniture("cabinet", closetPos, room)

	-- Dim light
	Shared.createLight(Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 1, roomPos.Z), room, 0.2)

	-- Hiding spots
	Shared.createHidingSpot(closetPos, "Closet", "upper_rm203_closet", room)
	table.insert(hidingSpots, {
		id = "upper_rm203_closet",
		position = closetPos,
		spotType = "Closet",
		isOccupied = false,
	})

	-- Waypoint
	table.insert(waypoints, {
		position = Vector3.new(roomPos.X, FLOOR_Y + 3, roomPos.Z),
		roomId = "Room203",
		dwellTime = 6,
	})

	-- Loot (medkit and documents as lore)
	table.insert(lootPositions, {
		itemType = "Medkit",
		position = Vector3.new(sideTablePos.X + 1, sideTablePos.Y + 1.5, sideTablePos.Z),
		chance = 1,
		guaranteed = true,
	})

	table.insert(lootPositions, {
		itemType = "Battery",
		position = Vector3.new(roomPos.X - 3, FLOOR_Y + 1, roomPos.Z + 3),
		chance = 0.6,
		guaranteed = false,
	})
end

local function buildRooms204to206(
	parent: Instance,
	hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } }
)
	-- Connected triple rooms on west side with internal doorways

	-- Room 204: Empty, connecting door to 205
	local room204Pos = Vector3.new(-30, FLOOR_Y, -20)
	local room204Size = Vector3.new(10, ROOM_HEIGHT, 10)

	local room204 = Shared.createRoom({
		position = room204Pos,
		size = room204Size,
		parent = parent,
		name = "Room204",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "east", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- to hallway
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- to 205
		},
	})

	Shared.createDoor(
		Vector3.new(room204Pos.X + room204Size.X / 2, FLOOR_Y + DOOR_HEIGHT / 2, room204Pos.Z),
		CFrame.Angles(0, math.rad(90), 0),
		room204,
		"Door_204_Hall",
		false,
		nil
	)

	-- Sparse furniture (empty room)
	local bed204Pos = Vector3.new(room204Pos.X - 2, FLOOR_Y + 1, room204Pos.Z - 2)
	Shared.createFurniture("bed", bed204Pos, room204)
	Shared.createLight(Vector3.new(room204Pos.X, FLOOR_Y + ROOM_HEIGHT - 1, room204Pos.Z), room204, 0.3)

	-- Hiding: under bed
	local underBed204 = Vector3.new(bed204Pos.X, FLOOR_Y + 0.5, bed204Pos.Z)
	Shared.createHidingSpot(underBed204, "UnderBed", "upper_rm204_underbed", room204)
	table.insert(hidingSpots, {
		id = "upper_rm204_underbed",
		position = underBed204,
		spotType = "UnderBed",
		isOccupied = false,
	})

	local closet204Pos = Vector3.new(room204Pos.X + 3, FLOOR_Y + 1, room204Pos.Z + 3)
	Shared.createFurniture("cabinet", closet204Pos, room204)
	Shared.createHidingSpot(closet204Pos, "Closet", "upper_rm204_closet", room204)
	table.insert(hidingSpots, {
		id = "upper_rm204_closet",
		position = closet204Pos,
		spotType = "Closet",
		isOccupied = false,
	})

	table.insert(waypoints, {
		position = Vector3.new(room204Pos.X, FLOOR_Y + 3, room204Pos.Z),
		roomId = "Room204",
		dwellTime = 3,
	})

	-- Room 205: Dark (no window), Pharmacy Key on nightstand
	local room205Pos = Vector3.new(-30, FLOOR_Y, -10)
	local room205Size = Vector3.new(10, ROOM_HEIGHT, 10)

	local room205 = Shared.createRoom({
		position = room205Pos,
		size = room205Size,
		parent = parent,
		name = "Room205",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "north", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- from 204
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- to 206
		},
	})

	-- Very dim light (dark room, no windows)
	Shared.createLight(Vector3.new(room205Pos.X, FLOOR_Y + ROOM_HEIGHT - 1, room205Pos.Z), room205, 0.05)

	local bed205Pos = Vector3.new(room205Pos.X + 2, FLOOR_Y + 1, room205Pos.Z)
	Shared.createFurniture("bed", bed205Pos, room205)

	-- Nightstand with Pharmacy Key
	local nightstandPos = Vector3.new(room205Pos.X + 2, FLOOR_Y + 0.5, room205Pos.Z + 2)
	Shared.createFurniture("table", nightstandPos, room205)

	-- Key item visual (small glowing part)
	local keyPart = createPart(
		room205,
		"PharmacyKey",
		Vector3.new(nightstandPos.X, nightstandPos.Y + 1.3, nightstandPos.Z),
		Vector3.new(0.5, 0.15, 1),
		Color3.fromRGB(200, 180, 60),
		0,
		Enum.Material.Metal
	)
	local keyLight = Instance.new("PointLight")
	keyLight.Brightness = 0.3
	keyLight.Range = 4
	keyLight.Color = Color3.fromRGB(255, 220, 100)
	keyLight.Parent = keyPart

	-- Hiding: under bed, closet
	local underBed205 = Vector3.new(bed205Pos.X, FLOOR_Y + 0.5, bed205Pos.Z)
	Shared.createHidingSpot(underBed205, "UnderBed", "upper_rm205_underbed", room205)
	table.insert(hidingSpots, {
		id = "upper_rm205_underbed",
		position = underBed205,
		spotType = "UnderBed",
		isOccupied = false,
	})

	local closet205Pos = Vector3.new(room205Pos.X - 3, FLOOR_Y + 1, room205Pos.Z - 3)
	Shared.createFurniture("cabinet", closet205Pos, room205)
	Shared.createHidingSpot(closet205Pos, "Closet", "upper_rm205_closet", room205)
	table.insert(hidingSpots, {
		id = "upper_rm205_closet",
		position = closet205Pos,
		spotType = "Closet",
		isOccupied = false,
	})

	table.insert(waypoints, {
		position = Vector3.new(room205Pos.X, FLOOR_Y + 3, room205Pos.Z),
		roomId = "Room205",
		dwellTime = 5,
	})

	-- Loot: Pharmacy Key is a key item (handled separately), but add a battery
	table.insert(lootPositions, {
		itemType = "Battery",
		position = Vector3.new(room205Pos.X - 2, FLOOR_Y + 1, room205Pos.Z + 2),
		chance = 0.5,
		guaranteed = false,
	})

	-- Room 206: Window overlooking courtyard, hallway door jammed
	local room206Pos = Vector3.new(-30, FLOOR_Y, 0)
	local room206Size = Vector3.new(10, ROOM_HEIGHT, 10)

	local room206 = Shared.createRoom({
		position = room206Pos,
		size = room206Size,
		parent = parent,
		name = "Room206",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "north", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- from 205
			-- No east doorway: hallway door is jammed shut
		},
	})

	-- Window on south wall (overlooking courtyard at Z+)
	local windowPos = Vector3.new(room206Pos.X, FLOOR_Y + 6, room206Pos.Z + room206Size.Z / 2 - 0.5)
	createPart(room206, "Window_206", windowPos, Vector3.new(4, 4, 0.3), COLOR_GLASS, 0.6, Enum.Material.Glass)

	-- Moonlight through window
	Shared.createLight(Vector3.new(room206Pos.X, FLOOR_Y + 5, room206Pos.Z + 2), room206, 0.4, COLOR_MOONLIGHT)

	-- Jammed hallway door (east wall, sealed shut — visible but non-functional)
	local jammedDoorPos = Vector3.new(room206Pos.X + room206Size.X / 2 - 0.5, FLOOR_Y + DOOR_HEIGHT / 2, room206Pos.Z)
	createPart(
		room206,
		"JammedDoor_206",
		jammedDoorPos,
		Vector3.new(WALL_THICKNESS, DOOR_HEIGHT, DOOR_WIDTH),
		Color3.fromRGB(100, 85, 70),
		0,
		Enum.Material.Wood
	)

	-- Furniture
	local bed206Pos = Vector3.new(room206Pos.X - 2, FLOOR_Y + 1, room206Pos.Z - 2)
	Shared.createFurniture("bed", bed206Pos, room206)

	Shared.createFurniture("chair", Vector3.new(room206Pos.X + 2, FLOOR_Y + 0.5, room206Pos.Z + 2), room206)

	-- Hiding: under bed, closet
	local underBed206 = Vector3.new(bed206Pos.X, FLOOR_Y + 0.5, bed206Pos.Z)
	Shared.createHidingSpot(underBed206, "UnderBed", "upper_rm206_underbed", room206)
	table.insert(hidingSpots, {
		id = "upper_rm206_underbed",
		position = underBed206,
		spotType = "UnderBed",
		isOccupied = false,
	})

	local closet206Pos = Vector3.new(room206Pos.X + 3, FLOOR_Y + 1, room206Pos.Z - 3)
	Shared.createFurniture("cabinet", closet206Pos, room206)
	Shared.createHidingSpot(closet206Pos, "Closet", "upper_rm206_closet", room206)
	table.insert(hidingSpots, {
		id = "upper_rm206_closet",
		position = closet206Pos,
		spotType = "Closet",
		isOccupied = false,
	})

	table.insert(waypoints, {
		position = Vector3.new(room206Pos.X, FLOOR_Y + 3, room206Pos.Z),
		roomId = "Room206",
		dwellTime = 4,
	})

	-- Loot: flare near the window
	table.insert(lootPositions, {
		itemType = "Flare",
		position = Vector3.new(room206Pos.X + 1, FLOOR_Y + 1, room206Pos.Z + 3),
		chance = 0.5,
		guaranteed = false,
	})
end

local function buildOperatingTheater(
	parent: Instance,
	_hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } }
)
	-- Operating Theater: central room, skylight, operating table, two entrances
	local roomPos = Vector3.new(0, FLOOR_Y, 0)
	local roomSize = Vector3.new(24, ROOM_HEIGHT, 20)

	local room = Shared.createRoom({
		position = roomPos,
		size = roomSize,
		parent = parent,
		name = "OperatingTheater",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "east", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			{ wall = "west", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	-- Skylight (transparent ceiling section)
	local skylightPos = Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 0.5, roomPos.Z)
	createPart(room, "Skylight", skylightPos, Vector3.new(8, 0.5, 8), COLOR_GLASS, 0.7, Enum.Material.Glass)

	-- Moonlight beam from skylight
	Shared.createLight(Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 2, roomPos.Z), room, 0.6, COLOR_MOONLIGHT)

	-- Operating table (center)
	local tablePos = Vector3.new(roomPos.X, FLOOR_Y + 2, roomPos.Z)
	createPart(
		room,
		"OperatingTable_Base",
		Vector3.new(tablePos.X, FLOOR_Y + 1, tablePos.Z),
		Vector3.new(2.5, 2, 6),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)
	createPart(
		room,
		"OperatingTable_Surface",
		Vector3.new(tablePos.X, FLOOR_Y + 2.2, tablePos.Z),
		Vector3.new(3, 0.3, 6.5),
		Color3.fromRGB(200, 200, 205),
		0,
		Enum.Material.SmoothPlastic
	)

	-- Overhead surgical light (arm + lamp)
	createPart(
		room,
		"SurgicalArm",
		Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 3, roomPos.Z),
		Vector3.new(0.4, 4, 0.4),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)
	createPart(
		room,
		"SurgicalLamp",
		Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 5, roomPos.Z),
		Vector3.new(2, 0.5, 2),
		Color3.fromRGB(220, 220, 225),
		0,
		Enum.Material.Metal
	)
	-- Lamp is off (no power) - faint ambient only
	Shared.createLight(Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 5.5, roomPos.Z), room, 0.05)

	-- Instrument trays
	createPart(
		room,
		"InstrumentTray_L",
		Vector3.new(roomPos.X - 3, FLOOR_Y + 2.5, roomPos.Z),
		Vector3.new(1.5, 0.1, 2),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)
	createPart(
		room,
		"InstrumentTray_R",
		Vector3.new(roomPos.X + 3, FLOOR_Y + 2.5, roomPos.Z),
		Vector3.new(1.5, 0.1, 2),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)

	-- Blood stain on floor near table
	createPart(
		room,
		"BloodStain_OR",
		Vector3.new(roomPos.X + 1, FLOOR_Y + 0.05, roomPos.Z - 2),
		Vector3.new(4, 0.05, 3),
		COLOR_BLOOD_STAIN,
		0.3,
		Enum.Material.Concrete
	)

	-- Cabinets along walls
	Shared.createFurniture("cabinet", Vector3.new(roomPos.X - 9, FLOOR_Y + 1, roomPos.Z - 7), room)
	Shared.createFurniture("cabinet", Vector3.new(roomPos.X + 9, FLOOR_Y + 1, roomPos.Z - 7), room)

	-- No hiding spots (open room, exposed)

	-- Waypoint
	table.insert(waypoints, {
		position = Vector3.new(roomPos.X, FLOOR_Y + 3, roomPos.Z),
		roomId = "OperatingTheater",
		dwellTime = 5,
	})

	-- Loot
	table.insert(lootPositions, {
		itemType = "Bandage",
		position = Vector3.new(roomPos.X + 9, FLOOR_Y + 2, roomPos.Z - 7),
		chance = 1,
		guaranteed = true,
	})

	table.insert(lootPositions, {
		itemType = "Bandage",
		position = Vector3.new(roomPos.X - 9, FLOOR_Y + 2, roomPos.Z - 7),
		chance = 0.4,
		guaranteed = false,
	})
end

local function buildStaffBreakRoom(
	parent: Instance,
	hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } }
)
	-- Staff Break Room: table, chairs, 4 lockers, whiteboard, microwave
	local roomPos = Vector3.new(25, FLOOR_Y, 10)
	local roomSize = Vector3.new(14, ROOM_HEIGHT, 12)

	local room = Shared.createRoom({
		position = roomPos,
		size = roomSize,
		parent = parent,
		name = "StaffBreakRoom",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "west", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	Shared.createDoor(
		Vector3.new(roomPos.X - roomSize.X / 2, FLOOR_Y + DOOR_HEIGHT / 2, roomPos.Z),
		CFrame.Angles(0, math.rad(90), 0),
		room,
		"Door_BreakRoom",
		false,
		nil
	)

	-- Central table with chairs
	local tableCenter = Vector3.new(roomPos.X, FLOOR_Y + 1, roomPos.Z)
	Shared.createFurniture("table", tableCenter, room)
	Shared.createFurniture("chair", Vector3.new(roomPos.X - 2, FLOOR_Y + 0.5, roomPos.Z), room)
	Shared.createFurniture("chair", Vector3.new(roomPos.X + 2, FLOOR_Y + 0.5, roomPos.Z), room)
	Shared.createFurniture("chair", Vector3.new(roomPos.X, FLOOR_Y + 0.5, roomPos.Z - 2), room)
	Shared.createFurniture("chair", Vector3.new(roomPos.X, FLOOR_Y + 0.5, roomPos.Z + 2), room)

	-- 4 Lockers along east wall
	local lockerBaseX = roomPos.X + roomSize.X / 2 - 1.5
	for i = 0, 3 do
		local lockerZ = roomPos.Z - 3 + (i * 2)
		Shared.createFurniture("locker", Vector3.new(lockerBaseX, FLOOR_Y + 1, lockerZ), room)
	end

	-- Whiteboard on north wall
	createPart(
		room,
		"Whiteboard",
		Vector3.new(roomPos.X, FLOOR_Y + 7, roomPos.Z - roomSize.Z / 2 + 0.6),
		Vector3.new(6, 4, 0.2),
		Color3.fromRGB(240, 240, 240),
		0,
		Enum.Material.SmoothPlastic
	)

	-- Counter with microwave (south wall)
	local counterPos = Vector3.new(roomPos.X - 3, FLOOR_Y + 2.5, roomPos.Z + roomSize.Z / 2 - 1.5)
	createPart(
		room,
		"Counter",
		counterPos,
		Vector3.new(6, 0.5, 2),
		Color3.fromRGB(140, 135, 125),
		0,
		Enum.Material.Granite
	)

	-- Microwave on counter
	createPart(
		room,
		"Microwave",
		Vector3.new(counterPos.X + 1, counterPos.Y + 0.7, counterPos.Z),
		Vector3.new(1.5, 1, 1.2),
		Color3.fromRGB(50, 50, 55),
		0,
		Enum.Material.Metal
	)

	-- Light
	Shared.createLight(Vector3.new(roomPos.X, FLOOR_Y + ROOM_HEIGHT - 1, roomPos.Z), room, 0.3)

	-- Hiding spot: inside locker (only 1 usable)
	local hidingLockerPos = Vector3.new(lockerBaseX, FLOOR_Y + 1, roomPos.Z - 3)
	Shared.createHidingSpot(hidingLockerPos, "Locker", "upper_breakroom_locker", room)
	table.insert(hidingSpots, {
		id = "upper_breakroom_locker",
		position = hidingLockerPos,
		spotType = "Locker",
		isOccupied = false,
	})

	-- Waypoint
	table.insert(waypoints, {
		position = Vector3.new(roomPos.X, FLOOR_Y + 3, roomPos.Z),
		roomId = "StaffBreakRoom",
		dwellTime = 4,
	})

	-- Loot
	table.insert(lootPositions, {
		itemType = "Battery",
		position = Vector3.new(lockerBaseX, FLOOR_Y + 2, roomPos.Z + 1),
		chance = 0.5,
		guaranteed = false,
	})

	table.insert(lootPositions, {
		itemType = "Bandage",
		position = Vector3.new(counterPos.X - 1, counterPos.Y + 0.5, counterPos.Z),
		chance = 0.4,
		guaranteed = false,
	})
end

local function buildPsychiatricWard(
	parent: Instance,
	hidingSpots: { HidingSpotData },
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } },
	lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } }
)
	-- Psychiatric Ward: locked wing with padded cells, nurse station, observation room
	local wardPos = Vector3.new(35, FLOOR_Y, 0)
	local wardSize = Vector3.new(20, ROOM_HEIGHT, 30)

	-- Main ward container
	local ward = Instance.new("Model")
	ward.Name = "PsychiatricWard"
	ward.Parent = parent

	-- Ward entrance (locked, requires keycard)
	local entranceDoorPos = Vector3.new(wardPos.X - wardSize.X / 2, FLOOR_Y + DOOR_HEIGHT / 2, wardPos.Z)
	Shared.createDoor(
		entranceDoorPos,
		CFrame.Angles(0, math.rad(90), 0),
		ward,
		"Door_PsychWard",
		true,
		"PsychWardKeycard"
	)

	-- Ward corridor (short corridor connecting all rooms)
	local corridorStartPos = Vector3.new(wardPos.X - 5, FLOOR_Y, wardPos.Z - 5)
	local corridorEndPos = Vector3.new(wardPos.X + 8, FLOOR_Y, wardPos.Z - 5)
	Shared.createCorridor(corridorStartPos, corridorEndPos, 4, ROOM_HEIGHT, ward, "PsychCorridor")

	-- North-south connector corridor
	local connectorStart = Vector3.new(wardPos.X + 2, FLOOR_Y, wardPos.Z - 15)
	local connectorEnd = Vector3.new(wardPos.X + 2, FLOOR_Y, wardPos.Z + 5)
	Shared.createCorridor(connectorStart, connectorEnd, 4, ROOM_HEIGHT, ward, "PsychCorridor_NS")

	-- Padded Cell A: empty
	local cellAPos = Vector3.new(40, FLOOR_Y, -20)
	local cellASize = Vector3.new(6, ROOM_HEIGHT, 6)

	local cellA = Shared.createRoom({
		position = cellAPos,
		size = cellASize,
		parent = ward,
		name = "PaddedCellA",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	Shared.createDoor(
		Vector3.new(cellAPos.X, FLOOR_Y + DOOR_HEIGHT / 2, cellAPos.Z + cellASize.Z / 2),
		nil,
		cellA,
		"Door_CellA",
		false,
		nil
	)

	-- Simple padding overlay on floor and walls
	createPart(
		cellA,
		"Padding_Floor",
		Vector3.new(cellAPos.X, FLOOR_Y + 0.1, cellAPos.Z),
		Vector3.new(cellASize.X - 1, 0.2, cellASize.Z - 1),
		COLOR_PADDED,
		0,
		Enum.Material.SmoothPlastic
	)

	-- Very dim light
	Shared.createLight(Vector3.new(cellAPos.X, FLOOR_Y + ROOM_HEIGHT - 1, cellAPos.Z), cellA, 0.1)

	-- No hiding spots in cells

	-- Padded Cell B: Patient 31's cell, walls covered in writing
	local cellBPos = Vector3.new(48, FLOOR_Y, -20)
	local cellBSize = Vector3.new(6, ROOM_HEIGHT, 6)

	local cellB = Shared.createRoom({
		position = cellBPos,
		size = cellBSize,
		parent = ward,
		name = "PaddedCellB",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	Shared.createDoor(
		Vector3.new(cellBPos.X, FLOOR_Y + DOOR_HEIGHT / 2, cellBPos.Z + cellBSize.Z / 2),
		nil,
		cellB,
		"Door_CellB",
		false,
		nil
	)

	-- Padded floor
	createPart(
		cellB,
		"Padding_Floor",
		Vector3.new(cellBPos.X, FLOOR_Y + 0.1, cellBPos.Z),
		Vector3.new(cellBSize.X - 1, 0.2, cellBSize.Z - 1),
		COLOR_PADDED,
		0,
		Enum.Material.SmoothPlastic
	)

	-- Wall writing (many small dark parts covering walls — Patient 31's ravings)
	local writingPositions = {
		-- North wall writing
		{
			pos = Vector3.new(cellBPos.X - 1, FLOOR_Y + 4, cellBPos.Z - cellBSize.Z / 2 + 0.6),
			size = Vector3.new(2, 0.15, 0.05),
		},
		{
			pos = Vector3.new(cellBPos.X + 0.5, FLOOR_Y + 5, cellBPos.Z - cellBSize.Z / 2 + 0.6),
			size = Vector3.new(3, 0.12, 0.05),
		},
		{
			pos = Vector3.new(cellBPos.X - 0.3, FLOOR_Y + 6, cellBPos.Z - cellBSize.Z / 2 + 0.6),
			size = Vector3.new(1.5, 0.15, 0.05),
		},
		{
			pos = Vector3.new(cellBPos.X + 1.5, FLOOR_Y + 3.5, cellBPos.Z - cellBSize.Z / 2 + 0.6),
			size = Vector3.new(2.5, 0.1, 0.05),
		},
		{
			pos = Vector3.new(cellBPos.X - 1.5, FLOOR_Y + 7, cellBPos.Z - cellBSize.Z / 2 + 0.6),
			size = Vector3.new(1.8, 0.15, 0.05),
		},
		-- East wall writing
		{
			pos = Vector3.new(cellBPos.X + cellBSize.X / 2 - 0.6, FLOOR_Y + 4.5, cellBPos.Z - 1),
			size = Vector3.new(0.05, 0.12, 2),
		},
		{
			pos = Vector3.new(cellBPos.X + cellBSize.X / 2 - 0.6, FLOOR_Y + 5.5, cellBPos.Z + 0.5),
			size = Vector3.new(0.05, 0.15, 1.5),
		},
		{
			pos = Vector3.new(cellBPos.X + cellBSize.X / 2 - 0.6, FLOOR_Y + 3, cellBPos.Z),
			size = Vector3.new(0.05, 0.1, 2.5),
		},
		{
			pos = Vector3.new(cellBPos.X + cellBSize.X / 2 - 0.6, FLOOR_Y + 6.5, cellBPos.Z - 0.5),
			size = Vector3.new(0.05, 0.15, 1.8),
		},
		-- West wall writing
		{
			pos = Vector3.new(cellBPos.X - cellBSize.X / 2 + 0.6, FLOOR_Y + 5, cellBPos.Z + 1),
			size = Vector3.new(0.05, 0.12, 2.2),
		},
		{
			pos = Vector3.new(cellBPos.X - cellBSize.X / 2 + 0.6, FLOOR_Y + 4, cellBPos.Z - 0.8),
			size = Vector3.new(0.05, 0.15, 1.5),
		},
		{
			pos = Vector3.new(cellBPos.X - cellBSize.X / 2 + 0.6, FLOOR_Y + 7, cellBPos.Z + 0.2),
			size = Vector3.new(0.05, 0.1, 2),
		},
		-- South wall writing
		{
			pos = Vector3.new(cellBPos.X - 0.5, FLOOR_Y + 4.5, cellBPos.Z + cellBSize.Z / 2 - 0.6),
			size = Vector3.new(2, 0.12, 0.05),
		},
		{
			pos = Vector3.new(cellBPos.X + 1, FLOOR_Y + 6, cellBPos.Z + cellBSize.Z / 2 - 0.6),
			size = Vector3.new(1.5, 0.15, 0.05),
		},
	}

	for i, w in writingPositions do
		createPart(cellB, `Writing_{i}`, w.pos, w.size, COLOR_WRITING, 0, Enum.Material.Concrete)
	end

	-- Large "IT SEES" scrawled text (prominent mark)
	createPart(
		cellB,
		"Writing_Main",
		Vector3.new(cellBPos.X, FLOOR_Y + 5.5, cellBPos.Z - cellBSize.Z / 2 + 0.6),
		Vector3.new(3.5, 0.8, 0.05),
		COLOR_WRITING,
		0,
		Enum.Material.Concrete
	)

	-- Very dim, oppressive lighting
	Shared.createLight(
		Vector3.new(cellBPos.X, FLOOR_Y + ROOM_HEIGHT - 1, cellBPos.Z),
		cellB,
		0.05,
		Color3.fromRGB(200, 180, 160)
	)

	-- Nurse Station: behind reinforced glass, Master Key location
	local nursePos = Vector3.new(40, FLOOR_Y, -5)
	local nurseSize = Vector3.new(8, ROOM_HEIGHT, 6)

	local nurseStation = Shared.createRoom({
		position = nursePos,
		size = nurseSize,
		parent = ward,
		name = "NurseStation",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "east", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	Shared.createDoor(
		Vector3.new(nursePos.X + nurseSize.X / 2, FLOOR_Y + DOOR_HEIGHT / 2, nursePos.Z),
		CFrame.Angles(0, math.rad(90), 0),
		nurseStation,
		"Door_NurseStation",
		false,
		nil
	)

	-- Reinforced glass window (north-facing, toward corridor)
	local glassPos = Vector3.new(nursePos.X, FLOOR_Y + 5, nursePos.Z - nurseSize.Z / 2 + 0.5)
	createPart(
		nurseStation,
		"ReinforcedGlass",
		glassPos,
		Vector3.new(nurseSize.X - 2, 5, 0.5),
		COLOR_GLASS,
		0.5,
		Enum.Material.Glass
	)

	-- Desk
	local nurseDeskPos = Vector3.new(nursePos.X, FLOOR_Y + 1, nursePos.Z - 1)
	Shared.createFurniture("desk", nurseDeskPos, nurseStation)

	-- Master Key on desk
	local masterKeyPart = createPart(
		nurseStation,
		"MasterKey",
		Vector3.new(nurseDeskPos.X + 1, nurseDeskPos.Y + 1.5, nurseDeskPos.Z),
		Vector3.new(0.5, 0.15, 1),
		Color3.fromRGB(180, 160, 40),
		0,
		Enum.Material.Metal
	)
	local masterKeyLight = Instance.new("PointLight")
	masterKeyLight.Brightness = 0.4
	masterKeyLight.Range = 5
	masterKeyLight.Color = Color3.fromRGB(255, 200, 80)
	masterKeyLight.Parent = masterKeyPart

	-- Cabinet
	Shared.createFurniture("cabinet", Vector3.new(nursePos.X - 2, FLOOR_Y + 1, nursePos.Z + 1), nurseStation)

	-- Light
	Shared.createLight(Vector3.new(nursePos.X, FLOOR_Y + ROOM_HEIGHT - 1, nursePos.Z), nurseStation, 0.2)

	-- Hiding: under desk in Nurse Station
	local underNurseDeskPos = Vector3.new(nurseDeskPos.X, FLOOR_Y + 0.5, nurseDeskPos.Z)
	Shared.createHidingSpot(underNurseDeskPos, "Desk", "upper_nursestation_underdesk", nurseStation)
	table.insert(hidingSpots, {
		id = "upper_nursestation_underdesk",
		position = underNurseDeskPos,
		spotType = "Desk",
		isOccupied = false,
	})

	-- Observation Room: one-way glass into Cell B
	local obsPos = Vector3.new(48, FLOOR_Y, -5)
	local obsSize = Vector3.new(6, ROOM_HEIGHT, 6)

	local obsRoom = Shared.createRoom({
		position = obsPos,
		size = obsSize,
		parent = ward,
		name = "ObservationRoom",
		wallThickness = WALL_THICKNESS,
		doorways = {
			{ wall = "west", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	Shared.createDoor(
		Vector3.new(obsPos.X - obsSize.X / 2, FLOOR_Y + DOOR_HEIGHT / 2, obsPos.Z),
		CFrame.Angles(0, math.rad(90), 0),
		obsRoom,
		"Door_ObsRoom",
		false,
		nil
	)

	-- One-way glass (north wall, looking into Cell B)
	local oneWayGlassPos = Vector3.new(obsPos.X, FLOOR_Y + 5, obsPos.Z - obsSize.Z / 2 + 0.5)
	createPart(
		obsRoom,
		"OneWayGlass",
		oneWayGlassPos,
		Vector3.new(obsSize.X - 2, 4, 0.4),
		Color3.fromRGB(40, 45, 50),
		0.3,
		Enum.Material.Glass
	)

	-- Desk with monitoring equipment
	Shared.createFurniture("desk", Vector3.new(obsPos.X, FLOOR_Y + 1, obsPos.Z), obsRoom)

	-- Monitor (small box on desk)
	createPart(
		obsRoom,
		"Monitor",
		Vector3.new(obsPos.X, FLOOR_Y + 2.8, obsPos.Z - 0.5),
		Vector3.new(1.5, 1.2, 0.3),
		Color3.fromRGB(30, 30, 35),
		0,
		Enum.Material.SmoothPlastic
	)

	-- Dim light
	Shared.createLight(Vector3.new(obsPos.X, FLOOR_Y + ROOM_HEIGHT - 1, obsPos.Z), obsRoom, 0.15)

	-- No hiding spots in observation room

	-- Ward waypoints (corridor intersections)
	table.insert(waypoints, {
		position = Vector3.new(wardPos.X - 2, FLOOR_Y + 3, wardPos.Z - 5),
		roomId = "PsychWard_Corridor",
		dwellTime = 3,
	})

	table.insert(waypoints, {
		position = Vector3.new(wardPos.X + 5, FLOOR_Y + 3, wardPos.Z - 15),
		roomId = "PsychWard_NorthEnd",
		dwellTime = 4,
	})

	table.insert(waypoints, {
		position = Vector3.new(nursePos.X, FLOOR_Y + 3, nursePos.Z),
		roomId = "NurseStation",
		dwellTime = 5,
	})

	-- Loot
	table.insert(lootPositions, {
		itemType = "Medkit",
		position = Vector3.new(nursePos.X - 2, FLOOR_Y + 2, nursePos.Z + 1),
		chance = 1,
		guaranteed = true,
	})

	table.insert(lootPositions, {
		itemType = "Battery",
		position = Vector3.new(nursePos.X + 2, FLOOR_Y + 2, nursePos.Z),
		chance = 1,
		guaranteed = true,
	})

	table.insert(lootPositions, {
		itemType = "Battery",
		position = Vector3.new(obsPos.X, FLOOR_Y + 2, obsPos.Z + 1),
		chance = 0.5,
		guaranteed = false,
	})
end

local function buildUpperHallway(
	parent: Instance,
	waypoints: { { position: Vector3, roomId: string, dwellTime: number } }
)
	-- L-shaped hallway connecting all upper floor rooms
	-- Runs west-to-east along north side (past rooms 201-203),
	-- then turns south along east side (to Psych Ward and Operating Theater)

	local hallway = Instance.new("Model")
	hallway.Name = "UpperHallway"
	hallway.Parent = parent

	local HALL_WIDTH = 6

	-- East-West segment: from west rooms (X=-25) past north rooms to turn point
	local ewStart = Vector3.new(-25, FLOOR_Y, -15)
	local ewEnd = Vector3.new(25, FLOOR_Y, -15)
	Shared.createCorridor(ewStart, ewEnd, HALL_WIDTH, ROOM_HEIGHT, hallway, "Hallway_EastWest")

	-- North-South segment: from turn point south to psych ward / operating theater area
	local nsStart = Vector3.new(22, FLOOR_Y, -15)
	local nsEnd = Vector3.new(22, FLOOR_Y, 15)
	Shared.createCorridor(nsStart, nsEnd, HALL_WIDTH, ROOM_HEIGHT, hallway, "Hallway_NorthSouth")

	-- West spur: connects to rooms 204-206 area
	local westSpur = Vector3.new(-25, FLOOR_Y, -15)
	local westEnd = Vector3.new(-25, FLOOR_Y, 5)
	Shared.createCorridor(westSpur, westEnd, HALL_WIDTH, ROOM_HEIGHT, hallway, "Hallway_WestSpur")

	-- Hallway lights (dim fluorescents, spaced along corridor)
	local hallLightPositions = {
		Vector3.new(-20, FLOOR_Y + ROOM_HEIGHT - 1, -15),
		Vector3.new(-10, FLOOR_Y + ROOM_HEIGHT - 1, -15),
		Vector3.new(0, FLOOR_Y + ROOM_HEIGHT - 1, -15),
		Vector3.new(10, FLOOR_Y + ROOM_HEIGHT - 1, -15),
		Vector3.new(20, FLOOR_Y + ROOM_HEIGHT - 1, -15),
		Vector3.new(22, FLOOR_Y + ROOM_HEIGHT - 1, -5),
		Vector3.new(22, FLOOR_Y + ROOM_HEIGHT - 1, 5),
		Vector3.new(-25, FLOOR_Y + ROOM_HEIGHT - 1, -5),
	}

	for _, lightPos in hallLightPositions do
		Shared.createLight(lightPos, hallway, 0.2)
	end

	-- Patrol waypoints at key intersections and turns
	table.insert(waypoints, {
		position = Vector3.new(-20, FLOOR_Y + 3, -15),
		roomId = "UpperHallway_West",
		dwellTime = 2,
	})

	table.insert(waypoints, {
		position = Vector3.new(0, FLOOR_Y + 3, -15),
		roomId = "UpperHallway_Center",
		dwellTime = 2,
	})

	table.insert(waypoints, {
		position = Vector3.new(22, FLOOR_Y + 3, -15),
		roomId = "UpperHallway_Turn",
		dwellTime = 3,
	})

	table.insert(waypoints, {
		position = Vector3.new(22, FLOOR_Y + 3, 0),
		roomId = "UpperHallway_South",
		dwellTime = 2,
	})

	table.insert(waypoints, {
		position = Vector3.new(22, FLOOR_Y + 3, 10),
		roomId = "UpperHallway_SouthEnd",
		dwellTime = 2,
	})

	table.insert(waypoints, {
		position = Vector3.new(-25, FLOOR_Y + 3, -5),
		roomId = "UpperHallway_WestSpur",
		dwellTime = 2,
	})

	-- Hallway environmental details: gurneys, scattered debris
	Shared.createFurniture("gurney", Vector3.new(-5, FLOOR_Y + 0.5, -14), hallway)
	Shared.createFurniture("gurney", Vector3.new(15, FLOOR_Y + 0.5, -16), hallway)

	-- Overturned chair in hallway
	local tippedChair = createPart(
		hallway,
		"TippedChair",
		Vector3.new(5, FLOOR_Y + 0.5, -14.5),
		Vector3.new(1.5, 1.5, 1.5),
		Color3.fromRGB(100, 90, 75),
		0,
		Enum.Material.Wood
	)
	tippedChair.Orientation = Vector3.new(45, 20, 0)

	-- Bloodstain trail in hallway
	createPart(
		hallway,
		"HallBlood_1",
		Vector3.new(8, FLOOR_Y + 0.05, -15),
		Vector3.new(2, 0.05, 1.5),
		COLOR_BLOOD_STAIN,
		0.35,
		Enum.Material.Concrete
	)
	createPart(
		hallway,
		"HallBlood_2",
		Vector3.new(12, FLOOR_Y + 0.05, -14.5),
		Vector3.new(1.5, 0.05, 1),
		COLOR_BLOOD_STAIN,
		0.4,
		Enum.Material.Concrete
	)
end

------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------

local UpperFloor = {}

function UpperFloor.build(parent: Instance): FloorData
	local floorModel = Instance.new("Model")
	floorModel.Name = "UpperFloor"
	floorModel.Parent = parent

	local hidingSpots: { HidingSpotData } = {}
	local waypoints: { { position: Vector3, roomId: string, dwellTime: number } } = {}
	local lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } } = {}

	-- Build all rooms
	buildRoom201(floorModel, hidingSpots, waypoints, lootPositions)
	buildRoom202(floorModel, hidingSpots, waypoints, lootPositions)
	buildRoom203(floorModel, hidingSpots, waypoints, lootPositions)
	buildRooms204to206(floorModel, hidingSpots, waypoints, lootPositions)
	buildOperatingTheater(floorModel, hidingSpots, waypoints, lootPositions)
	buildStaffBreakRoom(floorModel, hidingSpots, waypoints, lootPositions)
	buildPsychiatricWard(floorModel, hidingSpots, waypoints, lootPositions)
	buildUpperHallway(floorModel, waypoints)

	print(`[UpperFloor] Built: {#hidingSpots} hiding spots, {#waypoints} waypoints, {#lootPositions} loot positions`)

	return {
		hidingSpots = hidingSpots,
		waypoints = waypoints,
		lootPositions = lootPositions,
	}
end

return UpperFloor
