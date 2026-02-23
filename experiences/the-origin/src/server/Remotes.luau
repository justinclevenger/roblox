--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

-- Remote references (populated by init)
Remotes.EntityPositionUpdate = nil :: RemoteEvent?
Remotes.EntityStateChanged = nil :: RemoteEvent?
Remotes.SoundEvent = nil :: RemoteEvent?
Remotes.PlayerDamaged = nil :: RemoteEvent?
Remotes.ObjectiveUpdated = nil :: RemoteEvent?
Remotes.ObjectivesLoaded = nil :: RemoteEvent?
Remotes.ItemPickup = nil :: RemoteEvent?
Remotes.ItemPickupResult = nil :: RemoteEvent?
Remotes.UseItem = nil :: RemoteEvent?
Remotes.HidingEntered = nil :: RemoteEvent?
Remotes.HidingExited = nil :: RemoteEvent?
Remotes.HidingSpotChecked = nil :: RemoteEvent?
Remotes.GeneratorInteract = nil :: RemoteEvent?
Remotes.GeneratorStateUpdate = nil :: RemoteEvent?
Remotes.BeaconActivated = nil :: RemoteEvent?
Remotes.RoundStarted = nil :: RemoteEvent?
Remotes.RoundEnded = nil :: RemoteEvent?
Remotes.PlayerStateUpdate = nil :: RemoteEvent?
Remotes.FlashlightFlicker = nil :: RemoteEvent?

function Remotes.init()
	-- Create container folder
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage

	-- Helper to create and register a RemoteEvent
	local function createRemote(name: string): RemoteEvent
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		return remote
	end

	-- Create all remotes
	Remotes.EntityPositionUpdate = createRemote("EntityPositionUpdate")
	Remotes.EntityStateChanged = createRemote("EntityStateChanged")
	Remotes.SoundEvent = createRemote("SoundEvent")
	Remotes.PlayerDamaged = createRemote("PlayerDamaged")
	Remotes.ObjectiveUpdated = createRemote("ObjectiveUpdated")
	Remotes.ObjectivesLoaded = createRemote("ObjectivesLoaded")
	Remotes.ItemPickup = createRemote("ItemPickup")
	Remotes.ItemPickupResult = createRemote("ItemPickupResult")
	Remotes.UseItem = createRemote("UseItem")
	Remotes.HidingEntered = createRemote("HidingEntered")
	Remotes.HidingExited = createRemote("HidingExited")
	Remotes.HidingSpotChecked = createRemote("HidingSpotChecked")
	Remotes.GeneratorInteract = createRemote("GeneratorInteract")
	Remotes.GeneratorStateUpdate = createRemote("GeneratorStateUpdate")
	Remotes.BeaconActivated = createRemote("BeaconActivated")
	Remotes.RoundStarted = createRemote("RoundStarted")
	Remotes.RoundEnded = createRemote("RoundEnded")
	Remotes.PlayerStateUpdate = createRemote("PlayerStateUpdate")
	Remotes.FlashlightFlicker = createRemote("FlashlightFlicker")

	print("[Remotes] All remote events created")
end

return Remotes
