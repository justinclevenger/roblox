--!strict

--[[
	Hub - The Safe Room between runs.

	A small, atmospheric physical space that serves as the player's home base.
	Contains interactive stations for level select, loadout, lore, cosmetics,
	matchmaking, and a door to enter the selected level.

	The room degrades visually as playerProgress increases (0-5), reflecting
	the narrative's escalating dread: lights flicker, walls crack, something
	scratches behind the walls by Level 4.

	Exports:
	  build(playerProgress: number?): Model
	  cleanup(model: Model)
]]

local Shared = require(script.Parent.Hospital.Shared)

local Hub = {}

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------

local ROOM_WIDTH = 20 -- X
local ROOM_HEIGHT = 12 -- Y
local ROOM_DEPTH = 15 -- Z
local WALL_THICKNESS = 1
local DOOR_WIDTH = 5
local DOOR_HEIGHT = 8

-- Level names displayed on the bulletin board cards
local LEVEL_NAMES: { string } = {
	"St. Maren's Hospital",
	"Line 13 Subway",
	"Blackpoint Station",
	"Ashwood Forest",
	"The Origin",
}

-- Level IDs (matching Constants.LEVELS)
local LEVEL_IDS: { string } = {
	"st-marens-hospital",
	"line-13-subway",
	"blackpoint-station",
	"ashwood-forest",
	"the-origin",
}

------------------------------------------------------------------------
-- Color Palettes
------------------------------------------------------------------------

type ColorPalette = {
	wall: Color3,
	floor: Color3,
	ceiling: Color3,
	wood: Color3,
	metal: Color3,
	lightColor: Color3,
	lightBrightness: number,
}

local function getPalette(progress: number): ColorPalette
	if progress <= 1 then
		-- Warm, clean, inviting
		return {
			wall = Color3.fromRGB(175, 155, 130),
			floor = Color3.fromRGB(130, 105, 80),
			ceiling = Color3.fromRGB(165, 150, 135),
			wood = Color3.fromRGB(120, 85, 55),
			metal = Color3.fromRGB(140, 135, 125),
			lightColor = Color3.fromRGB(255, 220, 170),
			lightBrightness = 0.8,
		}
	elseif progress == 2 then
		-- Slightly muted, first signs of trouble
		return {
			wall = Color3.fromRGB(155, 140, 120),
			floor = Color3.fromRGB(120, 95, 72),
			ceiling = Color3.fromRGB(150, 138, 125),
			wood = Color3.fromRGB(105, 75, 50),
			metal = Color3.fromRGB(130, 125, 118),
			lightColor = Color3.fromRGB(240, 210, 165),
			lightBrightness = 0.6,
		}
	elseif progress == 3 then
		-- Cooler, darker, visibly degraded
		return {
			wall = Color3.fromRGB(135, 125, 115),
			floor = Color3.fromRGB(100, 85, 65),
			ceiling = Color3.fromRGB(130, 122, 112),
			wood = Color3.fromRGB(90, 65, 45),
			metal = Color3.fromRGB(115, 110, 105),
			lightColor = Color3.fromRGB(220, 200, 165),
			lightBrightness = 0.4,
		}
	elseif progress == 4 then
		-- Cold, dim, oppressive
		return {
			wall = Color3.fromRGB(110, 105, 100),
			floor = Color3.fromRGB(80, 72, 60),
			ceiling = Color3.fromRGB(105, 100, 95),
			wood = Color3.fromRGB(75, 55, 40),
			metal = Color3.fromRGB(95, 90, 88),
			lightColor = Color3.fromRGB(180, 175, 160),
			lightBrightness = 0.25,
		}
	else
		-- Nearly destroyed — sickly, barely lit
		return {
			wall = Color3.fromRGB(85, 82, 78),
			floor = Color3.fromRGB(60, 55, 48),
			ceiling = Color3.fromRGB(80, 78, 72),
			wood = Color3.fromRGB(55, 42, 30),
			metal = Color3.fromRGB(75, 72, 68),
			lightColor = Color3.fromRGB(160, 140, 110),
			lightBrightness = 0.12,
		}
	end
end

------------------------------------------------------------------------
-- Helper: Wall Crack
------------------------------------------------------------------------

local function addCrack(position: Vector3, size: Vector3, parent: Instance, name: string)
	local crack = Instance.new("Part")
	crack.Name = name
	crack.Size = size
	crack.Position = position
	crack.Anchored = true
	crack.Material = Enum.Material.Slate
	crack.Color = Color3.fromRGB(30, 28, 25)
	crack.Parent = parent
end

------------------------------------------------------------------------
-- Helper: Flickering Light Script (attribute-driven)
------------------------------------------------------------------------

--[[
	Marks a light fixture for flickering. The client can read the
	"Flickering" attribute and the "FlickerIntensity" attribute to
	drive a visual flicker loop. On the server side we just tag it.
]]
local function markFlickering(fixture: Part, intensity: number)
	fixture:SetAttribute("Flickering", true)
	fixture:SetAttribute("FlickerIntensity", intensity)
end

--[[
	Marks a light fixture as dead (off). Disables the PointLight
	and darkens the fixture.
]]
local function killLight(fixture: Part)
	fixture:SetAttribute("LightDead", true)
	fixture.Color = Color3.fromRGB(60, 58, 55)
	fixture.Transparency = 0

	local pointLight = fixture:FindFirstChildOfClass("PointLight")
	if pointLight then
		pointLight.Enabled = false
	end
end

------------------------------------------------------------------------
-- Helper: Scratching Indicator (visual-only)
------------------------------------------------------------------------

--[[
	Places a subtle visual indicator that something is behind the wall:
	a thin, slightly offset Part that pulses (tagged via attribute).
]]
local function addScratchIndicator(position: Vector3, parent: Instance, name: string)
	local indicator = Instance.new("Part")
	indicator.Name = name
	indicator.Size = Vector3.new(3, 2, 0.15)
	indicator.Position = position
	indicator.Anchored = true
	indicator.Material = Enum.Material.Slate
	indicator.Color = Color3.fromRGB(40, 35, 30)
	indicator.Transparency = 0.6
	indicator.CanCollide = false
	indicator:SetAttribute("Scratching", true)
	indicator:SetAttribute("ScratchSpeed", 1.5)
	indicator.Parent = parent
end

------------------------------------------------------------------------
-- Build: Bulletin Board (North Wall) — Level Select
------------------------------------------------------------------------

local function buildBulletinBoard(roomPos: Vector3, progress: number, _palette: ColorPalette, parent: Instance): Model
	local board = Instance.new("Model")
	board.Name = "BulletinBoard"

	-- Board backing (cork board)
	local backing = Instance.new("Part")
	backing.Name = "BoardBacking"
	backing.Size = Vector3.new(12, 6, 0.4)
	-- North wall is at Z = roomPos.Z - ROOM_DEPTH/2
	-- Place board slightly in front of wall
	backing.Position = roomPos + Vector3.new(0, 7, -ROOM_DEPTH / 2 + WALL_THICKNESS + 0.3)
	backing.Anchored = true
	backing.Material = Enum.Material.WoodPlanks
	backing.Color = Color3.fromRGB(160, 120, 70)
	backing.Parent = board

	-- Frame around the board
	local frameColor = Color3.fromRGB(80, 60, 40)
	local frameThickness = 0.3

	-- Top frame
	local frameTop = Instance.new("Part")
	frameTop.Name = "Frame_Top"
	frameTop.Size = Vector3.new(12.6, frameThickness, 0.5)
	frameTop.Position = backing.Position + Vector3.new(0, 3.15, 0)
	frameTop.Anchored = true
	frameTop.Material = Enum.Material.Wood
	frameTop.Color = frameColor
	frameTop.Parent = board

	-- Bottom frame
	local frameBottom = Instance.new("Part")
	frameBottom.Name = "Frame_Bottom"
	frameBottom.Size = Vector3.new(12.6, frameThickness, 0.5)
	frameBottom.Position = backing.Position + Vector3.new(0, -3.15, 0)
	frameBottom.Anchored = true
	frameBottom.Material = Enum.Material.Wood
	frameBottom.Color = frameColor
	frameBottom.Parent = board

	-- Left frame
	local frameLeft = Instance.new("Part")
	frameLeft.Name = "Frame_Left"
	frameLeft.Size = Vector3.new(frameThickness, 6.3, 0.5)
	frameLeft.Position = backing.Position + Vector3.new(-6.15, 0, 0)
	frameLeft.Anchored = true
	frameLeft.Material = Enum.Material.Wood
	frameLeft.Color = frameColor
	frameLeft.Parent = board

	-- Right frame
	local frameRight = Instance.new("Part")
	frameRight.Name = "Frame_Right"
	frameRight.Size = Vector3.new(frameThickness, 6.3, 0.5)
	frameRight.Position = backing.Position + Vector3.new(6.15, 0, 0)
	frameRight.Anchored = true
	frameRight.Material = Enum.Material.Wood
	frameRight.Color = frameColor
	frameRight.Parent = board

	-- Level cards — 5 small Parts pinned to board
	local cardWidth = 2
	local cardHeight = 2.5
	local cardSpacing = 2.2
	local startX = -((#LEVEL_NAMES - 1) * cardSpacing) / 2

	for i, levelName in LEVEL_NAMES do
		local isUnlocked = i <= (progress + 1)
		local cardX = startX + (i - 1) * cardSpacing

		-- Card Part
		local card = Instance.new("Part")
		card.Name = `LevelCard_{i}`
		card.Size = Vector3.new(cardWidth, cardHeight, 0.1)
		card.Position = backing.Position + Vector3.new(cardX, 0, 0.3)
		card.Anchored = true
		card.Material = Enum.Material.SmoothPlastic

		if isUnlocked then
			card.Color = Color3.fromRGB(230, 225, 210)
		else
			-- Locked: dim, faded
			card.Color = Color3.fromRGB(100, 95, 88)
			card.Transparency = 0.3
		end

		-- Store level data as attributes
		card:SetAttribute("LevelIndex", i)
		card:SetAttribute("LevelId", LEVEL_IDS[i])
		card:SetAttribute("LevelName", levelName)
		card:SetAttribute("IsUnlocked", isUnlocked)

		-- Pin (small red sphere at top)
		local pin = Instance.new("Part")
		pin.Name = `Pin_{i}`
		pin.Shape = Enum.PartType.Ball
		pin.Size = Vector3.new(0.3, 0.3, 0.3)
		pin.Position = card.Position + Vector3.new(0, cardHeight / 2 - 0.2, 0.1)
		pin.Anchored = true
		pin.Material = Enum.Material.SmoothPlastic
		pin.Color = if isUnlocked then Color3.fromRGB(200, 40, 40) else Color3.fromRGB(80, 40, 40)
		pin.Parent = board

		-- ProximityPrompt for level selection
		local prompt = Instance.new("ProximityPrompt")
		prompt.MaxActivationDistance = 8
		prompt.HoldDuration = 0.5
		prompt.RequiresLineOfSight = false

		if isUnlocked then
			prompt.ActionText = `Enter {levelName}`
			prompt.ObjectText = "Level Select"
		else
			prompt.ActionText = "Locked"
			prompt.ObjectText = levelName
			prompt.Enabled = true
		end

		prompt.Parent = card

		-- SurfaceGui for level name text
		local surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "LabelGui"
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 50
		surfaceGui.Parent = card

		local label = Instance.new("TextLabel")
		label.Name = "LevelLabel"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = if isUnlocked then `{i}` else "?"
		label.TextColor3 = if isUnlocked then Color3.fromRGB(40, 35, 30) else Color3.fromRGB(60, 55, 50)
		label.TextScaled = true
		label.Font = Enum.Font.Antique
		label.Parent = surfaceGui

		card.Parent = board
	end

	-- Red string connecting cards (visual thread)
	for i = 1, #LEVEL_NAMES - 1 do
		local fromX = startX + (i - 1) * cardSpacing
		local toX = startX + i * cardSpacing
		local midX = (fromX + toX) / 2

		local string_ = Instance.new("Part")
		string_.Name = `String_{i}_{i + 1}`
		string_.Size = Vector3.new(cardSpacing, 0.04, 0.04)
		string_.Position = backing.Position + Vector3.new(midX, cardHeight / 2 - 0.2, 0.35)
		string_.Anchored = true
		string_.Material = Enum.Material.Fabric
		string_.Color = Color3.fromRGB(180, 30, 30)
		string_.CanCollide = false
		string_.Parent = board
	end

	board.Parent = parent
	return board
end

------------------------------------------------------------------------
-- Build: Workbench (East Side) — Loadout / Perk Selection
------------------------------------------------------------------------

local function buildWorkbench(roomPos: Vector3, palette: ColorPalette, parent: Instance): Model
	local bench = Instance.new("Model")
	bench.Name = "Workbench"

	-- Table top
	local tableTop = Instance.new("Part")
	tableTop.Name = "TableTop"
	tableTop.Size = Vector3.new(6, 0.5, 3)
	tableTop.Position = roomPos + Vector3.new(ROOM_WIDTH / 2 - WALL_THICKNESS - 2, 3.25, 0)
	tableTop.Anchored = true
	tableTop.Material = Enum.Material.Wood
	tableTop.Color = palette.wood
	tableTop.Parent = bench

	-- Table legs
	for i, offset in
		{
			Vector3.new(-2.5, -1.5, -1),
			Vector3.new(2.5, -1.5, -1),
			Vector3.new(-2.5, -1.5, 1),
			Vector3.new(2.5, -1.5, 1),
		}
	do
		local leg = Instance.new("Part")
		leg.Name = `Leg_{i}`
		leg.Size = Vector3.new(0.4, 3, 0.4)
		leg.Position = tableTop.Position + offset
		leg.Anchored = true
		leg.Material = Enum.Material.Wood
		leg.Color = palette.wood
		leg.Parent = bench
	end

	-- Tools on the workbench (small decorative parts)
	-- Wrench
	local wrench = Instance.new("Part")
	wrench.Name = "Wrench"
	wrench.Size = Vector3.new(0.3, 0.15, 1.2)
	wrench.Position = tableTop.Position + Vector3.new(-1.5, 0.35, 0.3)
	wrench.Anchored = true
	wrench.Material = Enum.Material.Metal
	wrench.Color = Color3.fromRGB(160, 155, 150)
	wrench.Orientation = Vector3.new(0, 15, 0)
	wrench.Parent = bench

	-- Screwdriver
	local screwdriver = Instance.new("Part")
	screwdriver.Name = "Screwdriver"
	screwdriver.Size = Vector3.new(0.2, 0.15, 1.0)
	screwdriver.Position = tableTop.Position + Vector3.new(-0.5, 0.35, -0.4)
	screwdriver.Anchored = true
	screwdriver.Material = Enum.Material.Metal
	screwdriver.Color = Color3.fromRGB(180, 50, 40)
	screwdriver.Orientation = Vector3.new(0, -25, 0)
	screwdriver.Parent = bench

	-- Flashlight (on table)
	local flashlight = Instance.new("Part")
	flashlight.Name = "Flashlight"
	flashlight.Size = Vector3.new(0.4, 0.4, 1.5)
	flashlight.Position = tableTop.Position + Vector3.new(1.0, 0.45, 0)
	flashlight.Anchored = true
	flashlight.Material = Enum.Material.Metal
	flashlight.Color = Color3.fromRGB(50, 50, 50)
	flashlight.Parent = bench

	-- Ammo box / supply crate
	local crate = Instance.new("Part")
	crate.Name = "SupplyCrate"
	crate.Size = Vector3.new(1.5, 1, 1)
	crate.Position = tableTop.Position + Vector3.new(2, 0.75, 0.5)
	crate.Anchored = true
	crate.Material = Enum.Material.Wood
	crate.Color = Color3.fromRGB(100, 80, 55)
	crate.Parent = bench

	-- ProximityPrompt for loadout
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Loadout"
	prompt.ObjectText = "Workbench"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = tableTop

	-- Attribute for system identification
	tableTop:SetAttribute("InteractionType", "Loadout")

	bench.Parent = parent
	return bench
end

------------------------------------------------------------------------
-- Build: Evidence Wall (West Wall) — Lore Journal
------------------------------------------------------------------------

local function buildEvidenceWall(roomPos: Vector3, progress: number, _palette: ColorPalette, parent: Instance): Model
	local wall = Instance.new("Model")
	wall.Name = "EvidenceWall"

	-- Large cork/pinboard section on the west wall
	local backing = Instance.new("Part")
	backing.Name = "EvidenceBacking"
	backing.Size = Vector3.new(0.4, 7, 10)
	backing.Position = roomPos + Vector3.new(-ROOM_WIDTH / 2 + WALL_THICKNESS + 0.3, 6.5, 0)
	backing.Anchored = true
	backing.Material = Enum.Material.WoodPlanks
	backing.Color = Color3.fromRGB(150, 115, 65)
	backing.Parent = wall

	-- Frame
	local frameColor = Color3.fromRGB(70, 50, 35)

	local frameTop = Instance.new("Part")
	frameTop.Name = "Frame_Top"
	frameTop.Size = Vector3.new(0.5, 0.3, 10.6)
	frameTop.Position = backing.Position + Vector3.new(0, 3.65, 0)
	frameTop.Anchored = true
	frameTop.Material = Enum.Material.Wood
	frameTop.Color = frameColor
	frameTop.Parent = wall

	local frameBottom = Instance.new("Part")
	frameBottom.Name = "Frame_Bottom"
	frameBottom.Size = Vector3.new(0.5, 0.3, 10.6)
	frameBottom.Position = backing.Position + Vector3.new(0, -3.65, 0)
	frameBottom.Anchored = true
	frameBottom.Material = Enum.Material.Wood
	frameBottom.Color = frameColor
	frameBottom.Parent = wall

	-- Document pins (number scales with lore progress)
	-- At progress 0, show 1-2 starter documents. More appear as progress increases.
	local docCount = math.min(2 + progress * 3, 15)

	for i = 1, docCount do
		local doc = Instance.new("Part")
		doc.Name = `Document_{i}`
		-- Scatter documents across the board surface
		local docY = math.random(-250, 250) / 100
		local docZ = math.random(-400, 400) / 100
		doc.Size = Vector3.new(0.08, 0.8 + math.random() * 0.4, 0.6 + math.random() * 0.3)
		doc.Position = backing.Position + Vector3.new(0.3, docY, docZ)
		doc.Anchored = true
		doc.Material = Enum.Material.SmoothPlastic
		doc.CanCollide = false
		-- Alternate yellowed paper and white
		if i % 3 == 0 then
			doc.Color = Color3.fromRGB(200, 180, 140)
		else
			doc.Color = Color3.fromRGB(225, 220, 210)
		end
		doc.Orientation = Vector3.new(0, 0, math.random(-10, 10))
		doc.Parent = wall

		-- Pin for each document
		local pin = Instance.new("Part")
		pin.Name = `DocPin_{i}`
		pin.Shape = Enum.PartType.Ball
		pin.Size = Vector3.new(0.2, 0.2, 0.2)
		pin.Position = doc.Position + Vector3.new(0.1, doc.Size.Y / 2 - 0.1, 0)
		pin.Anchored = true
		pin.Material = Enum.Material.SmoothPlastic
		pin.Color = Color3.fromRGB(220, 200, 50)
		pin.CanCollide = false
		pin.Parent = wall
	end

	-- Red strings connecting related documents (visual conspiracy web)
	local stringCount = math.min(1 + progress * 2, 8)
	for i = 1, stringCount do
		local string_ = Instance.new("Part")
		string_.Name = `EvidenceString_{i}`
		local len = 2 + math.random() * 4
		string_.Size = Vector3.new(0.04, 0.04, len)
		string_.Position = backing.Position
			+ Vector3.new(0.35, math.random(-200, 200) / 100, math.random(-300, 300) / 100)
		string_.Anchored = true
		string_.Material = Enum.Material.Fabric
		string_.Color = Color3.fromRGB(180, 30, 30)
		string_.CanCollide = false
		-- Random angles for the threads
		string_.Orientation = Vector3.new(math.random(-30, 30), 0, math.random(-20, 20))
		string_.Parent = wall
	end

	-- ProximityPrompt to read evidence
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Examine Evidence"
	prompt.ObjectText = "Evidence Wall"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = backing

	backing:SetAttribute("InteractionType", "Evidence")
	backing:SetAttribute("LoreCount", docCount)

	wall.Parent = parent
	return wall
end

------------------------------------------------------------------------
-- Build: Locker (Corner) — Cosmetics / Unlocks
------------------------------------------------------------------------

local function buildLocker(roomPos: Vector3, palette: ColorPalette, parent: Instance): Model
	-- Place locker in the NE corner (near bulletin board + east wall)
	local lockerPos = roomPos
		+ Vector3.new(ROOM_WIDTH / 2 - WALL_THICKNESS - 1.5, 0, -ROOM_DEPTH / 2 + WALL_THICKNESS + 1.5)

	local lockerModel = Shared.createFurniture("locker", lockerPos, parent)
	lockerModel.Name = "CosmeticsLocker"

	-- Recolor to match hub palette
	for _, child in lockerModel:GetChildren() do
		if child:IsA("BasePart") then
			child.Color = palette.metal
		end
	end

	-- ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Cosmetics"
	prompt.ObjectText = "Locker"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false

	-- Find the main locker part to attach the prompt
	local mainPart = lockerModel:FindFirstChild("Locker") :: Part?
	if mainPart then
		mainPart:SetAttribute("InteractionType", "Cosmetics")
		prompt.Parent = mainPart
	else
		-- Fallback: parent to first BasePart
		local firstPart = lockerModel:FindFirstChildWhichIsA("BasePart")
		if firstPart then
			prompt.Parent = firstPart
		end
	end

	return lockerModel
end

------------------------------------------------------------------------
-- Build: Radio (Side Table) — Matchmaking
------------------------------------------------------------------------

local function buildRadio(roomPos: Vector3, palette: ColorPalette, parent: Instance): Model
	local radioModel = Instance.new("Model")
	radioModel.Name = "Radio"

	-- Small side table for the radio
	local sideTable = Instance.new("Part")
	sideTable.Name = "SideTable"
	sideTable.Size = Vector3.new(2, 2.5, 2)
	sideTable.Position = roomPos + Vector3.new(ROOM_WIDTH / 2 - WALL_THICKNESS - 1.5, 1.25, 3)
	sideTable.Anchored = true
	sideTable.Material = Enum.Material.Wood
	sideTable.Color = palette.wood
	sideTable.Parent = radioModel

	-- Radio body
	local radioBody = Instance.new("Part")
	radioBody.Name = "RadioBody"
	radioBody.Size = Vector3.new(1.2, 0.8, 0.8)
	radioBody.Position = sideTable.Position + Vector3.new(0, 1.65, 0)
	radioBody.Anchored = true
	radioBody.Material = Enum.Material.Metal
	radioBody.Color = Color3.fromRGB(50, 55, 45)
	radioBody.Parent = radioModel

	-- Antenna (thin vertical)
	local antenna = Instance.new("Part")
	antenna.Name = "Antenna"
	antenna.Size = Vector3.new(0.08, 1.5, 0.08)
	antenna.Position = radioBody.Position + Vector3.new(0.4, 1.15, 0)
	antenna.Anchored = true
	antenna.Material = Enum.Material.Metal
	antenna.Color = Color3.fromRGB(80, 80, 80)
	antenna.Orientation = Vector3.new(0, 0, -10)
	antenna.Parent = radioModel

	-- Dial (small cylinder)
	local dial = Instance.new("Part")
	dial.Name = "Dial"
	dial.Shape = Enum.PartType.Cylinder
	dial.Size = Vector3.new(0.15, 0.3, 0.3)
	dial.Position = radioBody.Position + Vector3.new(-0.3, 0.1, 0.45)
	dial.Anchored = true
	dial.Material = Enum.Material.Metal
	dial.Color = Color3.fromRGB(160, 140, 40)
	dial.Orientation = Vector3.new(0, 0, 90)
	dial.Parent = radioModel

	-- Small indicator light on radio
	local indicator = Instance.new("Part")
	indicator.Name = "IndicatorLight"
	indicator.Size = Vector3.new(0.15, 0.15, 0.08)
	indicator.Position = radioBody.Position + Vector3.new(0.2, 0.2, 0.42)
	indicator.Anchored = true
	indicator.Material = Enum.Material.Neon
	indicator.Color = Color3.fromRGB(40, 200, 40)
	indicator.Parent = radioModel

	-- ProximityPrompt for matchmaking
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Find Match"
	prompt.ObjectText = "Radio"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Parent = radioBody

	radioBody:SetAttribute("InteractionType", "Matchmaking")

	radioModel.Parent = parent
	return radioModel
end

------------------------------------------------------------------------
-- Build: Exit Door (South Wall)
------------------------------------------------------------------------

local function buildExitDoor(roomPos: Vector3, palette: ColorPalette, parent: Instance): Part
	local doorPos = roomPos + Vector3.new(0, DOOR_HEIGHT / 2, ROOM_DEPTH / 2)

	local door = Shared.createDoor(doorPos, nil, parent, "ExitDoor", false, nil)

	-- Restyle for hub
	door.Color = palette.wood
	door.Material = Enum.Material.Wood

	-- Override prompt text
	local prompt = door:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.ActionText = "Enter Level"
		prompt.ObjectText = "Exit"
		prompt.HoldDuration = 1.0
		prompt.MaxActivationDistance = 8
	end

	door:SetAttribute("InteractionType", "ExitDoor")

	return door
end

------------------------------------------------------------------------
-- Build: Ambient Details (Chair, Rug, Scattered Objects)
------------------------------------------------------------------------

local function buildAmbientDetails(roomPos: Vector3, progress: number, palette: ColorPalette, parent: Instance)
	-- Old rug in the center of the room
	local rug = Instance.new("Part")
	rug.Name = "Rug"
	rug.Size = Vector3.new(8, 0.05, 6)
	rug.Position = roomPos + Vector3.new(0, 0.03, 0)
	rug.Anchored = true
	rug.Material = Enum.Material.Fabric
	rug.Color = if progress >= 4 then Color3.fromRGB(60, 45, 35) else Color3.fromRGB(120, 55, 40)
	rug.Parent = parent

	-- Old armchair near the west wall (reading corner)
	local chair = Instance.new("Model")
	chair.Name = "Armchair"

	local seat = Instance.new("Part")
	seat.Name = "Seat"
	seat.Size = Vector3.new(3, 0.6, 3)
	seat.Position = roomPos + Vector3.new(-ROOM_WIDTH / 2 + WALL_THICKNESS + 2.5, 1.5, 4)
	seat.Anchored = true
	seat.Material = Enum.Material.Fabric
	seat.Color = if progress >= 3 then Color3.fromRGB(70, 60, 50) else Color3.fromRGB(110, 75, 50)
	seat.Parent = chair

	local backRest = Instance.new("Part")
	backRest.Name = "Back"
	backRest.Size = Vector3.new(3, 2.5, 0.6)
	backRest.Position = seat.Position + Vector3.new(0, 1.55, -1.2)
	backRest.Anchored = true
	backRest.Material = Enum.Material.Fabric
	backRest.Color = seat.Color
	backRest.Parent = chair

	local armLeft = Instance.new("Part")
	armLeft.Name = "Arm_Left"
	armLeft.Size = Vector3.new(0.5, 1.0, 2.5)
	armLeft.Position = seat.Position + Vector3.new(-1.5, 0.5, -0.3)
	armLeft.Anchored = true
	armLeft.Material = Enum.Material.Fabric
	armLeft.Color = seat.Color
	armLeft.Parent = chair

	local armRight = Instance.new("Part")
	armRight.Name = "Arm_Right"
	armRight.Size = Vector3.new(0.5, 1.0, 2.5)
	armRight.Position = seat.Position + Vector3.new(1.5, 0.5, -0.3)
	armRight.Anchored = true
	armRight.Material = Enum.Material.Fabric
	armRight.Color = seat.Color
	armRight.Parent = chair

	chair.Parent = parent

	-- Small bookshelf next to the armchair
	local bookshelf = Instance.new("Part")
	bookshelf.Name = "Bookshelf"
	bookshelf.Size = Vector3.new(3, 5, 1.5)
	bookshelf.Position = roomPos + Vector3.new(-ROOM_WIDTH / 2 + WALL_THICKNESS + 1, 2.5, 6)
	bookshelf.Anchored = true
	bookshelf.Material = Enum.Material.Wood
	bookshelf.Color = palette.wood
	bookshelf.Parent = parent

	-- Books (decorative colored spines)
	local bookColors = {
		Color3.fromRGB(140, 40, 40),
		Color3.fromRGB(40, 60, 100),
		Color3.fromRGB(50, 90, 45),
		Color3.fromRGB(120, 90, 30),
		Color3.fromRGB(80, 40, 80),
	}
	for i, bookColor in bookColors do
		local book = Instance.new("Part")
		book.Name = `Book_{i}`
		book.Size = Vector3.new(0.4, 1.2, 0.9)
		book.Position = bookshelf.Position + Vector3.new(-1 + (i - 1) * 0.5, 1.5, 0)
		book.Anchored = true
		book.Material = Enum.Material.SmoothPlastic
		book.Color = bookColor
		book.Parent = parent
	end

	-- Coffee mug on the workbench area (moved slightly)
	local mug = Instance.new("Part")
	mug.Name = "CoffeeMug"
	mug.Shape = Enum.PartType.Cylinder
	mug.Size = Vector3.new(0.6, 0.6, 0.6)
	mug.Position = roomPos + Vector3.new(ROOM_WIDTH / 2 - WALL_THICKNESS - 3, 3.8, -1.5)
	mug.Anchored = true
	mug.Material = Enum.Material.SmoothPlastic
	mug.Color = Color3.fromRGB(180, 180, 170)
	mug.Orientation = Vector3.new(0, 0, 90)
	mug.Parent = parent

	-- Map pinned to ceiling support beam (near entrance)
	if progress >= 1 then
		local map = Instance.new("Part")
		map.Name = "Map"
		map.Size = Vector3.new(3, 2, 0.05)
		map.Position = roomPos + Vector3.new(3, 5, ROOM_DEPTH / 2 - WALL_THICKNESS - 0.5)
		map.Anchored = true
		map.Material = Enum.Material.SmoothPlastic
		map.Color = Color3.fromRGB(210, 200, 170)
		map.Parent = parent
	end

	-- Degradation debris (at higher progress levels)
	if progress >= 3 then
		-- Dust/debris on the floor
		for i = 1, progress * 2 do
			local debris = Instance.new("Part")
			debris.Name = `Debris_{i}`
			debris.Size = Vector3.new(0.2 + math.random() * 0.4, 0.1 + math.random() * 0.15, 0.2 + math.random() * 0.4)
			debris.Position = roomPos + Vector3.new(math.random(-800, 800) / 100, 0.1, math.random(-600, 600) / 100)
			debris.Anchored = true
			debris.Material = Enum.Material.Slate
			debris.Color = Color3.fromRGB(80, 75, 70)
			debris.Orientation = Vector3.new(math.random(-15, 15), math.random(0, 360), math.random(-15, 15))
			debris.Parent = parent
		end
	end
end

------------------------------------------------------------------------
-- Build: Degradation Effects
------------------------------------------------------------------------

local function applyDegradation(roomPos: Vector3, progress: number, lights: { Part }, parent: Instance)
	if progress < 2 then
		return
	end

	-- Progress 2: Some lights flicker, one wall crack
	if progress >= 2 then
		-- Flicker two lights
		if lights[1] then
			markFlickering(lights[1], 0.3)
		end

		-- One crack on the north wall
		addCrack(
			roomPos + Vector3.new(3, 5, -ROOM_DEPTH / 2 + WALL_THICKNESS / 2),
			Vector3.new(0.08, 3, 0.15),
			parent,
			"Crack_1"
		)
	end

	-- Progress 3: More cracks, one light out, faint ambient sound indicator
	if progress >= 3 then
		-- Kill one light
		if lights[2] then
			killLight(lights[2])
		end

		-- More flicker on remaining lights
		if lights[3] then
			markFlickering(lights[3], 0.5)
		end

		-- Additional cracks
		addCrack(
			roomPos + Vector3.new(-4, 7, -ROOM_DEPTH / 2 + WALL_THICKNESS / 2),
			Vector3.new(0.06, 4, 0.12),
			parent,
			"Crack_2"
		)
		addCrack(
			roomPos + Vector3.new(ROOM_WIDTH / 2 - WALL_THICKNESS / 2, 4, -2),
			Vector3.new(0.12, 2.5, 0.06),
			parent,
			"Crack_3"
		)

		-- Faint ambient sound marker (client reads this)
		local ambientMarker = Instance.new("Part")
		ambientMarker.Name = "AmbientSoundMarker"
		ambientMarker.Size = Vector3.new(1, 1, 1)
		ambientMarker.Position = roomPos + Vector3.new(0, ROOM_HEIGHT / 2, 0)
		ambientMarker.Transparency = 1
		ambientMarker.CanCollide = false
		ambientMarker.Anchored = true
		ambientMarker:SetAttribute("AmbientSound", "CreakingRoom")
		ambientMarker:SetAttribute("Volume", 0.2)
		ambientMarker.Parent = parent
	end

	-- Progress 4: Significant cracks, lights mostly dim, scratching sounds
	if progress >= 4 then
		-- Kill another light
		if lights[1] then
			killLight(lights[1])
		end

		-- More aggressive flickering on remaining lights
		for _, light in lights do
			local pointLight = light:FindFirstChildOfClass("PointLight")
			if pointLight and pointLight.Enabled then
				markFlickering(light, 0.8)
			end
		end

		-- Large cracks across multiple walls
		addCrack(
			roomPos + Vector3.new(-5, 3, -ROOM_DEPTH / 2 + WALL_THICKNESS / 2),
			Vector3.new(0.1, 5, 0.2),
			parent,
			"Crack_4"
		)
		addCrack(
			roomPos + Vector3.new(-ROOM_WIDTH / 2 + WALL_THICKNESS / 2, 8, 3),
			Vector3.new(0.15, 3.5, 0.08),
			parent,
			"Crack_5"
		)
		addCrack(
			roomPos + Vector3.new(2, 9, -ROOM_DEPTH / 2 + WALL_THICKNESS / 2),
			Vector3.new(0.08, 2, 0.1),
			parent,
			"Crack_6"
		)

		-- Scratching sound indicators behind walls
		addScratchIndicator(roomPos + Vector3.new(-ROOM_WIDTH / 2 + 0.2, 4, -2), parent, "Scratch_West")
		addScratchIndicator(roomPos + Vector3.new(3, 5, -ROOM_DEPTH / 2 + 0.2), parent, "Scratch_North")
	end

	-- Progress 5: Nearly destroyed
	if progress >= 5 then
		-- Kill all lights except one
		for i, light in lights do
			if i > 1 then
				killLight(light)
			end
		end
		-- The surviving light barely works
		if lights[1] then
			local pointLight = lights[1]:FindFirstChildOfClass("PointLight")
			if pointLight then
				pointLight.Enabled = true
				pointLight.Brightness = 0.08
			end
			markFlickering(lights[1], 1.0)
		end

		-- Cracks everywhere
		for i = 7, 14 do
			local wallChoice = math.random(1, 4)
			local pos: Vector3
			local size: Vector3

			if wallChoice == 1 then
				-- North wall
				pos = roomPos
					+ Vector3.new(
						math.random(-800, 800) / 100,
						math.random(200, 1000) / 100,
						-ROOM_DEPTH / 2 + WALL_THICKNESS / 2
					)
				size = Vector3.new(0.08 + math.random() * 0.06, 2 + math.random() * 3, 0.12)
			elseif wallChoice == 2 then
				-- South wall
				pos = roomPos
					+ Vector3.new(
						math.random(-800, 800) / 100,
						math.random(200, 1000) / 100,
						ROOM_DEPTH / 2 - WALL_THICKNESS / 2
					)
				size = Vector3.new(0.08 + math.random() * 0.06, 2 + math.random() * 3, 0.12)
			elseif wallChoice == 3 then
				-- East wall
				pos = roomPos
					+ Vector3.new(
						ROOM_WIDTH / 2 - WALL_THICKNESS / 2,
						math.random(200, 1000) / 100,
						math.random(-600, 600) / 100
					)
				size = Vector3.new(0.12, 2 + math.random() * 3, 0.08 + math.random() * 0.06)
			else
				-- West wall
				pos = roomPos
					+ Vector3.new(
						-ROOM_WIDTH / 2 + WALL_THICKNESS / 2,
						math.random(200, 1000) / 100,
						math.random(-600, 600) / 100
					)
				size = Vector3.new(0.12, 2 + math.random() * 3, 0.08 + math.random() * 0.06)
			end

			addCrack(pos, size, parent, `Crack_{i}`)
		end

		-- Something behind the wall: a barely visible silhouette
		local silhouette = Instance.new("Part")
		silhouette.Name = "WallSilhouette"
		silhouette.Size = Vector3.new(0.3, 6, 3)
		silhouette.Position = roomPos + Vector3.new(-ROOM_WIDTH / 2 - 0.2, 4, -1)
		silhouette.Anchored = true
		silhouette.Material = Enum.Material.SmoothPlastic
		silhouette.Color = Color3.fromRGB(20, 18, 15)
		silhouette.Transparency = 0.85
		silhouette.CanCollide = false
		silhouette:SetAttribute("Silhouette", true)
		silhouette:SetAttribute("PulseRate", 0.3)
		silhouette.Parent = parent

		-- Multiple scratching indicators
		addScratchIndicator(roomPos + Vector3.new(-ROOM_WIDTH / 2 + 0.2, 6, 2), parent, "Scratch_West_2")
		addScratchIndicator(roomPos + Vector3.new(ROOM_WIDTH / 2 - 0.2, 3, -3), parent, "Scratch_East")
		addScratchIndicator(roomPos + Vector3.new(-2, 7, -ROOM_DEPTH / 2 + 0.2), parent, "Scratch_North_2")

		-- Ceiling drip (water stain + drip marker)
		local waterStain = Instance.new("Part")
		waterStain.Name = "WaterStain"
		waterStain.Size = Vector3.new(3, 0.05, 2.5)
		waterStain.Position = roomPos + Vector3.new(2, ROOM_HEIGHT - 0.3, -2)
		waterStain.Anchored = true
		waterStain.Material = Enum.Material.Slate
		waterStain.Color = Color3.fromRGB(50, 48, 42)
		waterStain.Transparency = 0.4
		waterStain.CanCollide = false
		waterStain:SetAttribute("Dripping", true)
		waterStain.Parent = parent
	end
end

------------------------------------------------------------------------
-- Build: Main Entry Point
------------------------------------------------------------------------

function Hub.build(playerProgress: number?): Model
	local progress = math.clamp(playerProgress or 0, 0, 5)

	local palette = getPalette(progress)

	local model = Instance.new("Model")
	model.Name = "Hub"
	model:SetAttribute("PlayerProgress", progress)

	local roomPos = Vector3.new(0, 0, 0)

	--------------------------------------------------------------------
	-- Room Structure (Walls, Floor, Ceiling)
	--------------------------------------------------------------------

	local _room = Shared.createRoom({
		position = roomPos,
		size = Vector3.new(ROOM_WIDTH, ROOM_HEIGHT, ROOM_DEPTH),
		parent = model,
		name = "HubRoom",
		wallThickness = WALL_THICKNESS,
		wallMaterial = Enum.Material.Concrete,
		wallColor = palette.wall,
		floorMaterial = Enum.Material.Wood,
		floorColor = palette.floor,
		ceilingMaterial = Enum.Material.Concrete,
		ceilingColor = palette.ceiling,
		doorways = {
			-- South wall: exit door opening
			{ wall = "south", offset = 0, width = DOOR_WIDTH, height = DOOR_HEIGHT },
		},
	})

	--------------------------------------------------------------------
	-- Lighting
	--------------------------------------------------------------------

	local lights: { Part } = {}

	-- Main overhead light (center)
	local mainLight = Shared.createLight(
		roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, 0),
		model,
		palette.lightBrightness,
		palette.lightColor
	)
	mainLight.Name = "Light_Main"
	table.insert(lights, mainLight)

	-- Workbench area light (east)
	local eastLight = Shared.createLight(
		roomPos + Vector3.new(ROOM_WIDTH / 2 - 3, ROOM_HEIGHT - 0.5, 0),
		model,
		palette.lightBrightness * 0.8,
		palette.lightColor
	)
	eastLight.Name = "Light_East"
	table.insert(lights, eastLight)

	-- Evidence wall light (west)
	local westLight = Shared.createLight(
		roomPos + Vector3.new(-ROOM_WIDTH / 2 + 3, ROOM_HEIGHT - 0.5, 0),
		model,
		palette.lightBrightness * 0.7,
		palette.lightColor
	)
	westLight.Name = "Light_West"
	table.insert(lights, westLight)

	-- Bulletin board spot light (north, angled down)
	local northLight = Shared.createLight(
		roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, -ROOM_DEPTH / 2 + 3),
		model,
		palette.lightBrightness * 0.9,
		palette.lightColor
	)
	northLight.Name = "Light_North"
	table.insert(lights, northLight)

	-- Warm accent near door (south)
	if progress <= 2 then
		local doorLight = Shared.createLight(
			roomPos + Vector3.new(0, ROOM_HEIGHT - 0.5, ROOM_DEPTH / 2 - 3),
			model,
			palette.lightBrightness * 0.5,
			Color3.fromRGB(255, 200, 140)
		)
		doorLight.Name = "Light_Door"
		table.insert(lights, doorLight)
	end

	--------------------------------------------------------------------
	-- Interactive Stations
	--------------------------------------------------------------------

	-- 1. Bulletin Board (north wall) — Level Select
	buildBulletinBoard(roomPos, progress, palette, model)

	-- 2. Workbench (east side) — Loadout
	buildWorkbench(roomPos, palette, model)

	-- 3. Evidence Wall (west wall) — Lore Journal
	buildEvidenceWall(roomPos, progress, palette, model)

	-- 4. Locker (NE corner) — Cosmetics
	buildLocker(roomPos, palette, model)

	-- 5. Radio (east side, on side table) — Matchmaking
	buildRadio(roomPos, palette, model)

	-- 6. Exit Door (south wall)
	buildExitDoor(roomPos, palette, model)

	--------------------------------------------------------------------
	-- Ambient Details
	--------------------------------------------------------------------

	buildAmbientDetails(roomPos, progress, palette, model)

	--------------------------------------------------------------------
	-- Ceiling Light Fixture Chain (decorative hanging element)
	--------------------------------------------------------------------

	-- A bare bulb hanging from a cord in the center (atmospheric)
	local cord = Instance.new("Part")
	cord.Name = "LightCord"
	cord.Size = Vector3.new(0.06, 2, 0.06)
	cord.Position = roomPos + Vector3.new(0, ROOM_HEIGHT - 1.5, 0)
	cord.Anchored = true
	cord.Material = Enum.Material.Fabric
	cord.Color = Color3.fromRGB(40, 38, 35)
	cord.CanCollide = false
	cord.Parent = model

	local bulb = Instance.new("Part")
	bulb.Name = "HangingBulb"
	bulb.Shape = Enum.PartType.Ball
	bulb.Size = Vector3.new(0.6, 0.6, 0.6)
	bulb.Position = cord.Position + Vector3.new(0, -1.1, 0)
	bulb.Anchored = true
	bulb.Material = Enum.Material.Neon
	bulb.Color = if progress >= 4 then Color3.fromRGB(80, 70, 50) else Color3.fromRGB(255, 230, 180)
	bulb.Transparency = if progress >= 4 then 0.5 else 0.1
	bulb.Parent = model

	-- PointLight on the hanging bulb for warm glow
	if progress < 5 then
		local bulbLight = Instance.new("PointLight")
		bulbLight.Brightness = if progress >= 4 then 0.1 else palette.lightBrightness * 0.6
		bulbLight.Color = palette.lightColor
		bulbLight.Range = if progress >= 4 then 8 else 16
		bulbLight.Shadows = true
		bulbLight.Parent = bulb
	end

	if progress >= 3 then
		markFlickering(bulb, 0.3 + progress * 0.15)
	end

	--------------------------------------------------------------------
	-- SpawnLocation
	--------------------------------------------------------------------

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn"
	spawn.Size = Vector3.new(4, 1, 4)
	spawn.Position = roomPos + Vector3.new(0, 0.5, 2)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Material = Enum.Material.Wood
	spawn.Color = palette.floor
	spawn.Transparency = 1 -- invisible; the floor provides visuals
	spawn.CanCollide = false
	spawn.Parent = model

	--------------------------------------------------------------------
	-- Degradation Effects
	--------------------------------------------------------------------

	applyDegradation(roomPos, progress, lights, model)

	--------------------------------------------------------------------
	-- Atmospheric Tags (client reads these for audio/VFX)
	--------------------------------------------------------------------

	model:SetAttribute("Atmosphere", if progress <= 1 then "Warm" elseif progress <= 3 then "Uneasy" else "Dread")
	model:SetAttribute("AmbientTemperature", if progress <= 1 then "Warm" elseif progress <= 3 then "Cool" else "Cold")

	--------------------------------------------------------------------
	-- Finalize
	--------------------------------------------------------------------

	model.Parent = workspace
	return model
end

------------------------------------------------------------------------
-- Cleanup
------------------------------------------------------------------------

function Hub.cleanup(model: Model)
	if model then
		model:Destroy()
	end
end

return Hub
