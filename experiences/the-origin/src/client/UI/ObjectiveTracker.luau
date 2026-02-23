--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Types = require(ReplicatedStorage.Shared.Types)

local CONTAINER_PADDING = 16
local CONTAINER_WIDTH = 260
local CONTAINER_MIN_HEIGHT = 36
local TEXT_PADDING = 10

local COLOR_BG = Color3.fromRGB(12, 12, 12)
local COLOR_BORDER = Color3.fromRGB(50, 50, 50)
local COLOR_TEXT = Color3.fromRGB(200, 200, 200)
local COLOR_TEXT_COMPLETED = Color3.fromRGB(100, 100, 100)
local COLOR_CHECKMARK = Color3.fromRGB(80, 160, 80)

local SLIDE_OFFSET = -280 -- off-screen to the left
local SLIDE_IN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SLIDE_OUT_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local _FADE_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local ObjectiveTracker = {}
ObjectiveTracker.__index = ObjectiveTracker

export type ObjectiveTracker = typeof(setmetatable(
	{} :: {
		container: Frame,
		headerLabel: TextLabel,
		objectiveLabel: TextLabel,
		checkmark: TextLabel,
		allObjectives: { Types.ObjectiveStep },
		currentObjective: Types.ObjectiveStep?,
		currentText: string,
		isVisible: boolean,
	},
	ObjectiveTracker
))

function ObjectiveTracker.new(parent: ScreenGui): ObjectiveTracker
	-- Container frame: top-left with semi-transparent background
	local container = Instance.new("Frame")
	container.Name = "ObjectiveTracker"
	container.Size = UDim2.fromOffset(CONTAINER_WIDTH, CONTAINER_MIN_HEIGHT)
	container.Position = UDim2.fromOffset(CONTAINER_PADDING, CONTAINER_PADDING)
	container.AnchorPoint = Vector2.new(0, 0)
	container.BackgroundColor3 = COLOR_BG
	container.BackgroundTransparency = 0.35
	container.BorderSizePixel = 0
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.ClipsDescendants = true
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 4)
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = COLOR_BORDER
	containerStroke.Thickness = 1
	containerStroke.Transparency = 0.5
	containerStroke.Parent = container

	local containerPadding = Instance.new("UIPadding")
	containerPadding.PaddingLeft = UDim.new(0, TEXT_PADDING)
	containerPadding.PaddingRight = UDim.new(0, TEXT_PADDING)
	containerPadding.PaddingTop = UDim.new(0, 8)
	containerPadding.PaddingBottom = UDim.new(0, 8)
	containerPadding.Parent = container

	local containerLayout = Instance.new("UIListLayout")
	containerLayout.FillDirection = Enum.FillDirection.Vertical
	containerLayout.Padding = UDim.new(0, 4)
	containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	containerLayout.Parent = container

	-- Header label ("OBJECTIVE")
	local headerLabel = Instance.new("TextLabel")
	headerLabel.Name = "Header"
	headerLabel.Size = UDim2.new(1, 0, 0, 12)
	headerLabel.BackgroundTransparency = 1
	headerLabel.Text = "OBJECTIVE"
	headerLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
	headerLabel.TextSize = 9
	headerLabel.Font = Enum.Font.GothamBold
	headerLabel.TextXAlignment = Enum.TextXAlignment.Left
	headerLabel.TextYAlignment = Enum.TextYAlignment.Top
	headerLabel.LayoutOrder = 1
	headerLabel.Parent = container

	-- Objective row frame (holds checkmark + text)
	local objectiveRow = Instance.new("Frame")
	objectiveRow.Name = "ObjectiveRow"
	objectiveRow.Size = UDim2.fromScale(1, 0)
	objectiveRow.BackgroundTransparency = 1
	objectiveRow.AutomaticSize = Enum.AutomaticSize.Y
	objectiveRow.LayoutOrder = 2
	objectiveRow.Parent = container

	-- Checkmark
	local checkmark = Instance.new("TextLabel")
	checkmark.Name = "Checkmark"
	checkmark.Size = UDim2.fromOffset(14, 14)
	checkmark.Position = UDim2.fromOffset(0, 1)
	checkmark.BackgroundTransparency = 1
	checkmark.Text = ""
	checkmark.TextColor3 = COLOR_CHECKMARK
	checkmark.TextSize = 12
	checkmark.Font = Enum.Font.GothamBold
	checkmark.TextXAlignment = Enum.TextXAlignment.Left
	checkmark.TextYAlignment = Enum.TextYAlignment.Top
	checkmark.Visible = false
	checkmark.Parent = objectiveRow

	-- Objective text
	local objectiveLabel = Instance.new("TextLabel")
	objectiveLabel.Name = "ObjectiveText"
	objectiveLabel.Size = UDim2.fromScale(1, 0)
	objectiveLabel.BackgroundTransparency = 1
	objectiveLabel.Text = ""
	objectiveLabel.TextColor3 = COLOR_TEXT
	objectiveLabel.TextSize = 12
	objectiveLabel.Font = Enum.Font.Gotham
	objectiveLabel.TextXAlignment = Enum.TextXAlignment.Left
	objectiveLabel.TextYAlignment = Enum.TextYAlignment.Top
	objectiveLabel.TextWrapped = true
	objectiveLabel.AutomaticSize = Enum.AutomaticSize.Y
	objectiveLabel.LayoutOrder = 2
	objectiveLabel.Parent = objectiveRow

	-- Start hidden (will slide in when objective is set)
	container.Position = UDim2.fromOffset(SLIDE_OFFSET, CONTAINER_PADDING)

	local self = setmetatable({
		container = container,
		headerLabel = headerLabel,
		objectiveLabel = objectiveLabel,
		checkmark = checkmark,
		allObjectives = {} :: { Types.ObjectiveStep },
		currentObjective = nil :: Types.ObjectiveStep?,
		currentText = "",
		isVisible = false,
	}, ObjectiveTracker)

	return self
end

function ObjectiveTracker.update(self: ObjectiveTracker, objective: Types.ObjectiveStep?)
	if objective == nil then
		-- No objective: slide out
		self:_slideOut()
		self.currentObjective = nil
		return
	end

	local objData = objective :: Types.ObjectiveStep
	local description = if typeof(objData) == "table" then (objData :: any).description or "" else tostring(objData)
	local isCompleted = if typeof(objData) == "table" then (objData :: any).completed or false else false

	-- Check if this is a new objective
	local isNewObjective = description ~= self.currentText
	self.currentObjective = objective
	self.currentText = description

	if isCompleted then
		-- Show completion state
		self.checkmark.Visible = true
		self.checkmark.Text = "+"
		self.objectiveLabel.TextColor3 = COLOR_TEXT_COMPLETED

		-- Adjust objective text position to make room for checkmark
		self.objectiveLabel.Position = UDim2.fromOffset(16, 0)
		self.objectiveLabel.Size = UDim2.new(1, -16, 0, 0)
	else
		-- Normal active objective
		self.checkmark.Visible = false
		self.objectiveLabel.TextColor3 = COLOR_TEXT
		self.objectiveLabel.Position = UDim2.fromOffset(0, 0)
		self.objectiveLabel.Size = UDim2.fromScale(1, 0)
	end

	self.objectiveLabel.Text = description

	if isNewObjective then
		self:_animateNewObjective()
	elseif not self.isVisible then
		self:_slideIn()
	end
end

function ObjectiveTracker.loadAll(self: ObjectiveTracker, objectives: { Types.ObjectiveStep })
	self.allObjectives = objectives

	-- Find and display the first incomplete objective
	for _, obj in objectives do
		local isCompleted = if typeof(obj) == "table" then (obj :: any).completed or false else false
		if not isCompleted then
			self:update(obj)
			return
		end
	end

	-- All complete or empty: hide
	self:update(nil)
end

function ObjectiveTracker._animateNewObjective(self: ObjectiveTracker)
	if self.isVisible then
		-- Slide out, then slide in with new text
		self:_slideOut()
		task.delay(0.35, function()
			self:_slideIn()
		end)
	else
		-- Just slide in
		self:_slideIn()
	end
end

function ObjectiveTracker._slideIn(self: ObjectiveTracker)
	self.isVisible = true
	self.container.Visible = true

	-- Ensure starting position is off-screen
	self.container.Position = UDim2.fromOffset(SLIDE_OFFSET, CONTAINER_PADDING)

	local tween = TweenService:Create(self.container, SLIDE_IN_INFO, {
		Position = UDim2.fromOffset(CONTAINER_PADDING, CONTAINER_PADDING),
	})
	tween:Play()
end

function ObjectiveTracker._slideOut(self: ObjectiveTracker)
	if not self.isVisible then
		return
	end

	self.isVisible = false

	local tween = TweenService:Create(self.container, SLIDE_OUT_INFO, {
		Position = UDim2.fromOffset(SLIDE_OFFSET, CONTAINER_PADDING),
	})
	tween:Play()

	tween.Completed:Connect(function()
		if not self.isVisible then
			self.container.Visible = false
		end
	end)
end

return ObjectiveTracker
