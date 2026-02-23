--!strict

local RunService = game:GetService("RunService")

local PIP_SIZE = UDim2.fromOffset(20, 20)
local PIP_GAP = 4
local MAX_PIPS = 4

local COLOR_FILLED = Color3.fromRGB(180, 30, 30)
local COLOR_EMPTY = Color3.fromRGB(40, 40, 40)
local COLOR_BORDER = Color3.fromRGB(60, 60, 60)
local COLOR_SPLATTER = Color3.fromRGB(120, 10, 10)

local PULSE_SPEED = 3
local CONTAINER_PADDING = 16

local HealthDisplay = {}
HealthDisplay.__index = HealthDisplay

export type HealthDisplay = typeof(setmetatable(
	{} :: {
		container: Frame,
		pips: { Frame },
		pipFills: { Frame },
		splatterOverlay: Frame,
		bleedingActive: boolean,
		pulseConnection: RBXScriptConnection?,
		currentHealth: number,
	},
	HealthDisplay
))

function HealthDisplay.new(parent: ScreenGui): HealthDisplay
	-- Container anchored to bottom-left
	local container = Instance.new("Frame")
	container.Name = "HealthDisplay"
	container.Size = UDim2.fromOffset(MAX_PIPS * (20 + PIP_GAP) - PIP_GAP + 8, 28)
	container.Position = UDim2.new(0, CONTAINER_PADDING, 1, -CONTAINER_PADDING - 28)
	container.AnchorPoint = Vector2.new(0, 0)
	container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	container.BackgroundTransparency = 0.4
	container.BorderSizePixel = 0
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 4)
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = COLOR_BORDER
	containerStroke.Thickness = 1
	containerStroke.Transparency = 0.5
	containerStroke.Parent = container

	-- Pip layout
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, PIP_GAP)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = container

	-- Create pip frames
	local pips: { Frame } = {}
	local pipFills: { Frame } = {}

	for i = 1, MAX_PIPS do
		local pip = Instance.new("Frame")
		pip.Name = `Pip_{i}`
		pip.Size = PIP_SIZE
		pip.BackgroundColor3 = COLOR_EMPTY
		pip.BorderSizePixel = 0
		pip.LayoutOrder = i
		pip.Parent = container

		local pipCorner = Instance.new("UICorner")
		pipCorner.CornerRadius = UDim.new(0, 3)
		pipCorner.Parent = pip

		local pipStroke = Instance.new("UIStroke")
		pipStroke.Color = COLOR_BORDER
		pipStroke.Thickness = 1
		pipStroke.Transparency = 0.6
		pipStroke.Parent = pip

		-- Fill overlay inside the pip
		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.fromScale(1, 1)
		fill.Position = UDim2.fromScale(0, 0)
		fill.BackgroundColor3 = COLOR_FILLED
		fill.BackgroundTransparency = 0
		fill.BorderSizePixel = 0
		fill.Visible = true
		fill.Parent = pip

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 3)
		fillCorner.Parent = fill

		pips[i] = pip
		pipFills[i] = fill
	end

	-- Blood splatter overlay for critical health
	local splatterOverlay = Instance.new("Frame")
	splatterOverlay.Name = "BloodSplatter"
	splatterOverlay.Size = UDim2.fromScale(1, 1)
	splatterOverlay.Position = UDim2.fromScale(0, 0)
	splatterOverlay.BackgroundTransparency = 1
	splatterOverlay.BorderSizePixel = 0
	splatterOverlay.ZIndex = 5
	splatterOverlay.Parent = parent

	-- Top edge
	local topEdge = Instance.new("ImageLabel")
	topEdge.Name = "TopEdge"
	topEdge.Size = UDim2.new(1, 0, 0, 80)
	topEdge.Position = UDim2.fromScale(0, 0)
	topEdge.BackgroundColor3 = COLOR_SPLATTER
	topEdge.BackgroundTransparency = 1
	topEdge.BorderSizePixel = 0
	topEdge.ImageTransparency = 1
	topEdge.Parent = splatterOverlay

	-- Use a gradient to simulate the blood vignette since we may not have image assets
	local topGradient = Instance.new("UIGradient")
	topGradient.Color = ColorSequence.new(COLOR_SPLATTER)
	topGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 1),
	})
	topGradient.Rotation = 90
	topGradient.Parent = topEdge

	-- Bottom edge
	local bottomEdge = Instance.new("Frame")
	bottomEdge.Name = "BottomEdge"
	bottomEdge.Size = UDim2.new(1, 0, 0, 80)
	bottomEdge.Position = UDim2.new(0, 0, 1, -80)
	bottomEdge.BackgroundColor3 = COLOR_SPLATTER
	bottomEdge.BackgroundTransparency = 1
	bottomEdge.BorderSizePixel = 0
	bottomEdge.Parent = splatterOverlay

	local bottomGradient = Instance.new("UIGradient")
	bottomGradient.Color = ColorSequence.new(COLOR_SPLATTER)
	bottomGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 0.3),
	})
	bottomGradient.Rotation = 90
	bottomGradient.Parent = bottomEdge

	-- Left edge
	local leftEdge = Instance.new("Frame")
	leftEdge.Name = "LeftEdge"
	leftEdge.Size = UDim2.new(0, 60, 1, 0)
	leftEdge.Position = UDim2.fromScale(0, 0)
	leftEdge.BackgroundColor3 = COLOR_SPLATTER
	leftEdge.BackgroundTransparency = 1
	leftEdge.BorderSizePixel = 0
	leftEdge.Parent = splatterOverlay

	local leftGradient = Instance.new("UIGradient")
	leftGradient.Color = ColorSequence.new(COLOR_SPLATTER)
	leftGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.6, 0.85),
		NumberSequenceKeypoint.new(1, 1),
	})
	leftGradient.Rotation = 0
	leftGradient.Parent = leftEdge

	-- Right edge
	local rightEdge = Instance.new("Frame")
	rightEdge.Name = "RightEdge"
	rightEdge.Size = UDim2.new(0, 60, 1, 0)
	rightEdge.Position = UDim2.new(1, -60, 0, 0)
	rightEdge.BackgroundColor3 = COLOR_SPLATTER
	rightEdge.BackgroundTransparency = 1
	rightEdge.BorderSizePixel = 0
	rightEdge.Parent = splatterOverlay

	local rightGradient = Instance.new("UIGradient")
	rightGradient.Color = ColorSequence.new(COLOR_SPLATTER)
	rightGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.4, 0.85),
		NumberSequenceKeypoint.new(1, 0.4),
	})
	rightGradient.Rotation = 0
	rightGradient.Parent = rightEdge

	splatterOverlay.Visible = false

	local self = setmetatable({
		container = container,
		pips = pips,
		pipFills = pipFills,
		splatterOverlay = splatterOverlay,
		bleedingActive = false,
		pulseConnection = nil :: RBXScriptConnection?,
		currentHealth = MAX_PIPS,
	}, HealthDisplay)

	return self
end

function HealthDisplay.update(self: HealthDisplay, health: number, maxHealth: number, isBleeding: boolean)
	local clampedHealth = math.clamp(health, 0, maxHealth)
	self.currentHealth = clampedHealth

	-- Update pip fills
	for i = 1, MAX_PIPS do
		local fill = self.pipFills[i]
		if i <= clampedHealth then
			fill.BackgroundColor3 = COLOR_FILLED
			fill.BackgroundTransparency = 0
			fill.Visible = true
		else
			fill.Visible = false
		end
	end

	-- Blood splatter overlay when health is low (1 or 2)
	if clampedHealth <= 2 and clampedHealth > 0 then
		self.splatterOverlay.Visible = true
		-- Adjust intensity based on health
		local intensity = if clampedHealth == 1 then 0 else 0.3
		for _, child in self.splatterOverlay:GetChildren() do
			if child:IsA("Frame") or child:IsA("ImageLabel") then
				child.BackgroundTransparency = intensity
			end
		end
	else
		self.splatterOverlay.Visible = false
	end

	-- Bleeding pulse effect at critical health
	if isBleeding and clampedHealth == 1 then
		if not self.bleedingActive then
			self.bleedingActive = true
			self:_startBleedPulse()
		end
	else
		if self.bleedingActive then
			self.bleedingActive = false
			self:_stopBleedPulse()
		end
	end
end

function HealthDisplay._startBleedPulse(self: HealthDisplay)
	-- Disconnect any existing pulse
	self:_stopBleedPulse()

	self.pulseConnection = RunService.Heartbeat:Connect(function()
		if not self.bleedingActive then
			return
		end

		local t = tick()
		local alpha = (math.sin(t * PULSE_SPEED * math.pi * 2) + 1) / 2
		-- Pulse pip transparency between 0 and 0.6
		local transparency = alpha * 0.6

		for i = 1, MAX_PIPS do
			local fill = self.pipFills[i]
			if fill.Visible then
				fill.BackgroundTransparency = transparency
			end
		end

		-- Pulse splatter overlay edges
		for _, child in self.splatterOverlay:GetChildren() do
			if child:IsA("Frame") or child:IsA("ImageLabel") then
				child.BackgroundTransparency = 0.1 + alpha * 0.4
			end
		end
	end)
end

function HealthDisplay._stopBleedPulse(self: HealthDisplay)
	if self.pulseConnection then
		self.pulseConnection:Disconnect()
		self.pulseConnection = nil
	end

	-- Reset pip transparency
	for i = 1, MAX_PIPS do
		local fill = self.pipFills[i]
		if fill.Visible then
			fill.BackgroundTransparency = 0
		end
	end
end

return HealthDisplay
