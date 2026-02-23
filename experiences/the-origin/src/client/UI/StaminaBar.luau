--!strict

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local BAR_WIDTH = 200
local BAR_HEIGHT = 4
local CONTAINER_PADDING_BOTTOM = 70 -- above inventory slots

local COLOR_FILL = Color3.fromRGB(200, 200, 200)
local COLOR_FILL_LOW = Color3.fromRGB(200, 60, 60)
local COLOR_BACKGROUND = Color3.fromRGB(25, 25, 25)
local COLOR_BORDER = Color3.fromRGB(60, 60, 60)

local LOW_THRESHOLD = 0.2
local PULSE_SPEED = 4
local FILL_TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FLASH_DURATION = 0.3

local StaminaBar = {}
StaminaBar.__index = StaminaBar

export type StaminaBar = typeof(setmetatable(
	{} :: {
		container: Frame,
		fillBar: Frame,
		lastStamina: number,
		pulseConnection: RBXScriptConnection?,
		isPulsing: boolean,
		flashActive: boolean,
	},
	StaminaBar
))

function StaminaBar.new(parent: ScreenGui): StaminaBar
	-- Outer container with border
	local container = Instance.new("Frame")
	container.Name = "StaminaBar"
	container.Size = UDim2.fromOffset(BAR_WIDTH, BAR_HEIGHT)
	container.Position = UDim2.new(0.5, 0, 1, -CONTAINER_PADDING_BOTTOM)
	container.AnchorPoint = Vector2.new(0.5, 1)
	container.BackgroundColor3 = COLOR_BACKGROUND
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 2)
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = COLOR_BORDER
	containerStroke.Thickness = 1
	containerStroke.Transparency = 0.5
	containerStroke.Parent = container

	-- Fill bar (shrinks from right to left)
	local fillBar = Instance.new("Frame")
	fillBar.Name = "Fill"
	fillBar.Size = UDim2.fromScale(1, 1)
	fillBar.Position = UDim2.fromScale(0, 0)
	fillBar.AnchorPoint = Vector2.new(0, 0)
	fillBar.BackgroundColor3 = COLOR_FILL
	fillBar.BackgroundTransparency = 0.1
	fillBar.BorderSizePixel = 0
	fillBar.Parent = container

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 2)
	fillCorner.Parent = fillBar

	local self = setmetatable({
		container = container,
		fillBar = fillBar,
		lastStamina = 1,
		pulseConnection = nil :: RBXScriptConnection?,
		isPulsing = false,
		flashActive = false,
	}, StaminaBar)

	return self
end

function StaminaBar.update(self: StaminaBar, stamina: number)
	local clamped = math.clamp(stamina, 0, 1)
	local previousStamina = self.lastStamina
	self.lastStamina = clamped

	-- Tween fill width
	local targetSize = UDim2.fromScale(clamped, 1)
	local tween = TweenService:Create(self.fillBar, FILL_TWEEN_INFO, {
		Size = targetSize,
	})
	tween:Play()

	-- Handle color based on stamina level
	if clamped < LOW_THRESHOLD and clamped > 0 then
		-- Low stamina: pulse effect
		self.fillBar.BackgroundColor3 = COLOR_FILL_LOW
		if not self.isPulsing then
			self:_startPulse()
		end
	elseif clamped == 0 then
		-- Empty: flash red and stop pulsing
		self:_stopPulse()
		if not self.flashActive and previousStamina > 0 then
			self:_flashEmpty()
		end
	else
		-- Normal stamina
		self.fillBar.BackgroundColor3 = COLOR_FILL
		self.fillBar.BackgroundTransparency = 0.1
		self:_stopPulse()
	end
end

function StaminaBar._startPulse(self: StaminaBar)
	self:_stopPulse()
	self.isPulsing = true

	self.pulseConnection = RunService.Heartbeat:Connect(function()
		if not self.isPulsing then
			return
		end

		local t = tick()
		local alpha = (math.sin(t * PULSE_SPEED * math.pi * 2) + 1) / 2
		-- Pulse transparency between 0.1 and 0.6
		self.fillBar.BackgroundTransparency = 0.1 + alpha * 0.5
	end)
end

function StaminaBar._stopPulse(self: StaminaBar)
	self.isPulsing = false
	if self.pulseConnection then
		self.pulseConnection:Disconnect()
		self.pulseConnection = nil
	end
	self.fillBar.BackgroundTransparency = 0.1
end

function StaminaBar._flashEmpty(self: StaminaBar)
	self.flashActive = true

	-- Briefly flash the bar red
	self.fillBar.BackgroundColor3 = COLOR_FILL_LOW
	self.fillBar.Size = UDim2.fromScale(1, 1)
	self.fillBar.BackgroundTransparency = 0

	-- Flash the entire container
	self.container.BackgroundColor3 = COLOR_FILL_LOW
	self.container.BackgroundTransparency = 0

	task.delay(FLASH_DURATION, function()
		-- Fade out the flash
		local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local fillFade = TweenService:Create(self.fillBar, fadeInfo, {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0, 1),
		})
		fillFade:Play()

		local containerFade = TweenService:Create(self.container, fadeInfo, {
			BackgroundColor3 = COLOR_BACKGROUND,
			BackgroundTransparency = 0.2,
		})
		containerFade:Play()

		task.delay(0.4, function()
			self.flashActive = false
			self.fillBar.BackgroundColor3 = COLOR_FILL
		end)
	end)
end

return StaminaBar
