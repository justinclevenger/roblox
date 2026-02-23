# The Origin — Randomized Jumpscare System

## Design Philosophy

The game's core terror comes from sustained dread — atmosphere, sound, and intelligent AI. Jumpscares serve a different purpose: they **punctuate** the dread. A well-placed jumpscare after 5 minutes of creeping tension amplifies the fear tenfold. A cheap jumpscare every 30 seconds teaches the player to stop caring.

**Rules:**

1. **Earned, not cheap.** Every jumpscare must follow a period of tension. The setup matters more than the payoff.
2. **Randomized, not scripted.** Players should never know when one is coming. Replays feel different.
3. **Cooldown-protected.** Minimum 90 seconds between jumpscares. Maximum 2 per 10-minute window.
4. **Contextual.** Jumpscares match the current environment and entity. A face in a mirror makes sense. A face in an open field doesn't.
5. **Some are harmless.** Not every scare is the entity. False alarms keep paranoia high without punishing the player.
6. **Never during hiding.** A jumpscare while the player is locked in a hiding animation with no control is unfair. Scares happen when the player can react.

---

## Scare Categories

### Category A: Environmental Scares (Harmless)

No entity involvement. The environment itself startles the player. These are the most frequent and serve to keep tension high during "safe" periods.

**A1 — Sudden Sound**
- A door slams somewhere nearby (wind, structural settling)
- Glass breaks in an adjacent room
- Metal clanging from vents/pipes
- A phone/radio/PA system crackles to life for 1-2 seconds
- Something heavy falls off a shelf
- **Trigger:** Player has been in a quiet area for 60+ seconds
- **Frequency:** Common (30% chance per eligible trigger)

**A2 — Object Movement**
- A chair slides across the floor on its own
- A gurney/cart rolls a few feet then stops
- Ceiling tiles drop
- A door creaks open slowly (no one there)
- Curtains/sheets billow from nonexistent wind
- **Trigger:** Player enters a room or passes through a corridor
- **Frequency:** Uncommon (15% chance per eligible room)

**A3 — Light Disruption**
- Overhead light explodes with a pop and sparks
- Flashlight flickers rapidly for 2 seconds (not battery — something else)
- All lights in a corridor go out in sequence approaching the player, then snap back on
- Emergency light starts spinning/strobing
- **Trigger:** Player is in a lit area or using flashlight
- **Frequency:** Uncommon (15% chance, minimum 3 minutes between light scares)

**A4 — False Figure**
- Shadow passes across a wall at the edge of vision (nothing there)
- Silhouette visible through frosted/dirty glass (gone when door opened)
- Mannequin/body that wasn't there before (or was it? player second-guesses themselves)
- Player's own shadow behaves slightly wrong for one frame
- **Trigger:** Player is alone and moving through a transition space (corridor, stairwell)
- **Frequency:** Rare (8% chance, maximum once per 5 minutes)

---

### Category B: Entity Proximity Scares (Warning)

The entity is genuinely nearby. These scares serve as an organic warning system — they're terrifying AND informational.

**B1 — Near Miss**
- Player rounds a corner and the entity is at the far end of the corridor, back turned, walking away
- Entity's shadow slides across the floor/wall of an adjacent room
- Entity's breathing/footsteps suddenly audible, very close, then moving away
- Hiding in a locker: entity walks past the slats, visible through the gaps, doesn't check
- **Trigger:** Entity is in PATROL within 30-50 studs and moving away from player
- **Frequency:** Organic (happens naturally when entity patrol brings it close)

**B2 — Almost Caught**
- Entity turns toward player's position — awareness ramp begins — player ducks behind cover just in time
- Entity checks the hiding spot the player JUST left
- Entity stops in a doorway the player needs to pass through, pauses, then moves on
- **Trigger:** Entity in INVESTIGATE or HUNT state near player
- **Frequency:** Organic

**B3 — Electronics Flare (Level 1 Specific)**
- CCTV monitor the player is watching suddenly shows the entity staring directly into the camera, close-up, then static
- Flashlight dims and the entity's breathing is RIGHT behind the player — then dims further and goes silent (entity actually moved away)
- PA system plays Patient 31's flatline tone, growing louder
- **Trigger:** The Patient is within 25 studs
- **Frequency:** Uncommon (20% chance when conditions met)

---

### Category C: Shock Scares (Direct)

Full jumpscares. Loud audio sting, visual disruption, high intensity. Used sparingly. These are the ones players will clip and share.

**C1 — The Face**
- Player looks in a mirror/reflective surface — their reflection is replaced by the entity's face for 0.5 seconds, then normal
- Player opens a locker/drawer/door and the entity's face is pressed against it from the other side — but it's already gone
- Turning around in a dead end — entity is RIGHT there, inches away — screen cuts to black for 0.3s — when vision returns, nothing
- **Audio:** Sharp, discordant sting (violin screech / reversed breath / metallic scrape)
- **Visual:** Camera jolts, brief chromatic aberration spike, 2-frame flash
- **Trigger:** Player is in a confined space, not in combat/chase, entity is NOT actually present
- **Frequency:** Rare (5% chance per eligible trigger, maximum once per 8 minutes, cooldown resets on death)
- **CRITICAL: The entity is NOT actually there.** This is a hallucination/false alarm. The player panics, sprints, makes noise — potentially attracting the REAL entity. The jumpscare creates a secondary danger.

**C2 — The Grab**
- Hand reaches out from under a bed/through a grate/from a vent as player passes — grabs at ankle
- Something brushes the player's shoulder from behind in a narrow space
- Reaching into a dark space for loot — something grabs the player's hand momentarily
- **Effect:** Brief camera shake, player model flinches (0.3s movement lock), NO damage
- **Audio:** Wet grab sound + player character gasp
- **Trigger:** Player interacting with specific objects (beds, vents, dark containers) for the first time
- **Frequency:** Rare (10% per eligible interaction, once per unique location per run)
- **No damage.** The scare IS the scare. Damaging the player would make these feel punishing rather than frightening.

**C3 — The Drop**
- Something drops from the ceiling directly in front of the player (dead animal, debris, a body, the entity's face flashing then gone)
- Player walks under a vent and something slams against the grate from above
- Ceiling tile collapses revealing a dark void with movement inside
- **Audio:** Heavy impact + player character recoil sound
- **Trigger:** Player passes under specific ceiling points
- **Frequency:** Rare (8% per eligible point, once per location per run)

**C4 — The Reveal**
- Player picks up a lore document/item — camera forces a slow look up from the document — entity is standing in the doorway. Screen cuts. Entity is gone.
- Flashlight dies. When it comes back (1.5s), the room has changed — furniture moved, writing on walls. Blink. Normal again.
- Player opens a door and the entity is on the other side, reaching for the handle. Both freeze. Entity lunges. Screen blacks out. Player is still alive, door is now closed, entity is gone.
- **Trigger:** Player picks up key lore items or opens specific doors (first time only per run)
- **Frequency:** Very rare. 2-3 total possible per level, only 1 fires per run (random selection).

---

### Category D: Persistent Anomalies (Slow Burn)

Not jumpscares in the traditional sense. These are slow, creeping wrongness that the player notices gradually — and then can't stop seeing.

**D1 — The Follower**
- Player notices a figure at extreme render distance — standing still, facing them
- If they look away and back, it's closer. Still facing them.
- Third look: gone
- NOT the entity. Something else. Never explained.
- **Trigger:** Player is in a large open area or long corridor with clear sightlines
- **Frequency:** Very rare (once per 2-3 runs, random)

**D2 — The Changed Room**
- Player returns to a previously visited room. Something has changed:
  - A chair is now facing the door
  - A message is written on the wall/mirror that wasn't there
  - A body is in a position it wasn't in before
  - Photos on the wall now have the player character's face
  - The clock shows a different time (always 3:31 AM — Patient 31)
- Changes are subtle. Player may not notice. That's fine. The ones who do will be terrified.
- **Trigger:** Player revisits a room they spent significant time in (30+ seconds previously)
- **Frequency:** Uncommon (25% chance on eligible revisits, maximum 2 per run)

**D3 — The Whisper**
- Player's name (their Roblox username) is whispered at barely audible volume
- A child's voice says something just below comprehension
- Backwards speech that, if reversed, says something related to the lore
- Entity makes a sound that sounds like it's trying to form words
- **Trigger:** Player has been alone (no entity within 80 studs) for 2+ minutes
- **Frequency:** Rare (15% chance, once per 5 minutes maximum)

**D4 — Screen Corruption**
- Brief UI glitch — health display shows wrong numbers for 0.5s
- Inventory flickers showing items the player doesn't have
- Loading screen text appears for a single frame during gameplay
- A second crosshair/cursor appears for 1-2 seconds then vanishes
- The pause menu appears for 0.1s then disappears (player didn't press anything)
- **Trigger:** Player at Proximity Fear Tier 1+ OR random during extended quiet periods
- **Frequency:** Rare (10% chance per minute at Tier 1+, once per 3 minutes max)

---

## Per-Level Scare Pools

Each level has a curated set of eligible scares that match the environment and entity.

### Level 1: St. Maren's Hospital

| Category | Eligible Scares | Level-Specific Variants |
|---|---|---|
| A1 Sound | Doors, glass, PA system, phone | Heart monitor flatline from empty room. Elevator ding (elevator is dead). |
| A2 Object | Gurney, wheelchair, curtain, IV stand | Wheelchair rolls down hallway on its own. IV bag swings violently. |
| A3 Light | Overhead, flashlight, corridor sequence | Operating theater skylight flickers. Emergency exit signs go red. |
| A4 Figure | Shadow, glass silhouette, mannequin | Mannequin in Emergency Ward has moved between visits. Shadow in Operating Theater gallery. |
| C1 Face | Mirror (restroom), window, locker | Reflection in Security Office monitors. Face in Morgue drawer glass. |
| C2 Grab | Under bed, through grate | Hand from under patient bed. Fingers through morgue vent. |
| C3 Drop | Ceiling tile, vent | Ceiling tile in basement corridor. Body in elevator shaft (look up). |
| C4 Reveal | Lore pickup, door open | Reading Patient 31 chart — look up — Patient in doorway. |
| D2 Changed | Patient rooms, break room | Coffee mug moved. Whiteboard message changed. Room 201 bed is now unmade. |

### Level 2: Line 13 Subway

| Category | Eligible Scares | Level-Specific Variants |
|---|---|---|
| A1 Sound | Metal, trains, water | Train horn in the distance (no trains running). Clicking from inside walls (Crawlers). Rail grinding sound. |
| A2 Object | Train doors, ceiling panels | Train doors at Moorfield open/close on their own. Ceiling grate falls. Turnstile spins. |
| A3 Light | Tunnel lights, emergency strips | Lights ahead go out in sequence as if something ran past them. Sparking rail. |
| A4 Figure | Tunnel silhouette, train window | Shape moves past train window from outside. Shadow drops from ceiling ahead then nothing. |
| C1 Face | Train window reflection, puddle | Crawler face in standing water reflection. Face presses against ventilation grate. |
| C2 Grab | Vent, floor grate, tunnel gap | Arm reaches from wall crack. Something brushes leg in flooded section. Hand from under train. |
| C3 Drop | Ceiling, vent shaft | Crawler body drops from ceiling 10 feet ahead — but it's just debris. Dead rat from vent. |
| D1 Follower | Long tunnel sightline | Figure at far end of Main Tunnel. Closer each glance. Gone. |
| D3 Whisper | Echo chambers, drainage | Your footstep echoes come back as something else's footsteps. Whisper from drain. |

### Level 3: Blackpoint Research Station

| Category | Eligible Scares | Level-Specific Variants |
|---|---|---|
| A1 Sound | Lab equipment, alarms, intercoms | Containment alarm blares for 2 seconds then stops. Centrifuge spins up on its own. |
| A2 Object | Lab stools, specimen jars, doors | Specimen jar falls off shelf. Containment cell door opens slowly. Office chair rotates to face you. |
| A3 Light | Fluorescent, containment lighting | Biology lab lights shift to UV momentarily (reveals hidden writing). Strobe in containment corridor. |
| A4 Figure | Glass reflection, fog, duplicates | Your reflection in containment glass moves independently for 0.5s. Second "you" at end of corridor. |
| C1 Face | One-way glass, monitors, tank glass | Face appears behind one-way glass (observation room). Monitor shows live feed of you from inside the room. Entity face in specimen jar (not a specimen). |
| C4 Reveal | Project ECHO docs, tank examination | Reading ECHO file — lights cut — when they return, something is drawn on the ceiling above you. |
| D2 Changed | Offices, containment cells | Cell Block B: the "mannequin" has turned to face the glass. Employee photo — one more face scratched out (yours). |
| D4 Corruption | Monitors, intercoms | Containment Control monitor shows cell feed of YOU inside a cell. Intercom plays your voice saying things you didn't say. |

**Mimic-Specific Scares (Level 3 Only):**
- Player picks up a loot item. Normal. Picks up another. As they turn away, the first "item" unfolds behind them. They hear it. Turn back. Nothing. Item is still there. Was it always?
- In multiplayer: a third "player" appears in a room with two actual players. No one called for them. Who is it?
- Player enters a room they've been in before. Everything is identical. Except there are two of everything. Two chairs. Two desks. Two doors. One of each is real.

### Level 4: Ashwood Forest

| Category | Eligible Scares | Level-Specific Variants |
|---|---|---|
| A1 Sound | Branch snapping, animal cry, wind | Heavy footstep behind you (just a branch falling). Scream in the distance (animal? person? neither). Rhythmic tapping on cabin window. |
| A2 Object | Tent flap, cabin door, campfire | Tent flap opens on its own. Cabin door creaks open — wind or Watcher? Campfire relights briefly (dead fire). |
| A3 Light | Flashlight, moonlight, cabin lights | Moon goes behind clouds — pitch darkness for 3 seconds. Flashlight catches something reflective in the trees (eyes? glass?). Cabin A light turns on. No one's inside. |
| A4 Figure | Tree line, fog, window | Figure between trees at edge of flashlight range — tree? Watcher? Just a tree. Figure in cabin window as you approach — gone when you enter. |
| C3 Drop | Tree branch, bird startled | Massive branch crashes down behind player. Flock of birds explodes from tree canopy. |
| D1 Follower | Forest clearings, trail sightlines | Figure at the tree line. Every time you look away it's one tree closer. It's NOT a Watcher (Watchers freeze — this doesn't). |
| D2 Changed | Campsite, cabins | Return to campsite — tent is now zipped closed from inside. Cabin B door is now locked (it wasn't before). |
| D3 Whisper | Wind, creek, cave | Wind carries syllables of your name. Creek water sounds like murmuring voices. Cave echoes come back distorted. |

**Watcher-Specific Scares (Level 4 Only):**
- Player scans the forest with flashlight. Counts 3 Watchers. Blinks. Counts 4. Where did the 4th come from?
- Fog rolls in. Clears. A Watcher is now 10 studs away that wasn't there before. Staring.
- Player enters Supply Shed. Closes door behind them. Turns around. A Watcher is IN the shed. Frozen. Watching. It was there the whole time.
- Looking down from the Watchtower: Watchers are arranged in a line leading directly to the tower base. Pointing up.

### Level 5: The Origin

| Category | Eligible Scares | Level-Specific Variants |
|---|---|---|
| A1 Sound | Stone grinding, water, whispers | Stone slab moves somewhere in the catacombs. Water level rises briefly (sound of rushing). Chanting from deep below. |
| A2 Object | Coffin lids, stone doors, debris | Coffin lid slides open (empty). Stone door grinds shut behind you (still passable, but the sound). Debris falls from ceiling as something moves above. |
| A3 Light | Torch, flashlight, bioluminescence | Torches in wall sconces ignite as you pass, extinguish behind you. Flashlight reveals symbols that glow and fade. Bioluminescent fungus pulses like a heartbeat. |
| A4 Figure | Shadows, reflections, carved faces | Carved faces in the walls — one of them blinks. Shadow on the wall has too many limbs. Your shadow stays behind when you move, then catches up. |
| C1 Face | Mirror Room, water surface, stone | Mirror Room: every reflection is you except one. Water surface in Flooded Gallery: the face looking up isn't yours. Carved face opens its mouth. |
| C4 Reveal | Throne examination, Seal interaction | Approaching the Throne — the entity on it turns its head toward you (first movement in millennia). The Seal pulses as you touch it — every entity in the level screams simultaneously. |
| D1 Follower | Catacomb corridors, Warren tunnels | Something follows at the edge of darkness. Not any entity you recognize. Something older. |
| D4 Corruption | UI, audio, visuals | Health display shows a fifth pip (you only have 4). Map/compass shows you going deeper when you're going up. Audio from Level 1 plays faintly (the phone ringing). |

---

## Technical Implementation

### Scare Manager (Server-Side)

```
ScareCooldownTracker
├── lastScareTime: number (tick)
├── scaresThisWindow: number (count in current 10-min window)
├── perLocationHistory: {[locationId]: {scareId, timestamp}[]}
├── playerStressLevel: number (0-1, based on recent events)
└── eligibleScares: () → FilteredScarePool
```

**Selection Logic:**
1. Check global cooldown (90s since last scare)
2. Check window limit (max 2 per 10 minutes)
3. Filter by current location (only contextually appropriate scares)
4. Filter by history (no repeat scares at same location in same run)
5. Weight by player stress level:
   - Low stress (long quiet period) → higher chance of environmental scares (Cat A)
   - Medium stress (entity nearby recently) → lower chance (player is already scared)
   - High stress (active chase/hide) → zero chance (never scare during gameplay tension)
6. Roll probability
7. If successful: execute scare, record to history, reset cooldown

### Scare Execution (Client-Side)

Each scare type has a ScareDefinition:

```
{
    id: string,
    category: "A" | "B" | "C" | "D",
    level: number,
    locations: string[],          -- eligible room IDs
    probability: number,          -- base % chance when eligible
    cooldownSeconds: number,      -- minimum time before this specific scare can re-trigger
    maxPerRun: number,            -- max times this scare fires per run (-1 = unlimited)
    requiresEntityDistance: {min: number, max: number}?,  -- entity distance constraints
    requiresPlayerState: string?, -- "walking" | "standing" | "crouching" | "interacting"
    audio: {
        sting: string?,           -- sharp audio cue (sound ID)
        ambient: string?,         -- ambient shift (sound ID)
        duration: number,         -- how long audio plays
    },
    visual: {
        cameraShake: {intensity: number, duration: number}?,
        flash: {frames: number, content: string}?,
        chromaticAberration: {intensity: number, duration: number}?,
        screenCut: {duration: number, color: Color3}?,
    },
    world: {
        spawnObject: {model: string, position: CFrame, duration: number}?,
        moveObject: {objectId: string, targetCFrame: CFrame, tweenTime: number}?,
        lightChange: {lightId: string, property: string, value: any, duration: number}?,
        soundEmitter: {position: Vector3, soundId: string, radius: number}?,
    },
    movementLock: number?,        -- seconds player input is dampened (max 0.5s)
}
```

### Performance Considerations

- All scare logic runs on the server to prevent client manipulation
- Visual/audio execution is via RemoteEvent to the specific client(s) affected
- World object changes (moved furniture, spawned objects) are replicated to all clients
- In multiplayer: jumpscares are per-player for Categories A/C/D. Only the affected player sees their face in the mirror or hears the whisper. Category B scares (entity proximity) are shared since the entity is a shared world object.
- Pre-instantiate scare objects at level load (hidden) rather than creating at trigger time — prevents frame drops at the worst possible moment.

### Multiplayer Scare Behavior

| Category | Who Experiences It | Others See/Hear |
|---|---|---|
| A (Environmental) | All players in range | Yes — shared world events |
| B (Entity Proximity) | All players in range | Yes — entity is real |
| C (Shock) | Target player only | No — hallucination, subjective |
| D (Anomaly) | Target player only | No — personal paranoia |

This creates a multiplayer dynamic where one player screams and the others don't know why. "Did you see that?!" "See what?" — pure paranoia fuel. The screaming player's reaction over proximity voice IS the scare for everyone else.

---

## Difficulty Modifier: Paranoia Mode

An unlockable difficulty modifier that increases scare frequency and intensity:

- Scare cooldown reduced from 90s to 45s
- Window limit increased from 2 to 4 per 10 minutes
- Category C probability doubled
- Category D scares can stack (multiple anomalies simultaneously)
- New scare type unlocked: **The Mirror Self** — player's character model occasionally acts independently for 0.5s (turns head, stops walking for a beat, looks at something the player didn't look at)
- Bonus XP: +25% for completing a level with Paranoia Mode active

---

## The Golden Rule

**The scariest jumpscare is the one that almost happens.** A door that creaks open to reveal nothing is scarier than a monster behind every door — because now EVERY door might have something behind it. The system is designed so that 70% of "scare-eligible" moments produce nothing. The anticipation does more work than the payoff. The player scares themselves.
