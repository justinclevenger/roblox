--!strict

--[[
	Hospital/Basement - Builds the Basement (Y=-12) geometry for
	St. Maren's Hospital (Level 1).

	Rooms: Morgue, Generator Room, Boiler Room, Storage Maze,
	       Laundry, Sub-Basement Door, Basement Corridor.

	The basement is darker, more industrial, and claustrophobic.
	Materials lean toward Concrete and Metal with dim, warm-tinted lights.
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

local FLOOR_Y = -12
local ROOM_HEIGHT = 12
local DOOR_WIDTH = 5
local DOOR_HEIGHT = 8

-- Basement color palette (dark, industrial)
local WALL_COLOR = Color3.fromRGB(120, 118, 112)
local FLOOR_COLOR = Color3.fromRGB(95, 95, 90)
local _PIPE_COLOR = Color3.fromRGB(100, 95, 90)
local METAL_COLOR = Color3.fromRGB(110, 110, 105)

------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------

local Basement = {}

function Basement.build(parent: Instance): FloorData
	local hidingSpots: { HidingSpotData } = {}
	local waypoints: { { position: Vector3, roomId: string, dwellTime: number } } = {}
	local lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } } = {}

	local floorModel = Instance.new("Model")
	floorModel.Name = "Basement"

	--------------------------------------------------------------------
	-- Basement Corridor
	--------------------------------------------------------------------
	do
		local corridorModel = Instance.new("Model")
		corridorModel.Name = "BasementCorridor"

		-- Main east-west corridor: X=-30 to X=30 at Z=0
		Shared.createCorridor(
			Vector3.new(-30, FLOOR_Y, 0),
			Vector3.new(30, FLOOR_Y, 0),
			5,
			ROOM_HEIGHT,
			corridorModel,
			"Corridor_Main"
		)

		-- Branch corridor to morgue: Z=0 to Z=-20 at X=-25
		Shared.createCorridor(
			Vector3.new(-25, FLOOR_Y, -5),
			Vector3.new(-25, FLOOR_Y, -20),
			5,
			ROOM_HEIGHT,
			corridorModel,
			"Corridor_ToMorgue"
		)

		-- Branch corridor to storage/laundry: Z=0 to Z=25 at X=25
		Shared.createCorridor(
			Vector3.new(25, FLOOR_Y, 5),
			Vector3.new(25, FLOOR_Y, 25),
			5,
			ROOM_HEIGHT,
			corridorModel,
			"Corridor_ToStorage"
		)

		-- Ceiling pipes running along corridor
		for i = 0, 5 do
			local pipeX = -25 + i * 10
			Shared.createPipe(
				Vector3.new(pipeX, FLOOR_Y + ROOM_HEIGHT - 1.5, 0),
				12,
				0.3,
				Vector3.new(0, 0, 90),
				corridorModel,
				`CeilingPipe_{i}`
			)
		end

		-- Dripping water sound markers (thin translucent parts)
		for _, pos in { Vector3.new(-10, FLOOR_Y + ROOM_HEIGHT - 2, 0), Vector3.new(10, FLOOR_Y + ROOM_HEIGHT - 2, 0) } do
			local drip = Instance.new("Part")
			drip.Name = "DripPoint"
			drip.Size = Vector3.new(0.5, 0.5, 0.5)
			drip.Position = pos
			drip.Anchored = true
			drip.Transparency = 0.9
			drip.CanCollide = false
			drip.Material = Enum.Material.Glass
			drip.Color = Color3.fromRGB(100, 130, 150)
			drip.Parent = corridorModel

			-- Small puddle on the floor below
			local puddle = Instance.new("Part")
			puddle.Name = "Puddle"
			puddle.Size = Vector3.new(2, 0.05, 2)
			puddle.Position = Vector3.new(pos.X, FLOOR_Y + 0.03, pos.Z)
			puddle.Anchored = true
			puddle.Material = Enum.Material.Glass
			puddle.Color = Color3.fromRGB(60, 80, 100)
			puddle.Transparency = 0.5
			puddle.Parent = corridorModel
		end

		-- Very dim corridor lights
		Shared.createLight(
			Vector3.new(-15, FLOOR_Y + ROOM_HEIGHT - 0.5, 0),
			corridorModel,
			0.15,
			Color3.fromRGB(255, 200, 150)
		)
		Shared.createLight(
			Vector3.new(15, FLOOR_Y + ROOM_HEIGHT - 0.5, 0),
			corridorModel,
			0.15,
			Color3.fromRGB(255, 200, 150)
		)
		Shared.createLight(
			Vector3.new(0, FLOOR_Y + ROOM_HEIGHT - 0.5, 0),
			corridorModel,
			0.2,
			Color3.fromRGB(255, 200, 150)
		)

		-- Corridor waypoints
		table.insert(
			waypoints,
			{ position = Vector3.new(0, FLOOR_Y + 3, 0), roomId = "BasementCorridor_Center", dwellTime = 1.5 }
		)
		table.insert(
			waypoints,
			{ position = Vector3.new(-20, FLOOR_Y + 3, 0), roomId = "BasementCorridor_West", dwellTime = 1 }
		)
		table.insert(
			waypoints,
			{ position = Vector3.new(20, FLOOR_Y + 3, 0), roomId = "BasementCorridor_East", dwellTime = 1 }
		)

		corridorModel.Parent = floorModel
	end

	--------------------------------------------------------------------
	-- Morgue
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(-25, FLOOR_Y, -20)
		local roomSize = Vector3.new(15, ROOM_HEIGHT, 15)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "Morgue",
			wallColor = Color3.fromRGB(170, 175, 170),
			wallMaterial = Enum.Material.Concrete,
			floorColor = Color3.fromRGB(130, 135, 130),
			floorMaterial = Enum.Material.Marble,
			doorways = {
				{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Door
		Shared.createDoor(roomPos + Vector3.new(0, DOOR_HEIGHT / 2, 8), nil, room, "MorgueDoor", false)

		-- Body drawers (6 drawers on west wall, 3 rows x 2 columns)
		for row = 0, 2 do
			for col = 0, 1 do
				local drawerY = FLOOR_Y + 1.5 + row * 2.5
				local drawerZ = roomPos.Z - 3 + col * 5

				-- Drawer front panel
				local drawer = Instance.new("Part")
				drawer.Name = `BodyDrawer_{row}_{col}`
				drawer.Size = Vector3.new(0.3, 2, 3)
				drawer.Position = Vector3.new(roomPos.X - 7, drawerY, drawerZ)
				drawer.Anchored = true
				drawer.Material = Enum.Material.Metal
				drawer.Color = Color3.fromRGB(190, 190, 185)
				drawer.Parent = room

				-- Handle
				local handle = Instance.new("Part")
				handle.Name = `DrawerHandle_{row}_{col}`
				handle.Size = Vector3.new(0.5, 0.2, 1)
				handle.Position = Vector3.new(roomPos.X - 6.6, drawerY, drawerZ)
				handle.Anchored = true
				handle.Material = Enum.Material.Metal
				handle.Color = Color3.fromRGB(150, 150, 145)
				handle.Parent = room
			end
		end

		-- Central examination table
		local examTable = Instance.new("Part")
		examTable.Name = "ExamTable"
		examTable.Size = Vector3.new(3, 0.4, 7)
		examTable.Position = roomPos + Vector3.new(2, 3, 0)
		examTable.Anchored = true
		examTable.Material = Enum.Material.Metal
		examTable.Color = Color3.fromRGB(180, 180, 175)
		examTable.Parent = room

		-- Table legs
		for _, offset in
			{ Vector3.new(-1, 1.5, -3), Vector3.new(1, 1.5, -3), Vector3.new(-1, 1.5, 3), Vector3.new(1, 1.5, 3) }
		do
			local leg = Instance.new("Part")
			leg.Name = "TableLeg"
			leg.Size = Vector3.new(0.3, 3, 0.3)
			leg.Position = roomPos + Vector3.new(2, 0, 0) + offset
			leg.Anchored = true
			leg.Material = Enum.Material.Metal
			leg.Color = Color3.fromRGB(160, 160, 155)
			leg.Parent = room
		end

		-- Floor drain
		local drain = Instance.new("Part")
		drain.Name = "FloorDrain"
		drain.Size = Vector3.new(2, 0.05, 2)
		drain.Position = roomPos + Vector3.new(2, FLOOR_Y + 0.03, 0)
		drain.Anchored = true
		drain.Material = Enum.Material.Metal
		drain.Color = Color3.fromRGB(60, 60, 55)
		drain.Parent = room

		-- Harsh overhead light
		Shared.createLight(roomPos + Vector3.new(2, ROOM_HEIGHT - 0.5, 0), room, 0.5, Color3.fromRGB(230, 240, 255))

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "Morgue", dwellTime = 4 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(4, 3.5, 2), chance = 1, guaranteed = true }
		)
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(-4, 0.5, -5), chance = 0.4, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Generator Room
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(0, FLOOR_Y, -20)
		local roomSize = Vector3.new(12, ROOM_HEIGHT, 10)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "GeneratorRoom",
			wallColor = WALL_COLOR,
			wallMaterial = Enum.Material.Concrete,
			floorColor = FLOOR_COLOR,
			floorMaterial = Enum.Material.Concrete,
			doorways = {
				{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Generator model (large box with details)
		local genBody = Instance.new("Part")
		genBody.Name = "Generator_Body"
		genBody.Size = Vector3.new(6, 4, 4)
		genBody.Position = roomPos + Vector3.new(0, 2, -1)
		genBody.Anchored = true
		genBody.Material = Enum.Material.Metal
		genBody.Color = Color3.fromRGB(80, 100, 80)
		genBody.Parent = room

		-- Control panel
		local controlPanel = Instance.new("Part")
		controlPanel.Name = "ControlPanel"
		controlPanel.Size = Vector3.new(2, 2, 0.3)
		controlPanel.Position = roomPos + Vector3.new(0, 3, 1.2)
		controlPanel.Anchored = true
		controlPanel.Material = Enum.Material.Metal
		controlPanel.Color = Color3.fromRGB(60, 60, 55)
		controlPanel.Parent = room

		-- Fuel port (interaction point)
		local fuelPort = Instance.new("Part")
		fuelPort.Name = "FuelPort"
		fuelPort.Size = Vector3.new(1, 1, 0.5)
		fuelPort.Position = roomPos + Vector3.new(3, 2, 1.2)
		fuelPort.Anchored = true
		fuelPort.Material = Enum.Material.Metal
		fuelPort.Color = Color3.fromRGB(150, 50, 50)
		fuelPort.Parent = room

		local fuelPrompt = Instance.new("ProximityPrompt")
		fuelPrompt.ActionText = "Fill Fuel"
		fuelPrompt.ObjectText = "Generator Fuel Port"
		fuelPrompt.HoldDuration = 2
		fuelPrompt.MaxActivationDistance = 6
		fuelPrompt.Parent = fuelPort

		-- Pull cord
		local pullCord = Instance.new("Part")
		pullCord.Name = "PullCord"
		pullCord.Size = Vector3.new(0.2, 1.5, 0.2)
		pullCord.Position = roomPos + Vector3.new(-3, 3.5, -1)
		pullCord.Anchored = true
		pullCord.Material = Enum.Material.Fabric
		pullCord.Color = Color3.fromRGB(140, 100, 60)
		pullCord.Parent = room

		local pullPrompt = Instance.new("ProximityPrompt")
		pullPrompt.ActionText = "Pull"
		pullPrompt.ObjectText = "Generator Starter"
		pullPrompt.HoldDuration = 0.5
		pullPrompt.MaxActivationDistance = 5
		pullPrompt.Parent = pullCord

		-- Exhaust pipes
		Shared.createPipe(roomPos + Vector3.new(0, 5, -4), 6, 0.4, Vector3.new(0, 0, 0), room, "ExhaustPipe")

		-- Light (off by default, very dim emergency)
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.1, Color3.fromRGB(255, 180, 100))

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "GeneratorRoom", dwellTime = 3 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(-4, 0.5, 3), chance = 1, guaranteed = true }
		)
	end

	--------------------------------------------------------------------
	-- Boiler Room
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(-25, FLOOR_Y, 10)
		local roomSize = Vector3.new(15, ROOM_HEIGHT, 15)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "BoilerRoom",
			wallColor = Color3.fromRGB(110, 105, 100),
			wallMaterial = Enum.Material.Concrete,
			floorColor = Color3.fromRGB(85, 85, 80),
			floorMaterial = Enum.Material.Concrete,
			doorways = {
				{ wall = "east", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Large boiler (cylinder-ish)
		local boilerBody = Instance.new("Part")
		boilerBody.Name = "Boiler"
		boilerBody.Size = Vector3.new(5, 6, 5)
		boilerBody.Position = roomPos + Vector3.new(-2, 3, -2)
		boilerBody.Anchored = true
		boilerBody.Material = Enum.Material.Metal
		boilerBody.Color = Color3.fromRGB(130, 70, 60)
		boilerBody.Parent = room

		-- Second smaller boiler
		local boiler2 = Instance.new("Part")
		boiler2.Name = "Boiler2"
		boiler2.Size = Vector3.new(4, 5, 4)
		boiler2.Position = roomPos + Vector3.new(-2, 2.5, 4)
		boiler2.Anchored = true
		boiler2.Material = Enum.Material.Metal
		boiler2.Color = Color3.fromRGB(120, 65, 55)
		boiler2.Parent = room

		-- Network of pipes (ceiling-mounted)
		for i = 0, 3 do
			Shared.createPipe(
				roomPos + Vector3.new(-5 + i * 3, ROOM_HEIGHT - 2, 0),
				14,
				0.35,
				Vector3.new(0, 0, 90),
				room,
				`Pipe_Horiz_{i}`
			)
		end

		-- Vertical pipes
		for i = 0, 1 do
			Shared.createPipe(
				roomPos + Vector3.new(-3 + i * 6, ROOM_HEIGHT / 2, -5),
				ROOM_HEIGHT,
				0.3,
				Vector3.new(0, 0, 0),
				room,
				`Pipe_Vert_{i}`
			)
		end

		-- Steam vent markers
		for _, pos in { roomPos + Vector3.new(-4, 4, -2), roomPos + Vector3.new(3, 6, 4) } do
			local vent = Instance.new("Part")
			vent.Name = "SteamVent"
			vent.Size = Vector3.new(1, 0.5, 1)
			vent.Position = pos
			vent.Anchored = true
			vent.Transparency = 0.7
			vent.CanCollide = false
			vent.Material = Enum.Material.SmoothPlastic
			vent.Color = Color3.fromRGB(200, 200, 200)
			vent.Parent = room
		end

		-- Catwalk (elevated metal grate)
		local catwalk = Instance.new("Part")
		catwalk.Name = "Catwalk"
		catwalk.Size = Vector3.new(3, 0.2, 12)
		catwalk.Position = roomPos + Vector3.new(5, 4, 0)
		catwalk.Anchored = true
		catwalk.Material = Enum.Material.DiamondPlate
		catwalk.Color = Color3.fromRGB(100, 100, 95)
		catwalk.Parent = room

		-- Catwalk railing
		local railing = Instance.new("Part")
		railing.Name = "Railing"
		railing.Size = Vector3.new(0.2, 3, 12)
		railing.Position = roomPos + Vector3.new(3.5, 5.5, 0)
		railing.Anchored = true
		railing.Material = Enum.Material.Metal
		railing.Color = Color3.fromRGB(120, 120, 115)
		railing.Transparency = 0.3
		railing.Parent = room

		-- Hiding spot: behind boiler pipes
		local _, spotData1 =
			Shared.createHidingSpot(roomPos + Vector3.new(-5, 1, -4), "Closet", "B_Boiler_Pipes1", room)
		table.insert(hidingSpots, spotData1)

		local _, spotData2 = Shared.createHidingSpot(roomPos + Vector3.new(4, 1, 5), "Closet", "B_Boiler_Pipes2", room)
		table.insert(hidingSpots, spotData2)

		-- Very dim warm light
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.15, Color3.fromRGB(255, 160, 80))

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "BoilerRoom", dwellTime = 3 })

		-- Loot (fuel canister can spawn here)
		table.insert(lootPositions, {
			itemType = "FuelCanister",
			position = roomPos + Vector3.new(4, 4.5, -3),
			chance = 0.5,
			guaranteed = false,
		})
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(-4, 0.5, 5), chance = 0.4, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Storage Maze
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(25, FLOOR_Y, -10)
		local roomSize = Vector3.new(20, ROOM_HEIGHT, 20)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "StorageMaze",
			wallColor = WALL_COLOR,
			wallMaterial = Enum.Material.Concrete,
			floorColor = FLOOR_COLOR,
			floorMaterial = Enum.Material.Concrete,
			doorways = {
				{ wall = "west", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Maze of tall shelving units blocking line of sight
		-- Row 1 (runs east-west)
		local shelfRow1 = Instance.new("Part")
		shelfRow1.Name = "ShelfRow_1"
		shelfRow1.Size = Vector3.new(12, 8, 2)
		shelfRow1.Position = roomPos + Vector3.new(2, 4, -6)
		shelfRow1.Anchored = true
		shelfRow1.Material = Enum.Material.Metal
		shelfRow1.Color = METAL_COLOR
		shelfRow1.Parent = room

		-- Row 2 (parallel, offset)
		local shelfRow2 = Instance.new("Part")
		shelfRow2.Name = "ShelfRow_2"
		shelfRow2.Size = Vector3.new(10, 8, 2)
		shelfRow2.Position = roomPos + Vector3.new(-2, 4, -1)
		shelfRow2.Anchored = true
		shelfRow2.Material = Enum.Material.Metal
		shelfRow2.Color = METAL_COLOR
		shelfRow2.Parent = room

		-- Row 3 (perpendicular, creates dead end)
		local shelfRow3 = Instance.new("Part")
		shelfRow3.Name = "ShelfRow_3"
		shelfRow3.Size = Vector3.new(2, 8, 8)
		shelfRow3.Position = roomPos + Vector3.new(5, 4, 4)
		shelfRow3.Anchored = true
		shelfRow3.Material = Enum.Material.Metal
		shelfRow3.Color = METAL_COLOR
		shelfRow3.Parent = room

		-- Row 4 (east side)
		local shelfRow4 = Instance.new("Part")
		shelfRow4.Name = "ShelfRow_4"
		shelfRow4.Size = Vector3.new(8, 8, 2)
		shelfRow4.Position = roomPos + Vector3.new(-3, 4, 6)
		shelfRow4.Anchored = true
		shelfRow4.Material = Enum.Material.Metal
		shelfRow4.Color = METAL_COLOR
		shelfRow4.Parent = room

		-- Scattered boxes on floor
		for i = 1, 6 do
			local box = Instance.new("Part")
			box.Name = `Box_{i}`
			box.Size = Vector3.new(1.5 + math.random() * 1.5, 1 + math.random() * 1.5, 1.5 + math.random() * 1.5)
			box.Position = roomPos + Vector3.new(math.random(-7, 7), FLOOR_Y + box.Size.Y / 2, math.random(-7, 7))
			box.Anchored = true
			box.Material = Enum.Material.Cardboard
			box.Color = Color3.fromRGB(160, 140, 110)
			box.Orientation = Vector3.new(0, math.random(0, 45), 0)
			box.Parent = room
		end

		-- Hiding spots: behind shelf rows
		local _, spotData1 =
			Shared.createHidingSpot(roomPos + Vector3.new(7, 1, -6), "Closet", "B_Storage_Shelf1", room)
		table.insert(hidingSpots, spotData1)

		local _, spotData2 =
			Shared.createHidingSpot(roomPos + Vector3.new(-6, 1, 6), "Closet", "B_Storage_Shelf2", room)
		table.insert(hidingSpots, spotData2)

		-- Dim light
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.15, Color3.fromRGB(255, 200, 150))

		-- Waypoints (multiple due to maze layout)
		table.insert(
			waypoints,
			{ position = roomPos + Vector3.new(-5, 3, -5), roomId = "StorageMaze_NW", dwellTime = 2 }
		)
		table.insert(
			waypoints,
			{ position = roomPos + Vector3.new(5, 3, -5), roomId = "StorageMaze_NE", dwellTime = 2 }
		)
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 5), roomId = "StorageMaze_S", dwellTime = 2 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(7, 0.5, 5), chance = 1, guaranteed = true }
		)
		table.insert(
			lootPositions,
			{ itemType = "Flare", position = roomPos + Vector3.new(-6, 0.5, -7), chance = 0.4, guaranteed = false }
		)
		table.insert(lootPositions, {
			itemType = "FuelCanister",
			position = roomPos + Vector3.new(-3, 0.5, 3),
			chance = 0.5,
			guaranteed = false,
		})
	end

	--------------------------------------------------------------------
	-- Laundry
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(25, FLOOR_Y, 20)
		local roomSize = Vector3.new(14, ROOM_HEIGHT, 14)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "Laundry",
			wallColor = Color3.fromRGB(165, 165, 160),
			wallMaterial = Enum.Material.Concrete,
			floorColor = Color3.fromRGB(120, 120, 115),
			floorMaterial = Enum.Material.Concrete,
			doorways = {
				{ wall = "north", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Washing machines (row of 3)
		for i = 0, 2 do
			Shared.createFurniture("washer", roomPos + Vector3.new(-4 + i * 4, 0, -4), room)
		end

		-- Dryers (row of 2)
		for i = 0, 1 do
			Shared.createFurniture("dryer", roomPos + Vector3.new(-2 + i * 4, 0, 4), room)
		end

		-- Laundry carts (2, one is a hiding spot)
		Shared.createFurniture("cart", roomPos + Vector3.new(4, 0, 0), room)
		local hidingCart = Shared.createFurniture("cart", roomPos + Vector3.new(-5, 0, 2), room)

		-- Hiding spot: inside laundry cart
		local _, spotData =
			Shared.createHidingSpot(roomPos + Vector3.new(-5, 1, 2), "LaundryCart", "B_Laundry_Cart", hidingCart)
		table.insert(hidingSpots, spotData)

		-- Folding table
		Shared.createFurniture("table", roomPos + Vector3.new(0, 0, 0), room)

		-- Ceiling pipes
		Shared.createPipe(
			roomPos + Vector3.new(0, ROOM_HEIGHT - 1.5, 0),
			12,
			0.25,
			Vector3.new(0, 0, 90),
			room,
			"CeilingPipe"
		)

		-- Light
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.25, Color3.fromRGB(255, 220, 180))

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "Laundry", dwellTime = 2 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(-3, 3.5, 0), chance = 0.4, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Sub-Basement Door
	--------------------------------------------------------------------
	do
		local doorPos = Vector3.new(30, FLOOR_Y, 30)

		local doorModel = Instance.new("Model")
		doorModel.Name = "SubBasementDoor"

		-- Small alcove room
		local alcove = Shared.createRoom({
			position = doorPos,
			size = Vector3.new(8, ROOM_HEIGHT, 8),
			parent = doorModel,
			name = "SubBasementAlcove",
			wallColor = Color3.fromRGB(100, 100, 95),
			wallMaterial = Enum.Material.Concrete,
			floorColor = Color3.fromRGB(80, 80, 75),
			floorMaterial = Enum.Material.Concrete,
			doorways = {
				{ wall = "north", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Heavy sealed door (no interaction in Level 1)
		local sealedDoor = Instance.new("Part")
		sealedDoor.Name = "SealedDoor"
		sealedDoor.Size = Vector3.new(6, 8, 1)
		sealedDoor.Position = doorPos + Vector3.new(0, 4, 3)
		sealedDoor.Anchored = true
		sealedDoor.Material = Enum.Material.Metal
		sealedDoor.Color = Color3.fromRGB(70, 70, 65)
		sealedDoor.Parent = alcove

		-- Warning signage (yellow stripe)
		local warningStripe = Instance.new("Part")
		warningStripe.Name = "WarningStripe"
		warningStripe.Size = Vector3.new(5.5, 0.5, 0.1)
		warningStripe.Position = doorPos + Vector3.new(0, 7, 2.4)
		warningStripe.Anchored = true
		warningStripe.Material = Enum.Material.SmoothPlastic
		warningStripe.Color = Color3.fromRGB(200, 180, 40)
		warningStripe.Parent = alcove

		-- Chains and padlock (decorative)
		local chains = Instance.new("Part")
		chains.Name = "Chains"
		chains.Size = Vector3.new(3, 0.3, 0.3)
		chains.Position = doorPos + Vector3.new(0, 4, 2.4)
		chains.Anchored = true
		chains.Material = Enum.Material.Metal
		chains.Color = Color3.fromRGB(140, 140, 130)
		chains.Parent = alcove

		-- No light here (pitch dark)

		-- Waypoint
		table.insert(
			waypoints,
			{ position = doorPos + Vector3.new(0, 3, 0), roomId = "SubBasementDoor", dwellTime = 1 }
		)

		doorModel.Parent = floorModel
	end

	--------------------------------------------------------------------
	-- Stairwell connection point (landing at basement level)
	-- (Actual stairwell geometry is built in GroundFloor.luau)
	--------------------------------------------------------------------
	table.insert(waypoints, { position = Vector3.new(0, FLOOR_Y + 3, 5), roomId = "Stairwell_Basement", dwellTime = 1 })

	floorModel.Parent = parent

	return {
		hidingSpots = hidingSpots,
		waypoints = waypoints,
		lootPositions = lootPositions,
	}
end

return Basement
