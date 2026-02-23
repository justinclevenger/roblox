--!strict

--[[
	Loot Spawner

	Handles spawning loot items across the level based on loot tables.
	Supports guaranteed spawns, probability-based spawns, and randomized
	placement for items like the fuel canister.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local LootSpawner = {}
LootSpawner.__index = LootSpawner

export type LootSpawner = typeof(setmetatable(
	{} :: {
		spawnedItems: { [string]: Instance },
		lootTable: { Types.LootSpawn },
		onPickupCallback: ((player: Player, item: Types.InventoryItem) -> boolean)?,
	},
	LootSpawner
))

function LootSpawner.new(): LootSpawner
	local self = setmetatable({
		spawnedItems = {},
		lootTable = {},
		onPickupCallback = nil,
	}, LootSpawner)

	return self
end

function LootSpawner.loadLevelLoot(self: LootSpawner, levelName: string)
	if levelName == "st-marens-hospital" then
		self:loadHospitalLoot()
	end
	-- TODO: Add loot tables for other levels
end

function LootSpawner.loadHospitalLoot(self: LootSpawner)
	-- Level 1: St. Maren's Hospital loot table
	-- Positions are placeholders — set during level geometry creation
	self.lootTable = {
		-- Ambulance Bay (guaranteed starter loot)
		{ itemType = "Battery", position = Vector3.new(0, 1, -50), chance = 1, guaranteed = true },
		{ itemType = "Bandage", position = Vector3.new(2, 1, -50), chance = 1, guaranteed = true },

		-- Security Office
		{ itemType = "Flashlight", position = Vector3.new(-20, 1, 0), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(-18, 1, 0), chance = 0.5, guaranteed = false },

		-- Emergency Ward
		{ itemType = "Bandage", position = Vector3.new(20, 1, 5), chance = 1, guaranteed = true },
		{ itemType = "Bandage", position = Vector3.new(25, 1, 5), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(22, 1, 5), chance = 0.4, guaranteed = false },

		-- Pharmacy
		{ itemType = "Bandage", position = Vector3.new(-15, 1, -20), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(-13, 1, -20), chance = 0.6, guaranteed = false },

		-- Upper Floor
		{ itemType = "Battery", position = Vector3.new(0, 11, 10), chance = 0.5, guaranteed = false },
		{ itemType = "Bandage", position = Vector3.new(5, 11, 15), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(-5, 11, 0), chance = 1, guaranteed = true },
		{ itemType = "Bandage", position = Vector3.new(10, 11, 20), chance = 0.4, guaranteed = false },

		-- Room 203
		{ itemType = "Medkit", position = Vector3.new(15, 11, 10), chance = 1, guaranteed = true },

		-- Nurse Station
		{ itemType = "Medkit", position = Vector3.new(-25, 11, 30), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(-23, 11, 30), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(-21, 11, 30), chance = 1, guaranteed = true },

		-- Basement
		{ itemType = "Bandage", position = Vector3.new(0, -9, 0), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(5, -9, 0), chance = 1, guaranteed = true },
		{ itemType = "Battery", position = Vector3.new(15, -9, -10), chance = 1, guaranteed = true },
		{ itemType = "Flare", position = Vector3.new(20, -9, -15), chance = 0.4, guaranteed = false },
		{ itemType = "Bandage", position = Vector3.new(-10, -9, 5), chance = 0.4, guaranteed = false },

		-- Chapel
		{ itemType = "Flare", position = Vector3.new(-10, 1, -30), chance = 0.3, guaranteed = false },

		-- Room 206
		{ itemType = "Flare", position = Vector3.new(20, 11, 25), chance = 0.5, guaranteed = false },
	}
end

function LootSpawner.spawnAll(self: LootSpawner, playerCount: number)
	-- Scale loot quantity based on player count
	local lootMultiplier = 1
	if playerCount == 2 then
		lootMultiplier = 1.3
	elseif playerCount >= 3 then
		lootMultiplier = 1.5
	end

	for _, loot in self.lootTable do
		local shouldSpawn = loot.guaranteed or (math.random() <= loot.chance * lootMultiplier)

		if shouldSpawn then
			self:spawnItem(loot)
		end
	end

	-- Randomize fuel canister location (Boiler Room or Storage)
	local fuelInBoilerRoom = math.random() > 0.5
	local fuelPosition = if fuelInBoilerRoom
		then Vector3.new(-15, -9, 10) -- Boiler Room placeholder
		else Vector3.new(20, -9, -20) -- Storage placeholder

	self:spawnItem({
		itemType = "FuelCanister",
		position = fuelPosition,
		chance = 1,
		guaranteed = true,
	})
end

function LootSpawner.spawnItem(self: LootSpawner, loot: Types.LootSpawn)
	local id = `{loot.itemType}_{math.random(10000, 99999)}`

	-- Create item model
	local itemModel = Instance.new("Model")
	itemModel.Name = id

	-- Create the visual part based on item type
	local part = Instance.new("Part")
	part.Name = "ItemPart"
	part.Anchored = true
	part.CanCollide = false
	part.Position = loot.position + Vector3.new(0, 1, 0) -- Slight hover above ground

	-- Size and color per item type
	if loot.itemType == "Battery" then
		part.Size = Vector3.new(0.4, 0.8, 0.4)
		part.Color = Color3.fromRGB(50, 180, 50)
		part.Material = Enum.Material.SmoothPlastic
	elseif loot.itemType == "Bandage" then
		part.Size = Vector3.new(0.6, 0.3, 0.4)
		part.Color = Color3.fromRGB(220, 220, 220)
		part.Material = Enum.Material.Fabric
	elseif loot.itemType == "Medkit" then
		part.Size = Vector3.new(0.8, 0.5, 0.6)
		part.Color = Color3.fromRGB(200, 30, 30)
		part.Material = Enum.Material.SmoothPlastic
	elseif loot.itemType == "Flare" then
		part.Size = Vector3.new(0.3, 1.0, 0.3)
		part.Color = Color3.fromRGB(200, 50, 30)
		part.Material = Enum.Material.Neon
	elseif loot.itemType == "Flashlight" then
		part.Size = Vector3.new(0.4, 0.4, 1.2)
		part.Color = Color3.fromRGB(60, 60, 65)
		part.Material = Enum.Material.Metal
	elseif loot.itemType == "FuelCanister" then
		part.Size = Vector3.new(0.8, 1.0, 0.5)
		part.Color = Color3.fromRGB(180, 30, 30)
		part.Material = Enum.Material.Metal
	else
		part.Size = Vector3.new(0.5, 0.5, 0.5)
		part.Color = Color3.fromRGB(200, 200, 200)
		part.Material = Enum.Material.SmoothPlastic
	end

	part.Parent = itemModel

	-- Add glow effect for visibility in darkness
	local light = Instance.new("PointLight")
	light.Brightness = 0.5
	light.Range = 6
	light.Color = Color3.fromRGB(255, 255, 200)
	light.Parent = part

	-- Add subtle highlight for item visibility
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.8
	highlight.OutlineTransparency = 0.3
	highlight.FillColor = Color3.fromRGB(255, 255, 200)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 150)
	highlight.Parent = itemModel

	-- Add ProximityPrompt for pickup
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Pick up"
	prompt.ObjectText = loot.itemType
	prompt.MaxActivationDistance = 8
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.Parent = part

	-- Store item data as attributes
	part:SetAttribute("ItemId", id)
	part:SetAttribute("ItemType", loot.itemType)

	itemModel.PrimaryPart = part
	itemModel.Parent = workspace

	-- Connect pickup handler
	prompt.Triggered:Connect(function(player: Player)
		self:onItemPickedUp(player, id, loot.itemType, itemModel)
	end)

	self.spawnedItems[id] = itemModel
	print(`[LootSpawner] Spawned {loot.itemType} at {loot.position}`)
end

function LootSpawner.onItemPickedUp(
	self: LootSpawner,
	player: Player,
	id: string,
	itemType: string,
	_itemModel: Instance
)
	local item: Types.InventoryItem = {
		id = id,
		name = itemType,
		itemType = itemType :: any,
	}

	if self.onPickupCallback then
		local success = self.onPickupCallback(player, item)
		if success then
			self:despawnItem(id)
			print(`[LootSpawner] {player.Name} picked up {itemType} ({id})`)
		else
			print(`[LootSpawner] {player.Name} could not pick up {itemType} — inventory full or rejected`)
		end
	else
		-- No callback registered; despawn by default
		self:despawnItem(id)
		warn(`[LootSpawner] No onPickupCallback set — {itemType} despawned without inventory handling`)
	end
end

function LootSpawner.despawnItem(self: LootSpawner, id: string)
	local item = self.spawnedItems[id]
	if item then
		item:Destroy()
		self.spawnedItems[id] = nil
	end
end

function LootSpawner.cleanup(self: LootSpawner)
	for _id, item in self.spawnedItems do
		if item then
			item:Destroy()
		end
	end
	table.clear(self.spawnedItems)
end

return LootSpawner
