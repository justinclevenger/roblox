--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Types = require(ReplicatedStorage.Shared.Types)

local SLOT_COUNT = 4
local SLOT_SIZE = 40
local SLOT_GAP = 4
local KEY_ITEM_SIZE = 24
local KEY_ITEM_GAP = 3
local CONTAINER_PADDING_BOTTOM = 16

local COLOR_SLOT_BG = Color3.fromRGB(20, 20, 20)
local COLOR_SLOT_BORDER = Color3.fromRGB(55, 55, 55)
local COLOR_SLOT_SELECTED = Color3.fromRGB(160, 160, 160)
local COLOR_TEXT = Color3.fromRGB(200, 200, 200)
local COLOR_KEY_ITEM_BG = Color3.fromRGB(35, 35, 35)
local COLOR_KEY_ITEM_BORDER = Color3.fromRGB(70, 60, 50)

-- Item-specific colors for abbreviation backgrounds
local ITEM_COLORS: { [string]: Color3 } = {
	Battery = Color3.fromRGB(40, 90, 40),
	Bandage = Color3.fromRGB(140, 140, 140),
	Medkit = Color3.fromRGB(120, 30, 30),
	Flare = Color3.fromRGB(160, 80, 20),
	Flashlight = Color3.fromRGB(140, 130, 30),
	FuelCanister = Color3.fromRGB(90, 20, 20),
}

-- Abbreviations for item names
local ITEM_ABBREVS: { [string]: string } = {
	Battery = "BAT",
	Bandage = "BND",
	Medkit = "MED",
	Flare = "FLR",
	Flashlight = "FLH",
	FuelCanister = "FUL",
}

local SELECT_TWEEN_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local InventoryDisplay = {}
InventoryDisplay.__index = InventoryDisplay

export type InventoryDisplay = typeof(setmetatable(
	{} :: {
		container: Frame,
		slots: { Frame },
		slotLabels: { TextLabel },
		slotStrokes: { UIStroke },
		keyItemContainer: Frame,
		keyItemFrames: { Frame },
		selectedIndex: number,
	},
	InventoryDisplay
))

function InventoryDisplay.new(parent: ScreenGui): InventoryDisplay
	local totalWidth = SLOT_COUNT * SLOT_SIZE + (SLOT_COUNT - 1) * SLOT_GAP

	-- Main container centered at bottom
	local container = Instance.new("Frame")
	container.Name = "InventoryDisplay"
	container.Size = UDim2.fromOffset(totalWidth, SLOT_SIZE)
	container.Position = UDim2.new(0.5, 0, 1, -CONTAINER_PADDING_BOTTOM)
	container.AnchorPoint = Vector2.new(0.5, 1)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, SLOT_GAP)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = container

	-- Create inventory slots
	local slots: { Frame } = {}
	local slotLabels: { TextLabel } = {}
	local slotStrokes: { UIStroke } = {}

	for i = 1, SLOT_COUNT do
		local slot = Instance.new("Frame")
		slot.Name = `Slot_{i}`
		slot.Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE)
		slot.BackgroundColor3 = COLOR_SLOT_BG
		slot.BackgroundTransparency = 0.2
		slot.BorderSizePixel = 0
		slot.LayoutOrder = i
		slot.Parent = container

		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 4)
		slotCorner.Parent = slot

		local stroke = Instance.new("UIStroke")
		stroke.Color = COLOR_SLOT_BORDER
		stroke.Thickness = 1
		stroke.Transparency = 0.3
		stroke.Parent = slot

		-- Item label (abbreviation)
		local label = Instance.new("TextLabel")
		label.Name = "ItemLabel"
		label.Size = UDim2.fromScale(1, 1)
		label.Position = UDim2.fromScale(0, 0)
		label.BackgroundTransparency = 1
		label.Text = ""
		label.TextColor3 = COLOR_TEXT
		label.TextSize = 10
		label.Font = Enum.Font.GothamBold
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Parent = slot

		-- Slot number indicator (subtle, top-right)
		local slotNumber = Instance.new("TextLabel")
		slotNumber.Name = "SlotNumber"
		slotNumber.Size = UDim2.fromOffset(12, 12)
		slotNumber.Position = UDim2.new(1, -2, 0, 2)
		slotNumber.AnchorPoint = Vector2.new(1, 0)
		slotNumber.BackgroundTransparency = 1
		slotNumber.Text = tostring(i)
		slotNumber.TextColor3 = Color3.fromRGB(80, 80, 80)
		slotNumber.TextSize = 8
		slotNumber.Font = Enum.Font.Gotham
		slotNumber.TextXAlignment = Enum.TextXAlignment.Right
		slotNumber.TextYAlignment = Enum.TextYAlignment.Top
		slotNumber.Parent = slot

		slots[i] = slot
		slotLabels[i] = label
		slotStrokes[i] = stroke
	end

	-- Key items container (small icons above inventory)
	local keyItemContainer = Instance.new("Frame")
	keyItemContainer.Name = "KeyItems"
	keyItemContainer.Size = UDim2.fromOffset(totalWidth, KEY_ITEM_SIZE)
	keyItemContainer.Position = UDim2.new(0.5, 0, 1, -CONTAINER_PADDING_BOTTOM - SLOT_SIZE - 6)
	keyItemContainer.AnchorPoint = Vector2.new(0.5, 1)
	keyItemContainer.BackgroundTransparency = 1
	keyItemContainer.BorderSizePixel = 0
	keyItemContainer.Parent = parent

	local keyLayout = Instance.new("UIListLayout")
	keyLayout.FillDirection = Enum.FillDirection.Horizontal
	keyLayout.Padding = UDim.new(0, KEY_ITEM_GAP)
	keyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	keyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	keyLayout.Parent = keyItemContainer

	local self = setmetatable({
		container = container,
		slots = slots,
		slotLabels = slotLabels,
		slotStrokes = slotStrokes,
		keyItemContainer = keyItemContainer,
		keyItemFrames = {} :: { Frame },
		selectedIndex = 1,
	}, InventoryDisplay)

	-- Select the first slot by default
	self:selectSlot(1)

	return self
end

function InventoryDisplay.update(self: InventoryDisplay, inventory: { Types.InventoryItem }, keyItems: { string })
	-- Update inventory slots
	for i = 1, SLOT_COUNT do
		local slot = self.slots[i]
		local label = self.slotLabels[i]

		if i <= #inventory then
			local item = inventory[i]
			local itemName = if typeof(item) == "table" then (item :: any).name or "" else tostring(item)
			local abbrev = ITEM_ABBREVS[itemName] or string.sub(itemName, 1, 3):upper()
			local itemColor = ITEM_COLORS[itemName] or Color3.fromRGB(50, 50, 50)

			label.Text = abbrev
			label.Visible = true

			-- Set item background color (subtle)
			slot.BackgroundColor3 = itemColor
			slot.BackgroundTransparency = 0.4
		else
			-- Empty slot
			label.Text = ""
			label.Visible = false
			slot.BackgroundColor3 = COLOR_SLOT_BG
			slot.BackgroundTransparency = 0.2
		end
	end

	-- Update key items display
	self:_updateKeyItems(keyItems)
end

function InventoryDisplay._updateKeyItems(self: InventoryDisplay, keyItems: { string })
	-- Clear existing key item frames
	for _, frame in self.keyItemFrames do
		frame:Destroy()
	end
	self.keyItemFrames = {}

	-- Create new key item icons
	for i, itemName in keyItems do
		local frame = Instance.new("Frame")
		frame.Name = `KeyItem_{itemName}`
		frame.Size = UDim2.fromOffset(KEY_ITEM_SIZE, KEY_ITEM_SIZE)
		frame.BackgroundColor3 = COLOR_KEY_ITEM_BG
		frame.BackgroundTransparency = 0.3
		frame.BorderSizePixel = 0
		frame.LayoutOrder = i
		frame.Parent = self.keyItemContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 3)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Color = COLOR_KEY_ITEM_BORDER
		stroke.Thickness = 1
		stroke.Transparency = 0.4
		stroke.Parent = frame

		-- Key icon label
		local keyLabel = Instance.new("TextLabel")
		keyLabel.Name = "Label"
		keyLabel.Size = UDim2.fromScale(1, 1)
		keyLabel.BackgroundTransparency = 1
		keyLabel.Text = string.sub(itemName, 1, 1):upper()
		keyLabel.TextColor3 = Color3.fromRGB(180, 160, 120)
		keyLabel.TextSize = 11
		keyLabel.Font = Enum.Font.GothamBold
		keyLabel.TextXAlignment = Enum.TextXAlignment.Center
		keyLabel.TextYAlignment = Enum.TextYAlignment.Center
		keyLabel.Parent = frame

		table.insert(self.keyItemFrames, frame)
	end
end

function InventoryDisplay.selectSlot(self: InventoryDisplay, index: number)
	local clamped = math.clamp(index, 1, SLOT_COUNT)
	self.selectedIndex = clamped

	for i = 1, SLOT_COUNT do
		local stroke = self.slotStrokes[i]
		if i == clamped then
			-- Selected slot: brighter border
			TweenService:Create(stroke, SELECT_TWEEN_INFO, {
				Color = COLOR_SLOT_SELECTED,
				Transparency = 0,
			}):Play()
		else
			-- Unselected slot: dim border
			TweenService:Create(stroke, SELECT_TWEEN_INFO, {
				Color = COLOR_SLOT_BORDER,
				Transparency = 0.3,
			}):Play()
		end
	end
end

return InventoryDisplay
