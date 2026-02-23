--!strict

--[[
	Hospital/Exterior - Builds the Exterior geometry for
	St. Maren's Hospital (Level 1).

	Areas: Ambulance Bay (player spawn), Courtyard, Fog Walls (boundary),
	       Hospital exterior shell.

	The exterior wraps the hospital building and provides the player spawn
	area (Ambulance Bay) and the back courtyard visible from upper floors.
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
local BUILDING_HEIGHT = 26 -- Ground floor + Upper floor + ceiling/roof
local FOG_WALL_HEIGHT = 40
local FOG_WALL_DISTANCE = 100

-- Exterior color palette
local EXTERIOR_WALL_COLOR = Color3.fromRGB(160, 155, 145) -- weathered concrete
local GROUND_COLOR = Color3.fromRGB(80, 85, 70) -- dark asphalt/ground
local AMBULANCE_BAY_COLOR = Color3.fromRGB(100, 100, 95) -- pavement
local COURTYARD_GRASS = Color3.fromRGB(60, 75, 50) -- dead/dark grass
local FOG_COLOR = Color3.fromRGB(40, 40, 45) -- near-black fog boundary

------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------

local Exterior = {}

function Exterior.build(parent: Instance): FloorData
	local hidingSpots: { HidingSpotData } = {}
	local waypoints: { { position: Vector3, roomId: string, dwellTime: number } } = {}
	local lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } } = {}

	local exteriorModel = Instance.new("Model")
	exteriorModel.Name = "Exterior"

	--------------------------------------------------------------------
	-- Hospital Exterior Walls (outer shell of the building)
	--------------------------------------------------------------------
	do
		local shellModel = Instance.new("Model")
		shellModel.Name = "BuildingShell"

		-- The hospital footprint is roughly X: -40 to 50, Z: -50 to 30
		-- These are the outer walls that define the building from outside.
		local shellThickness = 1.5
		local shellHeight = BUILDING_HEIGHT

		-- Approximate bounding box of the hospital interior:
		-- X: -38 to 43, Z: -48 to 27
		local minX = -40
		local maxX = 50
		local minZ = -50
		local maxZ = 30
		local centerY = FLOOR_Y + shellHeight / 2

		-- North wall (front of hospital, facing ambulance bay)
		Shared.createWall(
			Vector3.new((minX + maxX) / 2, centerY, minZ - shellThickness / 2),
			Vector3.new(maxX - minX + shellThickness * 2, shellHeight, shellThickness),
			shellModel,
			"ExteriorWall_North"
		).Color =
			EXTERIOR_WALL_COLOR

		-- South wall (back, facing courtyard)
		Shared.createWall(
			Vector3.new((minX + maxX) / 2, centerY, maxZ + shellThickness / 2),
			Vector3.new(maxX - minX + shellThickness * 2, shellHeight, shellThickness),
			shellModel,
			"ExteriorWall_South"
		).Color =
			EXTERIOR_WALL_COLOR

		-- West wall
		Shared.createWall(
			Vector3.new(minX - shellThickness / 2, centerY, (minZ + maxZ) / 2),
			Vector3.new(shellThickness, shellHeight, maxZ - minZ),
			shellModel,
			"ExteriorWall_West"
		).Color =
			EXTERIOR_WALL_COLOR

		-- East wall
		Shared.createWall(
			Vector3.new(maxX + shellThickness / 2, centerY, (minZ + maxZ) / 2),
			Vector3.new(shellThickness, shellHeight, maxZ - minZ),
			shellModel,
			"ExteriorWall_East"
		).Color =
			EXTERIOR_WALL_COLOR

		-- Main entrance opening (cut in north wall)
		-- The entrance is at X=0, Z=-50; we place door frame pieces
		local entranceWidth = 8
		local entranceHeight = 10

		-- Overhang / canopy above entrance
		local canopy = Instance.new("Part")
		canopy.Name = "EntranceCanopy"
		canopy.Size = Vector3.new(entranceWidth + 4, 0.5, 6)
		canopy.Position = Vector3.new(0, FLOOR_Y + entranceHeight + 0.5, minZ - 3)
		canopy.Anchored = true
		canopy.Material = Enum.Material.Concrete
		canopy.Color = Color3.fromRGB(150, 145, 138)
		canopy.Parent = shellModel

		-- Canopy support columns
		for _, xOff in { -entranceWidth / 2 - 1, entranceWidth / 2 + 1 } do
			local column = Instance.new("Part")
			column.Name = "CanopyColumn"
			column.Size = Vector3.new(1.5, entranceHeight, 1.5)
			column.Position = Vector3.new(xOff, FLOOR_Y + entranceHeight / 2, minZ - 5)
			column.Anchored = true
			column.Material = Enum.Material.Concrete
			column.Color = EXTERIOR_WALL_COLOR
			column.Parent = shellModel
		end

		-- Roof slab
		local roof = Instance.new("Part")
		roof.Name = "Roof"
		roof.Size = Vector3.new(maxX - minX + shellThickness * 2, 1, maxZ - minZ + shellThickness * 2)
		roof.Position = Vector3.new((minX + maxX) / 2, FLOOR_Y + shellHeight + 0.5, (minZ + maxZ) / 2)
		roof.Anchored = true
		roof.Material = Enum.Material.Concrete
		roof.Color = Color3.fromRGB(130, 125, 120)
		roof.Parent = shellModel

		shellModel.Parent = exteriorModel
	end

	--------------------------------------------------------------------
	-- Ambulance Bay (Player Spawn Area)
	--------------------------------------------------------------------
	do
		local bayPos = Vector3.new(0, FLOOR_Y, -70)
		local bayModel = Instance.new("Model")
		bayModel.Name = "AmbulanceBay"

		-- Pavement / ground slab
		local pavement = Shared.createFloor(
			Vector3.new(bayPos.X, bayPos.Y - 0.5, bayPos.Z),
			Vector3.new(24, 1, 16),
			bayModel,
			"Pavement"
		)
		pavement.Material = Enum.Material.Concrete
		pavement.Color = AMBULANCE_BAY_COLOR

		-- Connecting pavement to hospital entrance
		local walkway =
			Shared.createFloor(Vector3.new(0, FLOOR_Y - 0.5, -60), Vector3.new(10, 1, 20), bayModel, "Walkway")
		walkway.Material = Enum.Material.Concrete
		walkway.Color = AMBULANCE_BAY_COLOR

		-- Ambulance model (simplified box vehicle)
		local ambModel = Instance.new("Model")
		ambModel.Name = "Ambulance"

		-- Body
		local ambBody = Instance.new("Part")
		ambBody.Name = "Body"
		ambBody.Size = Vector3.new(6, 5, 14)
		ambBody.Position = bayPos + Vector3.new(-7, 2.5, 0)
		ambBody.Anchored = true
		ambBody.Material = Enum.Material.SmoothPlastic
		ambBody.Color = Color3.fromRGB(200, 200, 195)
		ambBody.Parent = ambModel

		-- Cab
		local ambCab = Instance.new("Part")
		ambCab.Name = "Cab"
		ambCab.Size = Vector3.new(6, 3.5, 5)
		ambCab.Position = bayPos + Vector3.new(-7, 2, -6)
		ambCab.Anchored = true
		ambCab.Material = Enum.Material.SmoothPlastic
		ambCab.Color = Color3.fromRGB(200, 200, 195)
		ambCab.Parent = ambModel

		-- Red stripe
		local stripe = Instance.new("Part")
		stripe.Name = "Stripe"
		stripe.Size = Vector3.new(0.1, 1, 12)
		stripe.Position = bayPos + Vector3.new(-4, 3, -1)
		stripe.Anchored = true
		stripe.Material = Enum.Material.SmoothPlastic
		stripe.Color = Color3.fromRGB(180, 40, 40)
		stripe.Parent = ambModel

		-- Wheels (simple dark cylinders)
		for _, offset in
			{
				Vector3.new(-4.5, 0.8, -4),
				Vector3.new(-4.5, 0.8, 4),
				Vector3.new(-9.5, 0.8, -4),
				Vector3.new(-9.5, 0.8, 4),
			}
		do
			local wheel = Instance.new("Part")
			wheel.Name = "Wheel"
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Size = Vector3.new(1, 1.5, 1.5)
			wheel.Position = bayPos + offset
			wheel.Anchored = true
			wheel.Material = Enum.Material.SmoothPlastic
			wheel.Color = Color3.fromRGB(30, 30, 30)
			wheel.Parent = ambModel
		end

		-- Light bar on top (red/blue)
		local lightBar = Instance.new("Part")
		lightBar.Name = "LightBar"
		lightBar.Size = Vector3.new(4, 0.5, 2)
		lightBar.Position = bayPos + Vector3.new(-7, 5.25, 0)
		lightBar.Anchored = true
		lightBar.Material = Enum.Material.Neon
		lightBar.Color = Color3.fromRGB(180, 40, 40)
		lightBar.Parent = ambModel

		ambModel.Parent = bayModel

		-- Spawn point marker
		local spawnPart = Instance.new("Part")
		spawnPart.Name = "SpawnPoint"
		spawnPart.Size = Vector3.new(4, 0.1, 4)
		spawnPart.Position = Vector3.new(0, FLOOR_Y + 0.05, -70)
		spawnPart.Anchored = true
		spawnPart.Transparency = 1
		spawnPart.CanCollide = false
		spawnPart.Parent = bayModel

		-- SpawnLocation for initial player spawn
		local spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "PlayerSpawn"
		spawnLocation.Size = Vector3.new(6, 1, 6)
		spawnLocation.Position = Vector3.new(0, FLOOR_Y - 0.5, -70)
		spawnLocation.Anchored = true
		spawnLocation.Material = Enum.Material.Concrete
		spawnLocation.Color = AMBULANCE_BAY_COLOR
		spawnLocation.Enabled = true
		spawnLocation.Neutral = true
		spawnLocation.Parent = bayModel

		-- Exterior lamp near ambulance bay
		Shared.createLight(bayPos + Vector3.new(8, 10, 0), bayModel, 0.6, Color3.fromRGB(255, 240, 200))

		-- Waypoint
		table.insert(waypoints, { position = bayPos + Vector3.new(0, 3, 0), roomId = "AmbulanceBay", dwellTime = 2 })

		-- Loot (guaranteed starter items near ambulance)
		table.insert(
			lootPositions,
			{ itemType = "Battery", position = bayPos + Vector3.new(3, 0.5, 2), chance = 1, guaranteed = true }
		)
		table.insert(
			lootPositions,
			{ itemType = "Bandage", position = bayPos + Vector3.new(5, 0.5, -2), chance = 1, guaranteed = true }
		)

		bayModel.Parent = exteriorModel
	end

	--------------------------------------------------------------------
	-- Courtyard (behind hospital)
	--------------------------------------------------------------------
	do
		local courtPos = Vector3.new(0, FLOOR_Y, 40)
		local courtModel = Instance.new("Model")
		courtModel.Name = "Courtyard"

		-- Grass/ground area
		local ground = Shared.createFloor(
			Vector3.new(courtPos.X, courtPos.Y - 0.5, courtPos.Z),
			Vector3.new(25, 1, 20),
			courtModel,
			"CourtyardGround"
		)
		ground.Material = Enum.Material.Grass
		ground.Color = COURTYARD_GRASS

		-- Paved walkway through center
		local path = Shared.createFloor(
			Vector3.new(courtPos.X, courtPos.Y - 0.45, courtPos.Z),
			Vector3.new(4, 0.1, 18),
			courtModel,
			"Pathway"
		)
		path.Material = Enum.Material.Concrete
		path.Color = Color3.fromRGB(110, 108, 100)

		-- Bench (simple)
		local benchSeat = Instance.new("Part")
		benchSeat.Name = "BenchSeat"
		benchSeat.Size = Vector3.new(6, 0.4, 2)
		benchSeat.Position = courtPos + Vector3.new(6, 1.8, 0)
		benchSeat.Anchored = true
		benchSeat.Material = Enum.Material.Wood
		benchSeat.Color = Color3.fromRGB(80, 55, 40)
		benchSeat.Parent = courtModel

		local benchBack = Instance.new("Part")
		benchBack.Name = "BenchBack"
		benchBack.Size = Vector3.new(6, 1.5, 0.4)
		benchBack.Position = courtPos + Vector3.new(6, 2.8, -0.8)
		benchBack.Anchored = true
		benchBack.Material = Enum.Material.Wood
		benchBack.Color = Color3.fromRGB(80, 55, 40)
		benchBack.Parent = courtModel

		-- Bench legs
		for _, xOff in { -2.5, 2.5 } do
			local leg = Instance.new("Part")
			leg.Name = "BenchLeg"
			leg.Size = Vector3.new(0.4, 1.8, 2)
			leg.Position = courtPos + Vector3.new(6 + xOff, 0.9, 0)
			leg.Anchored = true
			leg.Material = Enum.Material.Metal
			leg.Color = Color3.fromRGB(60, 60, 55)
			leg.Parent = courtModel
		end

		-- Non-functional fountain (stone basin)
		local fountainBase = Instance.new("Part")
		fountainBase.Name = "FountainBase"
		fountainBase.Size = Vector3.new(6, 1, 6)
		fountainBase.Position = courtPos + Vector3.new(-5, 0.5, 0)
		fountainBase.Anchored = true
		fountainBase.Material = Enum.Material.Slate
		fountainBase.Color = Color3.fromRGB(120, 115, 110)
		fountainBase.Parent = courtModel

		local fountainBowl = Instance.new("Part")
		fountainBowl.Name = "FountainBowl"
		fountainBowl.Size = Vector3.new(5, 0.5, 5)
		fountainBowl.Position = courtPos + Vector3.new(-5, 1.25, 0)
		fountainBowl.Anchored = true
		fountainBowl.Material = Enum.Material.Slate
		fountainBowl.Color = Color3.fromRGB(110, 105, 100)
		fountainBowl.Parent = courtModel

		-- Stagnant water in fountain
		local water = Instance.new("Part")
		water.Name = "StagnantWater"
		water.Size = Vector3.new(4.5, 0.1, 4.5)
		water.Position = courtPos + Vector3.new(-5, 1.55, 0)
		water.Anchored = true
		water.Material = Enum.Material.Glass
		water.Color = Color3.fromRGB(50, 70, 50)
		water.Transparency = 0.4
		water.CanCollide = false
		water.Parent = courtModel

		-- Fountain center pillar
		local pillar = Instance.new("Part")
		pillar.Name = "FountainPillar"
		pillar.Size = Vector3.new(1, 3, 1)
		pillar.Position = courtPos + Vector3.new(-5, 2.5, 0)
		pillar.Anchored = true
		pillar.Material = Enum.Material.Slate
		pillar.Color = Color3.fromRGB(105, 100, 95)
		pillar.Parent = courtModel

		-- Dead trees (tall dark brown cylinders)
		for _, offset in { Vector3.new(10, 0, 6), Vector3.new(-10, 0, -5) } do
			local trunk = Instance.new("Part")
			trunk.Name = "DeadTree"
			trunk.Shape = Enum.PartType.Cylinder
			trunk.Size = Vector3.new(8, 1.5, 1.5)
			trunk.Position = courtPos + offset + Vector3.new(0, 4, 0)
			trunk.Orientation = Vector3.new(0, 0, 90)
			trunk.Anchored = true
			trunk.Material = Enum.Material.Wood
			trunk.Color = Color3.fromRGB(50, 35, 25)
			trunk.Parent = courtModel

			-- Bare branches (thin parts at angles)
			for b = 1, 3 do
				local branch = Instance.new("Part")
				branch.Name = `Branch_{b}`
				branch.Size = Vector3.new(0.3, 3, 0.3)
				branch.Position = courtPos + offset + Vector3.new(math.random(-2, 2), 6 + b, math.random(-2, 2))
				branch.Orientation = Vector3.new(math.random(-30, 30), math.random(0, 360), math.random(-30, 30))
				branch.Anchored = true
				branch.Material = Enum.Material.Wood
				branch.Color = Color3.fromRGB(45, 30, 20)
				branch.Parent = courtModel
			end
		end

		-- Dim exterior light
		Shared.createLight(courtPos + Vector3.new(0, 8, 0), courtModel, 0.2, Color3.fromRGB(200, 210, 230))

		-- Waypoint (entity can patrol here if it exits the building)
		table.insert(waypoints, { position = courtPos + Vector3.new(0, 3, 0), roomId = "Courtyard", dwellTime = 5 })

		courtModel.Parent = exteriorModel
	end

	--------------------------------------------------------------------
	-- Fog Walls (invisible boundary)
	--------------------------------------------------------------------
	do
		local fogModel = Instance.new("Model")
		fogModel.Name = "FogWalls"

		-- Create invisible walls forming a perimeter around the hospital
		local walls = {
			-- North
			{
				pos = Vector3.new(0, FOG_WALL_HEIGHT / 2 - 10, -FOG_WALL_DISTANCE),
				size = Vector3.new(FOG_WALL_DISTANCE * 2, FOG_WALL_HEIGHT, 2),
				name = "FogWall_North",
			},
			-- South
			{
				pos = Vector3.new(0, FOG_WALL_HEIGHT / 2 - 10, FOG_WALL_DISTANCE),
				size = Vector3.new(FOG_WALL_DISTANCE * 2, FOG_WALL_HEIGHT, 2),
				name = "FogWall_South",
			},
			-- West
			{
				pos = Vector3.new(-FOG_WALL_DISTANCE, FOG_WALL_HEIGHT / 2 - 10, 0),
				size = Vector3.new(2, FOG_WALL_HEIGHT, FOG_WALL_DISTANCE * 2),
				name = "FogWall_West",
			},
			-- East
			{
				pos = Vector3.new(FOG_WALL_DISTANCE, FOG_WALL_HEIGHT / 2 - 10, 0),
				size = Vector3.new(2, FOG_WALL_HEIGHT, FOG_WALL_DISTANCE * 2),
				name = "FogWall_East",
			},
		}

		for _, wallDef in walls do
			local wall = Instance.new("Part")
			wall.Name = wallDef.name
			wall.Size = wallDef.size
			wall.Position = wallDef.pos
			wall.Anchored = true
			wall.Transparency = 1
			wall.CanCollide = true
			wall.Material = Enum.Material.SmoothPlastic
			wall.Color = FOG_COLOR
			wall.Parent = fogModel
		end

		fogModel.Parent = exteriorModel
	end

	--------------------------------------------------------------------
	-- Ground plane (dark surface extending beyond the hospital)
	--------------------------------------------------------------------
	do
		local groundPlane = Instance.new("Part")
		groundPlane.Name = "GroundPlane"
		groundPlane.Size = Vector3.new(FOG_WALL_DISTANCE * 2, 1, FOG_WALL_DISTANCE * 2)
		groundPlane.Position = Vector3.new(0, FLOOR_Y - 1, 0)
		groundPlane.Anchored = true
		groundPlane.Material = Enum.Material.Grass
		groundPlane.Color = GROUND_COLOR
		groundPlane.Parent = exteriorModel
	end

	--------------------------------------------------------------------
	-- Parking lot remnants (between ambulance bay and fog)
	--------------------------------------------------------------------
	do
		local parkingModel = Instance.new("Model")
		parkingModel.Name = "ParkingLot"

		-- Cracked asphalt
		local asphalt = Shared.createFloor(
			Vector3.new(20, FLOOR_Y - 0.5, -70),
			Vector3.new(20, 1, 20),
			parkingModel,
			"ParkingAsphalt"
		)
		asphalt.Material = Enum.Material.Concrete
		asphalt.Color = Color3.fromRGB(70, 70, 65)

		-- Abandoned car (simple box)
		local carBody = Instance.new("Part")
		carBody.Name = "AbandonedCar_Body"
		carBody.Size = Vector3.new(6, 3.5, 12)
		carBody.Position = Vector3.new(22, FLOOR_Y + 1.75, -72)
		carBody.Anchored = true
		carBody.Material = Enum.Material.Metal
		carBody.Color = Color3.fromRGB(70, 80, 85)
		carBody.Parent = parkingModel

		-- Car roof (slightly smaller)
		local carRoof = Instance.new("Part")
		carRoof.Name = "AbandonedCar_Roof"
		carRoof.Size = Vector3.new(5.5, 2, 6)
		carRoof.Position = Vector3.new(22, FLOOR_Y + 4, -72)
		carRoof.Anchored = true
		carRoof.Material = Enum.Material.Metal
		carRoof.Color = Color3.fromRGB(65, 75, 80)
		carRoof.Parent = parkingModel

		-- Car wheels
		for _, offset in
			{
				Vector3.new(-2.5, 0.6, -4.5),
				Vector3.new(-2.5, 0.6, 4.5),
				Vector3.new(2.5, 0.6, -4.5),
				Vector3.new(2.5, 0.6, 4.5),
			}
		do
			local wheel = Instance.new("Part")
			wheel.Name = "Wheel"
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Size = Vector3.new(0.8, 1.2, 1.2)
			wheel.Position = Vector3.new(22, FLOOR_Y, -72) + offset
			wheel.Anchored = true
			wheel.Material = Enum.Material.SmoothPlastic
			wheel.Color = Color3.fromRGB(25, 25, 25)
			wheel.Parent = parkingModel
		end

		-- Parking line markings (faded)
		for i = 0, 3 do
			local line = Instance.new("Part")
			line.Name = `ParkingLine_{i}`
			line.Size = Vector3.new(0.2, 0.02, 6)
			line.Position = Vector3.new(14 + i * 4, FLOOR_Y + 0.01, -68)
			line.Anchored = true
			line.Material = Enum.Material.SmoothPlastic
			line.Color = Color3.fromRGB(150, 150, 130)
			line.Transparency = 0.5
			line.Parent = parkingModel
		end

		parkingModel.Parent = exteriorModel
	end

	exteriorModel.Parent = parent

	return {
		hidingSpots = hidingSpots,
		waypoints = waypoints,
		lootPositions = lootPositions,
	}
end

return Exterior
