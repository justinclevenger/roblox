-- MapGenerator.lua
-- Procedural abandoned mental asylum map generator
-- Generates a multi-floor asylum building with surrounding forest and rain
-- Place as a ModuleScript in ServerScriptService or ReplicatedStorage

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoomTemplates = require(ReplicatedStorage.Shared.RoomTemplates)

local MapGenerator = {}

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------

local SLOT_SIZE: number = 24
local FLOOR_HEIGHT: number = 16
local WALL_THICKNESS: number = 1

------------------------------------------------------------------------
-- Direction system
------------------------------------------------------------------------

local DIRECTIONS: { [string]: { x: number, z: number } } = {
	north = { x = 0, z = -1 },
	south = { x = 0, z = 1 },
	east = { x = 1, z = 0 },
	west = { x = -1, z = 0 },
}

local OPPOSITE: { [string]: string } = {
	north = "south",
	south = "north",
	east = "west",
	west = "east",
}

------------------------------------------------------------------------
-- Grid helpers
------------------------------------------------------------------------

--- Create a 2D grid of given width and depth, initialized to nil
--- @param width number
--- @param depth number
--- @return { { any? } }
local function createGrid(width: number, depth: number): { { any? } }
	local grid = {}
	for x = 1, width do
		grid[x] = {}
		for z = 1, depth do
			grid[x][z] = nil
		end
	end
	return grid
end

--- Check whether (x, z) is within grid bounds
--- @param grid { { any? } }
--- @param x number
--- @param z number
--- @return boolean
local function inBounds(grid: { { any? } }, x: number, z: number): boolean
	return x >= 1 and x <= #grid and z >= 1 and z <= #grid[1]
end

--- Check whether a grid cell is empty (nil)
--- @param grid { { any? } }
--- @param x number
--- @param z number
--- @return boolean
local function isEmpty(grid: { { any? } }, x: number, z: number): boolean
	return inBounds(grid, x, z) and grid[x][z] == nil
end

--- Convert grid coordinates and floor index to world position (center of cell)
--- @param gridX number
--- @param gridZ number
--- @param floorIndex number
--- @return Vector3
local function gridToWorld(gridX: number, gridZ: number, floorIndex: number): Vector3
	local wx = (gridX - 1) * SLOT_SIZE + SLOT_SIZE / 2
	local wy = (floorIndex - 1) * FLOOR_HEIGHT
	local wz = (gridZ - 1) * SLOT_SIZE + SLOT_SIZE / 2
	return Vector3.new(wx, wy, wz)
end

--- Get cardinal neighbors of a grid cell
--- @param x number
--- @param z number
--- @return { { x: number, z: number, dir: string } }
local function getNeighbors(x: number, z: number): { { x: number, z: number, dir: string } }
	local result = {}
	for dir, delta in DIRECTIONS do
		table.insert(result, { x = x + delta.x, z = z + delta.z, dir = dir })
	end
	return result
end

------------------------------------------------------------------------
-- Module state
------------------------------------------------------------------------

local mapData: any = nil
local generatedParts: Folder? = nil

------------------------------------------------------------------------
-- Shuffle helper (Fisher-Yates)
------------------------------------------------------------------------

local function shuffle(tbl: { any }, rng: Random)
	for i = #tbl, 2, -1 do
		local j = rng:NextInteger(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

------------------------------------------------------------------------
-- Generation: Room Placement Helper
------------------------------------------------------------------------

--- Place a room on the grid, creating a room record and marking cells
--- @param floor any -- floor data table
--- @param grid { { any? } }
--- @param roomType string
--- @param cells { { x: number, z: number } }
--- @return any -- the created room record
local function placeRoomOnGrid(
	floor: any,
	grid: { { any? } },
	roomType: string,
	cells: { { x: number, z: number } }
): any
	local roomId = #floor.rooms + 1
	local room = {
		id = roomId,
		type = roomType,
		cells = cells,
		doors = {},
		condition = "normal",
	}
	table.insert(floor.rooms, room)
	for _, cell in cells do
		grid[cell.x][cell.z] = {
			roomId = roomId,
			roomType = roomType,
			doors = {},
		}
	end
	return room
end

------------------------------------------------------------------------
-- Generation: Stairwell Placement
------------------------------------------------------------------------

--- Place a 1x1 stairwell at the given grid position
--- @param floor any
--- @param grid { { any? } }
--- @param sx number
--- @param sz number
local function placeStairwell(floor: any, grid: { { any? } }, sx: number, sz: number)
	placeRoomOnGrid(floor, grid, "Stairwell", { { x = sx, z = sz } })
end

------------------------------------------------------------------------
-- Generation: Lobby Placement
------------------------------------------------------------------------

--- Place a 2x2 lobby near the south edge of floor 1
--- @param floor any
--- @param grid { { any? } }
--- @param gridWidth number
--- @param gridDepth number
--- @param rng Random
local function placeLobby(floor: any, grid: { { any? } }, gridWidth: number, gridDepth: number, rng: Random)
	local z = gridDepth - 1
	-- Try random X positions
	local attempts = {}
	for x = 1, gridWidth - 1 do
		table.insert(attempts, x)
	end
	shuffle(attempts, rng)

	for _, x in attempts do
		-- Check all 4 cells of the 2x2 lobby
		local cells = {
			{ x = x, z = z },
			{ x = x + 1, z = z },
			{ x = x, z = z + 1 },
			{ x = x + 1, z = z + 1 },
		}
		local canPlace = true
		for _, cell in cells do
			if not isEmpty(grid, cell.x, cell.z) then
				canPlace = false
				break
			end
		end
		if canPlace then
			placeRoomOnGrid(floor, grid, "Lobby", cells)
			return
		end
	end
end

------------------------------------------------------------------------
-- Generation: Hallway Growing
------------------------------------------------------------------------

--- Grow hallway branches from the stairwell
--- @param floor any
--- @param grid { { any? } }
--- @param startX number -- stairwell X
--- @param startZ number -- stairwell Z
--- @param rng Random
--- @param gridWidth number
--- @param gridDepth number
--- @return { { x: number, z: number } }
local function growHallways(
	floor: any,
	grid: { { any? } },
	startX: number,
	startZ: number,
	rng: Random,
	gridWidth: number,
	gridDepth: number
): { { x: number, z: number } }
	local hallwayCells = {}
	local dirNames = { "north", "south", "east", "west" }

	for _, dirName in dirNames do
		local delta = DIRECTIONS[dirName]
		local seedX = startX + delta.x
		local seedZ = startZ + delta.z

		if not inBounds(grid, seedX, seedZ) or not isEmpty(grid, seedX, seedZ) then
			continue
		end

		-- Grow a branch from this seed
		local maxLen = math.max(gridWidth, gridDepth) - 2
		local branchLen = rng:NextInteger(3, math.max(3, maxLen))
		local curX = seedX
		local curZ = seedZ
		local curDir = dirName

		for _ = 1, branchLen do
			-- Stay 1 cell from grid edges to leave room for rooms on sides
			if curX <= 1 or curX >= gridWidth or curZ <= 1 or curZ >= gridDepth then
				break
			end

			if not isEmpty(grid, curX, curZ) then
				break
			end

			-- Place hallway cell
			placeRoomOnGrid(floor, grid, "Hallway", { { x = curX, z = curZ } })
			table.insert(hallwayCells, { x = curX, z = curZ })

			-- Decide next direction: 70% straight, 30% turn
			local roll = rng:NextNumber()
			if roll > 0.7 then
				-- Turn perpendicular
				local perpDirs
				if curDir == "north" or curDir == "south" then
					perpDirs = { "east", "west" }
				else
					perpDirs = { "north", "south" }
				end
				curDir = perpDirs[rng:NextInteger(1, 2)]
			end

			local nextDelta = DIRECTIONS[curDir]
			curX = curX + nextDelta.x
			curZ = curZ + nextDelta.z
		end
	end

	return hallwayCells
end

------------------------------------------------------------------------
-- Generation: Room Filling
------------------------------------------------------------------------

--- Fill empty grid cells with random room templates
--- @param floor any
--- @param grid { { any? } }
--- @param rng Random
--- @param gridWidth number
--- @param gridDepth number
local function fillRooms(floor: any, grid: { { any? } }, rng: Random, gridWidth: number, gridDepth: number)
	-- First pass: fill empty cells adjacent to hallways/lobby
	local candidates = {}
	for x = 1, gridWidth do
		for z = 1, gridDepth do
			if not isEmpty(grid, x, z) then
				continue
			end
			-- Check if adjacent to a hallway or lobby
			local adjToHallwayOrLobby = false
			for _, neighbor in getNeighbors(x, z) do
				if inBounds(grid, neighbor.x, neighbor.z) and grid[neighbor.x][neighbor.z] ~= nil then
					local cellData = grid[neighbor.x][neighbor.z]
					if cellData.roomType == "Hallway" or cellData.roomType == "Lobby" then
						adjToHallwayOrLobby = true
						break
					end
				end
			end
			if adjToHallwayOrLobby then
				table.insert(candidates, { x = x, z = z })
			end
		end
	end

	shuffle(candidates, rng)

	for _, cand in candidates do
		if not isEmpty(grid, cand.x, cand.z) then
			continue -- may have been claimed by a multi-slot room
		end

		local template = RoomTemplates.pickRandom(rng)
		local placed = false

		-- Try multi-slot rooms
		if template.gridSize.x > 1 or template.gridSize.z > 1 then
			local sizeX = template.gridSize.x
			local sizeZ = template.gridSize.z
			local cells = {}
			local canFit = true

			for dx = 0, sizeX - 1 do
				for dz = 0, sizeZ - 1 do
					local cx = cand.x + dx
					local cz = cand.z + dz
					if not isEmpty(grid, cx, cz) then
						canFit = false
						break
					end
					table.insert(cells, { x = cx, z = cz })
				end
				if not canFit then
					break
				end
			end

			if canFit then
				placeRoomOnGrid(floor, grid, template.type, cells)
				placed = true
			end
		end

		-- Fallback to 1x1 room
		if not placed then
			if template.gridSize.x == 1 and template.gridSize.z == 1 then
				placeRoomOnGrid(floor, grid, template.type, { { x = cand.x, z = cand.z } })
			else
				-- Pick a 1x1 fallback
				local fallback = RoomTemplates.pickRandom(rng)
				local tries = 0
				while (fallback.gridSize.x > 1 or fallback.gridSize.z > 1) and tries < 20 do
					fallback = RoomTemplates.pickRandom(rng)
					tries += 1
				end
				if fallback.gridSize.x == 1 and fallback.gridSize.z == 1 then
					placeRoomOnGrid(floor, grid, fallback.type, { { x = cand.x, z = cand.z } })
				else
					-- Ultimate fallback: PatientRoom
					placeRoomOnGrid(floor, grid, "PatientRoom", { { x = cand.x, z = cand.z } })
				end
			end
		end
	end

	-- Second pass: fill remaining empty cells adjacent to ANY placed room
	local changed = true
	while changed do
		changed = false
		for x = 1, gridWidth do
			for z = 1, gridDepth do
				if not isEmpty(grid, x, z) then
					continue
				end
				local adjToRoom = false
				for _, neighbor in getNeighbors(x, z) do
					if inBounds(grid, neighbor.x, neighbor.z) and grid[neighbor.x][neighbor.z] ~= nil then
						adjToRoom = true
						break
					end
				end
				if adjToRoom then
					local template = RoomTemplates.pickRandom(rng)
					-- Only place 1x1 rooms in second pass
					local tries = 0
					while (template.gridSize.x > 1 or template.gridSize.z > 1) and tries < 20 do
						template = RoomTemplates.pickRandom(rng)
						tries += 1
					end
					if template.gridSize.x == 1 and template.gridSize.z == 1 then
						placeRoomOnGrid(floor, grid, template.type, { { x = x, z = z } })
					else
						placeRoomOnGrid(floor, grid, "PatientRoom", { { x = x, z = z } })
					end
					changed = true
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Generation: Door Carving
------------------------------------------------------------------------

--- Carve doors between adjacent rooms
--- @param floor any
--- @param grid { { any? } }
--- @param gridWidth number
--- @param gridDepth number
local function carveDoors(floor: any, grid: { { any? } }, gridWidth: number, gridDepth: number)
	-- Check east and south neighbors to avoid duplicate checks
	for x = 1, gridWidth do
		for z = 1, gridDepth do
			local cellA = grid[x][z]
			if cellA == nil then
				continue
			end

			-- Check east neighbor
			if x + 1 <= gridWidth and grid[x + 1][z] ~= nil then
				local cellB = grid[x + 1][z]
				if cellA.roomId ~= cellB.roomId then
					-- Check if both templates allow doors on these edges
					local templateA = RoomTemplates.templates[cellA.roomType]
					local templateB = RoomTemplates.templates[cellB.roomType]
					local aAllows = table.find(templateA.doorPositions, "east") ~= nil
					local bAllows = table.find(templateB.doorPositions, "west") ~= nil
					if aAllows and bAllows then
						-- Record door on both cells
						table.insert(cellA.doors, { dir = "east", neighborRoomId = cellB.roomId })
						table.insert(cellB.doors, { dir = "west", neighborRoomId = cellA.roomId })
						-- Record on room objects
						local roomA = floor.rooms[cellA.roomId]
						local roomB = floor.rooms[cellB.roomId]
						table.insert(
							roomA.doors,
							{ dir = "east", fromCell = { x = x, z = z }, toRoomId = cellB.roomId }
						)
						table.insert(
							roomB.doors,
							{ dir = "west", fromCell = { x = x + 1, z = z }, toRoomId = cellA.roomId }
						)
					end
				end
			end

			-- Check south neighbor
			if z + 1 <= gridDepth and grid[x][z + 1] ~= nil then
				local cellB = grid[x][z + 1]
				if cellA.roomId ~= cellB.roomId then
					local templateA = RoomTemplates.templates[cellA.roomType]
					local templateB = RoomTemplates.templates[cellB.roomType]
					local aAllows = table.find(templateA.doorPositions, "south") ~= nil
					local bAllows = table.find(templateB.doorPositions, "north") ~= nil
					if aAllows and bAllows then
						table.insert(cellA.doors, { dir = "south", neighborRoomId = cellB.roomId })
						table.insert(cellB.doors, { dir = "north", neighborRoomId = cellA.roomId })
						local roomA = floor.rooms[cellA.roomId]
						local roomB = floor.rooms[cellB.roomId]
						table.insert(
							roomA.doors,
							{ dir = "south", fromCell = { x = x, z = z }, toRoomId = cellB.roomId }
						)
						table.insert(
							roomB.doors,
							{ dir = "north", fromCell = { x = x, z = z + 1 }, toRoomId = cellA.roomId }
						)
					end
				end
			end
		end
	end

	-- Guarantee: every room gets at least 1 door
	for _, room in floor.rooms do
		if #room.doors == 0 then
			-- Force-connect to any adjacent room
			local connected = false
			for _, cell in room.cells do
				if connected then
					break
				end
				for _, neighbor in getNeighbors(cell.x, cell.z) do
					if inBounds(grid, neighbor.x, neighbor.z) and grid[neighbor.x][neighbor.z] ~= nil then
						local neighborCell = grid[neighbor.x][neighbor.z]
						if neighborCell.roomId ~= room.id then
							local dir = neighbor.dir
							local oppDir = OPPOSITE[dir]
							-- Add door on both sides
							table.insert(
								grid[cell.x][cell.z].doors,
								{ dir = dir, neighborRoomId = neighborCell.roomId }
							)
							table.insert(neighborCell.doors, { dir = oppDir, neighborRoomId = room.id })
							table.insert(
								room.doors,
								{ dir = dir, fromCell = { x = cell.x, z = cell.z }, toRoomId = neighborCell.roomId }
							)
							local neighborRoom = floor.rooms[neighborCell.roomId]
							table.insert(
								neighborRoom.doors,
								{ dir = oppDir, fromCell = { x = neighbor.x, z = neighbor.z }, toRoomId = room.id }
							)
							connected = true
							break
						end
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Generation: Solvability
------------------------------------------------------------------------

--- Ensure all rooms are reachable from the stairwell via doors
--- @param floor any
--- @param grid { { any? } }
--- @param startX number -- stairwell X
--- @param startZ number -- stairwell Z
--- @param gridWidth number
--- @param gridDepth number
local function ensureSolvability(
	floor: any,
	grid: { { any? } },
	startX: number,
	startZ: number,
	_gridWidth: number,
	_gridDepth: number
)
	-- Build room adjacency graph from doors
	local adjacency: { [number]: { [number]: boolean } } = {}
	for _, room in floor.rooms do
		adjacency[room.id] = {}
		for _, door in room.doors do
			adjacency[room.id][door.toRoomId] = true
		end
	end

	-- Find stairwell room id
	local stairwellCell = grid[startX][startZ]
	if stairwellCell == nil then
		return
	end
	local startRoomId = stairwellCell.roomId

	-- Flood fill from stairwell room
	local visited: { [number]: boolean } = {}
	local queue = { startRoomId }
	visited[startRoomId] = true

	while #queue > 0 do
		local currentId = table.remove(queue, 1)
		if adjacency[currentId] then
			for neighborId, _ in adjacency[currentId] do
				if not visited[neighborId] then
					visited[neighborId] = true
					table.insert(queue, neighborId)
				end
			end
		end
	end

	-- Any unreachable room: force a door to the nearest reachable neighbor
	-- Repeat until all rooms are connected (handles island clusters)
	local changed = true
	while changed do
		changed = false
		for _, room in floor.rooms do
			if visited[room.id] then
				continue
			end

			-- Find nearest reachable neighbor room by checking adjacent cells
			local connected = false
			for _, cell in room.cells do
				if connected then
					break
				end
				for _, neighbor in getNeighbors(cell.x, cell.z) do
					if connected then
						break
					end
					if inBounds(grid, neighbor.x, neighbor.z) and grid[neighbor.x][neighbor.z] ~= nil then
						local neighborCell = grid[neighbor.x][neighbor.z]
						if visited[neighborCell.roomId] then
							-- Force a door
							local dir = neighbor.dir
							local oppDir = OPPOSITE[dir]
							table.insert(
								grid[cell.x][cell.z].doors,
								{ dir = dir, neighborRoomId = neighborCell.roomId }
							)
							table.insert(neighborCell.doors, { dir = oppDir, neighborRoomId = room.id })
							table.insert(
								room.doors,
								{ dir = dir, fromCell = { x = cell.x, z = cell.z }, toRoomId = neighborCell.roomId }
							)
							local neighborRoom = floor.rooms[neighborCell.roomId]
							table.insert(
								neighborRoom.doors,
								{ dir = oppDir, fromCell = { x = neighbor.x, z = neighbor.z }, toRoomId = room.id }
							)

							-- Update adjacency
							if not adjacency[room.id] then
								adjacency[room.id] = {}
							end
							adjacency[room.id][neighborCell.roomId] = true
							if not adjacency[neighborCell.roomId] then
								adjacency[neighborCell.roomId] = {}
							end
							adjacency[neighborCell.roomId][room.id] = true

							-- Mark this room and flood fill from it
							visited[room.id] = true
							local subQueue = { room.id }
							while #subQueue > 0 do
								local curId = table.remove(subQueue, 1)
								if adjacency[curId] then
									for nId, _ in adjacency[curId] do
										if not visited[nId] then
											visited[nId] = true
											table.insert(subQueue, nId)
										end
									end
								end
							end

							connected = true
							changed = true
						end
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Generation: Conditions
------------------------------------------------------------------------

--- Apply condition overlays to rooms based on floor level
--- @param floor any
--- @param rng Random
--- @param floorIndex number
local function applyConditions(floor: any, rng: Random, floorIndex: number)
	local conditionChance = math.min(0.5, 0.15 + (floorIndex - 1) * 0.15)

	for _, room in floor.rooms do
		-- Skip Stairwell, Lobby, Hallway
		if room.type == "Stairwell" or room.type == "Lobby" or room.type == "Hallway" then
			continue
		end

		if rng:NextNumber() > conditionChance then
			continue
		end

		local template = RoomTemplates.templates[room.type]
		if template == nil then
			continue
		end

		-- Pick a random non-"normal" condition from template's conditions list
		local nonNormalConditions = {}
		for _, cond in template.conditions do
			if cond ~= "normal" then
				table.insert(nonNormalConditions, cond)
			end
		end

		if #nonNormalConditions > 0 then
			room.condition = nonNormalConditions[rng:NextInteger(1, #nonNormalConditions)]
		end
	end
end

------------------------------------------------------------------------
-- Generation: Furniture
------------------------------------------------------------------------

--- Place furniture in rooms based on their template slots
--- @param floor any
--- @param rng Random
local function placeFurniture(floor: any, rng: Random)
	for _, room in floor.rooms do
		local template = RoomTemplates.templates[room.type]
		if template == nil or template.furnitureSlots == nil or #template.furnitureSlots == 0 then
			continue
		end

		room.furniture = {}
		for _, slot in template.furnitureSlots do
			-- 60% chance to place each furniture item
			if rng:NextNumber() <= 0.6 then
				local knocked = rng:NextNumber() <= 0.3
				table.insert(room.furniture, {
					name = slot.name,
					x = slot.x,
					z = slot.z,
					knocked = knocked,
				})
			end
		end
	end
end

------------------------------------------------------------------------
-- Physical Part Building
------------------------------------------------------------------------

--- Create an anchored Part with given properties
--- @param parent Instance
--- @param name string
--- @param size Vector3
--- @param position Vector3
--- @param material Enum.Material
--- @param color Color3
--- @return Part
local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	material: Enum.Material,
	color: Color3
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Material = material
	part.Color = color
	part.Parent = parent
	return part
end

--- Build a floor slab for a grid cell
--- @param parent Instance
--- @param gridX number
--- @param gridZ number
--- @param floorIndex number
--- @param material Enum.Material
--- @param color Color3
--- @param roomType string
local function buildFloor(
	parent: Instance,
	gridX: number,
	gridZ: number,
	floorIndex: number,
	material: Enum.Material,
	color: Color3,
	roomType: string
)
	local worldPos = gridToWorld(gridX, gridZ, floorIndex)
	local floorY = worldPos.Y - 0.5
	local part = makePart(
		parent,
		"Floor",
		Vector3.new(SLOT_SIZE, 1, SLOT_SIZE),
		Vector3.new(worldPos.X, floorY, worldPos.Z),
		material,
		color
	)
	part:SetAttribute("RoomType", roomType)
end

--- Build a ceiling slab for a grid cell
--- @param parent Instance
--- @param gridX number
--- @param gridZ number
--- @param floorIndex number
--- @param color Color3
local function buildCeiling(parent: Instance, gridX: number, gridZ: number, floorIndex: number, color: Color3)
	local worldPos = gridToWorld(gridX, gridZ, floorIndex)
	local ceilingY = worldPos.Y + FLOOR_HEIGHT + 0.5
	makePart(
		parent,
		"Ceiling",
		Vector3.new(SLOT_SIZE, 1, SLOT_SIZE),
		Vector3.new(worldPos.X, ceilingY, worldPos.Z),
		Enum.Material.Concrete,
		color
	)
end

--- Build a full wall on one edge of a grid cell
--- @param parent Instance
--- @param gridX number
--- @param gridZ number
--- @param floorIndex number
--- @param dir string
--- @param material Enum.Material
--- @param color Color3
local function buildWall(
	parent: Instance,
	gridX: number,
	gridZ: number,
	floorIndex: number,
	dir: string,
	material: Enum.Material,
	color: Color3
)
	local worldPos = gridToWorld(gridX, gridZ, floorIndex)
	local floorY = worldPos.Y
	local wallCenterY = floorY + FLOOR_HEIGHT / 2

	local size: Vector3
	local position: Vector3

	if dir == "north" then
		size = Vector3.new(SLOT_SIZE, FLOOR_HEIGHT, WALL_THICKNESS)
		position = Vector3.new(worldPos.X, wallCenterY, worldPos.Z - SLOT_SIZE / 2)
	elseif dir == "south" then
		size = Vector3.new(SLOT_SIZE, FLOOR_HEIGHT, WALL_THICKNESS)
		position = Vector3.new(worldPos.X, wallCenterY, worldPos.Z + SLOT_SIZE / 2)
	elseif dir == "east" then
		size = Vector3.new(WALL_THICKNESS, FLOOR_HEIGHT, SLOT_SIZE)
		position = Vector3.new(worldPos.X + SLOT_SIZE / 2, wallCenterY, worldPos.Z)
	elseif dir == "west" then
		size = Vector3.new(WALL_THICKNESS, FLOOR_HEIGHT, SLOT_SIZE)
		position = Vector3.new(worldPos.X - SLOT_SIZE / 2, wallCenterY, worldPos.Z)
	end

	makePart(parent, "Wall_" .. dir, size, position, material, color)
end

--- Build a wall with a door opening (6 stud wide, 10 stud tall)
--- @param parent Instance
--- @param gridX number
--- @param gridZ number
--- @param floorIndex number
--- @param dir string
--- @param material Enum.Material
--- @param color Color3
local function buildDoorFrame(
	parent: Instance,
	gridX: number,
	gridZ: number,
	floorIndex: number,
	dir: string,
	material: Enum.Material,
	color: Color3
)
	local worldPos = gridToWorld(gridX, gridZ, floorIndex)
	local floorY = worldPos.Y
	local doorWidth = 6
	local doorHeight = 10

	if dir == "north" or dir == "south" then
		local wallZ
		if dir == "north" then
			wallZ = worldPos.Z - SLOT_SIZE / 2
		else
			wallZ = worldPos.Z + SLOT_SIZE / 2
		end

		-- Left wall segment
		local leftWidth = (SLOT_SIZE - doorWidth) / 2
		makePart(
			parent,
			"DoorFrame_" .. dir .. "_Left",
			Vector3.new(leftWidth, FLOOR_HEIGHT, WALL_THICKNESS),
			Vector3.new(worldPos.X - SLOT_SIZE / 2 + leftWidth / 2, floorY + FLOOR_HEIGHT / 2, wallZ),
			material,
			color
		)

		-- Right wall segment
		local rightWidth = (SLOT_SIZE - doorWidth) / 2
		makePart(
			parent,
			"DoorFrame_" .. dir .. "_Right",
			Vector3.new(rightWidth, FLOOR_HEIGHT, WALL_THICKNESS),
			Vector3.new(worldPos.X + SLOT_SIZE / 2 - rightWidth / 2, floorY + FLOOR_HEIGHT / 2, wallZ),
			material,
			color
		)

		-- Lintel above door
		local lintelHeight = FLOOR_HEIGHT - doorHeight
		makePart(
			parent,
			"DoorFrame_" .. dir .. "_Lintel",
			Vector3.new(doorWidth, lintelHeight, WALL_THICKNESS),
			Vector3.new(worldPos.X, floorY + doorHeight + lintelHeight / 2, wallZ),
			material,
			color
		)
	elseif dir == "east" or dir == "west" then
		local wallX
		if dir == "east" then
			wallX = worldPos.X + SLOT_SIZE / 2
		else
			wallX = worldPos.X - SLOT_SIZE / 2
		end

		-- Left (north side) wall segment
		local segmentLength = (SLOT_SIZE - doorWidth) / 2
		makePart(
			parent,
			"DoorFrame_" .. dir .. "_Left",
			Vector3.new(WALL_THICKNESS, FLOOR_HEIGHT, segmentLength),
			Vector3.new(wallX, floorY + FLOOR_HEIGHT / 2, worldPos.Z - SLOT_SIZE / 2 + segmentLength / 2),
			material,
			color
		)

		-- Right (south side) wall segment
		makePart(
			parent,
			"DoorFrame_" .. dir .. "_Right",
			Vector3.new(WALL_THICKNESS, FLOOR_HEIGHT, segmentLength),
			Vector3.new(wallX, floorY + FLOOR_HEIGHT / 2, worldPos.Z + SLOT_SIZE / 2 - segmentLength / 2),
			material,
			color
		)

		-- Lintel above door
		local lintelHeight = FLOOR_HEIGHT - doorHeight
		makePart(
			parent,
			"DoorFrame_" .. dir .. "_Lintel",
			Vector3.new(WALL_THICKNESS, lintelHeight, doorWidth),
			Vector3.new(wallX, floorY + doorHeight + lintelHeight / 2, worldPos.Z),
			material,
			color
		)
	end
end

--- Get wall and floor colors for a room type and condition
--- @param roomType string
--- @param condition string
--- @return Color3, Color3 -- wallColor, floorColor
local function getRoomColor(roomType: string, condition: string): (Color3, Color3)
	local wallColor: Color3
	local floorColor: Color3

	if roomType == "Hallway" then
		wallColor = Color3.fromRGB(180, 175, 165)
		floorColor = Color3.fromRGB(140, 135, 125)
	elseif roomType == "Lobby" then
		wallColor = Color3.fromRGB(170, 165, 155)
		floorColor = Color3.fromRGB(160, 150, 130)
	elseif roomType == "Stairwell" then
		wallColor = Color3.fromRGB(160, 155, 150)
		floorColor = Color3.fromRGB(130, 125, 120)
	elseif roomType == "PatientRoom" then
		wallColor = Color3.fromRGB(190, 185, 175)
		floorColor = Color3.fromRGB(155, 150, 140)
	elseif roomType == "PaddedCell" then
		wallColor = Color3.fromRGB(200, 195, 180)
		floorColor = Color3.fromRGB(170, 165, 150)
	elseif roomType == "OperatingRoom" then
		wallColor = Color3.fromRGB(200, 210, 200)
		floorColor = Color3.fromRGB(170, 180, 170)
	elseif roomType == "Bathroom" then
		wallColor = Color3.fromRGB(195, 200, 195)
		floorColor = Color3.fromRGB(165, 170, 165)
	elseif roomType == "Office" then
		wallColor = Color3.fromRGB(175, 165, 145)
		floorColor = Color3.fromRGB(120, 95, 65)
	elseif roomType == "StorageRoom" then
		wallColor = Color3.fromRGB(155, 150, 140)
		floorColor = Color3.fromRGB(130, 125, 115)
	else
		wallColor = Color3.fromRGB(175, 170, 160)
		floorColor = Color3.fromRGB(135, 130, 120)
	end

	-- Condition overrides
	if condition == "flooded" then
		floorColor = Color3.fromRGB(80, 90, 100)
	elseif condition == "collapsed" then
		wallColor = Color3.fromRGB(120, 115, 105)
		floorColor = Color3.fromRGB(100, 95, 85)
	elseif condition == "boarded" then
		wallColor = Color3.fromRGB(140, 120, 90)
	end

	return wallColor, floorColor
end

--- Build a simple furniture part
--- @param parent Instance
--- @param furnitureData any
--- @param roomWorldPos Vector3
--- @param floorY number
local function buildFurniturePart(parent: Instance, furnitureData: any, roomWorldPos: Vector3, floorY: number)
	local furnitureSize = Vector3.new(3, 3, 3)
	local furnitureColor = Color3.fromRGB(100, 80, 60)
	local furnitureMaterial = Enum.Material.WoodPlanks

	-- Adjust size/color based on furniture name
	local name = furnitureData.name
	if string.find(name, "bed") then
		furnitureSize = Vector3.new(5, 2, 8)
	elseif string.find(name, "desk") or string.find(name, "table") then
		furnitureSize = Vector3.new(6, 3, 4)
	elseif string.find(name, "chair") then
		furnitureSize = Vector3.new(2, 3, 2)
	elseif string.find(name, "cabinet") or string.find(name, "shelf") then
		furnitureSize = Vector3.new(4, 5, 2)
	elseif string.find(name, "bench") then
		furnitureSize = Vector3.new(6, 2, 2)
	elseif string.find(name, "crate") then
		furnitureSize = Vector3.new(3, 3, 3)
		furnitureMaterial = Enum.Material.WoodPlanks
	elseif string.find(name, "sink") or string.find(name, "toilet") then
		furnitureSize = Vector3.new(2, 3, 2)
		furnitureColor = Color3.fromRGB(200, 200, 195)
		furnitureMaterial = Enum.Material.SmoothPlastic
	elseif string.find(name, "tray") then
		furnitureSize = Vector3.new(2, 3, 1)
		furnitureMaterial = Enum.Material.Metal
		furnitureColor = Color3.fromRGB(160, 160, 165)
	elseif string.find(name, "light") then
		furnitureSize = Vector3.new(2, 1, 2)
		furnitureMaterial = Enum.Material.Metal
		furnitureColor = Color3.fromRGB(180, 180, 185)
	elseif string.find(name, "reception") then
		furnitureSize = Vector3.new(8, 3, 4)
	end

	-- Position relative to room origin (bottom-left corner of first cell)
	local originX = roomWorldPos.X - SLOT_SIZE / 2
	local originZ = roomWorldPos.Z - SLOT_SIZE / 2
	local posX = originX + furnitureData.x
	local posZ = originZ + furnitureData.z
	local posY = floorY + furnitureSize.Y / 2

	local part = makePart(
		parent,
		"Furniture_" .. name,
		furnitureSize,
		Vector3.new(posX, posY, posZ),
		furnitureMaterial,
		furnitureColor
	)

	-- Knocked over: rotate on X axis
	if furnitureData.knocked then
		part.Orientation = Vector3.new(90, 0, 0)
		part.Position = Vector3.new(posX, floorY + furnitureSize.Z / 2, posZ)
	end
end

--- Build all physical parts for one floor
--- @param parent Instance
--- @param floor any
--- @param grid { { any? } }
--- @param floorIndex number
--- @param gridWidth number
--- @param gridDepth number
--- @param isTopFloor boolean
local function buildFloorParts(
	parent: Instance,
	floor: any,
	grid: { { any? } },
	floorIndex: number,
	gridWidth: number,
	gridDepth: number,
	isTopFloor: boolean
)
	-- Track which rooms have had furniture built (use first cell)
	local furnitureBuilt: { [number]: boolean } = {}

	for x = 1, gridWidth do
		for z = 1, gridDepth do
			local cellData = grid[x][z]
			if cellData == nil then
				continue
			end

			local room = floor.rooms[cellData.roomId]
			local template = RoomTemplates.templates[cellData.roomType]
			if template == nil then
				continue
			end

			local condition = room.condition or "normal"
			local wallColor, floorColor = getRoomColor(cellData.roomType, condition)

			-- Build floor slab
			buildFloor(parent, x, z, floorIndex, template.floorMaterial, floorColor, cellData.roomType)

			-- Build ceiling (skip on stairwell unless top floor)
			if cellData.roomType ~= "Stairwell" or isTopFloor then
				buildCeiling(parent, x, z, floorIndex, wallColor)
			end

			-- Build walls for each direction
			for dir, delta in DIRECTIONS do
				local nx = x + delta.x
				local nz = z + delta.z

				-- Check if there's a door on this edge
				local hasDoor = false
				for _, door in cellData.doors do
					if door.dir == dir then
						hasDoor = true
						break
					end
				end

				-- Check if neighbor is same room (no wall needed)
				local sameRoom = false
				if inBounds(grid, nx, nz) and grid[nx][nz] ~= nil then
					if grid[nx][nz].roomId == cellData.roomId then
						sameRoom = true
					end
				end

				if sameRoom then
					-- No wall between cells of same room
					continue
				end

				-- Avoid duplicate walls: only build shared interior edges from one side
				-- East/south cell owns the wall; west/north neighbor skips it
				local neighborExists = inBounds(grid, nx, nz) and grid[nx][nz] ~= nil
				if neighborExists and (dir == "west" or dir == "north") then
					continue
				end

				if hasDoor then
					buildDoorFrame(parent, x, z, floorIndex, dir, template.wallMaterial, wallColor)
				else
					buildWall(parent, x, z, floorIndex, dir, template.wallMaterial, wallColor)
				end
			end

			-- Build furniture for first cell of each room
			if not furnitureBuilt[cellData.roomId] and room.furniture and #room.furniture > 0 then
				furnitureBuilt[cellData.roomId] = true
				local worldPos = gridToWorld(x, z, floorIndex)
				local floorY = worldPos.Y
				for _, furnitureItem in room.furniture do
					buildFurniturePart(parent, furnitureItem, worldPos, floorY)
				end
			end
		end
	end
end

--- Build a staircase connecting one floor to the next
--- @param parent Instance
--- @param gridX number
--- @param gridZ number
--- @param floorIndex number
local function buildStaircase(parent: Instance, gridX: number, gridZ: number, floorIndex: number)
	local worldPos = gridToWorld(gridX, gridZ, floorIndex)
	local baseY = worldPos.Y
	local stairColor = Color3.fromRGB(140, 135, 130)
	local stepCount = 8
	local stepHeight = FLOOR_HEIGHT / stepCount
	local stepDepth = (SLOT_SIZE - 4) / stepCount -- stair length along Z
	local stepWidth = SLOT_SIZE - 4

	for i = 0, stepCount - 1 do
		local stepY = baseY + (i + 0.5) * stepHeight
		local stepZ = worldPos.Z - (SLOT_SIZE - 4) / 2 + (i + 0.5) * stepDepth
		makePart(
			parent,
			"Stair_" .. tostring(i + 1),
			Vector3.new(stepWidth, stepHeight, stepDepth),
			Vector3.new(worldPos.X, stepY, stepZ),
			Enum.Material.Concrete,
			stairColor
		)
	end
end

------------------------------------------------------------------------
-- Exterior
------------------------------------------------------------------------

--- Build exterior walls, roof, and ground around the building
--- @param parent Instance
--- @param gridWidth number
--- @param gridDepth number
--- @param floorCount number
--- @param rng Random
local function buildExterior(parent: Instance, gridWidth: number, gridDepth: number, floorCount: number, _rng: Random)
	local extColor = Color3.fromRGB(140, 130, 120)
	local buildingWidth = gridWidth * SLOT_SIZE
	local buildingDepth = gridDepth * SLOT_SIZE
	local buildingHeight = floorCount * FLOOR_HEIGHT
	local centerX = buildingWidth / 2
	local centerZ = buildingDepth / 2

	-- North wall
	makePart(
		parent,
		"ExteriorWall_North",
		Vector3.new(buildingWidth, buildingHeight, WALL_THICKNESS),
		Vector3.new(centerX, buildingHeight / 2, 0),
		Enum.Material.Concrete,
		extColor
	)

	-- South wall with entrance opening (centered 8-stud-wide, 12-stud-tall gap)
	local entranceWidth = 8
	local entranceHeight = 12
	local leftSegWidth = (buildingWidth - entranceWidth) / 2
	local rightSegWidth = (buildingWidth - entranceWidth) / 2

	-- Left segment
	makePart(
		parent,
		"ExteriorWall_South_Left",
		Vector3.new(leftSegWidth, buildingHeight, WALL_THICKNESS),
		Vector3.new(leftSegWidth / 2, buildingHeight / 2, buildingDepth),
		Enum.Material.Concrete,
		extColor
	)

	-- Right segment
	makePart(
		parent,
		"ExteriorWall_South_Right",
		Vector3.new(rightSegWidth, buildingHeight, WALL_THICKNESS),
		Vector3.new(buildingWidth - rightSegWidth / 2, buildingHeight / 2, buildingDepth),
		Enum.Material.Concrete,
		extColor
	)

	-- Lintel above entrance
	local lintelHeight = buildingHeight - entranceHeight
	if lintelHeight > 0 then
		makePart(
			parent,
			"ExteriorWall_South_Lintel",
			Vector3.new(entranceWidth, lintelHeight, WALL_THICKNESS),
			Vector3.new(centerX, entranceHeight + lintelHeight / 2, buildingDepth),
			Enum.Material.Concrete,
			extColor
		)
	end

	-- East wall
	makePart(
		parent,
		"ExteriorWall_East",
		Vector3.new(WALL_THICKNESS, buildingHeight, buildingDepth),
		Vector3.new(buildingWidth, buildingHeight / 2, centerZ),
		Enum.Material.Concrete,
		extColor
	)

	-- West wall
	makePart(
		parent,
		"ExteriorWall_West",
		Vector3.new(WALL_THICKNESS, buildingHeight, buildingDepth),
		Vector3.new(0, buildingHeight / 2, centerZ),
		Enum.Material.Concrete,
		extColor
	)

	-- Roof slab
	makePart(
		parent,
		"Roof",
		Vector3.new(buildingWidth, 1, buildingDepth),
		Vector3.new(centerX, buildingHeight + 0.5, centerZ),
		Enum.Material.Concrete,
		extColor
	)

	-- Ground slab under building
	makePart(
		parent,
		"BuildingGround",
		Vector3.new(buildingWidth, 1, buildingDepth),
		Vector3.new(centerX, -0.5, centerZ),
		Enum.Material.Concrete,
		Color3.fromRGB(100, 95, 85)
	)
end

------------------------------------------------------------------------
-- Forest
------------------------------------------------------------------------

--- Build a forest of trees around the building
--- @param parent Instance
--- @param gridWidth number
--- @param gridDepth number
--- @param rng Random
local function buildForest(parent: Instance, gridWidth: number, gridDepth: number, rng: Random)
	local forestRadius = 200
	local buildingWidth = gridWidth * SLOT_SIZE
	local buildingDepth = gridDepth * SLOT_SIZE
	local centerX = buildingWidth / 2
	local centerZ = buildingDepth / 2

	local groundSize = 2 * forestRadius + math.max(buildingWidth, buildingDepth)

	-- Green grass ground plane
	makePart(
		parent,
		"ForestGround",
		Vector3.new(groundSize, 1, groundSize),
		Vector3.new(centerX, -1, centerZ),
		Enum.Material.Grass,
		Color3.fromRGB(60, 100, 40)
	)

	-- Tree placement by rejection sampling
	local trees: { { x: number, z: number } } = {}
	local minSpacing = 12
	local buildingMargin = 10
	local maxAttempts = 1500

	for _ = 1, maxAttempts do
		local tx = centerX + rng:NextNumber() * (groundSize - 20) - (groundSize - 20) / 2
		local tz = centerZ + rng:NextNumber() * (groundSize - 20) - (groundSize - 20) / 2

		-- Skip if inside or near building
		if
			tx > -buildingMargin
			and tx < buildingWidth + buildingMargin
			and tz > -buildingMargin
			and tz < buildingDepth + buildingMargin
		then
			continue
		end

		-- Check minimum spacing from other trees
		local tooClose = false
		for _, existingTree in trees do
			local dx = tx - existingTree.x
			local dz = tz - existingTree.z
			if math.sqrt(dx * dx + dz * dz) < minSpacing then
				tooClose = true
				break
			end
		end

		if tooClose then
			continue
		end

		table.insert(trees, { x = tx, z = tz })

		-- Build tree
		local trunkHeight = rng:NextNumber() * 8 + 8 -- 8 to 16
		local trunkRadius = rng:NextNumber() * 0.5 + 1.0 -- 1.0 to 1.5
		local canopySize = rng:NextNumber() * 6 + 8 -- 8 to 14

		-- Trunk (cylinder oriented vertically via rotation)
		local trunk = makePart(
			parent,
			"TreeTrunk",
			Vector3.new(trunkHeight, trunkRadius * 2, trunkRadius * 2),
			Vector3.new(tx, trunkHeight / 2, tz),
			Enum.Material.WoodPlanks,
			Color3.fromRGB(rng:NextInteger(80, 110), rng:NextInteger(55, 75), rng:NextInteger(30, 50))
		)
		trunk.Shape = Enum.PartType.Cylinder
		trunk.Orientation = Vector3.new(0, 0, 90)

		-- Canopy (ball)
		local canopy = makePart(
			parent,
			"TreeCanopy",
			Vector3.new(canopySize, canopySize, canopySize),
			Vector3.new(tx, trunkHeight + canopySize / 3, tz),
			Enum.Material.Grass,
			Color3.fromRGB(rng:NextInteger(30, 70), rng:NextInteger(90, 140), rng:NextInteger(25, 55))
		)
		canopy.Shape = Enum.PartType.Ball
		canopy.CanCollide = false
	end
end

------------------------------------------------------------------------
-- Rain
------------------------------------------------------------------------

--- Build a rain particle emitter above the building
--- @param parent Instance
--- @param gridWidth number
--- @param gridDepth number
local function buildRain(parent: Instance, gridWidth: number, gridDepth: number)
	local buildingWidth = gridWidth * SLOT_SIZE
	local buildingDepth = gridDepth * SLOT_SIZE
	local centerX = buildingWidth / 2
	local centerZ = buildingDepth / 2

	local rainPart = Instance.new("Part")
	rainPart.Name = "RainEmitter"
	rainPart.Size = Vector3.new(500, 1, 500)
	rainPart.Position = Vector3.new(centerX, 80, centerZ)
	rainPart.Anchored = true
	rainPart.Transparency = 1
	rainPart.CanCollide = false
	rainPart.Parent = parent

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Rain"
	emitter.Rate = 500
	emitter.Lifetime = NumberRange.new(2, 3)
	emitter.Speed = NumberRange.new(40, 50)
	emitter.EmissionDirection = Enum.NormalId.Bottom
	emitter.SpreadAngle = Vector2.new(5, 5)
	emitter.Color = ColorSequence.new(Color3.fromRGB(180, 190, 200))
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1.0),
	})
	emitter.Parent = rainPart
end

------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------

--- Generate a procedural asylum map
--- @param config { floors: number?, gridWidth: number?, gridDepth: number?, seed: number? }?
--- @return any -- mapData table
function MapGenerator.generate(config: { floors: number?, gridWidth: number?, gridDepth: number?, seed: number? }?): any
	config = config or {}
	local floorCount = config.floors or 2
	local gridWidth = math.max(5, config.gridWidth or 8)
	local gridDepth = math.max(5, config.gridDepth or 6)
	local seed = config.seed or os.time()

	-- Cleanup previous generation
	MapGenerator.cleanup()

	-- Init RNG
	local rng = Random.new(seed)

	-- Create output folder
	generatedParts = Instance.new("Folder")
	generatedParts.Name = "GeneratedAsylum"
	generatedParts.Parent = workspace

	-- Init mapData
	mapData = {
		floors = {},
		stairwellPos = nil,
		seed = seed,
		gridWidth = gridWidth,
		gridDepth = gridDepth,
		floorCount = floorCount,
	}

	-- Pick stairwell position (interior, away from edges)
	local stairX = rng:NextInteger(3, math.max(3, gridWidth - 2))
	local stairZ = rng:NextInteger(3, math.max(3, gridDepth - 2))
	mapData.stairwellPos = { x = stairX, z = stairZ }

	-- Generate each floor
	for floorIndex = 1, floorCount do
		local floor = {
			index = floorIndex,
			rooms = {},
			grid = nil,
		}
		local grid = createGrid(gridWidth, gridDepth)
		floor.grid = grid

		-- Step 3: Place stairwell on every floor at same position
		placeStairwell(floor, grid, stairX, stairZ)

		-- Step 4: Place lobby on floor 1
		if floorIndex == 1 then
			placeLobby(floor, grid, gridWidth, gridDepth, rng)
		end

		-- Step 5: Grow hallways from stairwell
		growHallways(floor, grid, stairX, stairZ, rng, gridWidth, gridDepth)

		-- Step 6: Fill empty slots with rooms
		fillRooms(floor, grid, rng, gridWidth, gridDepth)

		-- Step 7: Carve doors
		carveDoors(floor, grid, gridWidth, gridDepth)

		-- Step 8: Ensure solvability
		ensureSolvability(floor, grid, stairX, stairZ, gridWidth, gridDepth)

		-- Step 9: Apply conditions
		applyConditions(floor, rng, floorIndex)

		-- Step 10: Place furniture
		placeFurniture(floor, rng)

		table.insert(mapData.floors, floor)
	end

	-- Step 11: Build physical parts (floors, walls, ceilings + staircases)
	for floorIndex, floor in mapData.floors do
		local floorFolder = Instance.new("Folder")
		floorFolder.Name = "Floor_" .. tostring(floorIndex)
		floorFolder.Parent = generatedParts

		local isTopFloor = (floorIndex == floorCount)
		buildFloorParts(floorFolder, floor, floor.grid, floorIndex, gridWidth, gridDepth, isTopFloor)

		-- Build staircase on every floor except the top floor
		if not isTopFloor then
			buildStaircase(floorFolder, stairX, stairZ, floorIndex)
		end
	end

	-- Step 12: Build exterior shell
	local exteriorFolder = Instance.new("Folder")
	exteriorFolder.Name = "Exterior"
	exteriorFolder.Parent = generatedParts
	buildExterior(exteriorFolder, gridWidth, gridDepth, floorCount, rng)

	-- Step 13: Build forest
	local forestFolder = Instance.new("Folder")
	forestFolder.Name = "Forest"
	forestFolder.Parent = generatedParts
	buildForest(forestFolder, gridWidth, gridDepth, rng)

	-- Step 14: Add rain
	local weatherFolder = Instance.new("Folder")
	weatherFolder.Name = "Weather"
	weatherFolder.Parent = generatedParts
	buildRain(weatherFolder, gridWidth, gridDepth)

	return mapData
end

--- Get stairwell world positions per floor
--- @return { [number]: { Vector3 } }
function MapGenerator.getFloorConnections(): { [number]: { Vector3 } }
	local connections: { [number]: { Vector3 } } = {}
	if mapData == nil or mapData.stairwellPos == nil then
		return connections
	end

	for floorIndex = 1, mapData.floorCount do
		local worldPos = gridToWorld(mapData.stairwellPos.x, mapData.stairwellPos.z, floorIndex)
		connections[floorIndex] = { worldPos }
	end

	return connections
end

--- Destroy all generated parts and clear map data
function MapGenerator.cleanup()
	if generatedParts then
		generatedParts:Destroy()
		generatedParts = nil
	end
	mapData = nil
end

return MapGenerator
