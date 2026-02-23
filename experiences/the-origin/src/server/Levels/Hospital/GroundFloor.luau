--!strict

--[[
	Hospital/GroundFloor - Builds the Ground Floor (Y=0) geometry for
	St. Maren's Hospital (Level 1).

	Rooms: Reception/Lobby, Waiting Room, Security Office, Emergency Ward,
	       Pharmacy, Chapel, Restrooms, Ground Corridor (T-shape).

	Returns hiding spots, patrol waypoints, and loot spawn positions.
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

local FLOOR_Y = 0
local ROOM_HEIGHT = 12
local _WALL_THICKNESS = 1
local DOOR_WIDTH = 5
local DOOR_HEIGHT = 8

-- Color palette (muted, abandoned hospital)
local WALL_COLOR = Color3.fromRGB(180, 175, 165)
local FLOOR_COLOR = Color3.fromRGB(140, 140, 135)
local TILE_COLOR = Color3.fromRGB(155, 160, 155) -- greenish tile
local CHAPEL_WOOD = Color3.fromRGB(100, 70, 50)

------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------

local GroundFloor = {}

function GroundFloor.build(parent: Instance): FloorData
	local hidingSpots: { HidingSpotData } = {}
	local waypoints: { { position: Vector3, roomId: string, dwellTime: number } } = {}
	local lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } } = {}

	local floorModel = Instance.new("Model")
	floorModel.Name = "GroundFloor"

	--------------------------------------------------------------------
	-- Ground Corridor (T-shape)
	--------------------------------------------------------------------
	local corridorModel = Instance.new("Model")
	corridorModel.Name = "GroundCorridor"

	-- East-West corridor: runs from X=-30 to X=30 at Z=0
	Shared.createCorridor(
		Vector3.new(-30, FLOOR_Y, 0),
		Vector3.new(30, FLOOR_Y, 0),
		6,
		ROOM_HEIGHT,
		corridorModel,
		"Corridor_EastWest"
	)

	-- North-South corridor: runs from Z=-40 to Z=0 at X=0
	Shared.createCorridor(
		Vector3.new(0, FLOOR_Y, -40),
		Vector3.new(0, FLOOR_Y, 0),
		6,
		ROOM_HEIGHT,
		corridorModel,
		"Corridor_NorthSouth"
	)

	-- Corridor intersection waypoints
	table.insert(
		waypoints,
		{ position = Vector3.new(0, FLOOR_Y + 3, 0), roomId = "GroundCorridor_Center", dwellTime = 2 }
	)
	table.insert(
		waypoints,
		{ position = Vector3.new(-20, FLOOR_Y + 3, 0), roomId = "GroundCorridor_West", dwellTime = 1.5 }
	)
	table.insert(
		waypoints,
		{ position = Vector3.new(20, FLOOR_Y + 3, 0), roomId = "GroundCorridor_East", dwellTime = 1.5 }
	)
	table.insert(
		waypoints,
		{ position = Vector3.new(0, FLOOR_Y + 3, -20), roomId = "GroundCorridor_North", dwellTime = 1.5 }
	)

	-- Dim corridor lights
	Shared.createLight(Vector3.new(-15, FLOOR_Y + ROOM_HEIGHT - 0.5, 0), corridorModel, 0.3)
	Shared.createLight(Vector3.new(15, FLOOR_Y + ROOM_HEIGHT - 0.5, 0), corridorModel, 0.3)
	Shared.createLight(Vector3.new(0, FLOOR_Y + ROOM_HEIGHT - 0.5, -15), corridorModel, 0.25)
	Shared.createLight(Vector3.new(0, FLOOR_Y + ROOM_HEIGHT - 0.5, -30), corridorModel, 0.2)

	corridorModel.Parent = floorModel

	--------------------------------------------------------------------
	-- Reception / Lobby
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(0, FLOOR_Y, -30)
		local roomSize = Vector3.new(20, ROOM_HEIGHT, 20)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "Reception",
			wallColor = WALL_COLOR,
			floorColor = TILE_COLOR,
			floorMaterial = Enum.Material.Marble,
			doorways = {
				{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- to corridor
				{ wall = "north", offset = 0, width = 6, height = DOOR_HEIGHT }, -- main entrance (wider)
			},
		})

		-- Reception desk (large L-shaped counter)
		local deskTop = Instance.new("Part")
		deskTop.Name = "ReceptionDesk_Top"
		deskTop.Size = Vector3.new(8, 0.5, 3)
		deskTop.Position = roomPos + Vector3.new(-2, 3.5, -3)
		deskTop.Anchored = true
		deskTop.Material = Enum.Material.Wood
		deskTop.Color = Color3.fromRGB(100, 75, 55)
		deskTop.Parent = room

		local deskFront = Instance.new("Part")
		deskFront.Name = "ReceptionDesk_Front"
		deskFront.Size = Vector3.new(8, 3.5, 0.5)
		deskFront.Position = roomPos + Vector3.new(-2, 1.75, -1.5)
		deskFront.Anchored = true
		deskFront.Material = Enum.Material.Wood
		deskFront.Color = Color3.fromRGB(90, 65, 48)
		deskFront.Parent = room

		-- L-return of desk
		local deskReturn = Instance.new("Part")
		deskReturn.Name = "ReceptionDesk_Return"
		deskReturn.Size = Vector3.new(0.5, 3.5, 5)
		deskReturn.Position = roomPos + Vector3.new(-6, 1.75, -5)
		deskReturn.Anchored = true
		deskReturn.Material = Enum.Material.Wood
		deskReturn.Color = Color3.fromRGB(90, 65, 48)
		deskReturn.Parent = room

		-- Overturned chairs
		for i, offset in { Vector3.new(4, 0, 2), Vector3.new(6, 0, 4), Vector3.new(3, 0, 6) } do
			local chairModel = Shared.createFurniture("chair", roomPos + offset, room)
			-- Tilt some chairs (overturned)
			if i <= 2 then
				local parts = chairModel:GetChildren()
				for _, part in parts do
					if part:IsA("BasePart") then
						part.Orientation = Vector3.new(0, 0, 70 * (if i == 1 then 1 else -1))
						part.Position = part.Position + Vector3.new(0, -0.5, 0)
					end
				end
			end
		end

		-- Scattered papers (flat thin parts on floor)
		for i = 1, 5 do
			local paper = Instance.new("Part")
			paper.Name = `Paper_{i}`
			paper.Size = Vector3.new(0.6, 0.02, 0.8)
			paper.Position = roomPos + Vector3.new(math.random(-6, 6), 0.01, math.random(-5, 5))
			paper.Anchored = true
			paper.Material = Enum.Material.SmoothPlastic
			paper.Color = Color3.fromRGB(230, 225, 210)
			paper.Orientation = Vector3.new(0, math.random(0, 360), 0)
			paper.Parent = room
		end

		-- Desk monitor
		Shared.createFurniture("monitor", roomPos + Vector3.new(-3, 3.5, -3), room)

		-- Light (dim, flickering feel)
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.5)

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "Reception", dwellTime = 3 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(-2, 4, -3), chance = 0.6, guaranteed = false }
		)
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(3, 0.5, 2), chance = 0.4, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Waiting Room
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(20, FLOOR_Y, -30)
		local roomSize = Vector3.new(15, ROOM_HEIGHT, 15)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "WaitingRoom",
			wallColor = WALL_COLOR,
			floorColor = TILE_COLOR,
			floorMaterial = Enum.Material.Marble,
			doorways = {
				{ wall = "west", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- to Reception area
			},
		})

		-- Rows of chairs
		for row = -4, 4, 4 do
			for col = -3, 3, 3 do
				Shared.createFurniture("chair", roomPos + Vector3.new(col, 0, row), room)
			end
		end

		-- Static TV (wall-mounted)
		local tv = Instance.new("Part")
		tv.Name = "TV"
		tv.Size = Vector3.new(4, 2.5, 0.3)
		tv.Position = roomPos + Vector3.new(0, 8, -7.2)
		tv.Anchored = true
		tv.Material = Enum.Material.Glass
		tv.Color = Color3.fromRGB(15, 15, 20)
		tv.Parent = room

		-- Light
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.35)

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "WaitingRoom", dwellTime = 2 })

		-- Loot (magazine with note)
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(2, 2.5, 0), chance = 0.3, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Security Office
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(-30, FLOOR_Y, -20)
		local roomSize = Vector3.new(12, ROOM_HEIGHT, 12)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "SecurityOffice",
			wallColor = Color3.fromRGB(170, 165, 155),
			floorColor = FLOOR_COLOR,
			doorways = {
				{ wall = "east", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Locking door
		Shared.createDoor(
			roomPos + Vector3.new(6.5, DOOR_HEIGHT / 2, 0),
			CFrame.Angles(0, math.rad(90), 0),
			room,
			"SecurityDoor",
			true,
			"SecurityKey"
		)

		-- Security desk with monitors
		Shared.createFurniture("desk", roomPos + Vector3.new(0, 0, -3), room)
		for i = 0, 2 do
			Shared.createFurniture("monitor", roomPos + Vector3.new(-2 + i * 2, 3.5, -3), room)
		end

		-- Filing cabinet
		Shared.createFurniture("cabinet", roomPos + Vector3.new(-4, 0, 4), room)

		-- Hiding spot: under desk
		local _, spotData = Shared.createHidingSpot(roomPos + Vector3.new(0, 1, -3), "Desk", "GF_Security_Desk", room)
		table.insert(hidingSpots, spotData)

		-- Light
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.6)

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "SecurityOffice", dwellTime = 4 })

		-- Loot (guaranteed flashlight + battery)
		table.insert(
			lootPositions,
			{ itemType = "Flashlight", position = roomPos + Vector3.new(1, 4, -3), chance = 1, guaranteed = true }
		)
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(-1, 4, -3), chance = 0.5, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Emergency Ward
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(30, FLOOR_Y, 0)
		local roomSize = Vector3.new(25, ROOM_HEIGHT, 20)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "EmergencyWard",
			wallColor = Color3.fromRGB(185, 185, 178),
			floorColor = Color3.fromRGB(145, 150, 145),
			floorMaterial = Enum.Material.Marble,
			doorways = {
				{ wall = "west", offset = -3, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- to corridor
				{ wall = "west", offset = 5, width = DOOR_WIDTH, height = DOOR_HEIGHT }, -- second entrance
			},
		})

		-- 8 curtained bays (4 per side of a central aisle)
		local baySpacing = 5
		for bay = 0, 3 do
			local zOffset = -6 + bay * baySpacing

			-- North side bay (negative X from center within room)
			local bayPosN = roomPos + Vector3.new(-5, 0, zOffset)
			Shared.createFurniture("gurney", bayPosN, room)

			-- Curtains around north bay
			Shared.createCurtain(
				bayPosN + Vector3.new(0, ROOM_HEIGHT / 2, baySpacing / 2 - 0.1),
				Vector3.new(4, ROOM_HEIGHT - 2, 0.1),
				room,
				`Curtain_N{bay}_Back`
			)
			Shared.createCurtain(
				bayPosN + Vector3.new(2, ROOM_HEIGHT / 2, 0),
				Vector3.new(0.1, ROOM_HEIGHT - 2, baySpacing - 0.5),
				room,
				`Curtain_N{bay}_Side`
			)

			-- South side bay (positive X from center within room)
			local bayPosS = roomPos + Vector3.new(5, 0, zOffset)
			Shared.createFurniture("gurney", bayPosS, room)

			-- Curtains around south bay
			Shared.createCurtain(
				bayPosS + Vector3.new(0, ROOM_HEIGHT / 2, baySpacing / 2 - 0.1),
				Vector3.new(4, ROOM_HEIGHT - 2, 0.1),
				room,
				`Curtain_S{bay}_Back`
			)
			Shared.createCurtain(
				bayPosS + Vector3.new(-2, ROOM_HEIGHT / 2, 0),
				Vector3.new(0.1, ROOM_HEIGHT - 2, baySpacing - 0.5),
				room,
				`Curtain_S{bay}_Side`
			)

			-- Hiding spots behind curtains (2 of 8 bays usable)
			if bay == 1 or bay == 3 then
				local _, spotData =
					Shared.createHidingSpot(bayPosN + Vector3.new(0, 1, 0), "Closet", `GF_EW_Bay_N{bay}`, room)
				table.insert(hidingSpots, spotData)
			end
		end

		-- Overhead fluorescents (multiple dim lights)
		Shared.createLight(roomPos + Vector3.new(-5, ROOM_HEIGHT - 0.5, 0), room, 0.4)
		Shared.createLight(roomPos + Vector3.new(5, ROOM_HEIGHT - 0.5, 0), room, 0.4)

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "EmergencyWard", dwellTime = 3 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(-5, 3.5, -3), chance = 1, guaranteed = true }
		)
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(5, 3.5, 4), chance = 1, guaranteed = true }
		)
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(0, 0.5, 7), chance = 0.4, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Pharmacy
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(-25, FLOOR_Y, 10)
		local roomSize = Vector3.new(12, ROOM_HEIGHT, 10)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "Pharmacy",
			wallColor = Color3.fromRGB(190, 190, 185),
			floorColor = TILE_COLOR,
			floorMaterial = Enum.Material.Marble,
			doorways = {
				{ wall = "east", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Counter (half-gate service window)
		local counter = Instance.new("Part")
		counter.Name = "Counter"
		counter.Size = Vector3.new(10, 4, 1)
		counter.Position = roomPos + Vector3.new(0, 2, 1)
		counter.Anchored = true
		counter.Material = Enum.Material.Marble
		counter.Color = Color3.fromRGB(200, 200, 195)
		counter.Parent = room

		-- Shelves behind counter (filled with bottles)
		for i = 0, 2 do
			Shared.createFurniture("shelf", roomPos + Vector3.new(-3 + i * 3, 0, -3), room)
		end

		-- Locked medicine cabinet
		local cabinet = Shared.createFurniture("cabinet", roomPos + Vector3.new(4, 0, -3), room)
		Shared.createDoor(roomPos + Vector3.new(4, 4, -2), nil, cabinet, "MedicineCabinet", true, "PharmacyKey")

		-- Light
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.45)

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "Pharmacy", dwellTime = 3 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(-2, 4.5, -3), chance = 1, guaranteed = true }
		)
		table.insert(
			lootPositions,
			{ itemType = "Medkit", position = roomPos + Vector3.new(4, 4.5, -3), chance = 0.5, guaranteed = false }
		)
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = roomPos + Vector3.new(0, 2.5, 1.5), chance = 0.6, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Chapel
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(-25, FLOOR_Y, -40)
		local roomSize = Vector3.new(15, ROOM_HEIGHT, 12)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "Chapel",
			wallColor = Color3.fromRGB(175, 170, 160),
			floorColor = Color3.fromRGB(120, 100, 80),
			floorMaterial = Enum.Material.Wood,
			doorways = {
				{ wall = "east", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- Pews (3 rows)
		for row = 0, 2 do
			Shared.createFurniture("pew", roomPos + Vector3.new(0, 0, -2 + row * 3), room)
		end

		-- Altar (raised platform with cloth)
		local altar = Instance.new("Part")
		altar.Name = "Altar"
		altar.Size = Vector3.new(4, 3, 2)
		altar.Position = roomPos + Vector3.new(0, 1.5, -5)
		altar.Anchored = true
		altar.Material = Enum.Material.Wood
		altar.Color = CHAPEL_WOOD
		altar.Parent = room

		local cloth = Instance.new("Part")
		cloth.Name = "AltarCloth"
		cloth.Size = Vector3.new(3.5, 0.1, 1.8)
		cloth.Position = roomPos + Vector3.new(0, 3.05, -5)
		cloth.Anchored = true
		cloth.Material = Enum.Material.Fabric
		cloth.Color = Color3.fromRGB(140, 40, 40)
		cloth.Parent = room

		-- Cross on wall
		local crossVert = Instance.new("Part")
		crossVert.Name = "Cross_Vertical"
		crossVert.Size = Vector3.new(0.5, 4, 0.3)
		crossVert.Position = roomPos + Vector3.new(0, 8, -5.8)
		crossVert.Anchored = true
		crossVert.Material = Enum.Material.Wood
		crossVert.Color = CHAPEL_WOOD
		crossVert.Parent = room

		local crossHoriz = Instance.new("Part")
		crossHoriz.Name = "Cross_Horizontal"
		crossHoriz.Size = Vector3.new(2.5, 0.5, 0.3)
		crossHoriz.Position = roomPos + Vector3.new(0, 9, -5.8)
		crossHoriz.Anchored = true
		crossHoriz.Material = Enum.Material.Wood
		crossHoriz.Color = CHAPEL_WOOD
		crossHoriz.Parent = room

		-- Dim atmospheric light
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, -4), room, 0.25, Color3.fromRGB(255, 220, 160))

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "Chapel", dwellTime = 4 })

		-- Loot (flare near altar)
		table.insert(
			lootPositions,
			{ itemType = "Flare", position = roomPos + Vector3.new(1, 3.5, -5), chance = 0.3, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Restrooms
	--------------------------------------------------------------------
	do
		local roomPos = Vector3.new(25, FLOOR_Y, 20)
		local roomSize = Vector3.new(10, ROOM_HEIGHT, 8)

		local room = Shared.createRoom({
			position = roomPos,
			size = roomSize,
			parent = floorModel,
			name = "Restrooms",
			wallColor = Color3.fromRGB(185, 185, 180),
			floorColor = Color3.fromRGB(150, 155, 150),
			floorMaterial = Enum.Material.Marble,
			doorways = {
				{ wall = "west", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
			},
		})

		-- 3 Stalls (divider walls)
		local stallWidth = 3
		for i = 0, 2 do
			local stallX = roomPos.X - 3 + i * stallWidth

			-- Divider wall
			local divider = Instance.new("Part")
			divider.Name = `StallDivider_{i}`
			divider.Size = Vector3.new(0.3, 6, 3)
			divider.Position = Vector3.new(stallX + stallWidth / 2, FLOOR_Y + 3, roomPos.Z - 1)
			divider.Anchored = true
			divider.Material = Enum.Material.Metal
			divider.Color = Color3.fromRGB(160, 165, 160)
			divider.Parent = room

			-- Stall door (half-height)
			local stallDoor = Instance.new("Part")
			stallDoor.Name = `StallDoor_{i}`
			stallDoor.Size = Vector3.new(stallWidth - 0.5, 5, 0.3)
			stallDoor.Position = Vector3.new(stallX + stallWidth / 4, FLOOR_Y + 3, roomPos.Z + 0.5)
			stallDoor.Anchored = true
			stallDoor.Material = Enum.Material.Metal
			stallDoor.Color = Color3.fromRGB(155, 160, 155)
			stallDoor.Parent = room

			-- Toilet inside stall
			Shared.createFurniture("toilet", Vector3.new(stallX, FLOOR_Y, roomPos.Z - 2), room)

			-- Hiding spot (each stall)
			local _, spotData = Shared.createHidingSpot(
				Vector3.new(stallX, FLOOR_Y + 1, roomPos.Z - 1),
				"BathroomStall",
				`GF_Restroom_Stall{i}`,
				room
			)
			table.insert(hidingSpots, spotData)
		end

		-- Sinks along opposite wall
		for i = 0, 1 do
			Shared.createFurniture("sink", roomPos + Vector3.new(-2 + i * 4, 0, 3), room)
		end

		-- Mirror (reflective wall part)
		local mirror = Instance.new("Part")
		mirror.Name = "Mirror"
		mirror.Size = Vector3.new(6, 3, 0.2)
		mirror.Position = roomPos + Vector3.new(0, 5, 3.8)
		mirror.Anchored = true
		mirror.Material = Enum.Material.Glass
		mirror.Color = Color3.fromRGB(180, 200, 200)
		mirror.Reflectance = 0.4
		mirror.Parent = room

		-- Dim light (some broken)
		Shared.createLight(roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0), room, 0.3, Color3.fromRGB(200, 220, 255))

		-- Waypoint
		table.insert(waypoints, { position = roomPos + Vector3.new(0, 3, 0), roomId = "Restrooms", dwellTime = 2 })

		-- Loot
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = roomPos + Vector3.new(2, 3.5, 3), chance = 0.3, guaranteed = false }
		)
	end

	--------------------------------------------------------------------
	-- Stairwell (connecting GF to Basement and Upper Floor)
	--------------------------------------------------------------------
	do
		-- Stairs down to basement
		Shared.createStairwell(
			-12, -- basement floor
			FLOOR_Y,
			Vector3.new(0, 0, 5),
			floorModel,
			"Stairwell_GF_to_Basement"
		)

		-- Stairs up to upper floor
		Shared.createStairwell(
			FLOOR_Y,
			13, -- upper floor
			Vector3.new(0, 0, 10),
			floorModel,
			"Stairwell_GF_to_Upper"
		)

		-- Stairwell waypoints
		table.insert(waypoints, { position = Vector3.new(0, FLOOR_Y + 3, 7), roomId = "Stairwell_GF", dwellTime = 1 })
	end

	floorModel.Parent = parent

	return {
		hidingSpots = hidingSpots,
		waypoints = waypoints,
		lootPositions = lootPositions,
	}
end

return GroundFloor
