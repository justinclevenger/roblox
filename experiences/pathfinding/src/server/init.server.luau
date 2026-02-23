--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapGenerator = require(ReplicatedStorage.Shared.MapGenerator)
local Pathfinding = require(ReplicatedStorage.Shared.Pathfinding)

-- ── Generate the Asylum Map ──────────────────────────────────────────────
print("[Server] Generating asylum map...")

local mapData = MapGenerator.generate({
	floors = 2,
	gridWidth = 8,
	gridDepth = 6,
	seed = 42,
})

local _floorConnections = MapGenerator.getFloorConnections()

print(
	("[Server] Asylum generated: %d floors, stairwell at (%d, %d)"):format(
		mapData.floorCount,
		mapData.stairwellPos.x,
		mapData.stairwellPos.z
	)
)

for i = 1, mapData.floorCount do
	print(("[Server]   Floor %d: %d rooms"):format(i, #mapData.floors[i].rooms))
end

-- ── Spawn Players Inside the Lobby ───────────────────────────────────────
-- Find the lobby on floor 1 to set spawn position
local SLOT_SIZE = 24
local lobbySpawnPos: Vector3? = nil

for _, room in mapData.floors[1].rooms do
	if room.type == "Lobby" then
		local cell = room.cells[1]
		lobbySpawnPos =
			Vector3.new((cell.x - 1) * SLOT_SIZE + SLOT_SIZE / 2, 3, (cell.z - 1) * SLOT_SIZE + SLOT_SIZE / 2)
		break
	end
end

-- Move SpawnLocation to lobby
local spawnLocation = workspace:FindFirstChild("SpawnLocation")
if spawnLocation and lobbySpawnPos then
	spawnLocation.Position = lobbySpawnPos
	print(("[Server] Spawn set to lobby at %s"):format(tostring(lobbySpawnPos)))
end

-- ── NPC Setup ────────────────────────────────────────────────────────────
-- Create a simple NPC that wanders the asylum
local function createNPC(name: string, spawnPos: Vector3): Model
	local npcModel = Instance.new("Model")
	npcModel.Name = name

	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = npcModel

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Position = spawnPos
	rootPart.Anchored = false
	rootPart.CanCollide = true
	rootPart.Parent = npcModel

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 1)
	head.Position = spawnPos + Vector3.new(0, 1.5, 0)
	head.Anchored = false
	head.CanCollide = false
	head.Color = Color3.fromRGB(200, 180, 160)
	head.Parent = npcModel

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = spawnPos
	torso.Anchored = false
	torso.CanCollide = false
	torso.Color = Color3.fromRGB(100, 100, 110)
	torso.Parent = npcModel

	npcModel.PrimaryPart = rootPart
	npcModel.Parent = workspace

	return npcModel
end

-- Spawn an NPC near the stairwell on floor 1
local stairWorldPos = Vector3.new(
	(mapData.stairwellPos.x - 1) * SLOT_SIZE + SLOT_SIZE / 2,
	3,
	(mapData.stairwellPos.z - 1) * SLOT_SIZE + SLOT_SIZE / 2
)
local npc = createNPC("AsylumWanderer", stairWorldPos)
print("[Server] NPC spawned at stairwell")

-- Simple wander loop for the NPC
task.spawn(function()
	local humanoid = npc:WaitForChild("Humanoid") :: Humanoid
	local rootPart = npc:WaitForChild("HumanoidRootPart") :: BasePart
	humanoid.WalkSpeed = 8

	while humanoid.Health > 0 do
		-- Pick a random walkable position on floor 1
		local target = Pathfinding.getRandomWalkablePosition(rootPart.Position, 15, 40)
		if target then
			local rawPath = Pathfinding.findPath(rootPart.Position, target)
			if rawPath then
				local path = Pathfinding.smoothPath(rawPath, 4)
				for _, waypoint in path do
					humanoid:MoveTo(waypoint)
					local startTime = tick()
					while (rootPart.Position - waypoint).Magnitude > 5 and tick() - startTime < 3 do
						task.wait(0.1)
					end
				end
			end
		end

		-- Pause between wanders
		task.wait(1 + math.random() * 2)
	end
end)

-- ── Player Join Handling ─────────────────────────────────────────────────
Players.PlayerAdded:Connect(function(player: Player)
	print(("[Server] %s joined the asylum"):format(player.Name))
end)

Players.PlayerRemoving:Connect(function(player: Player)
	print(("[Server] %s left the asylum"):format(player.Name))
end)
