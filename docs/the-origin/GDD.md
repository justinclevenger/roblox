# The Origin — Game Design Document

## Overview

| Field | Value |
|-------|-------|
| Title | The Origin |
| Genre | Survival Horror |
| Platform | Roblox |
| Players | 1-4 (Solo + Co-op) |
| Session Length | 10-25 minutes per level |
| Target Audience | 13+ |
| Tone | Genuinely terrifying |

### Elevator Pitch

A survival horror experience where players trace the source of a supernatural threat across five escalating levels — from an abandoned hospital to the ancient site beneath it. No weapons. No fighting back. Only hide, run, or outsmart the entities hunting you. Each level introduces a new entity with unique AI behavior, forcing players to constantly adapt their survival strategies. Solo delivers a tight, narrative-driven horror experience. Co-op delivers paranoia — because multiplayer horror is scariest when it threatens to become solo at any moment.

### Core Pillars

1. **Genuine Terror** — Sustained dread through sound, lighting, and intelligent AI — punctuated by randomized jumpscares that earn their impact through tension buildup (see [jumpscare-system.md](jumpscare-system.md)).
2. **Adaptive Threat** — Entities learn your habits. Hiding in the same spot twice is a death sentence.
3. **No Combat** — You are prey. Survival means evasion, stealth, and resourcefulness.
4. **Escalating Mastery** — Each level teaches a new mechanic. By Level 5, everything combines.
5. **Atmospheric Storytelling** — Lore is found, not told. The story reveals itself through the environment.

---

## Core Loop

```
Enter Level → Scavenge (supplies, tools) → Survive threats → Reach extraction → Unlock next level
     ↑                                                              |
     └──── death resets the run, but progression persists ───────────┘
```

### Per-Run Flow

1. Spawn at level entry point
2. Explore and scavenge: flashlight batteries, bandages, flares, key items
3. Complete survival objectives (power generators, find fuel, activate extraction)
4. Survive while objectives complete (timers, entity aggression spikes)
5. Reach extraction point
6. Success: unlock next level, earn XP, update hub room

### Lives & Death

Players have **3 lives** (hearts) per run. Each death triggers a heart-shatter animation:

- **Death 1 & 2:** Heart cracks and shatters. Text: *"You've died."* Player respawns at nearest checkpoint with full health, keeping inventory and objective progress. Entity relocates. Ambient dread subtly increases.
- **Death 3 (final):** Last heart detonates. 2 seconds of absolute silence. Text: *"You've died forever."* Full run reset — return to Hub, all progress lost except permanent unlocks.
- **Co-op:** Deaths are per-player. Players enter a downed/crawl state first (30s revive window). Final death puts them in spectator mode — watching via fixed cameras, unable to communicate.

See [death-system.md](../docs/the-origin/death-system.md) for full animation design, respawn rules, checkpoint locations, and multiplayer behavior.

---

## Player Mechanics

### Movement

| Action | Speed | Sound Radius | Stamina Cost |
|--------|-------|-------------|--------------|
| Crouch walk | Very slow | 3 studs (ignored by entity) | None |
| Walk | Normal | 12 studs | None |
| Sprint | Fast | 40 studs | Drains over ~6s |
| Crouch (stationary) | — | Silent | Recovers stamina slowly |
| Standing still | — | Silent | Recovers stamina |

- Stamina recovers faster when standing still than when crouch-walking
- Sprinting when stamina is empty forces a stumble animation (loud, 1s recovery)
- Sprint burst is faster than any entity for ~2 seconds, then entities close the gap

### Health & Injury

- 4 health pips (hits from entity or hazards remove pips)
- No natural regeneration
- Injury states stack:
  - 3 pips: Normal
  - 2 pips: Limping (move speed -15%, footstep sounds louder)
  - 1 pip: Bleeding (leaves a trail the entity follows, vision impaired)
  - 0 pips: Death
- Bandage: restores 1 pip, stops bleeding
- Medkit: full heal, stops bleeding, removes all injury states

### Inventory

- Limited slots (4 items)
- Items: Battery, Bandage, Medkit, Flare, Key Items (keys, fuel, keycards)
- Key items don't consume inventory slots (stored separately)
- No item stacking (each battery/bandage is one slot)
- Forces choices: do you carry healing or flashlight fuel?

### Flashlight

- Primary tool. Toggle on/off.
- Battery drains over ~3 minutes of continuous use
- Batteries are consumable (swap when current one dies)
- Flashlight click sound is audible to entities (15 stud radius)
- Entity can see flashlight beam at 50+ studs (the light is a beacon)
- Turning it off in hiding is critical — but then you can't see

### Hiding

- Context-sensitive: approach a hiding spot, interact to enter
- Hiding spots: lockers, under desks/beds, inside closets, laundry carts, bathroom stalls
- Player enters a locked camera angle while hiding (can look around but not move)
- Breathing sounds continue — entity can hear you if very close
- Flashlight auto-turns off when hiding
- Entity checks hiding spots with increasing frequency based on adaptive behavior

### Flares

- Throwable distraction item
- Creates a bright light and sound at the thrown location
- Entity investigates the flare location for ~8 seconds
- Also illuminates dark areas briefly (useful for scouting)
- Limited supply (0-3 per run depending on loot luck)

---

## Entity AI System

### State Machine

```
IDLE → PATROL → INVESTIGATE → HUNT → CHASE → SEARCH → PATROL
                                                 ↓
                                              LOSE INTEREST → PATROL
```

### States

**IDLE** — Dormant at round start. Activates after a delay or trigger zone entry. Gives players safe early exploration.

**PATROL** — Semi-random path through the map. Weighted toward areas the player hasn't been spotted in recently. Walking pace, ambient sounds (dragging, breathing, distant thuds). Lingers in rooms for 8-15s.

**INVESTIGATE** — Triggered by sound events. Moves to sound origin at brisk pace. Checks nearby hiding spots with increasing thoroughness. Investigation radius and duration scale with loudness. Returns to PATROL after timeout.

**HUNT** — Activated by partial detection (glimpse, repeated nearby sounds). Actively sweeps area in tightening pattern. Faster than patrol, slower than chase. Checks hiding spots methodically. Ambient audio shifts.

**CHASE** — Full visual confirmation. Sprints faster than player's sustained run (player's initial burst is faster). Follows last-known trajectory, not perfect tracking. Turning corners and breaking line of sight works. Doors slow it briefly. If it loses sight for ~8-10s, drops to SEARCH.

**SEARCH** — Post-chase sweep. Erratic, aggressive. Checks hiding spots, doubles back, pauses to listen. Lasts 20-30s. Returns to PATROL with area bias if nothing found.

### Sensory Systems

#### Hearing (Primary Sense)

| Sound Source | Radius | Priority |
|-------------|--------|----------|
| Sprinting | 40 studs | High |
| Walking | 12 studs | Low |
| Crouching | 3 studs | Ignored |
| Opening doors | 25 studs | Medium |
| Knocking over objects | 35 studs | High |
| Flashlight clicking | 15 studs | Medium |
| Player taking damage | 50 studs | Critical |
| Thrown distraction (flare) | 45 studs | High |
| Generator pull cord | 60 studs | Critical |

- Sounds propagate through open doors and corridors, dampened through walls/closed doors
- Closing doors behind you reduces sound propagation significantly

#### Vision (Secondary Sense)

- ~60-degree forward cone
- Lit areas: 30 stud detection range
- Dark areas: 8 stud detection range
- Flashlight beam visible to entity at 50+ studs
- No vision behind it — circling around works if quiet
- Detection is not instant: 0.5-1s awareness ramp
- Ducking behind cover during awareness ramp triggers INVESTIGATE (not CHASE)

#### Trail Detection (Passive)

- Bleeding players leave a visible trail
- Entity follows blood trails at patrol speed
- Trail fades after 60 seconds
- Creates urgency to heal even when safe

### Adaptive Behavior

**Hiding Spot Memory** (per run)
- Tracks which hiding spots the player has used
- 1st use: entity walks past 90% of the time
- 2nd use of same spot: 50/50 check
- 3rd use: goes straight to it
- Different spot types tracked separately (lockers, desks, closets)
- Forces strategy rotation

**Route Memory** (per run)
- Repeated escape routes cause entity to patrol those corridors
- Subtle at first, obvious by third repetition
- Punishes predictable behavior

**Escalation Over Time**
- As run progresses / objectives near completion:
  - Patrol speed increases slightly
  - Investigation duration lengthens
  - Chase speed gets small bump
  - Hearing radius expands
- Creates natural difficulty curve: early exploration is manageable, final push is panic

**De-escalation (Rubber Banding)**
- Multiple deaths in short window: quietly reduce aggression
- Slightly slower patrol, shorter investigation
- Never obvious — player feels lucky, not pitied
- Prevents frustration spirals without removing threat

### Entity Profiles

| Parameter | The Patient (L1) | The Crawlers (L2) | The Mimic (L3) | The Watchers (L4) |
|-----------|-------------------|--------------------|-----------------|---------------------|
| Primary sense | Hearing | Hearing | Vision | Vision |
| Count | 1 | Pack (3-5) | 1 | Multiple (2-6) |
| Patrol speed | Slow | Fast | Medium | Static |
| Chase speed | Medium | Very fast | Medium | Teleport-like |
| Detection ramp | 1.5s (forgiving) | 0.3s (brutal) | 2s (deceptive) | Instant |
| Hiding checks | Rare early, learns | Always checks | Doesn't check — mimics spots | N/A (freezes when watched) |
| Unique mechanic | Flatlines electronics nearby | Climbs walls/ceilings | Appears as loot/teammate | Only moves when unobserved |
| Level | Hospital | Subway | Research Station | Forest |

#### The Patient (Level 1)
- Tutorial entity. Slower, more forgiving detection.
- Flatlines electronics within 20 studs (CCTV static, flashlight dims, radios buzz) — an early warning system players learn to read.
- Doesn't check hiding spots for first 2 uses (teaching the mechanic safely).
- After generator activation, all restraint removed. Full aggression.

#### The Crawlers (Level 2)
- Pack AI. 3-5 individuals that coordinate.
- Fast, aggressive, check hiding spots immediately.
- Climb walls and ceilings — looking "forward" isn't enough.
- Tight subway tunnels mean encounters are close-range and intense.
- Noise in flooded sections is amplified.

#### The Mimic (Level 3)
- Appears as duplicate objects, loot items, or teammate clones.
- Environmental tells: duplicated objects cast wrong shadows or have no shadow.
- In multiplayer: appears as a player character standing at end of hallway, waving.
- Silent (real players talk in proximity voice — silence is the tell).
- Or repeats last voice line it heard, slightly distorted.
- Attacks when approached while disguised.

#### The Watchers (Level 4)
- SCP-173 inspired. Only moves when unobserved.
- Multiple instances. You can watch one. You can't watch three.
- In multiplayer: coordinate who watches which one.
- Solo: resource management problem — can't watch them all.
- Count escalates as objectives are completed (starts at 2, ends at 6+).
- Dynamic fog periodically cuts sightlines.

---

## Proximity Fear System

The player's senses degrade as the entity gets closer, mirroring the character's terror. All transitions are gradual lerps, never instant.

### Distance Tiers

| Tier | Name | Distance | Description |
|------|------|----------|-------------|
| 0 | SAFE | 80+ studs | Normal gameplay |
| 1 | UNEASE | 50-80 | Subtle subconscious cues |
| 2 | DREAD | 25-50 | Player notices something is wrong |
| 3 | PANIC | 10-25 | Full dread, game screams at you to run |
| 4 | PROXIMITY | 0-10 | Contact imminent, total sensory overload |

### Effects Per Tier

**Tier 0 — SAFE**
- Clean visuals, ambient background hum
- The calm exists to make everything else worse by contrast

**Tier 1 — UNEASE**
- Slight color desaturation (5-10%)
- Ambient audio pitch drops slightly
- Faint low-frequency drone (sub-bass, felt more than heard)
- Vignette darkens at screen edges ~5%
- Occasional distant ambient sounds (creaks, whispers)

**Tier 2 — DREAD**
- Color desaturation 30-40%
- Vignette closes in noticeably
- Slow camera sway (not shake — nauseating drift)
- Heartbeat audio fades in, slow, synced with subtle screen pulse
- Ambient drone louder with dissonant tones
- Flashlight starts flickering
- Character breath sounds become audible
- FOV narrows 2-3 degrees (subconscious claustrophobia)

**Tier 3 — PANIC**
- Screen shake: small, irregular, unpredictable tremors
- Heavy desaturation (60-70%), sickly color shift
- Heartbeat accelerates, louder, dominant in mix
- Breathing becomes ragged, panicked
- Flashlight flickers aggressively, dims 30-40%
- Film grain / noise overlay
- Chromatic aberration at screen edges
- FOV narrows 5-7 degrees total
- Dissonant string music, building but never resolving
- Subliminal micro-glitches: 1-2 frame flashes of static, a face, corrupted geometry (once per 15-20s)
- Shadow flickers at screen edge if entity is behind player

**Tier 4 — PROXIMITY**
- Screen shake intensifies, sharp and jarring
- Near-full desaturation, crushed contrast
- Tunnel vision (vignette nearly closed)
- All audio layers competing: heartbeat, breathing, drone, music
- Flashlight dies for 0.5-1s blackouts
- Camera occasionally snaps toward entity direction (involuntary look)
- Whispering layer: unintelligible, layered voices
- Camera input slightly dampened (perceived loss of control, not actual speed reduction)

### Subliminal Flashes (Tier 3-4)

Single-frame images (16-33ms). Player doesn't consciously see them. Their brain does.

Content options:
- Distorted face (entity close-up)
- Corrupted text ("BEHIND YOU", "RUN", "IT SEES YOU")
- Glimpse of a different room (where entity actually is)
- Player's own character from third-person (as if being watched)
- VHS static/corruption

Frequency: once per 15-20s in Tier 3, slightly more in Tier 4. Overuse kills the effect.

### Audio Layer Stack

| Layer | Content | Active From | Scales With |
|-------|---------|-------------|-------------|
| 1 | Sub-bass drone | Tier 1 | Proximity (volume) |
| 2 | Heartbeat | Tier 2 | Proximity (tempo + volume) |
| 3 | Character breathing | Tier 2 | Proximity (intensity) |
| 4 | Dissonant music | Tier 3 | Proximity (layers + volume) |
| 5 | Whispers | Tier 4 | Proximity (volume) |
| 6 | Entity sounds (diegetic) | Always | Actual distance (3D spatial) |

Layers 1-5 are non-diegetic (in the player's head). Layer 6 is diegetic (exists in the world). Player should never be sure which sounds are "real."

### Design Rules

- All transitions lerp smoothly. No hard cuts between tiers.
- Audio does 80% of the work. A player with eyes closed should feel the system.
- Effects degrade perception but never make the game uncontrollable.
- Post-escape cooldown: effects fade over 5-8 seconds (relief is slow).
- Repeated prolonged exposure at Tier 2-3 slightly reduces effect intensity to avoid fatigue, then spikes again on distance change.
- Multiplayer: each player has independent proximity calculation. One player in PANIC while teammate across map is SAFE. Panicking player's distorted breathing bleeds into proximity voice for teammates.

---

## Level Architecture

### Campaign Structure

```
Level 1 ──complete──→ Level 2 ──complete──→ Level 3 ──complete──→ Level 4 ──complete──→ Level 5
                                                                                          │
                                                                                   ┌──────┴──────┐
                                                                              Ending A      Ending B
                                                                             (The Seal      (The Seal
                                                                              holds)        breaks)
```

### Hub — The Safe Room

A physical space between runs, not a menu screen.

| Element | Function |
|---------|----------|
| Bulletin Board | Level select (pinned photos, maps, evidence) |
| Workbench | Loadout / perk selection |
| Evidence Wall | Lore journal (strings connecting clues across levels) |
| Locker | Cosmetics / unlocks |
| Radio | Multiplayer lobby / matchmaking |
| Door | Enter selected level |

The safe room degrades as you progress. Lights flicker. Walls crack. Something scratches behind the walls by Level 4. By Level 5, it's barely holding together.

### Level Summaries

#### Level 1: St. Maren's Hospital
- **Entity:** The Patient (slow, stalks by sound)
- **Theme:** Darkness. Flashlight is your lifeline.
- **Structure:** 3 floors (Ground, Upper, Basement) + Exterior
- **Objective:** Restore power via basement generator → Extract from rooftop
- **Key Mechanic:** Learning the basics — hiding, sound management, flashlight discipline
- **See:** Level 1 Detailed Design (below)

#### Level 2: Line 13 Subway System
- **Entity:** The Crawlers (fast pack AI, climbs walls/ceilings)
- **Theme:** Tight spaces. Stamina management is critical.
- **Structure:** 3 stations connected by tunnel network
- **Objective:** Reroute power at midpoint station → Reach terminus station
- **Key Areas:** Flooded sections (loud wading), ventilation shafts, collapsed sections, the Nest (optional, lore-critical, suicidal)

#### Level 3: Blackpoint Research Station
- **Entity:** The Mimic (disguises as objects/teammates)
- **Theme:** Paranoia. Trust nothing.
- **Structure:** Surface admin + underground labs + deep level + dock extraction
- **Objective:** Find director's codes + upload data from server room → Extract by boat
- **Key Areas:** Containment cells (one shattered from inside), audio lab (recordings attract/repel?), the Tank (what they kept it in, now empty)

#### Level 4: Ashwood Forest & Cabins
- **Entity:** The Watchers (only move when unobserved, multiple)
- **Theme:** Open space paranoia. Line-of-sight management.
- **Structure:** Open world zone — ranger station, forest, cabin cluster, ridge
- **Objective:** Find fuel + power radio tower → Extract by vehicle from ranger station
- **Key Areas:** The Ring (circle of trees they won't enter — why?), dynamic fog, watchtower overlook, cave system (optional)

#### Level 5: The Origin (Beneath St. Maren's)
- **Entity:** All of them. Evolved.
- **Theme:** Full convergence. Every mechanic combined.
- **Structure:** Upper catacombs → The Warren (semi-procedural) → The Sanctuary
- **Objective:** Reach The Seal → Choose to destroy or reinforce it → Timed escape to surface
- **Key Areas:** Mirror Room (Mimic), The Narrow (Crawlers, crawlspace), Pillar Hall (Watchers), burial chambers (Patient)
- **Two endings** based on Seal choice

---

## Level 1: St. Maren's Hospital — Detailed Design

### Narrative

The player arrives responding to a distress signal. The building has been abandoned for weeks. Power is out. The last staff reports mention a patient in the psychiatric ward who "stopped being a patient." Objective: restore power via basement generator, unlock rooftop access, extract via helicopter.

### Floor Plan

```
                    ┌─────────────────────────────┐
                    │         ROOFTOP              │
                    │     [Extraction Point]       │
                    │   Locked until generator on  │
                    └──────────────┬───────────────┘
                                   │
┌──────────────────────────────────┼──────────────────────────────────┐
│                           UPPER FLOOR                               │
│                                                                     │
│  ┌────────┐ ┌────────┐ ┌────────┐  ┌────────────────────────────┐  │
│  │Rm 201  │ │Rm 202  │ │Rm 203  │  │    PSYCHIATRIC WARD        │  │
│  │        │ │        │ │(locked)│  │    [Locked Wing]            │  │
│  └───┬────┘ └───┬────┘ └───┬────┘  │ ┌──────────┐ ┌───────────┐│  │
│      │          │          │       │ │Padded     │ │Nurse      ││  │
│  ┌───┴──────────┴──────────┴────┐  │ │Cells A/B │ │Station    ││  │
│  │     UPPER HALLWAY (L-shape)  ├──┤ └──────────┘ └───────────┘│  │
│  └──┬────────┬──────────┬───────┘  └────────────────────────────┘  │
│     │        │          │                                           │
│  ┌──┴─────┐┌─┴────────┐┌┴───────────┐                              │
│  │Rm 204- ││Operating ││Staff Break │                              │
│  │206     ││Theater   ││Room        │                              │
│  │(triple)││[Skylight]││            │                              │
│  └────────┘└──────────┘└────────────┘                              │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ Main Stairwell
┌──────────────────────────────┼──────────────────────────────────────┐
│                          GROUND FLOOR                               │
│                                                                     │
│  ┌──────────┐ ┌──────────────────┐ ┌──────────┐ ┌───────────────┐  │
│  │ SECURITY │ │   RECEPTION /    │ │ WAITING  │ │  EMERGENCY    │  │
│  │ OFFICE   │ │     LOBBY        │ │  ROOM    │ │    WARD       │  │
│  │ [CCTV]   │ │ [Main Entrance]  │ │          │ │  [8 bays]     │  │
│  └────┬─────┘ └───────┬──────────┘ └────┬─────┘ └──────┬───────┘  │
│       └───────────────┴─────────────────┴───────────────┘          │
│                    GROUND FLOOR CORRIDOR (T-shape)                  │
│       ┌───────────────┼─────────────────┼───────────────┐          │
│  ┌────┴─────┐  ┌──────┴──────┐   ┌──────┴──────┐                  │
│  │ PHARMACY │  │   CHAPEL    │   │  RESTROOMS  │                  │
│  │ [Loot]   │  │   [Lore]    │   │  [Hiding]   │                  │
│  └──────────┘  └─────────────┘   └─────────────┘                  │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ Stairwell + Service Elevator (dead)
┌──────────────────────────────┼──────────────────────────────────────┐
│                           BASEMENT                                  │
│                                                                     │
│  ┌──────────┐ ┌────────────────┐ ┌──────────────────────────────┐  │
│  │  MORGUE  │ │  GENERATOR RM  │ │         STORAGE              │  │
│  │[6 drawer]│ │  [OBJECTIVE]   │ │       [Shelf maze]           │  │
│  └────┬─────┘ └───────┬────────┘ └──────────────┬───────────────┘  │
│       └───────────────┴─────────────────────────┘                  │
│                    BASEMENT CORRIDOR (narrow, pipes, dripping)      │
│       ┌───────────────┼────────────────────────────┐               │
│  ┌────┴──────┐                              ┌──────┴────────────┐  │
│  │BOILER ROOM│                              │LAUNDRY / UTILITY  │  │
│  │ [Steam]   │                              └──────┬────────────┘  │
│  └───────────┘                              ┌──────┴────────────┐  │
│                                             │SUB-BASEMENT DOOR  │  │
│                                             │[SEALED - Level 5] │  │
│                                             └───────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

EXTERIOR
┌─────────────────────────────────────────────────────────────────────┐
│  ┌──────────────┐              ┌─────────────┐                      │
│  │ AMBULANCE BAY│──[entrance]──│  COURTYARD  │                      │
│  │ [Spawn Point]│              │ [Visible     │                      │
│  └──────────────┘              │  from above] │                      │
│                                └─────────────┘                      │
│                    ~~~ FOG WALL — NO EXIT ~~~                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Room Details

#### Exterior

**Ambulance Bay (Spawn)**
- Player fades in next to an abandoned ambulance, engine ticking
- Radio crackle plays garbled distress signal, dies
- Fog wall on all sides — approaching triggers disoriented turn-around
- One ambulance is lootable
- Hospital entrance doors close behind you and don't reopen
- Loot: `1x Battery [guaranteed]`, `1x Bandage [guaranteed]`

**Courtyard**
- Visible from Upper Floor windows only — never physically entered
- Sometimes The Patient stands motionless in the courtyard when you look down
- Look away and back: it's gone
- Pure psychological tool

#### Ground Floor

**Reception / Lobby**
- First interior room. Large, open, trashed. Overturned chairs, scattered paperwork.
- Computer at reception flickers briefly — shows patient transfer log, dies
- Two exits: corridor left (Security), corridor right (Emergency Ward)
- Phone rings once on entry. Answering: silence, then a click. Never rings again.
- Loot: `1x Battery [70%]` in desk drawer

**Waiting Room**
- Chairs facing a static TV. TV turns on (white noise) when entered, then off.
- Magazines dated 3 months in the future.
- Child's drawing depicting the hospital with a tall dark figure.
- Vending machine: interactable, loud clunk, drops nothing. Sound carries.
- Loot: None. Exists to unsettle.

**Security Office**
- 6 CCTV monitors. 4 dead. 2 live:
  - Monitor A: Basement corridor. Occasionally shows The Patient (even before activation).
  - Monitor B: Cycles rooms. Every ~30s shows player's current location from impossible angle.
- Guaranteed flashlight spawn (if first visit).
- Incident report about "Patient 31" and repeated violent episodes.
- Locking door — usable as hiding room, but entity learns this fast.
- Loot: `1x Flashlight [guaranteed]`, `1x Battery [50%]`, `Lore: Incident Report #47`

**Emergency Ward**
- 8 curtained bays (2 rows of 4). Curtains openable/closable (slight sound).
- 6 bays empty with disheveled beds.
- 1 bay has a mannequin on gurney (jump scare bait — it's just a mannequin).
- 1 bay has medical supplies.
- Entity's first patrol route passes through here.
- Curtains sway from air movement. Or something passing behind them.
- Loot: `2x Bandage [guaranteed]`, `1x Battery [40%]`

**Pharmacy**
- Half-gate entry (vault over — brief animation, committed action).
- Glass crunches underfoot — louder footstep sounds, increased detection risk.
- Back room locked cabinet requires Pharmacy Key (found on Upper Floor).
- Cabinet contains medkit (full heal + stops bleeding).
- Loot: `1x Bandage [guaranteed]`, `1x Battery [60%]`, `1x Medkit [in locked cabinet]`

**Chapel**
- Pews, altar, stained glass (one panel shattered).
- Candles are lit. They shouldn't be. They weren't lit when you walked past earlier.
- Bible opened to a hand-edited page.
- Under a pew: note from staff member who hid here, describing footsteps that stop outside the door, leave, then come back.
- Loot: `Lore: Chapel Note`, `1x Flare [30%]`

**Restrooms**
- Stalls usable as hiding spots (close door, crouch).
- Mirror: first visit normal. Later visit (random trigger): reflection has a half-second delay.
- Overflowing toilet. Ambient dripping masks footsteps (double-edged).
- Loot: `1x Battery [30%]`

#### Upper Floor

**Patient Rooms 201-203 (Individual)**
- Standard hospital rooms with bed, IV stand, side table, bathroom, closet.
- Room 201: Untouched. Get-well card addressed to "Patient 31."
- Room 202: Trashed. Bed flipped. Claw marks on walls.
- Room 203: Locked from inside. Force open (loud) or use Master Key from Nurse Station. Contains a body and lore document.
- Each room has closet + under-bed hiding.
- Loot: `201: 1x Battery [50%]` | `202: Lore: Patient 31 Chart` | `203: 1x Medkit [guaranteed], Lore: Final Note`

**Patient Rooms 204-206 (Connected Triple)**
- Adjoining doors — move through all three without entering hallway.
- Flanking route to avoid entity in Upper Hallway.
- Room 204: Empty, door to 205 open.
- Room 205: Pharmacy Key on nightstand. No window, dark.
- Room 206: Window overlooks courtyard. Hallway door jammed (exit through 205/204 only).
- Loot: `205: Pharmacy Key [guaranteed]` | `206: 1x Flare [50%]`

**Operating Theater**
- Central Upper Floor room. Skylight provides only natural light (moonlight, sharp shadows).
- Operating table in center, clean, instruments laid out as if prepared. Recently.
- Gallery seating above (non-accessible) — sometimes a silhouette sits there.
- Two entrances — good for escape, bad because entity can enter from either.
- Loot: `1x Bandage [guaranteed]`

**Staff Break Room**
- Kitchenette, table, lockers, whiteboard.
- Whiteboard shift schedule — last day filled 3 weeks ago, one name circled in red.
- 4 lockers: 3 openable (loot), 1 jammed with periodic thumping inside. Never opens.
- Microwave turns on by itself after 30s in room. Loud beep. Attracts entity.
- Coffee still warm on table.
- Loot: `1x Battery [guaranteed]`, `1x Bandage [40%]`, `Lore: Staff Email Printout`

**Psychiatric Ward (Locked Wing)**
- Requires Psych Ward Keycard (hidden in Security Office desk drawer).
- Optional high-risk zone. Best loot. Entity spawns closer to this area.
- Short corridor, 4 doors, fluorescent light strobes.
- Padded Cell A: Empty. 300+ scratch marks counting days.
- Padded Cell B: Patient 31's cell. Walls covered in same phrase repeated thousands of times. Hole in padding reveals tape recorder. Playing it: Patient 31's voice, then something inhuman.
- Nurse Station: Behind reinforced glass. Master Key for all patient rooms. Monitor shows Patient 31 vitals — still reading, still alive.
- Observation Room: One-way glass into Cell B. After playing tape, something looks back through the glass.
- Loot: `Nurse Station: Master Key, 2x Battery, 1x Medkit` | `Cell B: Lore: Tape Recording`

**Rooftop Access**
- Electronically locked — requires generator power from basement.
- 30-second boot sequence after generator starts (lights flicker on floor by floor).
- Rooftop: helipad, fence, open sky.
- Interact with radio beacon. 60-second wait. Entity fully active. Proximity fear maxes out.
- Helicopter arrives. Player boards. As it lifts off, something is standing on the helipad where you just were.

#### Basement

**Morgue**
- 6 body drawers. 4 empty (loud metallic opening). 1 contains body with toe tag "Patient 30" + lore. 1 stuck — pulling makes noise, supplies wedged inside.
- Floor drain with dark liquid. Visible breath effect (cold).
- Entity frequently patrols here.
- Loot: `1x Bandage [guaranteed]`, `1x Battery [guaranteed]`, `Lore: Patient 30 Autopsy Report`

**Generator Room (Primary Objective)**
- Multi-step activation:
  1. Find fuel canister (Boiler Room or Storage, randomized)
  2. Fill generator (5s interaction, animation locks player)
  3. Prime generator — pull cord 3 times (each pull loud, chance to fail, average 4-5 pulls)
  4. Generator starts — EXTREMELY LOUD, entity enters HUNT toward basement
  5. Survive 30 seconds while generator powers up
- Peak tension moment of the level.

**Boiler Room**
- Steam pipes with periodic vent blasts (visual obstruction, minor damage).
- Steam hissing provides ambient noise cover — harder for entity to detect footsteps.
- But visibility is terrible. Might walk into entity.
- Catwalk — entity can be above or below.
- Loot: `Fuel Canister [50%]`, `1x Bandage [40%]`

**Storage**
- Maze of tall industrial shelving. Blocks line of sight completely.
- Multiple paths — easy to circle entity. Easy to get cornered at dead ends.
- Some shelves can be toppled (loud, blocks path temporarily).
- Deepest row has shipping manifests to "Blackpoint Coastal Facility."
- Loot: `Fuel Canister [50%]`, `1x Battery [guaranteed]`, `1x Flare [40%]`, `Lore: Shipping Manifests`

**Laundry / Utility**
- Washing machines, dryers, folding tables, laundry carts.
- Laundry carts: unique hiding spot (climb in, pull sheets over).
- A dryer turns on periodically. Something thumping inside. Don't open it.
- Connects to Sub-Basement door corridor.
- Loot: `1x Bandage [30%]`

**Sub-Basement Door**
- Heavy steel, industrial locks, "RESTRICTED" in faded red.
- Sealed. No interaction prompt in Level 1.
- Standing near it for 5+ seconds: a single knock from the other side.
- After completing Level 4: locks rusted, door slightly ajar.
- Entrance to Level 5.

### Scripted Events (First Playthrough Only)

| Trigger | Event |
|---------|-------|
| Enter Reception | Phone rings once. Answering: 2s static then flatline tone. |
| First Upper Floor visit | Door at end of hallway slams shut. Nothing there. |
| Enter Room 202 | TV briefly shows security footage of player entering lobby from impossible ceiling angle. |
| First basement visit | Lights flicker. Gurney rolls across corridor on its own. Stops at morgue door. |
| Pick up Patient 31 chart | All Upper Floor doors slam simultaneously. 3s silence. Normal. |
| Play tape in Psych Ward | Every light cuts out for 5s. When flashlight returns, something has moved. |
| Generator starts | Emergency PA crackles: voice reads patient names. It reads yours. |

### Entity Behavior (Level 1 Specific)

- Spawn: does not exist for first 90 seconds.
- First spawn: randomized between Upper Floor and Basement.
- 3 patrol route variants (randomized per run):
  - Route A (Upper Focus): Upper Hallway → Rooms → Operating Theater → Break Room → Stairwell → Ground Corridor → Emergency Ward → Stairwell → repeat
  - Route B (Basement Focus): Basement Corridor → Morgue → Boiler Room → Storage → Stairwell → Ground Corridor → Reception → Stairwell → repeat
  - Route C (Full Sweep): Basement → Ground → Upper → Basement (2-3 rooms per floor, different each cycle)
- Full patrol loop: ~3 minutes. Pauses in rooms 8-15s.

### Loot Table

| Item | Total Spawns | Guaranteed | Purpose |
|------|-------------|------------|---------|
| Flashlight | 1 | Yes (Security) | Core tool |
| Battery | ~8-10 | 3 guaranteed | Flashlight fuel |
| Bandage | ~6-8 | 4 guaranteed | Heal 1 pip |
| Medkit | 2 | 1 each (Rm 203, Nurse Station) | Full heal + stop bleed |
| Flare | 2-3 | 0 | Distraction (8s) |
| Fuel Canister | 1 | Yes (Boiler OR Storage) | Objective item |
| Pharmacy Key | 1 | Yes (Room 205) | Opens pharmacy cabinet |
| Psych Ward Keycard | 1 | Yes (Security Office) | Opens psychiatric wing |
| Master Key | 1 | Yes (Nurse Station) | Opens all patient rooms |
| Lore Documents | 7 | All fixed locations | Story + Evidence Wall |

### Critical Path

```
SPAWN (Ambulance Bay)
    ↓
ENTER HOSPITAL → Explore Ground Floor (safe, no entity yet)
    ↓             └── Find flashlight (Security Office)
GO UPSTAIRS (entity activates ~90s in)
    ↓             └── Find Pharmacy Key (Room 205)
    ↓             └── [Optional] Clear Psychiatric Ward
GO TO BASEMENT
    ↓             └── Find Fuel Canister (Boiler Room or Storage)
ACTIVATE GENERATOR → Fill → Prime → Start → SURVIVE 30s
    ↓
RETURN TO UPPER FLOOR → Rooftop door now unlocked
    ↓
ROOFTOP → Activate beacon → SURVIVE 60s
    ↓
EXTRACTION — LEVEL COMPLETE
```

### Timing

| Metric | Duration |
|--------|----------|
| Minimum completion (experienced) | ~8 minutes |
| Average first completion | ~18-25 minutes (with deaths) |
| Full exploration (all lore, psych ward) | ~30 minutes |

### Multiplayer Scaling

| Element | Solo | 2 Players | 3-4 Players |
|---------|------|-----------|-------------|
| Entity activation delay | 90s | 60s | 45s |
| Patrol speed | Base | +10% | +20% |
| Generator pull attempts | 4-5 | 5-6 | 6-8 |
| Extraction beacon wait | 60s | 75s | 90s |
| Loot quantity | Base | +30% | +50% |
| Hiding spot check rate | Low | Medium | High |
| Separation events | None | 1 (stairwell lock) | 2 (stairwell + corridor gate) |

---

## Progression System

### Permanent Unlocks (Account-Level)

- **Levels:** Complete one to unlock the next
- **Perks:** Lateral choices (not power creep):
  - Quieter footsteps vs. faster healing vs. longer sprint vs. larger inventory
  - One perk slot to start, second slot unlocked at Level 3 completion
- **Cosmetics:** Character outfits, flashlight skins, trail effects
- **Lore Journal:** Found documents persist on Evidence Wall in hub, building story across runs
- **Difficulty Modifiers:** Toggleable for bonus rewards (no flashlight, faster entity, fog, permadeath)
- **Nightmare Mode:** Replay any level with any entity (unlock per level completion)

### Per-Run Progression

- Better tools found deeper in levels (UV light reveals hidden paths, radio picks up entity location briefly)
- Risk/reward exploration — side rooms have better loot but more danger
- Optional objectives for bonus XP/currency

---

## Multiplayer Design

### Solo vs Co-op Philosophy

**Solo:** Tighter, more scripted scares. More narrative. Harder by design. The silence is the feature. The "canon" experience.

**Co-op (2-4 players):** Same maps, objectives scale (more tasks, spread across map). Monster AI more aggressive, scales with player count. Players can be separated by events (doors locking, floors collapsing). Downed state instead of instant death — crawl toward teammates. Proximity voice only — if separated, you're truly alone.

**Key insight:** Multiplayer horror is scariest when it threatens to become solo at any moment.

### Separation Events

Scripted moments where the game forcibly splits the party:
- Stairwell doors lock temporarily
- Corridor gates slam shut
- Floor collapses
- Duration: 30-60 seconds of forced isolation
- Entity may be on either side

### Downed State (Co-op Only)

- Instead of instant death, player enters crawl state
- Can slowly move and call out (proximity voice)
- Teammate must reach them within 30 seconds to revive
- If no revive: death, spectate until round ends or teammates extract
- Revived player comes back at 1 health pip

---

## Monetization

**Core principle:** No pay-to-win. All purchases are cosmetic, convenience, or content — never gameplay advantages. See `docs/the-origin/Monetization.md` for the full monetization design.

### Revenue Streams

| Stream | Model | Examples |
|--------|-------|---------|
| **All Access Pass** | Game Pass (one-time) | Unlocks all 5 levels immediately (removes sequential gate) |
| **Seasonal Pass** | Battle Pass (recurring, 30-day) | Free + paid cosmetic tracks with horror-themed challenges |
| **Cosmetic Shop** | Developer Products (repeatable) | Death animations, flashlight beams, trail effects, encounter cards |
| **Director's Cut** | Game Pass (one-time) | Extended lore, extra rooms, voice-acted audio logs, hidden 6th ending |
| **Nightmare Mode** | Game Pass (one-time) | Remix any entity into any level after completion |
| **Monster Pass** | Game Pass (one-time, post-launch) | Play as the entity in asymmetric multiplayer mode |
| **Premium Benefits** | Roblox Premium perks | +20% XP, exclusive cosmetics per level, early seasonal access |
| **Seasonal Events** | Limited-time content | Halloween, Friday the 13th, anniversary levels |

### Pricing Anchors

- Level 1 is free — the hook. Conversion prompt after first extraction.
- All Access Pass at 799 Robux — makes 199-399 Robux seasonal passes feel accessible.
- Every paid unlock has a free earning path (slower). No hard paywalls on core content.

### What We Never Sell

- Extra health, inventory slots, or entity slowdowns
- Lore access (sell the *presentation*, not the information)
- Randomized boxes with gameplay items (cosmetic-only if randomized, odds disclosed per Roblox policy)

---

## Technical Notes

- Server authoritative — all game state validated server-side
- Entity AI runs on server — never trust client for entity position/state
- Line-of-sight via Workspace:Raycast
- Sound propagation simplified via PathfindingService distance (not acoustic simulation)
- Entity pathfinding via PathfindingService / NavigationMesh
- Adaptive behavior stored in per-run dictionary: `{hidingSpotId: timesUsed, routeHash: timesRun}`
- Proximity fear effects are client-side post-processing (ColorCorrection, Blur, SunRays manipulation)
- Entity animations deliberately break blending for unsettling movement
- Future lighting mode for atmosphere
- Rojo + Wally toolchain, .luau with --!strict
