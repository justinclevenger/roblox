--!strict

--[[
	Audio Layers for Proximity Fear System

	Non-diegetic audio that plays in the player's head based on entity proximity.

	Layer Stack:
	1. Sub-bass drone       (Tier 1+, volume scales)
	2. Heartbeat            (Tier 2+, tempo + volume scale)
	3. Character breathing  (Tier 2+, intensity scales)
	4. Dissonant music      (Tier 3+, layers + volume scale)
	5. Whispers             (Tier 4 only)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SoundConfig = require(ReplicatedStorage.Shared.SoundConfig)
local Types = require(ReplicatedStorage.Shared.Types)

local AudioLayers = {}
AudioLayers.__index = AudioLayers

export type AudioLayers = typeof(setmetatable(
	{} :: {
		player: Player,
		sounds: { [string]: Sound },
		heartbeatBaseRate: number,
	},
	AudioLayers
))

function AudioLayers.new(player: Player): AudioLayers
	local self = setmetatable({
		player = player,
		sounds = {},
		heartbeatBaseRate = 1.0,
	}, AudioLayers)

	self:createSounds()

	return self
end

function AudioLayers.createSounds(self: AudioLayers)
	local parent = SoundService

	-- Layer 1: Sub-bass drone
	local drone = Instance.new("Sound")
	drone.Name = "FearDrone"
	drone.SoundId = SoundConfig.SubBassDrone.assetId
	drone.Volume = 0
	drone.Looped = true
	drone.Parent = parent
	self.sounds.Drone = drone

	-- Layer 2: Heartbeat
	local heartbeat = Instance.new("Sound")
	heartbeat.Name = "FearHeartbeat"
	heartbeat.SoundId = SoundConfig.Heartbeat.assetId
	heartbeat.Volume = 0
	heartbeat.Looped = true
	heartbeat.PlaybackSpeed = 1
	heartbeat.Parent = parent
	self.sounds.Heartbeat = heartbeat

	-- Layer 3: Breathing
	local breathing = Instance.new("Sound")
	breathing.Name = "FearBreathing"
	breathing.SoundId = SoundConfig.Breathing.assetId
	breathing.Volume = 0
	breathing.Looped = true
	breathing.Parent = parent
	self.sounds.Breathing = breathing

	-- Layer 3b: Panic breathing (crossfades with normal breathing at high intensity)
	local breathingPanic = Instance.new("Sound")
	breathingPanic.Name = "FearBreathingPanic"
	breathingPanic.SoundId = SoundConfig.BreathingPanic.assetId
	breathingPanic.Volume = 0
	breathingPanic.Looped = true
	breathingPanic.Parent = parent
	self.sounds.BreathingPanic = breathingPanic

	-- Layer 4: Dissonant music
	local music = Instance.new("Sound")
	music.Name = "FearMusic"
	music.SoundId = SoundConfig.DissonantStrings.assetId
	music.Volume = 0
	music.Looped = true
	music.Parent = parent
	self.sounds.Music = music

	-- Layer 5: Whispers
	local whispers = Instance.new("Sound")
	whispers.Name = "FearWhispers"
	whispers.SoundId = SoundConfig.Whispers.assetId
	whispers.Volume = 0
	whispers.Looped = true
	whispers.Parent = parent
	self.sounds.Whispers = whispers

	-- Start all looped sounds (volume 0, will be controlled by update)
	for _, sound in self.sounds do
		sound:Play()
	end
end

function AudioLayers.update(self: AudioLayers, dt: number, intensity: number, _tier: Types.FearTier)
	-- Layer 1: Sub-bass drone (Tier 1+, intensity > 0)
	local droneVolume = if intensity > 0.05 then math.clamp(intensity * 0.6, 0, 0.5) else 0
	self:lerpVolume("Drone", droneVolume, dt)

	-- Layer 2: Heartbeat (Tier 2+, intensity > 0.25)
	local heartbeatVolume = if intensity > 0.25 then math.clamp((intensity - 0.25) * 1.6, 0, 0.8) else 0
	self:lerpVolume("Heartbeat", heartbeatVolume, dt)

	-- Heartbeat tempo scales with intensity
	local heartbeat = self.sounds.Heartbeat
	if heartbeat then
		local targetSpeed = 0.7 + intensity * 1.0 -- 0.7x at low, 1.7x at max
		heartbeat.PlaybackSpeed += (targetSpeed - heartbeat.PlaybackSpeed) * math.min(dt * 2, 1)
	end

	-- Layer 3: Breathing (Tier 2+, intensity > 0.25)
	-- Crossfade between normal and panic breathing at threshold 0.6
	local breathThreshold = 0.6
	if intensity > 0.25 then
		local breathBase = math.clamp((intensity - 0.25) * 1.2, 0, 0.7)
		if intensity >= breathThreshold then
			-- Crossfade: reduce normal, increase panic
			local crossfade = math.clamp((intensity - breathThreshold) / (1 - breathThreshold), 0, 1)
			self:lerpVolume("Breathing", breathBase * (1 - crossfade), dt)
			self:lerpVolume("BreathingPanic", breathBase * crossfade, dt)
		else
			self:lerpVolume("Breathing", breathBase, dt)
			self:lerpVolume("BreathingPanic", 0, dt)
		end
	else
		self:lerpVolume("Breathing", 0, dt)
		self:lerpVolume("BreathingPanic", 0, dt)
	end

	-- Layer 4: Dissonant music (Tier 3+, intensity > 0.5)
	local musicVolume = if intensity > 0.5 then math.clamp((intensity - 0.5) * 2, 0, 0.6) else 0
	self:lerpVolume("Music", musicVolume, dt)

	-- Layer 5: Whispers (Tier 4 only, intensity > 0.75)
	local whisperVolume = if intensity > 0.75 then math.clamp((intensity - 0.75) * 4, 0, 0.5) else 0
	self:lerpVolume("Whispers", whisperVolume, dt)
end

function AudioLayers.lerpVolume(self: AudioLayers, soundName: string, targetVolume: number, dt: number)
	local sound = self.sounds[soundName]
	if not sound then
		return
	end

	local lerpSpeed = if targetVolume > sound.Volume then 3.0 else 1.5
	sound.Volume += (targetVolume - sound.Volume) * math.min(lerpSpeed * dt, 1)

	-- Clamp very small values to 0 to avoid barely-audible artifacts
	if sound.Volume < 0.01 then
		sound.Volume = 0
	end
end

function AudioLayers.cleanup(self: AudioLayers)
	for _, sound in self.sounds do
		sound:Stop()
		sound:Destroy()
	end
	table.clear(self.sounds)
end

return AudioLayers
