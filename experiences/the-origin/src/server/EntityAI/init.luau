--!strict

--[[
	EntityAI Controller

	Manages entity lifecycle, delegates to StateMachine for behavior,
	Senses for detection, and AdaptiveBehavior for learning.

	All entity logic runs server-side. Client receives position/state
	for rendering and proximity fear calculations only.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdaptiveBehavior = require(script.AdaptiveBehavior)
local Constants = require(ReplicatedStorage.Shared.Constants)
local Remotes = require(script.Parent.Remotes)
local Senses = require(script.Senses)
local StateMachine = require(script.StateMachine)
local Types = require(ReplicatedStorage.Shared.Types)

local EntityController = {}
EntityController.__index = EntityController

export type EntityController = typeof(setmetatable(
	{} :: {
		active: boolean,
		entityModel: Model?,
		stateMachine: StateMachine.StateMachine,
		senses: Senses.Senses,
		adaptive: AdaptiveBehavior.AdaptiveBehavior,
		profile: Types.EntityProfile,
		position: Vector3,
		currentState: Types.EntityState,
		lastReplicatedState: Types.EntityState,
	},
	EntityController
))

function EntityController.new(): EntityController
	-- Default to The Patient profile for Level 1
	local profile: Types.EntityProfile = {
		name = "The Patient",
		primarySense = "Hearing",
		patrolSpeed = 8,
		chaseSpeed = 20,
		senses = {
			hearingRange = 50,
			visionCone = Constants.ENTITY_VISION_CONE,
			visionRangeLit = Constants.ENTITY_VISION_LIT,
			visionRangeDark = Constants.ENTITY_VISION_DARK,
			flashlightDetectRange = Constants.ENTITY_FLASHLIGHT_DETECT,
			detectionRamp = 1.5,
		},
		checkHidingSpots = true,
		uniqueMechanic = "ElectronicFlatline",
	}

	local self = setmetatable({
		active = false,
		entityModel = nil,
		stateMachine = StateMachine.new(),
		senses = Senses.new(profile.senses),
		adaptive = AdaptiveBehavior.new(),
		profile = profile,
		position = Vector3.zero,
		currentState = "Idle" :: Types.EntityState,
		lastReplicatedState = "Idle" :: Types.EntityState,
	}, EntityController)

	return self
end

function EntityController.activate(self: EntityController, spawnPosition: Vector3)
	-- Create entity model
	local model = Instance.new("Model")
	model.Name = self.profile.name

	-- Create humanoid-like body
	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(2, 3, 1)
	torso.Position = spawnPosition + Vector3.new(0, 3, 0)
	torso.Anchored = true
	torso.CanCollide = false
	torso.Material = Enum.Material.SmoothPlastic
	torso.Color = Color3.fromRGB(40, 40, 45)
	torso.Transparency = 0.1
	torso.Parent = model

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Position = spawnPosition + Vector3.new(0, 5, 0)
	head.Anchored = true
	head.CanCollide = false
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(60, 55, 50)
	head.Parent = model

	-- Arms (thin, elongated for horror)
	for _, side in { -1, 1 } do
		local arm = Instance.new("Part")
		arm.Name = if side == -1 then "LeftArm" else "RightArm"
		arm.Size = Vector3.new(0.5, 3.5, 0.5)
		arm.Position = spawnPosition + Vector3.new(side * 1.5, 3, 0)
		arm.Anchored = true
		arm.CanCollide = false
		arm.Material = Enum.Material.SmoothPlastic
		arm.Color = Color3.fromRGB(45, 45, 50)
		arm.Parent = model
	end

	-- Legs
	for _, side in { -1, 1 } do
		local leg = Instance.new("Part")
		leg.Name = if side == -1 then "LeftLeg" else "RightLeg"
		leg.Size = Vector3.new(0.6, 3, 0.6)
		leg.Position = spawnPosition + Vector3.new(side * 0.5, 0.5, 0)
		leg.Anchored = true
		leg.CanCollide = false
		leg.Material = Enum.Material.SmoothPlastic
		leg.Color = Color3.fromRGB(35, 35, 40)
		leg.Parent = model
	end

	model.PrimaryPart = torso
	model.Parent = workspace

	self.entityModel = model
	self.position = spawnPosition
	self.active = true

	-- Initialize state machine for patrol
	self.stateMachine:transition("Patrol")
	self
		.stateMachine
		:setPosition(spawnPosition)
		-- Update senses exclude list so raycasts ignore the entity model
		-- NOTE: Senses.hasLineOfSight needs to be updated to use this field
		(self.senses :: any)
		.excludeInstances =
		{ model }

	print(`[EntityAI] {self.profile.name} activated at {spawnPosition}`)
end

function EntityController.deactivate(self: EntityController)
	if self.entityModel then
		self.entityModel:Destroy()
		self.entityModel = nil
	end

	self.active = false
	self.currentState = "Idle"
end

function EntityController.onSoundEvent(self: EntityController, event: Types.SoundEvent)
	if not self.active then
		return
	end

	local canHear = self.senses:canHearSound(self.position, event)
	if canHear then
		self.stateMachine:onSoundDetected(event)
	end
end

function EntityController.update(self: EntityController, dt: number)
	if not self.active then
		return
	end

	-- Update state machine
	self.stateMachine:update(dt)

	-- Sync position and state from state machine
	self.position = self.stateMachine:getPosition()
	self.currentState = self.stateMachine.currentState

	-- Update entity model position to match
	if self.entityModel and self.entityModel.PrimaryPart then
		local pos = self.position
		self.entityModel.PrimaryPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))

		-- Move other parts relative to torso
		local head = self.entityModel:FindFirstChild("Head")
		if head then
			(head :: Part).Position = pos + Vector3.new(0, 5, 0)
		end
		local la = self.entityModel:FindFirstChild("LeftArm")
		if la then
			(la :: Part).Position = pos + Vector3.new(-1.5, 3, 0)
		end
		local ra = self.entityModel:FindFirstChild("RightArm")
		if ra then
			(ra :: Part).Position = pos + Vector3.new(1.5, 3, 0)
		end
		local ll = self.entityModel:FindFirstChild("LeftLeg")
		if ll then
			(ll :: Part).Position = pos + Vector3.new(-0.5, 0.5, 0)
		end
		local rl = self.entityModel:FindFirstChild("RightLeg")
		if rl then
			(rl :: Part).Position = pos + Vector3.new(0.5, 0.5, 0)
		end
	end

	-- Check all players for vision detection
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if not character then
			continue
		end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			continue
		end

		local playerPos = (hrp :: BasePart).Position
		local lookDir = (self.stateMachine.currentPosition - self.position).Unit
		if lookDir.Magnitude ~= lookDir.Magnitude then
			lookDir = Vector3.new(0, 0, 1) -- NaN check
		end

		local isLit = false -- simplified
		local hasFlashlight = false -- TODO: check player flashlight state

		local visionResult = self.senses:checkVision(self.position, lookDir, playerPos, isLit, hasFlashlight)
		local detected = self.senses:updateDetection(player, visionResult, dt)

		if detected then
			self.stateMachine:onPlayerSpotted(playerPos)
		end
	end

	-- Update adaptive behavior
	self.adaptive:update(dt)

	-- Apply unique mechanics
	if self.profile.uniqueMechanic == "ElectronicFlatline" then
		-- TODO (Wave 4): Flatline nearby electronics when within range
		self:runUniqueMechanic()
	end

	-- Replicate position to all clients for proximity fear calculations
	if Remotes.EntityPositionUpdate then
		Remotes.EntityPositionUpdate:FireAllClients(self.position, self.currentState)
	end

	-- Replicate state changes to clients
	if self.currentState ~= self.lastReplicatedState then
		self.lastReplicatedState = self.currentState
		if Remotes.EntityStateChanged then
			Remotes.EntityStateChanged:FireAllClients(self.currentState)
		end
	end
end

function EntityController.runUniqueMechanic(_self: EntityController)
	-- TODO (Wave 4): Implement ElectronicFlatline mechanic
	-- When entity is within range of electronic objects (lights, generators),
	-- cause them to flicker and shut down, providing audio/visual cues to players.
end

return EntityController
