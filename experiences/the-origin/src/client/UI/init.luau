--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local HealthDisplay = require(script.HealthDisplay)
local InventoryDisplay = require(script.InventoryDisplay)
local ObjectiveTracker = require(script.ObjectiveTracker)
local StaminaBar = require(script.StaminaBar)

local UI = {}

function UI.new(player: Player)
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameUI"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 10
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local self = {
		screenGui = screenGui,
		health = HealthDisplay.new(screenGui),
		stamina = StaminaBar.new(screenGui),
		inventory = InventoryDisplay.new(screenGui),
		objectives = ObjectiveTracker.new(screenGui),
	}

	return self
end

-- Update methods that remotes call into
function UI.updateHealth(self: any, health: number, maxHealth: number, isBleeding: boolean)
	self.health:update(health, maxHealth, isBleeding)
end

function UI.updateStamina(self: any, stamina: number)
	self.stamina:update(stamina)
end

function UI.updateInventory(self: any, inventory: { Types.InventoryItem }, keyItems: { string })
	self.inventory:update(inventory, keyItems)
end

function UI.updateObjective(self: any, objective: Types.ObjectiveStep?)
	self.objectives:update(objective)
end

function UI.loadObjectives(self: any, objectives: { Types.ObjectiveStep })
	self.objectives:loadAll(objectives)
end

return UI
