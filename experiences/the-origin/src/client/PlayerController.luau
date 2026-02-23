--!strict

--[[
	Player Controller (Client)

	Handles client-side player mechanics:
	- Movement states (walk, sprint, crouch)
	- Stamina management
	- Flashlight control
	- Hiding interaction
	- Input binding

	Health and inventory are server-authoritative — this module
	sends requests and reflects server state.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local PlayerController = {}
PlayerController.__index = PlayerController

export type PlayerController = typeof(setmetatable(
	{} :: {
		player: Player,
		stamina: number,
		maxStamina: number,
		isSprinting: boolean,
		isCrouching: boolean,
		isHiding: boolean,
		flashlightOn: boolean,
		flashlightBattery: number, -- seconds remaining
		moveSpeed: number,
		injuryModifier: number,
		remotesFolder: Instance?,
	},
	PlayerController
))

function PlayerController.new(player: Player): PlayerController
	local self = setmetatable({
		player = player,
		stamina = 1.0, -- 0 to 1
		maxStamina = 1.0,
		isSprinting = false,
		isCrouching = false,
		isHiding = false,
		flashlightOn = false,
		flashlightBattery = Constants.FLASHLIGHT_BATTERY_LIFE,
		moveSpeed = Constants.SPEED_WALK,
		injuryModifier = 1.0,
		remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5),
	}, PlayerController)

	self:bindInputs()
	self:startUpdateLoop()

	return self
end

function PlayerController.bindInputs(self: PlayerController)
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:startSprint()
		elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C then
			self:toggleCrouch()
		elseif input.KeyCode == Enum.KeyCode.F then
			self:toggleFlashlight()
		elseif input.KeyCode == Enum.KeyCode.E then
			self:interact()
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject, _gameProcessed: boolean)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			self:stopSprint()
		end
	end)
end

function PlayerController.startUpdateLoop(self: PlayerController)
	RunService.Heartbeat:Connect(function(dt: number)
		self:updateStamina(dt)
		self:updateFlashlight(dt)
		self:updateMoveSpeed()
	end)
end

function PlayerController.startSprint(self: PlayerController)
	if self.isHiding or self.isCrouching then
		return
	end
	if self.stamina <= 0 then
		-- TODO: Trigger stumble animation + loud sound event
		return
	end
	self.isSprinting = true
end

function PlayerController.stopSprint(self: PlayerController)
	self.isSprinting = false
end

function PlayerController.toggleCrouch(self: PlayerController)
	if self.isHiding then
		return
	end
	self.isCrouching = not self.isCrouching
	if self.isCrouching then
		self.isSprinting = false
	end
end

function PlayerController.toggleFlashlight(self: PlayerController)
	if self.flashlightBattery <= 0 then
		-- Play dead click sound (no battery)
		return
	end
	self.flashlightOn = not self.flashlightOn

	local character = self.player.Character
	if not character then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end

	-- Create or get SpotLight
	local spotlight = head:FindFirstChild("Flashlight") :: SpotLight?
	if not spotlight then
		spotlight = Instance.new("SpotLight")
		spotlight.Name = "Flashlight"
		spotlight.Brightness = 2
		spotlight.Range = 40
		spotlight.Angle = 45
		spotlight.Face = Enum.NormalId.Front
		spotlight.Color = Color3.fromRGB(255, 250, 230)
		spotlight.Parent = head
	end

	spotlight.Enabled = self.flashlightOn

	-- Fire sound event to server (flashlight click is audible)
	local Remotes = self.remotesFolder
	if Remotes then
		local soundEvent = Remotes:FindFirstChild("SoundEvent")
		if soundEvent then
			soundEvent:FireServer("FlashlightClick", Constants.SOUND_FLASHLIGHT_CLICK)
		end
	end
end

function PlayerController.interact(self: PlayerController)
	local character = self.player.Character
	if not character then
		return
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	-- Raycast forward 8 studs
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { character }

	local lookDir = hrp.CFrame.LookVector
	local result = workspace:Raycast(hrp.Position, lookDir * 8, rayParams)

	if result and result.Instance then
		-- Check for hiding spot
		local hidingSpotId = result.Instance:GetAttribute("HidingSpotId")
		if hidingSpotId and not self.isHiding then
			self.isHiding = true
			self.flashlightOn = false -- auto-off
			-- Toggle off spotlight
			local head = character:FindFirstChild("Head")
			if head then
				local sl = head:FindFirstChild("Flashlight")
				if sl then
					(sl :: SpotLight).Enabled = false
				end
			end
			local Remotes = self.remotesFolder
			if Remotes then
				local remote = Remotes:FindFirstChild("HidingEntered")
				if remote then
					remote:FireServer(hidingSpotId)
				end
			end
			return
		end
	end

	-- If already hiding, exit
	if self.isHiding then
		self.isHiding = false
		local Remotes = self.remotesFolder
		if Remotes then
			local remote = Remotes:FindFirstChild("HidingExited")
			if remote then
				remote:FireServer()
			end
		end
	end
end

function PlayerController.flickerFlashlight(self: PlayerController)
	if not self.flashlightOn then
		return
	end
	local character = self.player.Character
	if not character then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	local spotlight = head:FindFirstChild("Flashlight") :: SpotLight?
	if not spotlight then
		return
	end

	-- Rapid flicker for 1 second
	task.spawn(function()
		for _i = 1, 6 do
			spotlight.Enabled = false
			task.wait(0.05 + math.random() * 0.1)
			spotlight.Enabled = true
			task.wait(0.05 + math.random() * 0.05)
		end
		spotlight.Enabled = self.flashlightOn
	end)
end

function PlayerController.refillBattery(self: PlayerController)
	self.flashlightBattery = Constants.FLASHLIGHT_BATTERY_LIFE
end

function PlayerController.setInjuryModifier(self: PlayerController, modifier: number)
	self.injuryModifier = modifier
end

function PlayerController.updateStamina(self: PlayerController, dt: number)
	if self.isSprinting then
		self.stamina -= dt / Constants.SPRINT_DURATION
		if self.stamina <= 0 then
			self.stamina = 0
			self:stopSprint()
			-- TODO: Stumble
		end
	else
		-- Recovery rate depends on movement state
		local recoveryRate = if self.isCrouching
			then Constants.STAMINA_RECOVERY_CROUCHING
			else Constants.STAMINA_RECOVERY_STANDING

		-- Standing still recovers fastest
		local character = self.player.Character
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		local isMoving = humanoid and humanoid.MoveDirection.Magnitude > 0.1

		if not isMoving then
			recoveryRate *= 1.5
		end

		self.stamina = math.min(self.maxStamina, self.stamina + (dt / Constants.SPRINT_DURATION) * recoveryRate)
	end
end

function PlayerController.updateFlashlight(self: PlayerController, dt: number)
	if self.flashlightOn then
		self.flashlightBattery -= dt
		if self.flashlightBattery <= 0 then
			self.flashlightBattery = 0
			self.flashlightOn = false
			-- TODO: Flashlight dies
		end
	end
end

function PlayerController.updateMoveSpeed(self: PlayerController)
	local character = self.player.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if not humanoid then
		return
	end

	if self.isHiding then
		humanoid.WalkSpeed = 0
	elseif self.isCrouching then
		humanoid.WalkSpeed = Constants.SPEED_CROUCH
	elseif self.isSprinting then
		humanoid.WalkSpeed = Constants.SPEED_SPRINT
	else
		humanoid.WalkSpeed = Constants.SPEED_WALK
	end

	-- Apply injury modifier at the end
	humanoid.WalkSpeed = humanoid.WalkSpeed * self.injuryModifier
end

return PlayerController
