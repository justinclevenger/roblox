--!strict

--[[
	Hospital/Shared - Builder helper functions for programmatic level geometry.

	Provides reusable primitives (walls, floors, ceilings, rooms, corridors,
	stairs, doors, furniture, lights, and hiding spots) used by each floor
	module (GroundFloor, Basement, UpperFloor, Exterior, Roof).
]]

local Shared = {}

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------

local DEFAULT_WALL_COLOR = Color3.fromRGB(180, 175, 165)
local DEFAULT_FLOOR_COLOR = Color3.fromRGB(140, 140, 135)
local DEFAULT_CEILING_COLOR = Color3.fromRGB(160, 155, 150)
local DEFAULT_WALL_THICKNESS = 1
local DEFAULT_DOOR_WIDTH = 5
local DEFAULT_DOOR_HEIGHT = 8

------------------------------------------------------------------------
-- Type Definitions
------------------------------------------------------------------------

export type DoorwayDef = {
	wall: "north" | "south" | "east" | "west",
	offset: number,
	width: number,
	height: number,
}

export type RoomConfig = {
	position: Vector3,
	size: Vector3,
	parent: Instance,
	name: string?,
	wallThickness: number?,
	floorMaterial: Enum.Material?,
	wallMaterial: Enum.Material?,
	ceilingMaterial: Enum.Material?,
	wallColor: Color3?,
	floorColor: Color3?,
	ceilingColor: Color3?,
	doorways: { DoorwayDef }?,
	noFloor: boolean?,
	noCeiling: boolean?,
}

export type HidingSpotData = {
	id: string,
	position: Vector3,
	spotType: string,
	isOccupied: boolean,
}

------------------------------------------------------------------------
-- Primitive Builders
------------------------------------------------------------------------

function Shared.createWall(position: Vector3, size: Vector3, parent: Instance, name: string?): Part
	local wall = Instance.new("Part")
	wall.Name = name or "Wall"
	wall.Size = size
	wall.Position = position
	wall.Anchored = true
	wall.Material = Enum.Material.Concrete
	wall.Color = DEFAULT_WALL_COLOR
	wall.Parent = parent
	return wall
end

function Shared.createFloor(position: Vector3, size: Vector3, parent: Instance, name: string?): Part
	local floor = Instance.new("Part")
	floor.Name = name or "Floor"
	floor.Size = size
	floor.Position = position
	floor.Anchored = true
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = DEFAULT_FLOOR_COLOR
	floor.Parent = parent
	return floor
end

function Shared.createCeiling(position: Vector3, size: Vector3, parent: Instance, name: string?): Part
	local ceiling = Instance.new("Part")
	ceiling.Name = name or "Ceiling"
	ceiling.Size = size
	ceiling.Position = position
	ceiling.Anchored = true
	ceiling.Material = Enum.Material.Concrete
	ceiling.Color = DEFAULT_CEILING_COLOR
	ceiling.Parent = parent
	return ceiling
end

------------------------------------------------------------------------
-- Room Builder
------------------------------------------------------------------------

--[[
	Creates a fully enclosed room with 4 walls, floor, and ceiling.
	Doorway gaps are cut from walls as specified in config.doorways.

	Room coordinate convention:
	  - config.position is the floor-center of the room (Y = floor surface Y)
	  - config.size = Vector3(lengthX, height, depthZ)
	  - Walls are placed at the outer edges of the room footprint.

	Returns a Model containing all child Parts.
]]
function Shared.createRoom(config: RoomConfig): Model
	local model = Instance.new("Model")
	model.Name = config.name or "Room"

	local pos = config.position
	local sx = config.size.X -- room interior width (X)
	local sy = config.size.Y -- room height
	local sz = config.size.Z -- room interior depth (Z)
	local wt = config.wallThickness or DEFAULT_WALL_THICKNESS

	local wallMat = config.wallMaterial or Enum.Material.Concrete
	local wallCol = config.wallColor or DEFAULT_WALL_COLOR
	local floorMat = config.floorMaterial or Enum.Material.SmoothPlastic
	local floorCol = config.floorColor or DEFAULT_FLOOR_COLOR
	local ceilMat = config.ceilingMaterial or Enum.Material.Concrete
	local ceilCol = config.ceilingColor or DEFAULT_CEILING_COLOR

	-- Helper to set material/color on a Part
	local function stylePart(part: Part, mat: Enum.Material, col: Color3)
		part.Material = mat
		part.Color = col
	end

	-- Floor slab (spans full footprint including wall thickness)
	if not config.noFloor then
		local flr = Shared.createFloor(
			Vector3.new(pos.X, pos.Y - 0.5, pos.Z),
			Vector3.new(sx + wt * 2, 1, sz + wt * 2),
			model,
			"Floor"
		)
		stylePart(flr, floorMat, floorCol)
	end

	-- Ceiling slab
	if not config.noCeiling then
		local ceil = Shared.createCeiling(
			Vector3.new(pos.X, pos.Y + sy + 0.5, pos.Z),
			Vector3.new(sx + wt * 2, 1, sz + wt * 2),
			model,
			"Ceiling"
		)
		stylePart(ceil, ceilMat, ceilCol)
	end

	-- Build doorway lookup: wall -> list of doorways sorted by offset
	local doorwayMap: { [string]: { DoorwayDef } } = {
		north = {},
		south = {},
		east = {},
		west = {},
	}
	if config.doorways then
		for _, dw in config.doorways do
			table.insert(doorwayMap[dw.wall], dw)
		end
	end
	-- Sort each wall's doorways by offset
	for _, list in doorwayMap do
		table.sort(list, function(a, b)
			return a.offset < b.offset
		end)
	end

	--[[
		Wall segment builder.

		For a wall of total length `wallLen`, centered at wallCenter, with
		normal along the given axis, cut out doorway gaps and emit solid
		segments for the remaining portions.

		wallCenter: center position of full wall (without doorway cuts)
		wallLen: total length of the wall
		wallHeight: height of the wall
		axis: "x" or "z" — which axis the wall spans
		doorways: list of DoorwayDef for this wall
	]]
	local function buildWallWithDoorways(
		wallCenter: Vector3,
		wallLen: number,
		wallHeight: number,
		axis: string,
		doorways: { DoorwayDef },
		wallName: string
	)
		if #doorways == 0 then
			-- Solid wall, no doorways
			local size: Vector3
			if axis == "x" then
				size = Vector3.new(wallLen, wallHeight, wt)
			else
				size = Vector3.new(wt, wallHeight, wallLen)
			end
			local w = Shared.createWall(wallCenter, size, model, wallName)
			stylePart(w, wallMat, wallCol)
			return
		end

		-- We need to split the wall into segments around each doorway.
		-- Work in local 1D coordinates along the wall: 0 = left/front edge, wallLen = right/back edge.
		-- Doorway offset is relative to wall center (0 = centered).

		local segments: { { start: number, finish: number, isUpper: boolean, doorHeight: number } } = {}
		local cursor = 0

		for _, dw in doorways do
			local dwCenter = wallLen / 2 + dw.offset
			local dwStart = dwCenter - dw.width / 2
			local dwEnd = dwCenter + dw.width / 2

			-- Clamp
			dwStart = math.max(0, dwStart)
			dwEnd = math.min(wallLen, dwEnd)

			-- Segment before doorway
			if dwStart > cursor then
				table.insert(segments, { start = cursor, finish = dwStart, isUpper = false, doorHeight = 0 })
			end

			-- Upper segment above the doorway (transom)
			local dwH = math.min(dw.height, wallHeight)
			if dwH < wallHeight then
				table.insert(segments, { start = dwStart, finish = dwEnd, isUpper = true, doorHeight = dwH })
			end

			cursor = dwEnd
		end

		-- Trailing segment after last doorway
		if cursor < wallLen then
			table.insert(segments, { start = cursor, finish = wallLen, isUpper = false, doorHeight = 0 })
		end

		-- Emit geometry for each segment
		for i, seg in segments do
			local segLen = seg.finish - seg.start
			if segLen <= 0 then
				continue
			end

			local segCenter1D = seg.start + segLen / 2 - wallLen / 2 -- relative to wall center
			local segPos: Vector3
			local segSize: Vector3

			if seg.isUpper then
				-- Transom piece above doorway
				local transomH = wallHeight - seg.doorHeight
				local transomY = wallCenter.Y + seg.doorHeight / 2 + transomH / 2

				if axis == "x" then
					segPos = Vector3.new(wallCenter.X + segCenter1D, transomY, wallCenter.Z)
					segSize = Vector3.new(segLen, transomH, wt)
				else
					segPos = Vector3.new(wallCenter.X, transomY, wallCenter.Z + segCenter1D)
					segSize = Vector3.new(wt, transomH, segLen)
				end
			else
				if axis == "x" then
					segPos = Vector3.new(wallCenter.X + segCenter1D, wallCenter.Y, wallCenter.Z)
					segSize = Vector3.new(segLen, wallHeight, wt)
				else
					segPos = Vector3.new(wallCenter.X, wallCenter.Y, wallCenter.Z + segCenter1D)
					segSize = Vector3.new(wt, wallHeight, segLen)
				end
			end

			local w = Shared.createWall(segPos, segSize, model, `{wallName}_Seg{i}`)
			stylePart(w, wallMat, wallCol)
		end
	end

	-- Wall center Y
	local wallCY = pos.Y + sy / 2

	-- North wall (negative Z face)
	buildWallWithDoorways(
		Vector3.new(pos.X, wallCY, pos.Z - sz / 2 - wt / 2),
		sx + wt * 2,
		sy,
		"x",
		doorwayMap["north"],
		"Wall_North"
	)

	-- South wall (positive Z face)
	buildWallWithDoorways(
		Vector3.new(pos.X, wallCY, pos.Z + sz / 2 + wt / 2),
		sx + wt * 2,
		sy,
		"x",
		doorwayMap["south"],
		"Wall_South"
	)

	-- West wall (negative X face)
	buildWallWithDoorways(
		Vector3.new(pos.X - sx / 2 - wt / 2, wallCY, pos.Z),
		sz,
		sy,
		"z",
		doorwayMap["west"],
		"Wall_West"
	)

	-- East wall (positive X face)
	buildWallWithDoorways(
		Vector3.new(pos.X + sx / 2 + wt / 2, wallCY, pos.Z),
		sz,
		sy,
		"z",
		doorwayMap["east"],
		"Wall_East"
	)

	model.Parent = config.parent
	return model
end

------------------------------------------------------------------------
-- Door Builder
------------------------------------------------------------------------

function Shared.createDoor(
	position: Vector3,
	rotation: CFrame?,
	parent: Instance,
	name: string?,
	isLocked: boolean?,
	requiredKey: string?
): Part
	local door = Instance.new("Part")
	door.Name = name or "Door"
	door.Size = Vector3.new(DEFAULT_DOOR_WIDTH, DEFAULT_DOOR_HEIGHT, 0.5)
	door.Anchored = true
	door.Material = Enum.Material.Wood
	door.Color = Color3.fromRGB(90, 70, 55)

	if rotation then
		door.CFrame = rotation + position
	else
		door.Position = position
	end

	-- ProximityPrompt for interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = name or "Door"
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 8

	if isLocked then
		prompt.ActionText = "Locked"
		prompt.Enabled = true
		door:SetAttribute("IsLocked", true)
		door:SetAttribute("RequiredKey", requiredKey or "")
	else
		prompt.ActionText = "Open"
	end

	prompt.Parent = door
	door.Parent = parent
	return door
end

------------------------------------------------------------------------
-- Corridor Builder
------------------------------------------------------------------------

--[[
	Creates a corridor between two points with floor, ceiling, and side walls.
	Currently supports axis-aligned corridors (startPos and endPos must share
	either the same X or same Z coordinate).

	Returns a Model containing all corridor geometry.
]]
function Shared.createCorridor(
	startPos: Vector3,
	endPos: Vector3,
	width: number,
	height: number,
	parent: Instance,
	name: string?
): Model
	local model = Instance.new("Model")
	model.Name = name or "Corridor"

	local dx = endPos.X - startPos.X
	local dz = endPos.Z - startPos.Z
	local centerX = (startPos.X + endPos.X) / 2
	local centerZ = (startPos.Z + endPos.Z) / 2
	local floorY = math.min(startPos.Y, endPos.Y)

	local length: number
	local isXAligned: boolean

	if math.abs(dx) >= math.abs(dz) then
		length = math.abs(dx)
		isXAligned = true
	else
		length = math.abs(dz)
		isXAligned = false
	end

	-- Floor
	if isXAligned then
		Shared.createFloor(Vector3.new(centerX, floorY - 0.5, centerZ), Vector3.new(length, 1, width), model, "Floor")
	else
		Shared.createFloor(Vector3.new(centerX, floorY - 0.5, centerZ), Vector3.new(width, 1, length), model, "Floor")
	end

	-- Ceiling
	if isXAligned then
		Shared.createCeiling(
			Vector3.new(centerX, floorY + height + 0.5, centerZ),
			Vector3.new(length, 1, width),
			model,
			"Ceiling"
		)
	else
		Shared.createCeiling(
			Vector3.new(centerX, floorY + height + 0.5, centerZ),
			Vector3.new(width, 1, length),
			model,
			"Ceiling"
		)
	end

	-- Side walls
	local wt = 1
	if isXAligned then
		-- Walls along Z axis (north/south of corridor)
		Shared.createWall(
			Vector3.new(centerX, floorY + height / 2, centerZ - width / 2 - wt / 2),
			Vector3.new(length, height, wt),
			model,
			"Wall_Left"
		)
		Shared.createWall(
			Vector3.new(centerX, floorY + height / 2, centerZ + width / 2 + wt / 2),
			Vector3.new(length, height, wt),
			model,
			"Wall_Right"
		)
	else
		-- Walls along X axis (west/east of corridor)
		Shared.createWall(
			Vector3.new(centerX - width / 2 - wt / 2, floorY + height / 2, centerZ),
			Vector3.new(wt, height, length),
			model,
			"Wall_Left"
		)
		Shared.createWall(
			Vector3.new(centerX + width / 2 + wt / 2, floorY + height / 2, centerZ),
			Vector3.new(wt, height, length),
			model,
			"Wall_Right"
		)
	end

	model.Parent = parent
	return model
end

------------------------------------------------------------------------
-- Stairwell Builder
------------------------------------------------------------------------

--[[
	Creates a stairwell connecting two floor levels at the given position.
	The stairwell is a series of step Parts forming a switchback stair
	enclosed in a shaft.

	bottomY: Y of lower floor surface
	topY: Y of upper floor surface
	position: XZ center of the stairwell
]]
function Shared.createStairwell(
	bottomY: number,
	topY: number,
	position: Vector3,
	parent: Instance,
	name: string?
): Model
	local model = Instance.new("Model")
	model.Name = name or "Stairwell"

	local totalRise = topY - bottomY
	local stepCount = math.floor(totalRise) -- 1 stud rise per step
	local stepWidth = 6
	local stepDepth = 2
	local stairDepth = stepCount / 2 * stepDepth -- switchback: half steps each direction

	-- Landing platform at bottom
	local landingBottom = Shared.createFloor(
		Vector3.new(position.X, bottomY - 0.5, position.Z - stairDepth / 2 - 2),
		Vector3.new(stepWidth, 1, 4),
		model,
		"Landing_Bottom"
	)
	landingBottom.Material = Enum.Material.Concrete
	landingBottom.Color = Color3.fromRGB(130, 130, 125)

	-- Steps going up (first half - moving in +Z direction)
	local halfSteps = math.floor(stepCount / 2)
	for i = 0, halfSteps - 1 do
		local step = Instance.new("Part")
		step.Name = `Step_{i}`
		step.Size = Vector3.new(stepWidth, 1, stepDepth)
		step.Position = Vector3.new(position.X, bottomY + i + 0.5, position.Z - stairDepth / 2 + i * stepDepth)
		step.Anchored = true
		step.Material = Enum.Material.Concrete
		step.Color = Color3.fromRGB(130, 130, 125)
		step.Parent = model
	end

	-- Mid-landing
	local midY = bottomY + halfSteps
	local midLanding = Shared.createFloor(
		Vector3.new(position.X, midY - 0.5, position.Z + stairDepth / 2 + 2),
		Vector3.new(stepWidth, 1, 4),
		model,
		"Landing_Mid"
	)
	midLanding.Material = Enum.Material.Concrete
	midLanding.Color = Color3.fromRGB(130, 130, 125)

	-- Steps going up (second half - moving in -Z direction, switchback)
	local remainingSteps = stepCount - halfSteps
	for i = 0, remainingSteps - 1 do
		local step = Instance.new("Part")
		step.Name = `Step_{halfSteps + i}`
		step.Size = Vector3.new(stepWidth, 1, stepDepth)
		step.Position = Vector3.new(position.X, midY + i + 0.5, position.Z + stairDepth / 2 - i * stepDepth)
		step.Anchored = true
		step.Material = Enum.Material.Concrete
		step.Color = Color3.fromRGB(130, 130, 125)
		step.Parent = model
	end

	-- Landing platform at top
	local landingTop = Shared.createFloor(
		Vector3.new(position.X, topY - 0.5, position.Z - stairDepth / 2 - 2),
		Vector3.new(stepWidth, 1, 4),
		model,
		"Landing_Top"
	)
	landingTop.Material = Enum.Material.Concrete
	landingTop.Color = Color3.fromRGB(130, 130, 125)

	-- Enclosing walls
	local shaftHeight = totalRise + 2
	local shaftCenterY = (bottomY + topY) / 2

	-- West wall
	Shared.createWall(
		Vector3.new(position.X - stepWidth / 2 - 0.5, shaftCenterY, position.Z),
		Vector3.new(1, shaftHeight, stairDepth + 8),
		model,
		"ShaftWall_West"
	)
	-- East wall
	Shared.createWall(
		Vector3.new(position.X + stepWidth / 2 + 0.5, shaftCenterY, position.Z),
		Vector3.new(1, shaftHeight, stairDepth + 8),
		model,
		"ShaftWall_East"
	)

	model.Parent = parent
	return model
end

------------------------------------------------------------------------
-- Furniture Builder
------------------------------------------------------------------------

--[[
	Creates simple furniture from basic Parts.
	Supported types: "bed", "desk", "chair", "cabinet", "gurney",
	                 "locker", "shelf", "table", "toilet", "sink",
	                 "monitor", "pew", "washer", "dryer", "cart"
	Returns a Model.
]]
function Shared.createFurniture(furnitureType: string, position: Vector3, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = furnitureType

	if furnitureType == "bed" then
		-- Frame
		local frame = Instance.new("Part")
		frame.Name = "Frame"
		frame.Size = Vector3.new(4, 1.5, 7)
		frame.Position = position + Vector3.new(0, 0.75, 0)
		frame.Anchored = true
		frame.Material = Enum.Material.Metal
		frame.Color = Color3.fromRGB(200, 200, 200)
		frame.Parent = model

		-- Mattress
		local mattress = Instance.new("Part")
		mattress.Name = "Mattress"
		mattress.Size = Vector3.new(3.5, 0.6, 6.5)
		mattress.Position = position + Vector3.new(0, 1.8, 0)
		mattress.Anchored = true
		mattress.Material = Enum.Material.Fabric
		mattress.Color = Color3.fromRGB(180, 180, 170)
		mattress.Parent = model

		-- Pillow
		local pillow = Instance.new("Part")
		pillow.Name = "Pillow"
		pillow.Size = Vector3.new(2.5, 0.4, 1.5)
		pillow.Position = position + Vector3.new(0, 2.2, -2.5)
		pillow.Anchored = true
		pillow.Material = Enum.Material.Fabric
		pillow.Color = Color3.fromRGB(220, 220, 210)
		pillow.Parent = model
	elseif furnitureType == "desk" then
		-- Desktop
		local top = Instance.new("Part")
		top.Name = "Desktop"
		top.Size = Vector3.new(5, 0.5, 3)
		top.Position = position + Vector3.new(0, 3, 0)
		top.Anchored = true
		top.Material = Enum.Material.Wood
		top.Color = Color3.fromRGB(110, 80, 60)
		top.Parent = model

		-- Legs
		for i, offset in
			{ Vector3.new(-2, 1.5, -1), Vector3.new(2, 1.5, -1), Vector3.new(-2, 1.5, 1), Vector3.new(2, 1.5, 1) }
		do
			local leg = Instance.new("Part")
			leg.Name = `Leg_{i}`
			leg.Size = Vector3.new(0.4, 3, 0.4)
			leg.Position = position + offset
			leg.Anchored = true
			leg.Material = Enum.Material.Metal
			leg.Color = Color3.fromRGB(80, 80, 80)
			leg.Parent = model
		end
	elseif furnitureType == "chair" then
		-- Seat
		local seat = Instance.new("Part")
		seat.Name = "Seat"
		seat.Size = Vector3.new(2, 0.4, 2)
		seat.Position = position + Vector3.new(0, 2, 0)
		seat.Anchored = true
		seat.Material = Enum.Material.Plastic
		seat.Color = Color3.fromRGB(60, 80, 100)
		seat.Parent = model

		-- Back
		local back = Instance.new("Part")
		back.Name = "Back"
		back.Size = Vector3.new(2, 2, 0.3)
		back.Position = position + Vector3.new(0, 3.2, -0.85)
		back.Anchored = true
		back.Material = Enum.Material.Plastic
		back.Color = Color3.fromRGB(60, 80, 100)
		back.Parent = model
	elseif furnitureType == "cabinet" then
		local cab = Instance.new("Part")
		cab.Name = "Cabinet"
		cab.Size = Vector3.new(3, 6, 2)
		cab.Position = position + Vector3.new(0, 3, 0)
		cab.Anchored = true
		cab.Material = Enum.Material.Metal
		cab.Color = Color3.fromRGB(160, 160, 155)
		cab.Parent = model
	elseif furnitureType == "gurney" then
		-- Frame with wheels
		local frame = Instance.new("Part")
		frame.Name = "Frame"
		frame.Size = Vector3.new(3, 0.3, 7)
		frame.Position = position + Vector3.new(0, 2.5, 0)
		frame.Anchored = true
		frame.Material = Enum.Material.Metal
		frame.Color = Color3.fromRGB(200, 200, 200)
		frame.Parent = model

		-- Mattress pad
		local pad = Instance.new("Part")
		pad.Name = "Pad"
		pad.Size = Vector3.new(2.8, 0.4, 6.5)
		pad.Position = position + Vector3.new(0, 2.9, 0)
		pad.Anchored = true
		pad.Material = Enum.Material.Fabric
		pad.Color = Color3.fromRGB(180, 180, 175)
		pad.Parent = model

		-- Legs
		for i, offset in
			{
				Vector3.new(-1.2, 1.25, -3),
				Vector3.new(1.2, 1.25, -3),
				Vector3.new(-1.2, 1.25, 3),
				Vector3.new(1.2, 1.25, 3),
			}
		do
			local leg = Instance.new("Part")
			leg.Name = `Leg_{i}`
			leg.Size = Vector3.new(0.3, 2.5, 0.3)
			leg.Position = position + offset
			leg.Anchored = true
			leg.Material = Enum.Material.Metal
			leg.Color = Color3.fromRGB(160, 160, 160)
			leg.Parent = model
		end
	elseif furnitureType == "locker" then
		local locker = Instance.new("Part")
		locker.Name = "Locker"
		locker.Size = Vector3.new(2, 7, 2)
		locker.Position = position + Vector3.new(0, 3.5, 0)
		locker.Anchored = true
		locker.Material = Enum.Material.Metal
		locker.Color = Color3.fromRGB(100, 110, 100)
		locker.Parent = model
	elseif furnitureType == "shelf" then
		-- Tall shelving unit
		local frame = Instance.new("Part")
		frame.Name = "Frame"
		frame.Size = Vector3.new(5, 8, 2)
		frame.Position = position + Vector3.new(0, 4, 0)
		frame.Anchored = true
		frame.Material = Enum.Material.Metal
		frame.Color = Color3.fromRGB(120, 120, 115)
		frame.Parent = model

		-- Shelves (3 levels)
		for i = 1, 3 do
			local shelf = Instance.new("Part")
			shelf.Name = `Shelf_{i}`
			shelf.Size = Vector3.new(4.8, 0.2, 1.8)
			shelf.Position = position + Vector3.new(0, i * 2, 0)
			shelf.Anchored = true
			shelf.Material = Enum.Material.Metal
			shelf.Color = Color3.fromRGB(140, 140, 135)
			shelf.Parent = model
		end
	elseif furnitureType == "table" then
		local top = Instance.new("Part")
		top.Name = "Top"
		top.Size = Vector3.new(4, 0.4, 4)
		top.Position = position + Vector3.new(0, 3, 0)
		top.Anchored = true
		top.Material = Enum.Material.Wood
		top.Color = Color3.fromRGB(100, 75, 55)
		top.Parent = model

		for i, offset in
			{
				Vector3.new(-1.6, 1.5, -1.6),
				Vector3.new(1.6, 1.5, -1.6),
				Vector3.new(-1.6, 1.5, 1.6),
				Vector3.new(1.6, 1.5, 1.6),
			}
		do
			local leg = Instance.new("Part")
			leg.Name = `Leg_{i}`
			leg.Size = Vector3.new(0.4, 3, 0.4)
			leg.Position = position + offset
			leg.Anchored = true
			leg.Material = Enum.Material.Wood
			leg.Color = Color3.fromRGB(90, 65, 45)
			leg.Parent = model
		end
	elseif furnitureType == "toilet" then
		-- Bowl
		local bowl = Instance.new("Part")
		bowl.Name = "Bowl"
		bowl.Size = Vector3.new(1.5, 1.5, 2)
		bowl.Position = position + Vector3.new(0, 0.75, 0)
		bowl.Anchored = true
		bowl.Material = Enum.Material.SmoothPlastic
		bowl.Color = Color3.fromRGB(230, 230, 225)
		bowl.Parent = model

		-- Tank
		local tank = Instance.new("Part")
		tank.Name = "Tank"
		tank.Size = Vector3.new(1.5, 1.8, 0.8)
		tank.Position = position + Vector3.new(0, 1.4, -1.2)
		tank.Anchored = true
		tank.Material = Enum.Material.SmoothPlastic
		tank.Color = Color3.fromRGB(230, 230, 225)
		tank.Parent = model
	elseif furnitureType == "sink" then
		-- Basin
		local basin = Instance.new("Part")
		basin.Name = "Basin"
		basin.Size = Vector3.new(2, 0.6, 1.5)
		basin.Position = position + Vector3.new(0, 3, 0)
		basin.Anchored = true
		basin.Material = Enum.Material.SmoothPlastic
		basin.Color = Color3.fromRGB(225, 225, 220)
		basin.Parent = model

		-- Pedestal
		local pedestal = Instance.new("Part")
		pedestal.Name = "Pedestal"
		pedestal.Size = Vector3.new(0.8, 3, 0.8)
		pedestal.Position = position + Vector3.new(0, 1.5, 0)
		pedestal.Anchored = true
		pedestal.Material = Enum.Material.SmoothPlastic
		pedestal.Color = Color3.fromRGB(225, 225, 220)
		pedestal.Parent = model
	elseif furnitureType == "monitor" then
		-- Small monitor screen on a stand
		local screen = Instance.new("Part")
		screen.Name = "Screen"
		screen.Size = Vector3.new(2, 1.5, 0.2)
		screen.Position = position + Vector3.new(0, 1, 0)
		screen.Anchored = true
		screen.Material = Enum.Material.Glass
		screen.Color = Color3.fromRGB(20, 25, 30)
		screen.Parent = model
	elseif furnitureType == "pew" then
		-- Church pew (long bench)
		local seat = Instance.new("Part")
		seat.Name = "Seat"
		seat.Size = Vector3.new(8, 0.4, 2)
		seat.Position = position + Vector3.new(0, 1.8, 0)
		seat.Anchored = true
		seat.Material = Enum.Material.Wood
		seat.Color = Color3.fromRGB(90, 60, 40)
		seat.Parent = model

		local back = Instance.new("Part")
		back.Name = "Back"
		back.Size = Vector3.new(8, 2, 0.4)
		back.Position = position + Vector3.new(0, 3, -0.8)
		back.Anchored = true
		back.Material = Enum.Material.Wood
		back.Color = Color3.fromRGB(90, 60, 40)
		back.Parent = model
	elseif furnitureType == "washer" then
		local machine = Instance.new("Part")
		machine.Name = "Washer"
		machine.Size = Vector3.new(3, 3.5, 3)
		machine.Position = position + Vector3.new(0, 1.75, 0)
		machine.Anchored = true
		machine.Material = Enum.Material.Metal
		machine.Color = Color3.fromRGB(200, 200, 195)
		machine.Parent = model

		-- Door (circle approximation)
		local door = Instance.new("Part")
		door.Name = "Door"
		door.Size = Vector3.new(1.5, 1.5, 0.2)
		door.Position = position + Vector3.new(0, 1.75, 1.5)
		door.Anchored = true
		door.Material = Enum.Material.Glass
		door.Color = Color3.fromRGB(50, 50, 50)
		door.Parent = model
	elseif furnitureType == "dryer" then
		local machine = Instance.new("Part")
		machine.Name = "Dryer"
		machine.Size = Vector3.new(3, 3.5, 3)
		machine.Position = position + Vector3.new(0, 1.75, 0)
		machine.Anchored = true
		machine.Material = Enum.Material.Metal
		machine.Color = Color3.fromRGB(190, 190, 185)
		machine.Parent = model
	elseif furnitureType == "cart" then
		-- Laundry / utility cart
		local bin = Instance.new("Part")
		bin.Name = "Bin"
		bin.Size = Vector3.new(3, 2.5, 3)
		bin.Position = position + Vector3.new(0, 2.5, 0)
		bin.Anchored = true
		bin.Material = Enum.Material.Fabric
		bin.Color = Color3.fromRGB(180, 175, 170)
		bin.Parent = model

		-- Frame
		local frame = Instance.new("Part")
		frame.Name = "Frame"
		frame.Size = Vector3.new(3.2, 1, 3.2)
		frame.Position = position + Vector3.new(0, 0.5, 0)
		frame.Anchored = true
		frame.Material = Enum.Material.Metal
		frame.Color = Color3.fromRGB(150, 150, 145)
		frame.Parent = model
	end

	model.Parent = parent
	return model
end

------------------------------------------------------------------------
-- Light Builder
------------------------------------------------------------------------

function Shared.createLight(position: Vector3, parent: Instance, brightness: number?, color: Color3?): Part
	local fixture = Instance.new("Part")
	fixture.Name = "LightFixture"
	fixture.Size = Vector3.new(1, 0.5, 1)
	fixture.Position = position
	fixture.Anchored = true
	fixture.Material = Enum.Material.SmoothPlastic
	fixture.Color = Color3.fromRGB(240, 240, 230)
	fixture.Transparency = 0.3

	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = brightness or 0.4
	pointLight.Color = color or Color3.fromRGB(255, 240, 200)
	pointLight.Range = 20
	pointLight.Shadows = true
	pointLight.Parent = fixture

	fixture.Parent = parent
	return fixture
end

------------------------------------------------------------------------
-- Hiding Spot Builder
------------------------------------------------------------------------

--[[
	Creates an interactable hiding spot with a ProximityPrompt.
	Returns the Part and a HidingSpotData table.
]]
function Shared.createHidingSpot(
	position: Vector3,
	spotType: string,
	id: string,
	parent: Instance
): (Part, HidingSpotData)
	local spot = Instance.new("Part")
	spot.Name = `HidingSpot_{id}`
	spot.Transparency = 1
	spot.CanCollide = false
	spot.Anchored = true
	spot.Size = Vector3.new(3, 5, 3)
	spot.Position = position

	spot:SetAttribute("HidingSpotId", id)
	spot:SetAttribute("SpotType", spotType)
	spot:SetAttribute("IsOccupied", false)

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Hide"
	prompt.ObjectText = spotType
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 6
	prompt.Parent = spot

	spot.Parent = parent

	local data: HidingSpotData = {
		id = id,
		position = position,
		spotType = spotType,
		isOccupied = false,
	}

	return spot, data
end

------------------------------------------------------------------------
-- Utility: Curtain Part (used in Emergency Ward bays)
------------------------------------------------------------------------

function Shared.createCurtain(position: Vector3, size: Vector3, parent: Instance, name: string?): Part
	local curtain = Instance.new("Part")
	curtain.Name = name or "Curtain"
	curtain.Size = size
	curtain.Position = position
	curtain.Anchored = true
	curtain.Material = Enum.Material.Fabric
	curtain.Color = Color3.fromRGB(150, 180, 170)
	curtain.Transparency = 0.3
	curtain.CanCollide = false
	curtain.Parent = parent
	return curtain
end

------------------------------------------------------------------------
-- Utility: Pipe (cylinder) for basement environments
------------------------------------------------------------------------

function Shared.createPipe(
	position: Vector3,
	length: number,
	radius: number,
	orientation: Vector3,
	parent: Instance,
	name: string?
): Part
	local pipe = Instance.new("Part")
	pipe.Name = name or "Pipe"
	pipe.Shape = Enum.PartType.Cylinder
	pipe.Size = Vector3.new(length, radius * 2, radius * 2)
	pipe.Position = position
	pipe.Orientation = orientation
	pipe.Anchored = true
	pipe.Material = Enum.Material.Metal
	pipe.Color = Color3.fromRGB(100, 95, 90)
	pipe.Parent = parent
	return pipe
end

return Shared
