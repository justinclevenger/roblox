--!strict

--[[
	Visual Effects for Proximity Fear System

	Controls: color correction, vignette, screen shake, film grain,
	chromatic aberration, FOV, subliminal flashes.
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)

local VisualEffects = {}
VisualEffects.__index = VisualEffects

export type VisualEffects = typeof(setmetatable(
	{} :: {
		player: Player,
		camera: Camera?,
		baseFOV: number,
		shakeOffset: Vector3,
		lastSubliminalFlash: number,
		subliminalCooldown: number,
		-- Post-processing references (created at runtime)
		colorCorrection: ColorCorrectionEffect?,
		blur: BlurEffect?,
		-- GUI overlay references
		vignetteGui: ScreenGui?,
		vignetteFrame: Frame?,
		flashLabel: TextLabel?,
		grainFrame: Frame?,
	},
	VisualEffects
))

function VisualEffects.new(player: Player): VisualEffects
	local self = setmetatable({
		player = player,
		camera = workspace.CurrentCamera,
		baseFOV = 70,
		shakeOffset = Vector3.zero,
		lastSubliminalFlash = 0,
		subliminalCooldown = 18, -- seconds between subliminal flashes
		colorCorrection = nil,
		blur = nil,
		vignetteGui = nil,
		vignetteFrame = nil,
		flashLabel = nil,
		grainFrame = nil,
	}, VisualEffects)

	self:setupPostProcessing()

	return self
end

function VisualEffects.setupPostProcessing(self: VisualEffects)
	-- Create dedicated post-processing for fear system
	-- (separate from the level's base lighting effects)
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "FearColorCorrection"
	cc.Brightness = 0
	cc.Contrast = 0
	cc.Saturation = 0
	cc.Parent = Lighting
	self.colorCorrection = cc

	local blur = Instance.new("BlurEffect")
	blur.Name = "FearBlur"
	blur.Size = 0
	blur.Parent = Lighting
	self.blur = blur

	-- GUI overlays
	local playerGui = self.player:WaitForChild("PlayerGui")

	-- Vignette overlay
	local vignetteGui = Instance.new("ScreenGui")
	vignetteGui.Name = "FearVignette"
	vignetteGui.IgnoreGuiInset = true
	vignetteGui.DisplayOrder = 100
	vignetteGui.Parent = playerGui

	local vignetteFrame = Instance.new("Frame")
	vignetteFrame.Name = "Vignette"
	vignetteFrame.Size = UDim2.fromScale(1, 1)
	vignetteFrame.Position = UDim2.fromScale(0, 0)
	vignetteFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	vignetteFrame.BackgroundTransparency = 1
	vignetteFrame.BorderSizePixel = 0
	vignetteFrame.Parent = vignetteGui

	-- Use UIGradient for radial vignette effect
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(0.8, 0.5),
		NumberSequenceKeypoint.new(1, 0),
	})
	gradient.Offset = Vector2.new(0.5, 0.5)
	gradient.Parent = vignetteFrame

	self.vignetteGui = vignetteGui
	self.vignetteFrame = vignetteFrame

	-- Film grain overlay (sits inside vignette ScreenGui)
	local grainFrame = Instance.new("Frame")
	grainFrame.Name = "FilmGrain"
	grainFrame.Size = UDim2.fromScale(1, 1)
	grainFrame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
	grainFrame.BackgroundTransparency = 1
	grainFrame.BorderSizePixel = 0
	grainFrame.Parent = vignetteGui
	self.grainFrame = grainFrame

	-- Subliminal flash overlay
	local flashGui = Instance.new("ScreenGui")
	flashGui.Name = "SubliminalFlash"
	flashGui.IgnoreGuiInset = true
	flashGui.DisplayOrder = 200
	flashGui.Parent = playerGui

	local flashLabel = Instance.new("TextLabel")
	flashLabel.Name = "Flash"
	flashLabel.Size = UDim2.fromScale(1, 1)
	flashLabel.Position = UDim2.fromScale(0, 0)
	flashLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	flashLabel.BackgroundTransparency = 1
	flashLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
	flashLabel.TextScaled = true
	flashLabel.Font = Enum.Font.Code
	flashLabel.Text = ""
	flashLabel.Visible = false
	flashLabel.BorderSizePixel = 0
	flashLabel.Parent = flashGui
	self.flashLabel = flashLabel
end

function VisualEffects.update(self: VisualEffects, dt: number, intensity: number, tier: Types.FearTier)
	self:updateColorCorrection(intensity)
	self:updateScreenShake(dt, intensity, tier)
	self:updateFOV(intensity)
	self:updateVignette(intensity)

	-- Film grain at Tier 3+ (Panic / Proximity)
	if self.grainFrame then
		if tier == "Panic" or tier == "Proximity" then
			self.grainFrame.BackgroundTransparency = 1 - (intensity * 0.15)
		else
			self.grainFrame.BackgroundTransparency = 1
		end
	end

	if tier == "Panic" or tier == "Proximity" then
		self:updateSubliminalFlashes(dt, intensity)
	end
end

function VisualEffects.updateColorCorrection(self: VisualEffects, intensity: number)
	local cc = self.colorCorrection
	if not cc then
		return
	end

	-- Desaturation: 0% at safe → 70% at proximity
	cc.Saturation = -intensity * 0.93 -- 0.93 * 0.75 ≈ 0.7 at max

	-- Brightness drops slightly
	cc.Brightness = -intensity * 0.08

	-- Contrast increases for harsh shadows
	cc.Contrast = intensity * 0.2
end

function VisualEffects.updateScreenShake(self: VisualEffects, _dt: number, intensity: number, tier: Types.FearTier)
	if tier == "Safe" or tier == "Unease" then
		self.shakeOffset = Vector3.zero
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	-- Shake magnitude scales with intensity
	local magnitude = 0
	if tier == "Dread" then
		-- Slow nauseating sway, not shake
		local sway = math.sin(os.clock() * 0.8) * 0.15 * intensity
		self.shakeOffset = Vector3.new(sway, sway * 0.5, 0)
	elseif tier == "Panic" then
		magnitude = intensity * 0.3
		self.shakeOffset = Vector3.new((math.random() - 0.5) * magnitude, (math.random() - 0.5) * magnitude * 0.7, 0)
	elseif tier == "Proximity" then
		magnitude = intensity * 0.6
		self.shakeOffset = Vector3.new(
			(math.random() - 0.5) * magnitude,
			(math.random() - 0.5) * magnitude,
			(math.random() - 0.5) * magnitude * 0.3
		)
	end

	-- Apply shakeOffset to camera CFrame each frame
	camera.CFrame = camera.CFrame * CFrame.new(self.shakeOffset)
end

function VisualEffects.updateFOV(self: VisualEffects, intensity: number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	-- FOV narrows up to 7 degrees at max intensity
	camera.FieldOfView = self.baseFOV - (intensity * 9.3) -- 9.3 * 0.75 ≈ 7 at max
end

function VisualEffects.updateVignette(self: VisualEffects, intensity: number)
	-- Vignette is a ScreenGui with a dark gradient frame
	-- Opacity: 0 at safe, 0.8 at proximity
	local vignetteOpacity = intensity * 0.8
	if self.vignetteFrame then
		self.vignetteFrame.BackgroundTransparency = 1 - vignetteOpacity
	end
end

function VisualEffects.updateSubliminalFlashes(self: VisualEffects, dt: number, intensity: number)
	self.lastSubliminalFlash += dt

	-- Scale cooldown: shorter at higher intensity
	local cooldown = self.subliminalCooldown * (1.5 - intensity)

	if self.lastSubliminalFlash >= cooldown then
		self.lastSubliminalFlash = 0

		-- Pick random flash content
		local flashOptions = {
			"BEHIND YOU",
			"RUN",
			"IT SEES YOU",
			"DON'T LOOK",
			"HELP ME",
		}

		if self.flashLabel then
			-- 50% chance text, 50% chance solid flash
			if math.random() > 0.5 then
				self.flashLabel.Text = flashOptions[math.random(1, #flashOptions)]
				self.flashLabel.BackgroundTransparency = 0.7
			else
				self.flashLabel.Text = ""
				self.flashLabel.BackgroundTransparency = 0
			end
			self.flashLabel.Visible = true

			-- Hide after 1-2 frames (~33ms)
			task.delay(0.033, function()
				if self.flashLabel then
					self.flashLabel.Visible = false
				end
			end)
		end
	end
end

function VisualEffects.cleanup(self: VisualEffects)
	if self.colorCorrection then
		self.colorCorrection:Destroy()
	end
	if self.blur then
		self.blur:Destroy()
	end
	if self.vignetteGui then
		self.vignetteGui:Destroy()
	end
	-- flashLabel's parent ScreenGui needs to be destroyed separately
	if self.flashLabel then
		local flashGui = self.flashLabel.Parent
		if flashGui then
			flashGui:Destroy()
		end
	end
end

return VisualEffects
