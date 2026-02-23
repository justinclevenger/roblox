--!strict

--[[
	Roof (Level 1) - St. Maren's Hospital

	Helipad with painted H marking, radio beacon equipment,
	perimeter fence, and rooftop access door.

	Floor Y = 26. Open-air area. Final extraction point.
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

local ROOF_Y = 26

-- Muted rooftop colors
local COLOR_CONCRETE = Color3.fromRGB(130, 125, 120) -- weathered concrete
local COLOR_HELIPAD = Color3.fromRGB(110, 105, 100) -- darker helipad surface
local COLOR_H_MARKING = Color3.fromRGB(200, 180, 40) -- faded yellow H
local COLOR_FENCE = Color3.fromRGB(90, 90, 95) -- chain-link metal
local COLOR_METAL = Color3.fromRGB(120, 120, 125) -- equipment metal
local COLOR_ANTENNA = Color3.fromRGB(160, 30, 30) -- red beacon tip
local COLOR_STAIRWELL_HOUSING = Color3.fromRGB(140, 135, 128) -- concrete housing
local COLOR_WIRE = Color3.fromRGB(50, 50, 55) -- cables and wires
local COLOR_MOONLIGHT = Color3.fromRGB(180, 200, 220) -- cold ambient

-- Roof dimensions
local ROOF_EXTENT_X = 40 -- total width of roof
local ROOF_EXTENT_Z = 40 -- total depth of roof
local FENCE_HEIGHT = 6
local FENCE_THICKNESS = 0.3

------------------------------------------------------------------------
-- Helper: create a simple part
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
	part.Color = color or COLOR_CONCRETE
	part.Transparency = transparency or 0
	part.Material = material or Enum.Material.Concrete
	part.Parent = parent
	return part
end

------------------------------------------------------------------------
-- Build sections
------------------------------------------------------------------------

local function buildRoofSurface(parent: Instance)
	-- Main roof floor
	Shared.createFloor(Vector3.new(0, ROOF_Y, 0), Vector3.new(ROOF_EXTENT_X, 1, ROOF_EXTENT_Z), parent, "RoofFloor")

	-- Slight lip / raised edge around roof before fence
	local lipHeight = 1.5
	local lipThickness = 1

	-- North lip
	createPart(
		parent,
		"RoofLip_North",
		Vector3.new(0, ROOF_Y + lipHeight / 2, -ROOF_EXTENT_Z / 2 + lipThickness / 2),
		Vector3.new(ROOF_EXTENT_X, lipHeight, lipThickness),
		COLOR_CONCRETE,
		0,
		Enum.Material.Concrete
	)

	-- South lip
	createPart(
		parent,
		"RoofLip_South",
		Vector3.new(0, ROOF_Y + lipHeight / 2, ROOF_EXTENT_Z / 2 - lipThickness / 2),
		Vector3.new(ROOF_EXTENT_X, lipHeight, lipThickness),
		COLOR_CONCRETE,
		0,
		Enum.Material.Concrete
	)

	-- East lip
	createPart(
		parent,
		"RoofLip_East",
		Vector3.new(ROOF_EXTENT_X / 2 - lipThickness / 2, ROOF_Y + lipHeight / 2, 0),
		Vector3.new(lipThickness, lipHeight, ROOF_EXTENT_Z),
		COLOR_CONCRETE,
		0,
		Enum.Material.Concrete
	)

	-- West lip
	createPart(
		parent,
		"RoofLip_West",
		Vector3.new(-ROOF_EXTENT_X / 2 + lipThickness / 2, ROOF_Y + lipHeight / 2, 0),
		Vector3.new(lipThickness, lipHeight, ROOF_EXTENT_Z),
		COLOR_CONCRETE,
		0,
		Enum.Material.Concrete
	)
end

local function buildHelipad(parent: Instance)
	-- Helipad: large square landing pad with painted H marking
	local helipadPos = Vector3.new(0, ROOF_Y, 0)
	local helipadSize = Vector3.new(20, 0.15, 20)

	-- Helipad surface (slightly raised from roof)
	createPart(
		parent,
		"HelipadSurface",
		Vector3.new(helipadPos.X, ROOF_Y + 0.6, helipadPos.Z),
		helipadSize,
		COLOR_HELIPAD,
		0,
		Enum.Material.Concrete
	)

	-- Circle border (approximated with 8 angled parts forming an octagon)
	local circleRadius = 9
	local segmentCount = 12
	for i = 0, segmentCount - 1 do
		local angle = (i / segmentCount) * math.pi * 2
		local nextAngle = ((i + 1) / segmentCount) * math.pi * 2
		local midAngle = (angle + nextAngle) / 2

		local cx = helipadPos.X + math.cos(midAngle) * circleRadius
		local cz = helipadPos.Z + math.sin(midAngle) * circleRadius

		local segLength = 2 * circleRadius * math.sin(math.pi / segmentCount)
		local rotY = math.deg(-midAngle + math.pi / 2)

		local seg = createPart(
			parent,
			`HeliCircle_{i}`,
			Vector3.new(cx, ROOF_Y + 0.75, cz),
			Vector3.new(segLength + 0.2, 0.08, 0.4),
			COLOR_H_MARKING,
			0,
			Enum.Material.SmoothPlastic
		)
		seg.Orientation = Vector3.new(0, rotY, 0)
	end

	-- H marking (two vertical bars + one horizontal crossbar)
	local hY = ROOF_Y + 0.8
	local barThickness = 0.8
	local barLength = 6

	-- Left vertical bar of H
	createPart(
		parent,
		"H_LeftBar",
		Vector3.new(helipadPos.X - 2, hY, helipadPos.Z),
		Vector3.new(barThickness, 0.08, barLength),
		COLOR_H_MARKING,
		0,
		Enum.Material.SmoothPlastic
	)

	-- Right vertical bar of H
	createPart(
		parent,
		"H_RightBar",
		Vector3.new(helipadPos.X + 2, hY, helipadPos.Z),
		Vector3.new(barThickness, 0.08, barLength),
		COLOR_H_MARKING,
		0,
		Enum.Material.SmoothPlastic
	)

	-- Horizontal crossbar of H
	createPart(
		parent,
		"H_CrossBar",
		Vector3.new(helipadPos.X, hY, helipadPos.Z),
		Vector3.new(4.8, 0.08, barThickness),
		COLOR_H_MARKING,
		0,
		Enum.Material.SmoothPlastic
	)

	-- Corner landing lights (dim, non-functional without power)
	local cornerOffsets = {
		Vector3.new(-8, 0, -8),
		Vector3.new(8, 0, -8),
		Vector3.new(-8, 0, 8),
		Vector3.new(8, 0, 8),
	}

	for i, offset in cornerOffsets do
		local lightPos = helipadPos + offset + Vector3.new(0, 1.2, 0)
		createPart(
			parent,
			`HeliLight_Post_{i}`,
			Vector3.new(lightPos.X, ROOF_Y + 0.8, lightPos.Z),
			Vector3.new(0.4, 1.2, 0.4),
			COLOR_METAL,
			0,
			Enum.Material.Metal
		)

		createPart(
			parent,
			`HeliLight_Bulb_{i}`,
			Vector3.new(lightPos.X, ROOF_Y + 1.5, lightPos.Z),
			Vector3.new(0.6, 0.3, 0.6),
			Color3.fromRGB(80, 60, 40),
			0.2,
			Enum.Material.Neon
		)
		-- Lights are off (no power yet)
	end
end

local function buildBeacon(parent: Instance)
	-- Radio beacon / extraction equipment near helipad
	local beaconPos = Vector3.new(5, ROOF_Y, 5)

	-- Equipment table base
	createPart(
		parent,
		"BeaconTable",
		Vector3.new(beaconPos.X, ROOF_Y + 1.2, beaconPos.Z),
		Vector3.new(3, 1.5, 2),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)

	-- Radio unit (box on table)
	local radioBox = createPart(
		parent,
		"RadioUnit",
		Vector3.new(beaconPos.X - 0.3, ROOF_Y + 2.3, beaconPos.Z),
		Vector3.new(2, 1, 1.5),
		Color3.fromRGB(50, 55, 50),
		0,
		Enum.Material.Metal
	)

	-- Control panel face (lighter front)
	createPart(
		parent,
		"RadioPanel",
		Vector3.new(beaconPos.X - 0.3, ROOF_Y + 2.3, beaconPos.Z - 0.8),
		Vector3.new(1.8, 0.8, 0.05),
		Color3.fromRGB(60, 65, 60),
		0,
		Enum.Material.SmoothPlastic
	)

	-- Indicator lights on panel (small colored parts, off)
	createPart(
		parent,
		"Indicator_Red",
		Vector3.new(beaconPos.X - 0.8, ROOF_Y + 2.5, beaconPos.Z - 0.85),
		Vector3.new(0.2, 0.2, 0.05),
		Color3.fromRGB(100, 30, 30),
		0,
		Enum.Material.Neon
	)

	createPart(
		parent,
		"Indicator_Green",
		Vector3.new(beaconPos.X - 0.4, ROOF_Y + 2.5, beaconPos.Z - 0.85),
		Vector3.new(0.2, 0.2, 0.05),
		Color3.fromRGB(30, 60, 30),
		0,
		Enum.Material.Neon
	)

	-- Antenna mast
	local antennaBase = Vector3.new(beaconPos.X + 1, ROOF_Y, beaconPos.Z)
	createPart(
		parent,
		"AntennaMast",
		Vector3.new(antennaBase.X, ROOF_Y + 5, antennaBase.Z),
		Vector3.new(0.3, 10, 0.3),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)

	-- Antenna top (red beacon tip)
	createPart(
		parent,
		"AntennaTop",
		Vector3.new(antennaBase.X, ROOF_Y + 10.2, antennaBase.Z),
		Vector3.new(0.5, 0.4, 0.5),
		COLOR_ANTENNA,
		0,
		Enum.Material.Neon
	)

	-- Guy wires (thin diagonal supports)
	local wirePositions = {
		{
			from = Vector3.new(antennaBase.X, ROOF_Y + 8, antennaBase.Z),
			to = Vector3.new(antennaBase.X + 3, ROOF_Y + 0.5, antennaBase.Z + 3),
		},
		{
			from = Vector3.new(antennaBase.X, ROOF_Y + 8, antennaBase.Z),
			to = Vector3.new(antennaBase.X - 3, ROOF_Y + 0.5, antennaBase.Z + 3),
		},
		{
			from = Vector3.new(antennaBase.X, ROOF_Y + 8, antennaBase.Z),
			to = Vector3.new(antennaBase.X, ROOF_Y + 0.5, antennaBase.Z - 3),
		},
	}

	for i, wire in wirePositions do
		local midPoint = (wire.from + wire.to) / 2
		local diff = wire.to - wire.from
		local length = diff.Magnitude

		local wirePart = createPart(
			parent,
			`GuyWire_{i}`,
			midPoint,
			Vector3.new(0.08, length, 0.08),
			COLOR_WIRE,
			0,
			Enum.Material.Metal
		)

		-- Orient wire to point from -> to
		wirePart.CFrame = CFrame.lookAt(midPoint, midPoint + diff) * CFrame.Angles(math.rad(90), 0, 0)
	end

	-- Cable coil on ground near equipment
	createPart(
		parent,
		"CableCoil",
		Vector3.new(beaconPos.X - 2, ROOF_Y + 0.6, beaconPos.Z + 1),
		Vector3.new(1, 0.5, 1),
		COLOR_WIRE,
		0,
		Enum.Material.Fabric
	)

	-- ProximityPrompt to activate beacon
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Activate Beacon"
	prompt.ObjectText = "Emergency Beacon"
	prompt.MaxActivationDistance = 8
	prompt.HoldDuration = 2
	prompt.RequiresLineOfSight = true
	prompt.Enabled = false -- Disabled until generator powers up
	prompt.Parent = radioBox
end

local function buildFence(parent: Instance)
	-- Chain-link perimeter fence around the roof edge
	local fenceInset = 1.5 -- distance inward from roof edge
	local halfX = ROOF_EXTENT_X / 2 - fenceInset
	local halfZ = ROOF_EXTENT_Z / 2 - fenceInset
	local fenceY = ROOF_Y + FENCE_HEIGHT / 2 + 1.5 -- above lip

	-- North fence
	createPart(
		parent,
		"Fence_North",
		Vector3.new(0, fenceY, -halfZ),
		Vector3.new(ROOF_EXTENT_X - fenceInset * 2, FENCE_HEIGHT, FENCE_THICKNESS),
		COLOR_FENCE,
		0.4,
		Enum.Material.Metal
	)

	-- South fence
	createPart(
		parent,
		"Fence_South",
		Vector3.new(0, fenceY, halfZ),
		Vector3.new(ROOF_EXTENT_X - fenceInset * 2, FENCE_HEIGHT, FENCE_THICKNESS),
		COLOR_FENCE,
		0.4,
		Enum.Material.Metal
	)

	-- East fence
	createPart(
		parent,
		"Fence_East",
		Vector3.new(halfX, fenceY, 0),
		Vector3.new(FENCE_THICKNESS, FENCE_HEIGHT, ROOF_EXTENT_Z - fenceInset * 2),
		COLOR_FENCE,
		0.4,
		Enum.Material.Metal
	)

	-- West fence
	createPart(
		parent,
		"Fence_West",
		Vector3.new(-halfX, fenceY, 0),
		Vector3.new(FENCE_THICKNESS, FENCE_HEIGHT, ROOF_EXTENT_Z - fenceInset * 2),
		COLOR_FENCE,
		0.4,
		Enum.Material.Metal
	)

	-- Fence posts at corners (solid metal poles)
	local corners = {
		Vector3.new(-halfX, fenceY, -halfZ),
		Vector3.new(halfX, fenceY, -halfZ),
		Vector3.new(-halfX, fenceY, halfZ),
		Vector3.new(halfX, fenceY, halfZ),
	}

	for i, cornerPos in corners do
		createPart(
			parent,
			`FencePost_{i}`,
			cornerPos,
			Vector3.new(0.4, FENCE_HEIGHT + 0.5, 0.4),
			COLOR_FENCE,
			0,
			Enum.Material.Metal
		)
	end

	-- Mid-span posts on each side
	local midPosts = {
		Vector3.new(0, fenceY, -halfZ),
		Vector3.new(0, fenceY, halfZ),
		Vector3.new(-halfX, fenceY, 0),
		Vector3.new(halfX, fenceY, 0),
	}

	for i, midPos in midPosts do
		createPart(
			parent,
			`FenceMidPost_{i}`,
			midPos,
			Vector3.new(0.35, FENCE_HEIGHT + 0.3, 0.35),
			COLOR_FENCE,
			0,
			Enum.Material.Metal
		)
	end

	-- Razor wire along fence top (thin jagged strip)
	local razorY = fenceY + FENCE_HEIGHT / 2 + 0.3

	createPart(
		parent,
		"RazorWire_North",
		Vector3.new(0, razorY, -halfZ),
		Vector3.new(ROOF_EXTENT_X - fenceInset * 2, 0.4, 0.4),
		Color3.fromRGB(150, 145, 140),
		0.2,
		Enum.Material.Metal
	)

	createPart(
		parent,
		"RazorWire_South",
		Vector3.new(0, razorY, halfZ),
		Vector3.new(ROOF_EXTENT_X - fenceInset * 2, 0.4, 0.4),
		Color3.fromRGB(150, 145, 140),
		0.2,
		Enum.Material.Metal
	)

	createPart(
		parent,
		"RazorWire_East",
		Vector3.new(halfX, razorY, 0),
		Vector3.new(0.4, 0.4, ROOF_EXTENT_Z - fenceInset * 2),
		Color3.fromRGB(150, 145, 140),
		0.2,
		Enum.Material.Metal
	)

	createPart(
		parent,
		"RazorWire_West",
		Vector3.new(-halfX, razorY, 0),
		Vector3.new(0.4, 0.4, ROOF_EXTENT_Z - fenceInset * 2),
		Color3.fromRGB(150, 145, 140),
		0.2,
		Enum.Material.Metal
	)
end

local function buildStairwellAccess(parent: Instance)
	-- Rooftop access structure (small housing over stairwell exit)
	local housingPos = Vector3.new(-12, ROOF_Y, -12)
	local housingSize = Vector3.new(8, 10, 8)

	-- Housing walls
	createPart(
		parent,
		"StairHousing_North",
		Vector3.new(housingPos.X, ROOF_Y + housingSize.Y / 2, housingPos.Z - housingSize.Z / 2),
		Vector3.new(housingSize.X, housingSize.Y, 1),
		COLOR_STAIRWELL_HOUSING,
		0,
		Enum.Material.Concrete
	)

	createPart(
		parent,
		"StairHousing_South",
		Vector3.new(housingPos.X, ROOF_Y + housingSize.Y / 2, housingPos.Z + housingSize.Z / 2),
		Vector3.new(housingSize.X, housingSize.Y, 1),
		COLOR_STAIRWELL_HOUSING,
		0,
		Enum.Material.Concrete
	)

	createPart(
		parent,
		"StairHousing_East",
		Vector3.new(housingPos.X + housingSize.X / 2, ROOF_Y + housingSize.Y / 2, housingPos.Z),
		Vector3.new(1, housingSize.Y, housingSize.Z),
		COLOR_STAIRWELL_HOUSING,
		0,
		Enum.Material.Concrete
	)

	-- West wall has doorway opening
	-- Left portion of west wall
	createPart(
		parent,
		"StairHousing_WestLeft",
		Vector3.new(housingPos.X - housingSize.X / 2, ROOF_Y + housingSize.Y / 2, housingPos.Z - 2.5),
		Vector3.new(1, housingSize.Y, 3),
		COLOR_STAIRWELL_HOUSING,
		0,
		Enum.Material.Concrete
	)

	-- Right portion of west wall
	createPart(
		parent,
		"StairHousing_WestRight",
		Vector3.new(housingPos.X - housingSize.X / 2, ROOF_Y + housingSize.Y / 2, housingPos.Z + 2.5),
		Vector3.new(1, housingSize.Y, 3),
		COLOR_STAIRWELL_HOUSING,
		0,
		Enum.Material.Concrete
	)

	-- Above door portion
	createPart(
		parent,
		"StairHousing_WestAbove",
		Vector3.new(housingPos.X - housingSize.X / 2, ROOF_Y + 9, housingPos.Z),
		Vector3.new(1, 2, 2),
		COLOR_STAIRWELL_HOUSING,
		0,
		Enum.Material.Concrete
	)

	-- Ceiling of housing
	createPart(
		parent,
		"StairHousing_Ceiling",
		Vector3.new(housingPos.X, ROOF_Y + housingSize.Y + 0.5, housingPos.Z),
		Vector3.new(housingSize.X + 1, 1, housingSize.Z + 1),
		COLOR_STAIRWELL_HOUSING,
		0,
		Enum.Material.Concrete
	)

	-- Rooftop access door (locked until generator powers up)
	local DOOR_HEIGHT = 8
	local doorPos = Vector3.new(housingPos.X - housingSize.X / 2, ROOF_Y + DOOR_HEIGHT / 2, housingPos.Z)
	Shared.createDoor(
		doorPos,
		CFrame.Angles(0, math.rad(90), 0),
		parent,
		"Door_RoofAccess",
		true,
		"GeneratorPower" -- Special key: unlocked when generator is running
	)

	-- Interior light (dim)
	Shared.createLight(Vector3.new(housingPos.X, ROOF_Y + housingSize.Y - 1, housingPos.Z), parent, 0.15)

	-- Stairwell going down (connecting to upper floor)
	Shared.createStairwell(13, ROOF_Y, Vector3.new(housingPos.X, 0, housingPos.Z), parent, "Stairwell_UpperToRoof")
end

local function buildRooftopDetails(parent: Instance)
	-- HVAC units (large metal boxes scattered on roof)
	local hvacPositions = {
		{ pos = Vector3.new(14, ROOF_Y + 2, -14), size = Vector3.new(4, 4, 3) },
		{ pos = Vector3.new(-14, ROOF_Y + 1.5, 10), size = Vector3.new(3, 3, 4) },
		{ pos = Vector3.new(12, ROOF_Y + 2.5, 14), size = Vector3.new(5, 5, 3) },
	}

	for i, hvac in hvacPositions do
		createPart(parent, `HVAC_{i}`, hvac.pos, hvac.size, COLOR_METAL, 0, Enum.Material.Metal)

		-- Fan grille on top
		createPart(
			parent,
			`HVAC_Grille_{i}`,
			Vector3.new(hvac.pos.X, hvac.pos.Y + hvac.size.Y / 2 + 0.1, hvac.pos.Z),
			Vector3.new(hvac.size.X - 0.5, 0.1, hvac.size.Z - 0.5),
			Color3.fromRGB(70, 70, 75),
			0.3,
			Enum.Material.Metal
		)
	end

	-- Ventilation pipes
	createPart(
		parent,
		"VentPipe_1",
		Vector3.new(14, ROOF_Y + 5, -14),
		Vector3.new(0.8, 3, 0.8),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)

	createPart(
		parent,
		"VentPipe_2",
		Vector3.new(12, ROOF_Y + 6, 14),
		Vector3.new(0.8, 3.5, 0.8),
		COLOR_METAL,
		0,
		Enum.Material.Metal
	)

	-- Ambient moonlight across the roof
	Shared.createLight(Vector3.new(0, ROOF_Y + 15, 0), parent, 0.5, COLOR_MOONLIGHT)
	Shared.createLight(Vector3.new(-10, ROOF_Y + 12, -10), parent, 0.3, COLOR_MOONLIGHT)
	Shared.createLight(Vector3.new(10, ROOF_Y + 12, 10), parent, 0.3, COLOR_MOONLIGHT)

	-- Scattered debris: old crate, tarp
	createPart(
		parent,
		"OldCrate",
		Vector3.new(-8, ROOF_Y + 1, 5),
		Vector3.new(2, 2, 2),
		Color3.fromRGB(100, 80, 55),
		0,
		Enum.Material.Wood
	)

	local tarp = createPart(
		parent,
		"Tarp",
		Vector3.new(-6, ROOF_Y + 0.3, 7),
		Vector3.new(4, 0.1, 3),
		Color3.fromRGB(60, 80, 60),
		0,
		Enum.Material.Fabric
	)
	tarp.Orientation = Vector3.new(3, 15, -2) -- slightly rumpled
end

------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------

local Roof = {}

function Roof.build(parent: Instance): FloorData
	local roofModel = Instance.new("Model")
	roofModel.Name = "Roof"
	roofModel.Parent = parent

	local hidingSpots: { HidingSpotData } = {}
	local waypoints: { { position: Vector3, roomId: string, dwellTime: number } } = {}
	local lootPositions: { { itemType: string, position: Vector3, chance: number, guaranteed: boolean } } = {}

	-- Build all sections
	buildRoofSurface(roofModel)
	buildHelipad(roofModel)
	buildBeacon(roofModel)
	buildFence(roofModel)
	buildStairwellAccess(roofModel)
	buildRooftopDetails(roofModel)

	-- No hiding spots on roof (open area, exposed)

	-- Patrol waypoints around helipad
	table.insert(waypoints, {
		position = Vector3.new(-8, ROOF_Y + 3, -8),
		roomId = "Roof_NW",
		dwellTime = 3,
	})

	table.insert(waypoints, {
		position = Vector3.new(8, ROOF_Y + 3, -8),
		roomId = "Roof_NE",
		dwellTime = 3,
	})

	table.insert(waypoints, {
		position = Vector3.new(0, ROOF_Y + 3, 8),
		roomId = "Roof_South",
		dwellTime = 4,
	})

	-- Loot: small chance of battery near HVAC units
	table.insert(lootPositions, {
		itemType = "Battery",
		position = Vector3.new(14, ROOF_Y + 1, -12),
		chance = 0.3,
		guaranteed = false,
	})

	print(`[Roof] Built: {#hidingSpots} hiding spots, {#waypoints} waypoints, {#lootPositions} loot positions`)

	return {
		hidingSpots = hidingSpots,
		waypoints = waypoints,
		lootPositions = lootPositions,
	}
end

return Roof
