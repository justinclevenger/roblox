--!strict

export type EntityState = "Idle" | "Patrol" | "Investigate" | "Hunt" | "Chase" | "Search"

export type SoundEvent = {
	position: Vector3,
	radius: number,
	priority: "Low" | "Medium" | "High" | "Critical",
	source: Player?,
}

export type EntitySenses = {
	hearingRange: number,
	visionCone: number,
	visionRangeLit: number,
	visionRangeDark: number,
	flashlightDetectRange: number,
	detectionRamp: number,
}

export type EntityProfile = {
	name: string,
	primarySense: "Hearing" | "Vision",
	patrolSpeed: number,
	chaseSpeed: number,
	senses: EntitySenses,
	checkHidingSpots: boolean,
	uniqueMechanic: string,
}

export type AdaptiveMemory = {
	hidingSpotUses: { [string]: number },
	escapeRoutes: { [string]: number },
	timeSinceStart: number,
	playerDeaths: number,
}

export type FearTier = "Safe" | "Unease" | "Dread" | "Panic" | "Proximity"

export type PlayerState = {
	health: number,
	maxHealth: number,
	stamina: number,
	isSprinting: boolean,
	isCrouching: boolean,
	isHiding: boolean,
	isBleeding: boolean,
	isDowned: boolean,
	hidingSpotId: string?,
	inventory: { InventoryItem },
	keyItems: { string },
}

export type InventoryItem = {
	id: string,
	name: string,
	itemType: "Battery" | "Bandage" | "Medkit" | "Flare" | "Flashlight" | "FuelCanister",
}

export type LootSpawn = {
	itemType: string,
	position: Vector3,
	chance: number, -- 0 to 1
	guaranteed: boolean,
}

export type LoreEntry = {
	id: string,
	title: string,
	content: string,
	level: number,
	found: boolean,
}

export type ObjectiveStep = {
	id: string,
	description: string,
	completed: boolean,
	requiredItems: { string }?,
}

export type HidingSpot = {
	id: string,
	position: Vector3,
	spotType: "Locker" | "UnderBed" | "Closet" | "LaundryCart" | "BathroomStall" | "Desk",
	isOccupied: boolean,
}

export type PatrolWaypoint = {
	position: Vector3,
	roomId: string,
	dwellTime: number,
}

export type BloodTrailPoint = {
	position: Vector3,
	timestamp: number,
}

export type LevelData = {
	hidingSpots: { HidingSpot },
	waypoints: { PatrolWaypoint },
	lootPositions: { LootSpawn },
	spawnPoint: Vector3,
	entitySpawnPositions: { Vector3 },
}

export type DoorData = {
	id: string,
	position: Vector3,
	isLocked: boolean,
	requiredKey: string?,
	soundRadius: number,
}

export type PlayerSaveData = {
	levelsUnlocked: { string },
	loreFound: { string },
	xp: number,
	perks: { string },
}

return nil
