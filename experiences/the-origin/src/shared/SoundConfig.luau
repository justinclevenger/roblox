--!strict
--# selene: allow(incorrect_standard_library_use)

--[[
	Sound configuration for The Origin.

	Asset IDs are placeholders — replace with actual uploaded audio asset IDs.
	Each entry defines a sound's properties for consistent use across client/server.
]]

export type SoundEntry = {
	assetId: string,
	volume: number,
	looped: boolean,
	rollOff: Enum.RollOffType?,
	maxDistance: number?,
	group: string,
}

local SoundConfig = {
	-- Ambient
	HospitalAmbience = {
		assetId = "rbxassetid://0", -- placeholder
		volume = 0.3,
		looped = true,
		group = "Ambient",
	},
	BasementDrip = {
		assetId = "rbxassetid://0",
		volume = 0.4,
		looped = true,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 40,
		group = "Ambient",
	},
	SteamVent = {
		assetId = "rbxassetid://0",
		volume = 0.6,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 30,
		group = "Ambient",
	},

	-- Player
	FootstepWalk = {
		assetId = "rbxassetid://0",
		volume = 0.3,
		looped = false,
		group = "Player",
	},
	FootstepSprint = {
		assetId = "rbxassetid://0",
		volume = 0.6,
		looped = false,
		group = "Player",
	},
	FootstepCrouch = {
		assetId = "rbxassetid://0",
		volume = 0.1,
		looped = false,
		group = "Player",
	},
	Breathing = {
		assetId = "rbxassetid://0",
		volume = 0.5,
		looped = true,
		group = "Player",
	},
	BreathingPanic = {
		assetId = "rbxassetid://0",
		volume = 0.8,
		looped = true,
		group = "Player",
	},
	FlashlightClick = {
		assetId = "rbxassetid://0",
		volume = 0.4,
		looped = false,
		group = "Player",
	},
	Heartbeat = {
		assetId = "rbxassetid://0",
		volume = 0.6,
		looped = true,
		group = "Player",
	},

	-- Entity
	EntityFootstep = {
		assetId = "rbxassetid://0",
		volume = 0.5,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 60,
		group = "Entity",
	},
	EntityBreathing = {
		assetId = "rbxassetid://0",
		volume = 0.4,
		looped = true,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 40,
		group = "Entity",
	},
	EntityChaseSound = {
		assetId = "rbxassetid://0",
		volume = 0.8,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 80,
		group = "Entity",
	},

	-- Proximity Fear (non-diegetic, client-only)
	SubBassDrone = {
		assetId = "rbxassetid://0",
		volume = 0.3,
		looped = true,
		group = "Fear",
	},
	DissonantStrings = {
		assetId = "rbxassetid://0",
		volume = 0.5,
		looped = true,
		group = "Fear",
	},
	Whispers = {
		assetId = "rbxassetid://0",
		volume = 0.4,
		looped = true,
		group = "Fear",
	},

	-- Environment
	DoorOpen = {
		assetId = "rbxassetid://0",
		volume = 0.5,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 30,
		group = "Environment",
	},
	DoorSlam = {
		assetId = "rbxassetid://0",
		volume = 0.8,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 50,
		group = "Environment",
	},
	GlassCrunch = {
		assetId = "rbxassetid://0",
		volume = 0.4,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 25,
		group = "Environment",
	},
	MorgueDrawer = {
		assetId = "rbxassetid://0",
		volume = 0.7,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 35,
		group = "Environment",
	},
	GeneratorPull = {
		assetId = "rbxassetid://0",
		volume = 0.9,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 60,
		group = "Environment",
	},
	GeneratorRunning = {
		assetId = "rbxassetid://0",
		volume = 0.7,
		looped = true,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 50,
		group = "Environment",
	},
	PhoneRing = {
		assetId = "rbxassetid://0",
		volume = 0.6,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 30,
		group = "Environment",
	},
	VendingMachine = {
		assetId = "rbxassetid://0",
		volume = 0.5,
		looped = false,
		rollOff = Enum.RollOffType.InverseTapered,
		maxDistance = 35,
		group = "Environment",
	},
}

return SoundConfig
