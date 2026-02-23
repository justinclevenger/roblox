# Level 4: Ashwood Forest & Cabins — Detailed Design

## Table of Contents

1. [Narrative Setup](#narrative-setup)
2. [Design Philosophy](#design-philosophy)
3. [Map Layout](#map-layout)
4. [Area-by-Area Details](#area-by-area-details)
5. [The Watchers — Entity Design](#the-watchers--entity-design)
6. [Dynamic Fog System](#dynamic-fog-system)
7. [The Ring — Safe Zone Design](#the-ring--safe-zone-design)
8. [Scripted Events](#scripted-events)
9. [Loot Table Summary](#loot-table-summary)
10. [Critical Path](#critical-path)
11. [Timing](#timing)
12. [Multiplayer Scaling](#multiplayer-scaling)
13. [The Cave — Optional Area](#the-cave--optional-area)
14. [Proximity Fear Modifications](#proximity-fear-modifications)
15. [Audio Design Notes](#audio-design-notes)
16. [Technical Notes](#technical-notes)

---

## Narrative Setup

### Context

The player has just escaped Blackpoint Research Station (Level 3) by boat. The extraction was compromised — the boat runs aground on a shoreline several miles from the station. The radio picked up a fragmented emergency broadcast during transit: a ranger station in Ashwood Forest has a working vehicle. It is the only way out.

The player arrives at the forest edge at dusk. The sky is bruised orange and grey. Through the tree line, the ranger station watchtower is visible, its light dark. The forest is silent — no birdsong, no insects, no wind. The silence is wrong. Forests are never silent.

### The Search Party

Three weeks before the player arrives, a search-and-rescue team was dispatched to Ashwood Forest after hikers went missing. The team established a base camp, explored the cabin cluster, and attempted to radio for extraction from the ridge tower. They never came back. Their campsite remains. Their equipment remains. They do not.

One member — Dr. Elena Vasik, a researcher reassigned from Blackpoint — had been studying reports of "stationary figures" observed by satellite in the forest canopy. Her notes in Cabin A document her growing understanding of what the Watchers are: not creatures, but expressions of something deeper. The same something sealed beneath St. Maren's. Her final entries are written in the dark, by feel, because she understood that closing her eyes — even to blink — was no longer safe.

### Connection to the Campaign

Ashwood Forest sits between Blackpoint Research Station and St. Maren's Hospital. It is the surface expression of whatever is sealed below. The trees are older than they should be. The carvings in The Ring predate any known settlement. The cave on the ridge descends toward the same geological layer as St. Maren's sub-basement. Everything connects underground.

From the cliff edge on the ridge, the player can see Blackpoint Station in the valley below. It is burning. Whatever happened after they left, the containment failed completely.

---

## Design Philosophy

### The Tonal Shift

Levels 1-3 are enclosed spaces: corridors, rooms, tunnels, labs. The player learned to manage threats by reading sightlines, closing doors, tucking into hiding spots. The geometry was their ally — walls limited where threats could come from.

Level 4 destroys that.

The forest is open. Threats come from every direction. There are no corridors to bottleneck movement, no doors to close, no lockers to hide in. The player's survival tools from the first three levels are almost entirely irrelevant. Instead, the player has one tool: sight. And one enemy: anything that takes sight away.

This is the design intent: **suffocating in open air**. The forest should feel more claustrophobic than any corridor because the player cannot stop watching. Every direction they look is a direction they are not looking somewhere else. The Watchers exploit this with mathematical certainty — you cannot observe 360 degrees. In a corridor, you watch forward. In the forest, you watch everywhere, which means you watch nowhere.

### Core Tension Loop

```
See a Watcher → freeze, watch it → realize you cannot see behind you
    → hear/sense another → turn to check → the first one moved
        → fog rolls in → you can see nothing → they can move freely
            → fog lifts → they are closer. All of them.
```

### Player Emotional Arc

| Phase | Emotion | Gameplay |
|-------|---------|----------|
| Arrival (Ranger Station) | Relief — open air after three enclosed levels | Safe exploration, orientation |
| First Forest Traverse | Unease — too quiet, shapes between trees | First Watcher sighting, learning the rules |
| Cabin Cluster | Growing dread — understanding the threat | Fuel acquisition, lore discovery, Watcher count increases |
| Ridge Ascent | Panic — Watchers multiplying, fog intensifying | Radio tower objective under pressure |
| Return to Ranger Station | Controlled terror — must traverse full forest with 6+ Watchers | Final gauntlet |
| Extraction Drive | Cathartic dread — they line the road, headlights are your only defense | Scripted finale |

---

## Map Layout

### ASCII Top-Down Map

```
NORTH
  ↑

                              ┌─────────────────────┐
                              │     THE RIDGE        │
                              │                      │
                              │  [Radio Tower]       │
                              │       ↑              │
                              │  [Cave Entrance]     │
                              │       ↑              │
                              │  [Cliff Edge]        │
                              └─────────┬────────────┘
                                        │
                         ~~~~ Ridge Trail (steep, narrow) ~~~~
                                        │
           ┌────────────────────────────┼────────────────────────────────┐
           │                                                             │
           │                     ASHWOOD FOREST                          │
           │                                                             │
           │         [Dense Woods]            [Dense Woods]              │
           │              ·  ·  ·    ·  ·  ·    ·  ·  ·                 │
           │           ·        ·  ·        ·  ·        ·               │
           │    ┌──────────┐  ·    ┌──────────┐   ·  ┌────────┐        │
           │    │ Cabin A  │· · · ·│ Cabin B  │· · · │Cabin C │        │
           │    │(Research)│  · ·  │(Hunter's)│  · · │(Ruined)│        │
           │    │  ┌─────┐ │       └──────────┘      └────────┘        │
           │    │  │Root  │ │                                            │
           │    │  │Cellar│ │            [Clearing]                      │
           │    │  └──────┘ │          ·    ·    ·                       │
           │    └──────────┘        ·              ·                     │
           │           ·         ·                    ·                  │
           │  [Dense      ·   ·       [The Ring]        ·               │
           │   Woods]  · · ·        ·  o  o  o  ·        ·             │
           │          ·           · o          o ·          ·            │
           │         ·           · o    SAFE    o ·          ·          │
           │          ·           · o          o ·          ·            │
           │           ·  · · ·    ·  o  o  o  ·        ·              │
           │              ·   ·       · · · · ·       ·                 │
           │               ·    ·                   ·                   │
           │     [Abandoned  ·    ·    · · · · ·                        │
           │      Campsite]    ·    ·                                    │
           │         ·           · · ·                                   │
           │          ·  ·  ·  ·       ·                                │
           │    [Creek ~~~~~~~~~~~ ·     ·                              │
           │     Bed]  ~~~~~~~~~~~~  ·     ·                            │
           │           ~~~~~~~~~~~~~   ·     ·                          │
           │                             ·     ·                        │
           │         === Main Trail ===    ·     ·                      │
           │        ===               ===    ·                          │
           │       ===                 ===                              │
           └────────┼───────────────────┼───────────────────────────────┘
                    │                   │
         === Trail ===        === Trail ===
                    │                   │
           ┌────────┼───────────────────┼───────────────────────────┐
           │        │   RANGER STATION  │                           │
           │        │                   │                           │
           │   ┌─────────┐  ┌──────────────┐  ┌────────────────┐   │
           │   │  Main    │  │   Garage      │  │  Watchtower    │   │
           │   │  Office  │  │ [Extraction   │  │  [Overlook]    │   │
           │   │  [Radio] │  │  Vehicle]     │  │                │   │
           │   └─────────┘  └──────────────┘  └────────────────┘   │
           │                                                        │
           │   ┌────────────┐         ┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐   │
           │   │  Supply    │         │     Parking Lot         │   │
           │   │  Shed      │         │  [SPAWN / Entry Point]  │   │
           │   └────────────┘         └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘   │
           │                                                        │
           └────────────────────────────────────────────────────────┘
                                   │
                            ══ Forest Road ══
                            ══ (Exit Route) ══
                                   ↓
                              SOUTH (Exit)
```

### Spatial Relationships

| From | To | Distance (studs) | Travel Time (walk) | Notes |
|------|----|-------------------|---------------------|-------|
| Ranger Station | Forest Edge | 60 | ~8s | Two trail entrances into forest |
| Forest Edge | Cabin Cluster | 200-250 | ~30s on trail | Off-trail: slower, denser |
| Forest Edge | The Ring | 180 | ~25s | Off-trail only, no path leads here |
| Forest Edge | Clearing | 160 | ~22s | Visible from trail |
| Forest Edge | Creek Bed | 140 | ~20s | Low ground, must descend |
| Cabin Cluster | Ridge Trail | 120 | ~16s | Trail narrows, incline begins |
| Ridge Trail Base | Cliff Edge | 100 | ~14s | Steep, movement speed -10% |
| Cliff Edge | Radio Tower | 80 | ~11s | Final stretch |
| Cabin Cluster | The Ring | 90 | ~12s | Through dense woods |
| Cabin Cluster | Abandoned Campsite | 110 | ~15s | Trail connects |
| Ranger Station | Radio Tower (full) | ~500 | ~70s on trail | Full critical path traverse |

### Navigation Notes

- **Trail System:** Packed-dirt paths connect Ranger Station to Cabin Cluster to Ridge. Walking speed is normal. Visibility is moderate (20-30 studs through trees). Trails feel safe but are where Watchers position themselves.
- **Off-Trail (Dense Woods):** Movement speed reduced by 20%. Undergrowth crunch adds ambient noise (sound radius +5 studs). Visibility drops to 10-15 studs. Harder for Watchers to move unobserved (more visual obstructions to track them behind), but harder for the player to spot them.
- **Creek Bed:** Movement speed reduced by 15% (wading). Water sound masks footsteps (sound radius halved). Low ground means limited visibility upward — Watchers on the bank above are hard to track.
- **Ridge Trail:** Narrow, inclined. Movement speed -10%. No off-trail option (cliff on one side, steep drop on other). Bottleneck — Watchers ahead and behind create an impossible observation problem.

---

## Area-by-Area Details

### Ranger Station (Entry Zone)

The Ranger Station is a small compound at the southern edge of Ashwood Forest. It sits in a cleared area with gravel parking, a few outbuildings, and a watchtower. The compound is ringed by a low wooden fence — decorative, not defensive. The forest begins immediately beyond.

The station has not been abandoned long. Lights are on in the main office (generator-powered, fuel low). Coffee on the desk is cold but not molded. The vehicle in the garage has a full tank — no, wait. The fuel gauge reads empty. Someone drained it.

#### Main Office

**Description:** Single-story wood-panel building. Reception desk, filing cabinets, wall-mounted map of Ashwood Forest under glass. Two desks with computers (dead). Corkboard with missing-person flyers — the search party members. A radio unit on the back desk, wired to the watchtower antenna and the ridge radio tower.

**Atmosphere:** Warm interior light from a desk lamp running on the last of the generator fuel. The lamp flickers. Outside the windows: darkness and tree shapes. The normalcy of the office makes the wrongness of the forest worse.

**Gameplay Function:**
- Orientation point. The wall map is interactable — examining it reveals the forest layout, marking key landmarks on the player's HUD map.
- The radio is the emotional hook: it was working when the search party arrived. It is dead now. The antenna cable has been severed — cleanly, not torn. The radio tower on the ridge has its own transmitter. That is the objective.
- Safe zone for first 60 seconds of gameplay (no Watchers spawn in ranger station compound initially).

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Desk drawer |
| Battery | 50% | Filing cabinet |
| Bandage | 100% | First aid box on wall |
| Flare | 40% | Under desk |
| Lore: Ranger Dispatch Log | 100% | On desk |

**Lore: Ranger Dispatch Log**
> Day 1: Search team arrived 0600. Four members, one civilian advisor (Dr. Vasik, Blackpoint). Assigned Cabin A as base. Radio check nominal.
> Day 2: Team reports "unusual stillness" in forest. No wildlife. Vasik requests satellite imagery of canopy.
> Day 3: Satellite images show anomalies. Vasik says they're "stationary figures." Ranger Torres says they're tree stumps.
> Day 4: Torres didn't come back from patrol. Found his pack on the trail. His compass was spinning.
> Day 5: Radio contact lost with ridge tower. Team dispatched to investigate. No return.
> Day 6: [Entry is a single long scratch across the page]

---

#### Garage

**Description:** Attached structure with roll-up door (jammed open). A forest service pickup truck inside — green, mud-spattered, keys in ignition. The fuel gauge reads empty. Two empty fuel canisters on the workbench. A third canister is missing — its outline visible in the dust. Tire jack, tool rack, oil stains.

**Atmosphere:** Mechanical, practical. Smells like grease and pine. The truck is the most normal object in the game — it represents escape, civilization, the promise that this ends. The empty gauge is a gut punch.

**Gameplay Function:**
- Extraction vehicle. The player must find a fuel canister (Cabin B) and return here to fuel the truck.
- Fueling interaction: 8-second hold. Player is locked in animation, pouring fuel. Vulnerable.
- After fueling + powering radio tower, the extraction sequence begins here.
- The garage provides overhead cover — Watchers cannot be above you here. But the open roll-up door means you must watch the entrance.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 60% | Workbench drawer |
| Bandage | 40% | First aid kit on wall |
| Lore: Vehicle Maintenance Log | 100% | Clipboard on dashboard |

**Lore: Vehicle Maintenance Log**
> Last service: [date 3 weeks ago]. Fuel drained for generator. NOTE: replacement fuel in Hunter's cabin (Cabin B). Torres has the key. Do NOT go after dark.

This note establishes the critical path: fuel is in Cabin B.

---

#### Watchtower

**Description:** Wooden observation tower, 40 studs tall. Ladder access (climbing animation: 4 seconds, committed action — cannot cancel). Square observation platform with railing, mounted binoculars (interactable), emergency spotlight (dead — no power). 360-degree view of the forest canopy, the cabin cluster, the ridge, and the road south.

**Atmosphere:** Wind up here — the only place you hear wind in the level. The canopy stretches in every direction, black-green under the overcast sky. Moonlight occasionally breaks through clouds, silvering the treetops. Through the binoculars, you can see details at distance: the cabin roofs, the radio tower's blinking red light (dead), the cliff edge.

And among the trees, standing motionless: pale shapes. The Watchers. You can count them from here. **You should not.**

**Gameplay Function:**
- Reconnaissance. The binoculars let the player survey the forest and tag Watcher positions (visible as faint outlines through the binoculars for 30 seconds after spotting). This is a double-edged tool: while looking through binoculars, the player's actual viewport is the binocular view — they cannot see anything at the base of the tower or behind them.
- The spotlight can be powered later (after radio tower objective) — it creates a directed beam that freezes Watchers in a large cone but draws all others toward the station.
- While on the tower platform, the player is considered to have line of sight on any Watcher within the binocular's view cone only. Watchers behind the tower, at its base, or obscured by canopy can move freely. Climbing the ladder leaves the player unable to observe anything — 4 seconds of blindness.
- **The Counting Rule:** If the player uses the binoculars and looks at more than 3 Watchers within 10 seconds, a scripted event triggers (see Scripted Events). This is the "counting them is a mistake" mechanic.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Emergency kit on platform |
| Flare | 60% | Flare box on platform |
| Lore: Watchtower Observation Notes | 100% | Notebook on railing |

**Lore: Watchtower Observation Notes**
> Written by Ranger Torres across several days. Early entries are professional: weather observations, trail conditions, wildlife absence. Later entries become erratic:
> "Counted 7 today. Yesterday it was 5. They don't come from anywhere. They just ARE. I've been watching the same one for two hours. It hasn't moved. But it's closer. I never saw it move. I never stopped watching. But it's closer."
> Final entry: "They know when you're counting. Stop counting. STOP COUNTING."

---

#### Supply Shed

**Description:** Small wooden outbuilding, padlocked (lock is rusted, breaks with interaction). Single room, shelving on three walls, a workbench. Dim interior — one small window, grime-covered. Flashlight necessary.

When the player opens the door and sweeps the flashlight across the interior: a Watcher. Standing in the back corner. Motionless. Facing the player. It has been here before the player arrived. It has been watching the door.

**Atmosphere:** The first direct encounter. Everything about this moment must communicate the rules before the player consciously understands them: the Watcher is frozen because the player is looking at it. The player must loot the shed. The Watcher is between the player and the supplies. The player must enter the room with it. They must take items off shelves while keeping their camera trained on the Watcher. If they look at the shelf to grab an item — even for a moment — the Watcher can move.

**Gameplay Function:**
- Tutorial encounter. The Watcher in the shed is scripted to be less aggressive than normal Watchers for the first 30 seconds — it will only move 2-3 studs per "unobserved window" rather than the normal distance. This gives the player time to understand the mechanic.
- The shed is small enough that the player can keep the Watcher in peripheral vision (within camera frustum) while looting. This teaches the core skill.
- If the player backs out of the shed without looking away, the Watcher does not follow (it is "assigned" to this location for the tutorial). If the player looks away inside the shed, the Watcher closes to grab range and the kill animation plays.
- After the player leaves the shed and moves 30+ studs away, the Watcher despawns from the shed and enters the normal Watcher pool.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Shelf A |
| Battery | 60% | Shelf B |
| Bandage | 100% | First aid tin on shelf |
| Bandage | 50% | Workbench |
| Flare | 100% | Flare box on shelf (guaranteed, tutorial mercy) |

---

### Forest (Open World Zone)

The forest is the connective tissue of the level — approximately 600x600 studs of navigable terrain between the Ranger Station (south), Cabin Cluster (center-north), The Ring (center-west), and the Ridge (north). It is not a single "room" but a continuous space with varying density, elevation, and visibility.

The forest floor is uneven: roots, rocks, fallen branches. Ambient audio is conspicuously absent — no crickets, no owls, no rustling. The silence is suffocating. The only sounds are the player's footsteps, their breathing, and occasionally, from somewhere in the trees, a sound like stone grinding against stone. That is a Watcher moving.

#### Trail System

**Description:** Three main trails connect the landmarks:
- **South Trail:** Ranger Station to Cabin Cluster (via Abandoned Campsite). Widest, most maintained. Gravel surface. Lantern posts (unlit) every 40 studs.
- **North Trail:** Cabin Cluster to Ridge Trail base. Narrower, dirt surface. Incline begins.
- **West Trail:** Branches off South Trail toward the Creek Bed. Least maintained, partially overgrown.

**Atmosphere:** The trails feel deceptively safe — defined paths, clear sightlines of 25-30 studs. But the Watchers favor the trail edges. They stand just beyond the sightline, between trees, watching the path. The player will walk past them without noticing. Then, checking behind: they are closer. On the trail. Facing the player. When did they get on the trail?

**Gameplay Function:**
- Fast travel corridors. Normal movement speed. The trade-off: trails are where Watchers position themselves most densely (60% of idle Watcher positions are within 15 studs of a trail).
- Trail intersections are decision points. The player can see down two paths but not behind them. Standing at an intersection and rotating to check all directions is the core gameplay loop.
- Lantern posts can be lit with flares (8-second duration). A lit lantern illuminates 15 studs around it — this does NOT freeze Watchers (light alone is not "observation") but makes them visible, giving the player more reaction time.

**Watcher Placement:** 60% of Watcher idle positions are trail-adjacent (within 15 studs). Watchers stand between trees flanking the trail, often partially obscured. They are positioned to be visible only in the flashlight beam or peripheral vision — the player must actively sweep to find them.

---

#### Dense Woods

**Description:** Off-trail forest. Thick undergrowth, closely spaced trees, fallen logs, root systems. Visibility drops to 10-15 studs. The canopy is denser here — less moonlight penetrates. The flashlight beam catches on trunks and leaves, creating sharp shadows that look like shapes. Some of them are.

**Atmosphere:** Claustrophobic despite being outdoors. The trees press in. Every trunk could be a Watcher. The player's flashlight sweeps across bark, moss, rocks — and occasionally something pale and wrong-shaped that was not a tree. The dense woods are the closest Level 4 gets to the corridor horror of earlier levels, but without walls or hiding spots.

**Gameplay Function:**
- Alternative to trails. Slower (-20% movement speed) and louder (undergrowth crunch, +5 stud sound radius), but Watchers have difficulty moving unseen — more visual obstructions mean any Watcher movement has a higher chance of crossing the player's peripheral vision.
- The density creates natural "gates" — narrow passages between tree clusters where the player can only look forward. These are the most dangerous moments off-trail.
- No hiding spots in the traditional sense. The player can crouch behind fallen logs to break line of sight from one direction, but this is not a "hide" mechanic — no interaction prompt, no locked camera. It simply means Watchers on the other side of the log cannot see the player (and the player cannot see them).

**Watcher Placement:** 25% of Watcher idle positions. They stand between trees, sometimes partially behind trunks. In the dense woods, Watchers are harder to spot but also move shorter distances when unobserved — the visual clutter means they have fewer clear movement paths.

---

#### Clearing

**Description:** Roughly circular open area, 50 studs diameter. Grass, a few scattered rocks, a dead tree in the center (lightning-struck, blackened). No cover. Full moonlight when clouds break.

**Atmosphere:** Exposed. The clearing is bright enough that the player can see the tree line in every direction — and everything at the tree line can see them. It feels like standing on a stage. The dead tree in the center casts a long shadow that rotates slowly as the moon moves (scripted). The shadow points toward the nearest Watcher.

**Gameplay Function:**
- High-visibility zone. The player can see Watchers at the tree line (30-40 stud sightline to the edges). This makes the clearing feel temporarily safe — the player can observe in all directions.
- The trap: the clearing has no cover. If fog rolls in while the player is in the clearing, they lose all sightlines simultaneously. Every Watcher in range can move freely. When the fog lifts, the Watchers will have entered the clearing. The player will be surrounded.
- The dead tree's shadow is a subtle environmental tell — it slowly rotates to point toward the nearest Watcher. Observant players can use this to locate threats. This is never explained in-game. It is a reward for paying attention.
- Passing through the clearing is necessary for certain routes but should feel like a gamble every time.

**Watcher Placement:** 0% idle positions inside the clearing. Watchers position at the tree line (within 5 studs of the clearing edge). They ring the clearing, watching inward.

**Loot:** None. The clearing is empty. That is the point.

---

#### Creek Bed

**Description:** Shallow stream (ankle-deep, 8-10 studs wide) cutting east-west through the forest in a depression 6-8 studs below the forest floor. Rocky banks, exposed roots, smooth stones. The water is dark, reflecting the canopy and sky. Scattered debris — branches, a boot, a compass (smashed).

**Atmosphere:** The water noise is the only persistent ambient sound in the forest. It is simultaneously comforting (sound! Natural sound!) and terrifying (it masks everything else). The creek bed is low ground — the player cannot see the forest floor above the banks. Watchers could be standing at the bank edge, looking down, and the player would not see them until they looked up.

**Gameplay Function:**
- Sound masking. Water noise halves the player's footstep sound radius (good for avoiding detection in levels with hearing-based entities — less relevant here since Watchers don't track by sound, but the player doesn't know that yet). The real danger: the water noise masks the stone-grinding sound of Watcher movement, removing a key audio cue.
- Wading reduces movement speed by 15%.
- The creek bed is a natural corridor — the player is funneled east-west. Looking forward/backward along the creek provides 20-stud sightlines. Looking up toward the banks is the vulnerability — limited upward visibility, and Watchers on the bank above are silhouetted against the sky.
- The smashed compass is lore: Torres's. The boot is also Torres's. Torres is not here.

**Watcher Placement:** 10% of Watcher idle positions. Watchers stand at the bank edges, looking down into the creek bed. They are most visible when the player looks up — silhouettes against the sky.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 50% | In waterproof case, wedged between rocks |
| Bandage | 40% | In Torres's discarded pack |
| Lore: Torres's Field Journal (partial) | 100% | In pack |

**Lore: Torres's Field Journal (partial)**
> Pages water-damaged. Legible fragments:
> "...can see them from the watchtower. Five. No, six. They weren't there yesterday..."
> "...Vasik says don't look at them directly. Says counting them 'establishes a connection.' She's from Blackpoint. She knows things she won't say..."
> "...went off trail to avoid them. They were already there. Waiting. How do they know where I'm going before I do..."
> Final legible entry: "...the ring of trees. The carvings. They won't go near it. Vasik says it's old. Older than anything. I'm going there. I'm not coming back to camp."
> Torres's body is never found. His fate is unknown.

---

#### Abandoned Campsite

**Description:** A cleared area adjacent to the South Trail, roughly 30x30 studs. Four tents (two standing, one collapsed, one shredded). Central fire pit with cold ash. Folding table with maps, equipment, and scattered supplies. Camp chairs overturned. A lantern on the table still has fuel — it can be lit (interactable, provides 15-stud ambient light radius, lasts 5 minutes real time).

**Atmosphere:** Evidence of rapid departure. Food still in sealed containers. Sleeping bags rolled out. Personal effects: a novel facedown, reading glasses on a map, a half-written letter home. These people did not choose to leave. The shredded tent has long parallel tears — not claw marks (too wide), more like the fabric was pulled apart by hands.

**Gameplay Function:**
- Loot cache. The campsite has the highest loot density outside the Ranger Station.
- The lit lantern is a strategic choice: it illuminates the campsite, making Watchers visible and frozen in the light radius — but the light is visible from a distance, and once it expires, any Watchers that gathered at the edge of the light radius are suddenly in the dark and can move freely.
- The collapsed tent can be entered (crouch inside). This is the closest thing to a hiding spot in the forest, but it blocks the player's vision in all directions — inside the tent, you cannot observe anything. Any Watcher in range moves freely. Entering the tent is a panic button, not a strategy.
- The campsite is a waypoint on the South Trail. Players will pass through it on every critical path traversal.

**Watcher Placement:** No Watchers initially idle at the campsite. After the player's first visit, one Watcher spawns on subsequent approaches — standing among the tents, facing the trail. The player rounds the corner and finds it waiting.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Equipment box |
| Battery | 40% | Tent A |
| Bandage | 100% | First aid kit on table |
| Bandage | 60% | Tent B |
| Medkit | 30% | Tent A |
| Flare | 50% | Equipment box |
| Lore: Search Party Report | 100% | On table |
| Lore: Vasik's Letter (unsent) | 100% | In tent A |

**Lore: Search Party Report**
> Standard SAR form. Team roster: Ranger Torres (lead), Ranger Okafor, Medic Harlan, Dr. Elena Vasik (civilian advisor, Blackpoint). Objective: locate missing hikers (party of 3, reported overdue 72 hours). Day 1-2 summary: no sign of hikers. Day 3: "Non-standard situation. Recommend abort. Override by Vasik — states phenomena are 'consistent with Blackpoint data' and require documentation."

**Lore: Vasik's Letter (unsent)**
> "Dear Mara — I know I said this posting would be routine. It isn't. The things in the satellite images are real. They're standing in the forest. Dozens. And they are the same as what we had in containment at Blackpoint. The same source. The same behavior. But we had one, sealed, controlled. Here they are free. I think the seal is weakening. I think that's why they're appearing on the surface. I need to get to the ridge to confirm. If you're reading this and I haven't come home, the research is in Cabin A. Destroy it. Or give it to someone who can stop this. I love you."

---

#### The Ring

*See dedicated section: [The Ring — Safe Zone Design](#the-ring--safe-zone-design)*

---

### Cabin Cluster

Three cabins arranged in a rough triangle, 30-40 studs apart, in a cleared area of the forest. Connected by worn footpaths. A hand-painted wooden sign at the entrance reads "ASHWOOD CABINS — FORESTRY SERVICE." The sign is old. The paint is old. But the wood is older — impossibly old, petrified almost.

---

#### Cabin A — Researcher's Cabin

**Description:** Single-story, two-room cabin. Main room: desk, cot, shelving, wood-burning stove (cold). Walls covered in pinned papers — satellite imagery, topographic maps, hand-drawn diagrams of Watcher positions over time. String connects pins on a wall map showing Watcher migration patterns, all converging on a point underground — the same coordinates as St. Maren's sub-basement. A door in the floor leads to the Root Cellar.

Second room: small bathroom. Mirror intact. Toilet, sink, no window.

**Atmosphere:** The cabin of someone who understood. Vasik's workspace is meticulous early on — labeled folders, dated notes, clean handwriting. Then it deteriorates. Notes become scrawled. Diagrams become frantic. The final documents are barely legible, written in what might be multiple hands (or one hand losing control). The walls are covered so completely that the cabin itself feels like it is watching the player through a hundred pinned eyes of imagery and notes.

**Gameplay Function:**
- Primary lore location. Vasik's research is the deepest dive into the Watcher phenomenon and its connection to the broader campaign narrative.
- Root Cellar access (see below).
- Cabin interior is enclosed — functions like an indoor space. Standard rules: closing the cabin door blocks Watcher line of sight. The player is safe inside with the door closed (no windows face Watcher idle positions). But they must open the door to leave, and Watchers may have gathered outside.
- The windows (2, facing south and east) allow the player to observe outside. Any Watcher visible through the window is frozen. But the window's view cone is limited — the north and west sides of the cabin are unobserved.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Desk drawer |
| Battery | 50% | Shelf |
| Bandage | 60% | Bathroom cabinet |
| Lore: Vasik's Research Notes (1-5) | 100% | Pinned to walls, in order |
| Lore: Vasik's Final Entry | 100% | On desk, under paperweight |

**Lore: Vasik's Research Notes (series of 5)**

> **Note 1 — Classification:** "The entities (I'm calling them 'Watchers' — Torres's term) exhibit behavior consistent with Blackpoint Subject Alpha, but without the containment-induced dormancy. Key properties: rigid immobility when under direct observation. Instantaneous relocation when line of sight is broken. No observed locomotion — they do not walk, crawl, or run. They simply are somewhere, and then they are somewhere else. Hypothesis: they do not exist in the space between observed positions. They are not moving. They are re-appearing."

> **Note 2 — Observation Mechanics:** "Observation must be direct and conscious. Camera surveillance does not inhibit them (confirmed via trail cam footage — the cameras capture nothing. The frames between 'empty trail' and 'Watcher in frame' are missing. Not corrupted. Missing.). Peripheral awareness is sufficient — the observer does not need to focus, only to hold the Watcher within their conscious visual field. Implication: they interact with consciousness, not light."

> **Note 3 — Multiplication:** "Day 1: 2 observed. Day 3: 5. Day 5: 9. They are not arriving. They are manifesting. Each one we observe seems to... authorize the next. Counting them is an act of acknowledgment. Acknowledgment is permission. I have told the team to stop counting. Torres won't listen."

> **Note 4 — The Ring:** "The carved circle NW of the cabins. Petroglyphs — pre-colonial, pre-indigenous, pre-everything. The symbols don't match any known linguistic or artistic tradition. Carbon dating of the tree bark around the carvings returns errors. The Watchers will not enter the Ring. I've watched them approach and stop. Not physically stopped — they simply do not appear inside it. The Ring is an older boundary. Whatever drew those symbols understood the Watchers. Or is what the Watchers are afraid of."

> **Note 5 — The Source:** "Mapped their emergence pattern. They radiate outward from a central point. Triangulated: 47.2914N, 122.3816W. Cross-referenced: the coordinates match a geological survey from 1973. There's a cave system beneath. And beneath that — I pulled the Blackpoint archives. Same coordinates as Sub-Level D. Same coordinates as St. Maren's sub-basement. The containment site. The Seal. It's all the same place. They're not coming from the forest. They're coming from below. The forest is just where they surface."

**Lore: Vasik's Final Entry**
> Written in darkness (the text is uneven, pressed hard into the paper, overlapping in places):
> "I understand now. They don't want to reach us. They ARE reaching. They are fingers. Extensions. Something below is reaching up through the ground, through the geology, through the trees, and these things — these Watchers — are its fingertips testing the surface. We are not being hunted. We are being felt for. And every time we look at one, we tell it exactly where we are. Stop looking. Stop looking. But if you stop looking, they"
> The entry ends mid-sentence.

---

#### Cabin B — Hunter's Cabin

**Description:** Single-room cabin, larger than Cabin A. Practical, utilitarian. Gun rack (empty — guns removed long ago). Workbench with trapping supplies, rope, wire. Wall-mounted animal heads (deer, elk — their glass eyes catch the flashlight). A wood-burning stove (warm — embers still glowing. Someone was here recently). Heavy table, two chairs. One chair overturned.

The fuel canister is on the workbench, partially hidden behind coiled rope. It is the full, red, standard fuel canister. The extraction vehicle needs it. It is here. The objective is here.

**Atmosphere:** This cabin belonged to someone self-sufficient. The hunter. No name in any records — just "the hunter." They lived here before the forestry service built the ranger station. They knew the forest. The traps on the workbench are not for animals — the wire gauges are wrong, the mechanisms are wrong. These traps were designed for something that stands still and then isn't there.

**Gameplay Function:**
- **Critical objective: fuel canister.** The canister is a key item (does not consume inventory slot). Picking it up triggers a Watcher escalation event: 2 additional Watchers spawn in the forest (total goes from current count to current +2). The act of taking the fuel — of progressing toward escape — makes it harder to escape.
- The cabin door can be barricaded (interaction: push heavy table against door, 4-second animation). Barricaded door takes Watchers ~10 seconds to breach if they reach it unobserved. This buys time but traps the player — the only exit is the door.
- Window (1, east-facing): small, player can observe through it but cannot climb through. Limited observation cone.
- The glowing embers are a narrative detail: someone was here very recently. The hunter? Or something that mimics occupancy? The overturned chair suggests a struggle or sudden departure.

**Watcher Placement:** After the fuel canister is picked up, a Watcher spawns 15 studs from the cabin door (outside, facing the door). The player opens the door to leave and finds it waiting. This is the first time the objective progression directly spawns a threat.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Fuel Canister | 100% | Workbench (KEY ITEM) |
| Battery | 100% | Table drawer |
| Bandage | 100% | Cabinet |
| Flare | 70% | Shelf near door |
| Lore: Hunter's Trap Designs | 100% | Rolled papers on workbench |

**Lore: Hunter's Trap Designs**
> Technical drawings. Not labeled in any language. Diagrams show elaborate mirror and wire arrangements designed to create overlapping reflective observation fields — corridors of mirrors that observe everything within them from infinite angles. Marginal note in English, barely legible: "If it can never be unobserved, it can never move. Infinite observation. But what happens to a thing that can never move? Does it die? Or does it just get angry?"
> A second marginal note, different ink: "The mirrors broke. All of them. At the same time. In the middle of the night. While I was sleeping."

---

#### Cabin C — Collapsed Cabin

**Description:** This cabin has partially collapsed. The north wall has buckled inward, the roof sags at a 30-degree angle, and the floor is covered in debris: shattered furniture, broken glass, splintered wood. The door hangs from one hinge. Inside, the collapse has created a compressed space — the player must crouch to enter.

In the debris, tangled in fallen roof beams and shattered furniture: a Watcher. It is lying at an angle, beams across its body, wood and glass pressing it into the floor. Its head is turned toward the door. It is watching.

It cannot move. The debris holds it. But it is watching.

**Atmosphere:** Wrong. This should be a relief — a Watcher restrained, immobilized, harmless. But the player must crouch past it to reach the back of the cabin. They must get close. Its pale face is visible between the beams. Its expression (if it can be called an expression) is not struggling. It is patient. It has been here for a long time. It will be here longer.

**Gameplay Function:**
- The Watcher in the debris is permanently immobilized. It cannot move regardless of observation. It is a narrative and atmospheric set piece only.
- However: its presence triggers the Proximity Fear System. Getting close to it (within 10 studs) ramps up to Tier 2-3 DREAD/PANIC effects. The player's screen distorts, heartbeat rises, simply from proximity — even though the Watcher cannot harm them. This teaches the player that the fear response is based on closeness, not threat.
- The back of the cabin (past the Watcher) contains an optional loot stash and a lore item.
- The collapsed structure blocks most exterior sightlines — while inside, the player can only observe out through the door. If other Watchers are outside, they can approach from all unobserved sides.

**Watcher Placement:** One (1) immobilized Watcher in debris. Does not count toward the active Watcher pool. Does trigger Proximity Fear.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 80% | Behind collapsed shelf |
| Medkit | 40% | Crushed first aid box (partially accessible) |
| Lore: Carved Message | 100% | Scratched into floor beam near Watcher |

**Lore: Carved Message**
> Scratched into a beam, positioned so the Watcher must have been looking at it as the cabin collapsed. As if someone carved it for the Watcher to read:
> "WE WERE HERE BEFORE YOU. WE WILL BE HERE AFTER. GO BACK DOWN."
> The carving style matches the Ring petroglyphs.

---

#### Root Cellar (beneath Cabin A)

**Description:** Accessed via a floor hatch in Cabin A. Wooden ladder descends 10 studs into a packed-earth cellar, 15x15 studs. Shelving with preserved food (old), water jugs, a cot, and a battery-powered lantern (functional — provides dim ambient light). The air is damp and cool. Root systems push through the earth walls. No windows. No other exits.

**Atmosphere:** Profoundly enclosed after the openness of the forest. The Root Cellar is the only truly interior space in the level (besides the cabins). It is silent — the forest sounds do not penetrate. The earthen walls absorb everything. It should feel safe. The Watchers cannot see the player here. The player cannot see them.

And that is the terror. The Root Cellar is safe from Watchers but removes the player's only tool: observation. Every second spent here, the Watchers above are free to move, to reposition, to surround the cabin. Descending is safe. Ascending is the gamble.

**Gameplay Function:**
- Complete Watcher reprieve. No Watcher can observe or reach the player in the Root Cellar. Proximity Fear drops to Tier 0. The player can breathe.
- While in the Root Cellar, all Watchers in range of Cabin A are free to move. They will converge on the cabin area over time (1 Watcher repositions to within 20 studs of Cabin A per 15 seconds the player is underground).
- Ascending the ladder is a 3-second committed animation. The player emerges into Cabin A and must immediately check windows and doors. By the time they surface, Watchers may be surrounding the cabin.
- Contains a cot that functions as a "rest point" — interacting restores stamina fully. There is no time-acceleration; the player simply recovers stamina without needing to stand still.
- The lantern can be taken as a temporary light source (handheld, replaces flashlight slot while held, 3-minute duration, dimmer but wider radius). Useful if flashlight battery is dead.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | On shelf |
| Battery | 70% | Under cot |
| Bandage | 100% | First aid tin |
| Medkit | 50% | Behind water jugs |
| Portable Lantern | 100% | On hook (temporary light source) |
| Lore: Vasik's Audio Log | 100% | Tape recorder on cot |

**Lore: Vasik's Audio Log**
> [Recorded on handheld device. Background: earth, close, muffled.]
> "Day 6. I'm in the cellar. I can hear them above me. Not moving — they don't make sound when they move. But the cabin creaks. The floor shifts. Weight, distributed across the floor above me. How many? I can't look. I won't look. I've worked it out. Every time you observe them, you establish a bilateral connection. You see them. They see you. They know where you are. Permanently. Every Watcher you have ever looked at knows where you are forever. The only defense is to never have seen them. And it's too late for that. For all of us.
> [Long pause.]
> "I'm going to the Ridge. The cave there — it goes down. Deep. Toward the source. If I can understand what's reaching up through the ground, maybe I can understand how to send it back. If you find this, don't follow me.
> [Pause.]
> "Follow me."

---

### The Ridge

The Ridge is the northern boundary of the playable area — a steep, rocky incline rising 30-40 studs above the forest floor. The tree line thins here, replaced by exposed rock, scrub brush, and wind. The Ridge Trail from the Cabin Cluster narrows to a single switchback path, flanked by drop-offs. This is the most exposed terrain in the level.

---

#### Cliff Edge

**Description:** The Ridge Trail opens onto a flat rock outcropping overlooking the valley south. From here, the entire forest canopy is visible — a dark carpet of treetops stretching to the Ranger Station. The Cabin Cluster is identifiable by the cleared area. The Ring is faintly visible as a lighter circle in the canopy.

Looking southeast: Blackpoint Research Station. The buildings are on fire. Smoke pillars rise into the overcast sky. Something went very wrong after the player left. The destruction is clearly ongoing — explosions occasionally light up the distant structures. The player cannot return there.

Looking north: mountains, cloud cover, nothing. The world ends at the playable boundary.

**Atmosphere:** Vertiginous, exposed, final. The cliff edge is the highest point in the level and provides the most comprehensive view — but it also places the player on a promontory with approach from only one direction (the trail). The wind is stronger here, and for the first time in the level, the player can hear something other than silence: wind. The relief of wind-sound is immediately undercut by the burning Blackpoint view.

**Gameplay Function:**
- Reconnaissance. The player can survey the forest below and identify Watcher positions (they are visible from above as pale shapes among the dark canopy). However, viewing from the cliff edge does NOT freeze Watchers below — the distance (80+ studs) exceeds the observation freeze range (see Entity Design). The Watchers below are decorative from this vantage. Only Watchers within 60 studs are affected by observation.
- The Blackpoint fire is a narrative beat: the player's previous escape route is gone. Forward is the only option.
- Lore item here connects Level 3 and Level 4.

**Watcher Placement:** One Watcher idles on the Ridge Trail between the cliff edge and the Radio Tower. The trail is narrow enough that the player cannot pass without being within 5 studs of it. They must observe it while navigating past.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 50% | Behind rock |
| Lore: Blackpoint Emergency Broadcast (written) | 100% | Taped to a rescue marker pole |

**Lore: Blackpoint Emergency Broadcast (written)**
> Transcription of the emergency broadcast the player heard on the boat in the Level 3 extraction:
> "This is Blackpoint Station, all channels, all frequencies. Containment failure across all sub-levels. Subject Alpha is — [static] — the seals are not holding. Repeat, the seals are not holding. We are initiating Protocol Terminus. All personnel evacuate to — [static] — do NOT proceed to St. Maren's. Repeat, do NOT proceed to — [static]"
> Handwritten note below in Vasik's writing: "Protocol Terminus is demolition. They're destroying the station to prevent surface breach. It won't work. The breach isn't at Blackpoint. It's under the hospital. It was always under the hospital."

---

#### Cave Entrance

*See dedicated section: [The Cave — Optional Area](#the-cave--optional-area)*

---

#### Radio Tower

**Description:** A 60-stud metal lattice communications tower on the highest point of the Ridge. The base station is a small concrete bunker (8x8 studs interior) with a steel door (ajar). Inside: radio transmitter console, power junction box, emergency generator (small, portable type), and a wall of patch cables and antenna routing equipment.

The tower's warning light is dead. The power junction is disconnected — the cable has been cut. Not frayed or damaged by weather. Cut. The same clean severance as the Ranger Station radio cable.

**Atmosphere:** Industrial, final. The concrete bunker is the most "Level 1-3" space in the level — enclosed, lit by emergency LEDs, humming with residual power. The radio console has a chair in front of it. On the chair: a pair of glasses. Vasik's glasses. She was here. She powered the radio. She made a call. To whom?

**Gameplay Function:**
- **Critical objective: power the radio tower.** This is a multi-step interaction:
  1. Reconnect the power junction (interact with junction box, 3-second hold — rewiring animation).
  2. Start the emergency generator (pull-cord mechanic, same as Level 1 — 3-5 pulls, each pull audible at 40 studs but Watchers don't respond to sound; the pulls are a tension mechanic, not a detection trigger).
  3. Wait for the radio to boot (15-second timer with progress bar). Player can move during this time.
  4. Transmit the extraction call (5-second radio interaction — player holds the transmitter, speaks pre-recorded dialogue: "This is [callsign], requesting emergency extraction at Ashwood Ranger Station. Vehicle will be on the forest road heading south. Respond." Static. Then: a voice. "Copy, Ashwood. ETA thirty minutes. Get to the vehicle. Do not stop driving. Do not look at the road." The voice is Vasik's.
- Completing the radio call triggers the final escalation: total Watcher count increases to 6+ (see Entity Design). Fog frequency doubles. The return trip to the Ranger Station is the final gauntlet.
- The bunker door can be closed (blocks Watcher line of sight while inside). The bunker has no windows — same trade-off as the Root Cellar: safe while inside, blind to exterior.

**Watcher Placement:** Two Watchers spawn on the Ridge Trail between the Radio Tower and the Cabin Cluster when the radio call completes. They are positioned 40 studs apart on the narrow trail. The player must observe both while descending — and the trail curves, making simultaneous observation impossible.

**Loot:**
| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Bunker shelf |
| Bandage | 60% | Emergency kit |
| Flare | 50% | Emergency kit |
| Lore: Radio Log (Previous Transmissions) | 100% | Printout by console |

**Lore: Radio Log (Previous Transmissions)**
> Timestamped transmissions, most recent first:
> [T-6 days] OUTGOING: "Ashwood station to Blackpoint, search team status update. No sign of hikers. Requesting satellite pass. Over."
> [T-6 days] INCOMING: "Blackpoint copies. Satellite pass scheduled 0900. Be advised, we are tracking... anomalies... in your sector. Stand by for imagery."
> [T-4 days] OUTGOING: "Ashwood to any station. Requesting immediate extraction. Repeat, immediate extraction. Situation is not — we can't — they're everywhere. Please. Please respond."
> [T-4 days] INCOMING: [No response logged]
> [T-1 day] OUTGOING — UNIDENTIFIED CALLER: "The seal is cracking. I can hear it from here. From the cave. It sounds like breathing. I'm going down."
> The final transmission is from Vasik. She went into the cave.

---

### Extraction Sequence

#### Return to Ranger Station

After completing the radio tower objective, the player must traverse the entire forest south to the Ranger Station. This is the longest single-objective traversal in the level and serves as the final gauntlet.

**What changes:**
- Watcher count is at maximum (6+ solo, scaled for multiplayer).
- Fog frequency increases (every 60-90 seconds instead of every 120-180 seconds).
- Fog duration increases (20-30 seconds instead of 12-18 seconds).
- New Watcher positions are seeded along the critical path (trail system), ensuring the player encounters at least 3 Watchers during the return.
- Ambient audio intensifies: the stone-grinding sound of Watcher movement is more frequent, coming from multiple directions.

**Design Intent:** The return trip inverts the level. The player traversed this forest exploring, curious, cautious. Now they traverse it fleeing, knowing exactly what is in the trees with them, unable to avoid all of it. The forest that was mysterious is now a gauntlet. Every landmark is a reference point for how far they still have to go.

---

#### Ranger Station Garage — Fueling and Escape

**Sequence:**
1. Player arrives at Ranger Station with fuel canister (already acquired from Cabin B).
2. Approach vehicle in garage. Interact: "Fuel Vehicle" (8-second hold, pouring animation, player is locked).
3. Vehicle starts (cutscene: engine turns over, headlights flood the garage).
4. Player enters vehicle (interact). Driving sequence begins.

**The Drive:**
- The driving sequence is semi-scripted. The player controls the vehicle on the forest road heading south. The road is straight but narrow, lined with trees. The headlights illuminate 40 studs ahead.
- The Watchers line the road. They stand at the road's edges, facing the vehicle. Dozens of them — far more than the 6 in the gameplay section. This is a narrative escalation, not a gameplay one. The Watchers on the road are set pieces.
- The vehicle moves at a fixed pace (player can accelerate slightly, cannot stop or reverse). The headlights serve as the observation mechanic — Watchers in the headlight cone are frozen. Watchers outside the headlight cone (behind, to the sides) are visible only as shapes in the darkness.
- A Watcher appears in the road directly ahead. The headlights freeze it. The vehicle approaches. 10 studs. 5 studs. The player must hold their nerve — the vehicle will pass through it (it phases/vanishes at the last moment). Swerving off the road ends the run (crash, death, restart from garage fueling).
- Duration: 45 seconds of driving. The road opens. The trees thin. Dawn light breaks on the horizon.
- **Level Complete.**

**Post-Extraction:**
- As the vehicle exits the forest, the rearview mirror shows the tree line. Every Watcher is at the forest edge. Watching the vehicle leave. Not following. Watching.
- Smash cut to black. Level 4 complete. Level 5 unlocked.

---

## The Watchers — Entity Design

### Overview

| Parameter | Value |
|-----------|-------|
| Entity Name | The Watchers |
| Classification | Multi-instance, vision-reactive |
| Primary Sense | N/A (does not "detect" — reacts to observation state) |
| Count | 2 (start) → 6+ (end), scaling with objectives |
| Patrol Speed | 0 (static — does not patrol) |
| Movement Mechanism | Instantaneous relocation when unobserved |
| Chase Speed | N/A (does not chase — teleports to proximity) |
| Detection Ramp | Instant (no awareness buildup) |
| Hiding Check | N/A (irrelevant — freezes when watched) |
| Kill Condition | Contact (within 2 studs while player is unaware) |
| Unique Mechanic | Only exists/moves in unobserved space |

### Observation Rules

#### What Counts as "Observed"

A Watcher is considered "observed" (and therefore frozen/immobile) when ALL of the following are true:

1. **Within the player's camera view frustum.** The Watcher must occupy at least a portion of the rendered screen space. This is a frustum check against the camera's FOV (default ~70 degrees). If the Watcher is behind the camera, outside the horizontal FOV, or above/below the vertical FOV, it is unobserved.

2. **Within observation range.** Maximum observation range is **60 studs**. Beyond 60 studs, a Watcher is considered unobserved regardless of camera direction. This prevents the player from "locking" distant Watchers from safe positions.

3. **Not occluded.** A Raycast from the camera to the Watcher's center mass must hit the Watcher without being blocked by terrain, structures, trees, or fog. If any opaque object fully occludes the Watcher, it is unobserved. Partial occlusion (e.g., behind a tree trunk but head/torso visible) still counts as observed.

4. **Not obscured by fog.** During fog events, Watchers beyond the fog visibility distance (dynamically calculated, see Fog System) are treated as fully occluded regardless of camera direction.

**Critical clarification — flashlight beam:**
The flashlight beam does NOT constitute "observation" on its own. A Watcher illuminated by the flashlight beam but outside the camera frustum (e.g., the beam bounces off it at the edge of the screen but the camera is facing elsewhere) is NOT observed. However, the flashlight extends effective observation range in darkness: without the flashlight, Watchers in dark areas are only visible/observable within 15 studs. With the flashlight on, Watchers in the beam are observable up to the full 60-stud range.

**Critical clarification — binoculars:**
The watchtower binoculars extend observation range to 120 studs but narrow the effective frustum to ~20 degrees. Watchers observed through binoculars are frozen. Watchers outside the binocular view are unobserved — including Watchers at the base of the tower.

**In multiplayer:** Each player has an independent observation frustum. A Watcher is frozen if observed by ANY player. Players can coordinate: "I'm watching the one on the left, you watch right." This is the core multiplayer mechanic.

#### What Happens When Unobserved

When a Watcher transitions from "observed" to "unobserved" (the player looks away, fog rolls in, they turn a corner, they blink [see below]), the Watcher **instantly relocates**. This is not animation — the Watcher does not walk, slide, or phase. It is simply in Position A, then it is in Position B. The transition occurs in a single server tick.

**Relocation rules:**
- The Watcher relocates to the nearest valid position that is:
  - Closer to the player (always closes distance)
  - Currently unobserved by any player
  - On the NavMesh (valid standing position)
  - Not inside a sealed structure (closed cabin door blocks entry)
- **Relocation distance per "blink":** 8-15 studs (randomized). This means a single look-away can move a Watcher from 30 studs to 15-22 studs. Two look-aways can put it within kill range.
- **Relocation cooldown:** 0.3 seconds. After relocating, a Watcher cannot relocate again for 0.3s even if still unobserved. This prevents instant teleportation across the map and gives the "appear closer" effect rather than "appear on top of you." At sustained unobservation, a Watcher closes approximately 25-50 studs per second.
- **Relocation audio cue:** Each relocation produces a brief stone-grinding sound, spatialized to the Watcher's NEW position. This is the player's only warning of movement they didn't see. The sound is quiet (8-stud radius) and masked by water, wind, or fog audio.

#### The Blink Mechanic

The player character does NOT have a blink animation or forced blink mechanic in standard gameplay. "Blinking" is a metaphor for any interruption of observation:
- Looking away (camera rotation)
- Entering a menu or inventory screen (observation continues — game does not pause)
- Loading/transitioning (not applicable — open world)
- Fog rolling in (visibility reduction)
- Flashlight dying (darkness reduces observation range)
- Climbing the watchtower ladder (4-second committed animation, observation interrupted)
- Entering/exiting hiding positions (brief camera transition)
- Taking damage (flinch animation briefly disrupts camera direction)

There is NO forced blink mechanic. The player's control over observation is total — the tension comes from the impossibility of observing everything simultaneously, not from the game taking observation away (except fog, which is the designed tension mechanic).

### Movement When Unobserved — Visual Treatment

The player never sees a Watcher move. The relocation is instant. However, the visual feedback for "a Watcher has moved" is designed to be deeply unsettling:

1. Player looks at Watcher A (frozen, 30 studs away).
2. Player rotates camera to check behind them (breaking observation of Watcher A).
3. Player rotates camera back to Watcher A's position.
4. Watcher A is now at 18 studs. Same pose. Same direction. But closer. The player's brain fills in the movement that didn't happen — and the imagined movement is worse than anything animated.

If the player sweeps their camera quickly enough to catch a Watcher mid-relocation, the Watcher simply appears in the new position at the edge of the frustum — the player sees it "pop" into existence for a single frame at the new location. This is intentional and mirrors SCP-173 behavior. The pop is accompanied by a louder version of the stone-grinding audio.

### Kill Behavior

When a Watcher reaches **within 2 studs** of a player while the player is **not observing it:**

1. **Sound cue:** A sharp stone-crack sound, very close and loud, plays 0.2 seconds before the kill (this is a mercy frame — exceptionally skilled players can whip the camera around in time, but the window is nearly impossible to hit consistently).
2. **Kill animation:** The screen snaps to face the Watcher (involuntary camera movement). The Watcher is directly in front of the player, face-filling the screen. The screen goes to static for 0.5 seconds.
3. **Death screen:** Standard death screen. "You were taken."
4. **Damage model:** In solo, Watcher contact is **instant death** (all 4 pips). This is different from Levels 1-3 where entities deal 1-2 pip damage. The Watchers are a binary threat: observed = harmless, unobserved = fatal. There is no "taking a hit and running."
5. **Co-op modification:** In multiplayer, Watcher contact deals 3 pips of damage (downs the player from full health, kills from 2+ pips of prior damage). A downed player can be revived. The Watcher that downed a player freezes in place over the downed player's body — the rescuing teammate must approach while observing the Watcher. If they look away to interact with the downed player, the Watcher kills both.

### The "Don't Count Them" Rule

This is a soft mechanic — not punitive, but consequential.

**Trigger:** If the player directly observes (camera frustum + within 60 studs) 4 or more unique Watchers within a 15-second window, the "counting" event triggers.

**What happens:**
1. All observed Watchers turn their heads to face the player simultaneously (this is the only time Watchers move while observed — a head rotation, not locomotion).
2. A new Watcher spawns at the edge of the player's observation range (60 studs, behind the camera).
3. A low-frequency audio sting plays (sub-bass hit + high whine).
4. The fog timer accelerates: the next fog event occurs within 15-30 seconds regardless of the normal schedule.

**Design intent:** Counting is an act of cataloging. The player is trying to quantify the threat — "How many are there? Can I track all of them?" The answer is no. Trying to answer yes makes it worse. The Watchers notice being counted. They respond by creating more of themselves. This discourages systematic "clearing" behavior and reinforces the intended emotional state: you don't know how many there are. You can't know. Stop trying.

**Lore connection:** Vasik's Note 3 explains the mechanic narratively: "Counting them is an act of acknowledgment. Acknowledgment is permission."

### Escalation Schedule

| Event | Active Watchers (Solo) | Notes |
|-------|------------------------|-------|
| Level Start | 0 | 60-second safe period in Ranger Station |
| Leave Ranger Station compound | 1 (Supply Shed tutorial) | Shed Watcher, semi-scripted |
| Enter forest | 2 | One trail-adjacent, one in dense woods |
| Reach Cabin Cluster | 3 | Third spawns near cabins |
| Pick up fuel canister | 4 | +1 immediately, +1 within 30 seconds |
| Reach Radio Tower | 4 | No change during ascent |
| Complete radio call | 6 | +2 spawn on Ridge Trail |
| Begin return to Ranger Station | 6-8 | +0-2 based on time elapsed |
| Reach Ranger Station garage | 6-8 | All converge on station perimeter |
| Driving sequence | Narrative only | Dozens visible (set pieces, not gameplay) |

### Watcher Visual Design

**Appearance:** Tall (8 studs, approximately 1.3x player height). Humanoid silhouette but proportions are wrong — arms slightly too long, torso slightly too narrow, head slightly too large. Pale grey-white surface texture, matte, no specular reflection. No facial features except two dark recesses where eyes would be — not eyes, just absence. No mouth. No ears. No clothing. The surface looks like stone or bleached wood.

**Pose:** When frozen (observed), Watchers stand in a slightly forward-leaning posture, arms at sides, head tilted slightly down as if looking at the player's feet. They do not move — no idle animation, no breathing, no sway. Absolute stillness. This is more unsettling than any animation.

**Relocation pose variation:** Each relocation can subtly change the Watcher's pose. It might be leaning forward more. Arms might be slightly raised. Head might be tilted to the other side. These changes are small enough that the player isn't sure if the pose changed or if they're imagining it. This amplifies paranoia.

---

## Dynamic Fog System

### Overview

The Dynamic Fog System is the primary mechanical threat enabler in Level 4. The Watchers cannot move while observed. The fog removes observation. Without fog, a skilled player could theoretically survive indefinitely by maintaining careful 360-degree camera sweeps. The fog makes this impossible.

### Fog Behavior

**Appearance:** The fog manifests as a ground-level mist that rises rapidly (2-3 seconds from clear to full density). It is grey-white, slightly luminescent in moonlight, and reduces visibility in a smooth gradient. It does not appear as a wall — it fills the space naturally, thickening with distance.

**Visibility reduction curve:**
| Fog Phase | Visibility Range | Observation Effective Range |
|-----------|-----------------|---------------------------|
| Clear | 30-40 studs (forest) | 60 studs |
| Early fog (0-3s) | 20-25 studs | 40 studs |
| Mid fog (3-8s) | 10-15 studs | 20 studs |
| Full fog | 5-8 studs | 8 studs |

At full fog density, effective observation range drops to 8 studs — the player can only freeze Watchers within near-melee range. Everything beyond 8 studs is unobserved. Every Watcher in the forest can move freely.

### Fog Schedule

| Phase of Level | Fog Interval | Fog Duration | Warning Time |
|----------------|-------------|-------------|-------------|
| Early (Ranger Station → Forest entry) | No fog | — | — |
| Mid (Forest exploration → Cabin Cluster) | 150-180 seconds | 12-15 seconds | 5 seconds |
| Late (Radio Tower objective active) | 120-150 seconds | 15-20 seconds | 4 seconds |
| Final (Return to Ranger Station) | 60-90 seconds | 20-30 seconds | 3 seconds |

### Fog Warning System

The player receives a brief warning before fog arrives:

1. **Audio cue (T-5s to T-3s):** A low, resonant horn-like sound from no discernible direction. Distant. Mournful. Like a foghorn but organic.
2. **Visual cue (T-3s):** The edges of the screen begin to soften. Slight white vignette. Ground-level wisps appear.
3. **Temperature cue (T-2s):** The player character's breath becomes visible (cold vapor). This is visible even without flashlight.
4. **Full onset (T-0):** Fog rises rapidly, reaching full density in 2-3 seconds.

The warning is consistent and learnable. After 2-3 fog events, the player should recognize the horn sound and immediately prepare: identify the nearest Watcher positions, move toward cover or a defensible observation point, and brace.

### Fog Dissipation

Fog lifts gradually over 3-5 seconds (reverse of onset). During dissipation, visibility returns in stages — the player can see farther and farther, re-establishing observation of Watchers that were previously hidden. This is the "how much did they move?" reveal — often the most frightening moment. A Watcher that was 25 studs away before the fog is now 10. One that was 15 is now 5. One that wasn't visible before is now directly behind the player.

### Fog Interaction with Locations

| Location | Fog Behavior |
|----------|-------------|
| Open forest | Full fog effect |
| Dense woods | Fog is slightly denser (visibility -2 studs) — canopy traps it |
| Clearing | Fog is slightly thinner (visibility +3 studs) — open air disperses faster |
| Creek bed | Fog pools in the depression — thicker, longer duration (+5 seconds) |
| Ridge | Fog is thinner at elevation. Visibility -30% instead of full reduction |
| Cabin interiors (door closed) | No fog inside. Windows show fog outside |
| Root Cellar | No fog |
| The Ring | **No fog enters the Ring.** The fog flows around it. The Ring is always clear. This is one of the Ring's safe-zone properties |
| Cave | No fog inside |

### Strategic Implications

The fog system creates a rhythm:
1. **Clear phase:** Player moves, observes, navigates. Identifies Watcher positions.
2. **Warning phase:** Player prepares. Finds a defensible position (back against a wall, inside a cabin, in the Ring, in a narrow corridor with sight lines limited to two directions).
3. **Fog phase:** Player holds position, observing the 5-8 stud bubble around them. Everything beyond is blind. Watchers advance.
4. **Dissipation phase:** Player assesses new Watcher positions. Adjusts route. Moves.

This rhythm is the heartbeat of Level 4. The fog is not a random event — it is the game's metronome, dictating the pace of play.

---

## The Ring — Safe Zone Design

### Physical Description

A circle of 12 ancient trees, each 4-5 studs in diameter, spaced evenly around a 25-stud-diameter clearing. The trees are a different species than the rest of the forest — darker bark, no leaves (bare branches reaching upward like fingers), and significantly older (trunk girth suggests centuries or millennia of growth). Each tree bears carvings: deep, weathered petroglyphs cut into the bark.

The ground inside the Ring is different — bare earth, no grass, no undergrowth. The soil is packed hard, almost like stone. In the exact center: a flat rock, roughly circular, 3 studs diameter. The rock's surface bears the same petroglyphic carvings as the trees. When the flashlight beam hits the rock, the carvings seem to shift slightly (optical illusion or actual subtle animation — never confirmed).

### The Carvings

The petroglyphs do not match any known symbolic system. They are abstract: spirals, concentric circles, angular patterns resembling eyes or mouths, and one repeating motif — a vertical line with horizontal lines radiating from it, like a spine with ribs. Or like a figure with arms. Or like a tree with branches. The ambiguity is intentional.

One carving on the north-facing tree is different from all others: it depicts a recognizable image. A circle (the Ring?) containing smaller circles (trees?) surrounding a central shape (the rock?). Outside the circle: many vertical lines (Watchers?). The vertical lines have no arms, no features. They stand outside the circle. They do not enter.

This is the only "map" of the Ring's protective function. It was carved by whoever created this place, and it shows the boundary as intentional.

### Safe Zone Rules

| Property | Behavior |
|----------|----------|
| Watcher entry | Watchers cannot manifest inside the Ring. They stop at the tree line and remain frozen regardless of observation state. |
| Fog | Fog does not enter the Ring. The interior remains clear during fog events. The fog flows visibly around the tree line. |
| Proximity Fear | Drops to Tier 0 inside the Ring, regardless of Watcher proximity outside. |
| Observation | The player can observe Watchers from inside the Ring, freezing them. Watchers at the Ring's edge remain visible even during fog (the clear interior means sightlines to the tree line are preserved). |
| Time limit | None. The player can remain in the Ring indefinitely. |
| Loot | Minimal (see below). The Ring is not a reward — it is a sanctuary. |

### Watcher Behavior at the Ring

When a Watcher's relocation path would bring it into the Ring, it instead stops at the nearest tree trunk and remains there. Watchers accumulate at the Ring's perimeter if the player stays inside — they line up between the trees, filling every gap, facing inward. They cannot enter. But they wait.

If the player stays in the Ring for more than 60 seconds, an additional Watcher spawns at the Ring's edge every 30 seconds (up to a maximum of all active Watchers being at the Ring). This does not create new Watchers — it relocates existing ones. The Ring becomes a cage of Watchers staring inward, and the player must eventually leave through them.

Leaving the Ring means passing between two Watchers standing at the tree line, within 2 studs of each. The player must observe both (keep both in frustum) while passing between them. This is the cost of safety.

### Is It Truly Safe?

Yes. The Ring is genuinely safe. There is no trap, no gotcha, no betrayal of the safe zone. This is a deliberate design decision: the player must have one place in the forest where they can stop, breathe, and plan. Without it, the level is relentless and exhausting. The Ring is the exhale in the breathing rhythm of tension and release.

However, the Ring's safety comes with a cost:
1. **No objectives in the Ring.** The player must leave to progress.
2. **Watcher accumulation.** Staying too long draws them all to the perimeter.
3. **Lore discomfort.** What made the Ring? Why does it work? The carved message in Cabin C ("WE WERE HERE BEFORE YOU") suggests something older than the Watchers created this boundary. Is that something still here? The center rock's shifting carvings suggest it might be. The Ring is safe from Watchers because something in the Ring is scarier than the Watchers. The player is never told this directly.

### Lore Implications

The Ring is connected to the Seal beneath St. Maren's. The same symbols appear in both locations (the player will recognize them in Level 5). The Ring is a surface expression of the Seal — a boundary marker. Whatever intelligence created the Seal also created the Ring. The Watchers — extensions of whatever is sealed — cannot cross a boundary set by their own prison.

This implies the Seal is not just a physical barrier. It is a symbolic one. The carvings are the lock. The Ring is proof that symbols have power in this world. Level 5's choice (reinforce or destroy the Seal) gains weight: the symbols work. The question is whether they will hold.

### Loot

| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Base of center rock |
| Lore: Ring Petroglyphs (sketch) | 100% | Auto-collected on first entry |

**Lore: Ring Petroglyphs**
> Sketch added to journal showing the north-tree carving: the circle with figures outside. Journal note auto-generated: "The carvings on these trees match symbols from Blackpoint's Sub-Level D archives. Whatever made these was here before the forest. Before the mountain. The Watchers won't cross the tree line. I don't know what does live here, but the Watchers are afraid of it."

---

## Scripted Events

### First-Playthrough Triggers

These events fire only on the player's first successful run of Level 4. They are flagged per-account and do not repeat.

| # | Trigger | Event | Purpose |
|---|---------|-------|---------|
| 1 | Enter Main Office, examine radio | Radio emits 2 seconds of clear signal — a voice saying "Don't come into the forest" — then dies completely. The signal was live. Someone is broadcasting. | Establishes the radio tower objective emotionally. Someone is out there. |
| 2 | Climb watchtower for the first time | As the player reaches the platform, a Watcher is standing on the platform, facing the ladder. It was not visible during the climb. It freezes when the player's camera clears the platform edge. It is 3 studs away. | First "they are already here" shock. Teaches that Watchers can be anywhere, including elevated positions. |
| 3 | Open Supply Shed door | Flashlight sweeps across the shed interior and illuminates the tutorial Watcher in the back corner. A musical sting plays. Player character audibly gasps. | First face-to-face encounter. Tutorial moment. |
| 4 | Count 4+ Watchers via binoculars (The Counting) | All observed Watchers simultaneously turn their heads to face the player. The binocular view flickers with static. A new Watcher appears at the base of the watchtower (visible when the player descends). | "Don't count them" rule enforcement. The player realizes observation is bidirectional. |
| 5 | First fog event | The horn sounds. The player's character says (auto-dialogue, whispered): "No. No no no." Fog rises. When it lifts, the nearest Watcher has moved 15+ studs closer. | Teaches the fog mechanic. The auto-dialogue communicates urgency without a tutorial prompt. |
| 6 | Enter Cabin A, read Vasik's Final Entry | All cabin lights go out (lantern, flashlight flickers and dies for 3 seconds). Sound of wood creaking — the cabin walls. Something is pressing against the cabin from outside. When the flashlight returns, a Watcher's face is visible in the window, pressed against the glass. It is watching the player read. | The Watchers know about Vasik. They know the player is learning what Vasik learned. They are paying attention. |
| 7 | Pick up fuel canister in Cabin B | The cabin door (if closed) slowly swings open on its own. Through the doorway: a Watcher, 15 studs away, facing the door. It was not there when the door was closed. Behind it, in the tree line, two more. The act of taking the fuel has consequences. | Connects objective progression to threat escalation. The game punishes progress — and the player has no choice but to progress. |
| 8 | Complete radio transmission | After the response ("Do not stop driving. Do not look at the road."), the radio emits a burst of white noise. Then, faintly, layered under static, dozens of voices whispering the player's callsign. Not the responder. Something else was listening to the radio call. | The extraction is compromised. Something knows the player is leaving. The return trip is framed as a race against something that is already prepared. |

### Repeating Events (Every Run)

| Trigger | Event | Notes |
|---------|-------|-------|
| Player stops moving for 10+ seconds in forest | Ambient stone-grinding sound from behind camera, 15-20 studs | Punishes paralysis. Keep moving. |
| Player enters clearing during fog | Fog lifts to reveal 2+ Watchers have entered clearing edge | Clearing is only "safe" in clear conditions |
| Player stays in Root Cellar 30+ seconds | Creaking from above (Watchers on cabin floor). Gets louder over time | Pressure to leave safe space |
| Player walks same trail section 3 times | Additional Watcher spawns on that trail section | Punishes repetitive routes (mirrors adaptive AI from earlier levels) |
| Fog event with player on Ridge Trail | Watcher spawns at both ends of the current trail segment (if not already present) | Ridge Trail is a kill corridor during fog |

---

## Loot Table Summary

### Consumables

| Item | Total Available | Guaranteed | Random (Probability) | Primary Locations |
|------|----------------|------------|----------------------|-------------------|
| Battery | 14-18 | 8 | 6-10 (40-80% each) | All areas |
| Bandage | 10-14 | 5 | 5-9 (30-60% each) | Ranger Station, Campsite, Cabins |
| Medkit | 2-3 | 0 | 2-3 (30-50% each) | Campsite, Cabin C, Root Cellar |
| Flare | 3-5 | 1 (Supply Shed) | 2-4 (40-70% each) | Ranger Station, Campsite, Ridge |

### Key Items (No Inventory Slot)

| Item | Location | Guaranteed | Purpose |
|------|----------|-----------|---------|
| Fuel Canister | Cabin B workbench | 100% | Fuel extraction vehicle |
| Portable Lantern | Root Cellar | 100% | Temporary light source (optional tool) |

### Lore Items

| Item | Location | Content Summary |
|------|----------|----------------|
| Ranger Dispatch Log | Main Office desk | Search party arrival and timeline |
| Vehicle Maintenance Log | Garage dashboard | Directs player to Cabin B for fuel |
| Watchtower Observation Notes | Watchtower platform | Torres's entries, "stop counting" warning |
| Torres's Field Journal | Creek Bed pack | Torres's deterioration, mentions The Ring |
| Search Party Report | Campsite table | Team roster, Vasik's Blackpoint connection |
| Vasik's Letter (unsent) | Campsite tent | Personal stakes, references Blackpoint, directs to Cabin A |
| Vasik's Research Notes (1-5) | Cabin A walls | Core Watcher lore — observation mechanics, multiplication, The Ring, The Source |
| Vasik's Final Entry | Cabin A desk | "We are being felt for" — thematic thesis |
| Hunter's Trap Designs | Cabin B workbench | Mirror-trap concept, failure |
| Carved Message | Cabin C floor beam | "Go back down" — pre-human origin |
| Vasik's Audio Log | Root Cellar tape recorder | Bilateral observation, going to the cave |
| Blackpoint Emergency Broadcast | Cliff Edge marker | Blackpoint destruction, St. Maren's connection |
| Radio Log | Radio Tower console | Full transmission history, Vasik's final broadcast |
| Ring Petroglyphs | The Ring (auto-collect) | Symbol connection to Blackpoint/Seal |
| Cave Paintings (series) | Cave (optional) | See Cave section |

---

## Critical Path

```
SPAWN (Ranger Station Parking Lot)
    │
    ↓ (60s safe exploration)
RANGER STATION
    ├── Main Office: Get map, learn radio is dead, establish objective
    ├── Garage: Find vehicle, fuel gauge empty, establish fuel objective
    ├── Watchtower: Survey forest, see Watchers (optional but recommended)
    └── Supply Shed: First Watcher encounter (tutorial), loot
    │
    ↓ (Enter forest — 2 Watchers active)
FOREST TRAVERSE (South Trail → Cabin Cluster)
    │   Pass through Abandoned Campsite (waypoint, loot)
    │   Manage Watchers on trail (observe, navigate)
    │   Survive first fog event
    │
    ↓ (3 Watchers active)
CABIN CLUSTER
    ├── Cabin A: Read Vasik's research (lore, optional but narratively critical)
    ├── Cabin B: ██ GET FUEL CANISTER ██ (REQUIRED)
    │   └── (Picking up fuel → 4-5 Watchers active, Watcher spawns outside cabin)
    └── Cabin C: Lore (optional)
    │
    ↓ (4-5 Watchers active)
RIDGE ASCENT (North Trail → Ridge Trail)
    │   Narrow trail, limited observation angles
    │   Cliff Edge (optional — survey, lore)
    │   Cave Entrance (optional — high risk, lore reward)
    │
    ↓
RADIO TOWER
    ├── Reconnect power junction (3s)
    ├── Start generator (3-5 pulls)
    ├── Wait for radio boot (15s)
    └── ██ TRANSMIT EXTRACTION CALL ██ (REQUIRED)
        └── (Radio call complete → 6+ Watchers active, fog intensifies)
    │
    ↓ (6-8 Watchers, fog every 60-90s)
RETURN TO RANGER STATION (Full forest traverse, final gauntlet)
    │   Ridge → Cabin Cluster → South Trail → Ranger Station
    │   Most dangerous section of the level
    │
    ↓
RANGER STATION GARAGE
    ├── ██ FUEL VEHICLE ██ (8s interaction)
    ├── Start vehicle (cutscene)
    └── Drive out (semi-scripted, 45s)
    │
    ↓
EXTRACTION — LEVEL COMPLETE
```

### Alternate Routes

The open-world structure means the player can vary their approach:
- **Direct path:** Ranger Station → Cabin B (fuel) → Radio Tower → Ranger Station. Fastest, but traverses the most open terrain.
- **Perimeter path:** Follow forest edges, using dense woods for cover. Slower, but fewer Watcher encounters (fewer idle positions off-trail).
- **Ring refuge:** Use The Ring as a waypoint for rest and observation reset between objectives. Adds travel time but provides recovery opportunities.
- **Root Cellar staging:** Use Root Cellar as a staging point for the Cabin Cluster, managing approaches to each cabin individually.

---

## Timing

| Metric | Duration |
|--------|----------|
| Minimum completion (experienced, critical path only) | ~10 minutes |
| Average first completion (with deaths) | ~20-30 minutes |
| Full exploration (all lore, cave, all cabins, all areas) | ~35-45 minutes |
| Extraction driving sequence | 45 seconds |
| Time spent in fog (cumulative, average run) | 3-5 minutes |
| Time in safe zones (Ring, Root Cellar, Cabins — cumulative) | 2-4 minutes |

### Pacing Breakdown

| Segment | Duration (avg first run) | Tension Level |
|---------|--------------------------|---------------|
| Ranger Station exploration | 3-5 min | Low (orientation) |
| First forest traverse | 4-6 min | Building (first encounters) |
| Cabin Cluster exploration | 5-8 min | High (enclosed + Watchers outside) |
| Ridge ascent + Radio Tower | 4-6 min | Very High (narrow terrain, escalation) |
| Return traverse | 3-5 min | Maximum (final gauntlet) |
| Extraction sequence | 1-2 min | Cathartic (relief + spectacle) |

---

## Multiplayer Scaling

### Watcher Count Scaling

| Event | Solo | 2 Players | 3 Players | 4 Players |
|-------|------|-----------|-----------|-----------|
| Forest entry | 2 | 3 | 4 | 5 |
| Cabin Cluster | 3 | 4 | 5 | 6 |
| Post-fuel pickup | 4-5 | 5-6 | 7-8 | 8-9 |
| Post-radio call | 6 | 8 | 10 | 12 |
| Final gauntlet max | 8 | 10 | 12 | 14+ |

### Fog Scaling

| Parameter | Solo | 2 Players | 3 Players | 4 Players |
|-----------|------|-----------|-----------|-----------|
| Mid-level interval | 150-180s | 130-160s | 110-140s | 90-120s |
| Late-level interval | 120-150s | 100-130s | 80-110s | 60-90s |
| Final gauntlet interval | 60-90s | 50-80s | 40-70s | 30-60s |
| Fog duration | Base | +3s | +5s | +8s |

### Objective Scaling

| Objective | Solo | 2 Players | 3 Players | 4 Players |
|-----------|------|-----------|-----------|-----------|
| Generator pulls (Radio Tower) | 3-5 | 4-6 | 5-7 | 6-8 |
| Radio boot time | 15s | 20s | 25s | 30s |
| Vehicle fuel time | 8s | 10s | 12s | 15s |
| Extraction beacon wait | — | — | — | — |

### Multiplayer-Specific Mechanics

**Observation Coordination:**
The core multiplayer mechanic is dividing observation duty. With 2+ players, the group can watch in multiple directions simultaneously — each player's frustum independently freezes Watchers. This makes Watchers less dangerous per-encounter but the increased Watcher count ensures the math never works out: 4 players with ~70-degree FOV each cover ~280 degrees. The remaining 80 degrees is always unobserved. Watchers exploit gaps.

**Separation Events:**
| Trigger | Event | Duration |
|---------|-------|----------|
| First fog event with 2+ players | Players' flashlights die for different durations (one player loses light for 5s, others for 2s — the one in darkness is isolated) | 5 seconds |
| Enter Cabin Cluster with 3+ players | A cabin door slams shut and jams, trapping the player inside. Others must continue without their observation coverage. | 30 seconds |
| Radio Tower generator start | A rockslide blocks the Ridge Trail behind the tower. Players who haven't reached the tower are separated from those who have. | Until radio call complete |
| Final gauntlet (return traverse) | Fog events desynchronize — different players experience fog at slightly different times, creating windows where one player can see but another cannot. | Ongoing |

**Downed State Interaction:**
When a player is downed by a Watcher (3 pip damage), the Watcher stands over the downed player, frozen in the downed player's observation (the downed player can still look around). If the downed player loses consciousness (30-second bleedout timer), the Watcher kills them. Rescuing teammates must:
1. Approach within 5 studs (easy — but the Watcher is right there).
2. Keep the Watcher in their frustum while interacting with the downed player (3-second revive).
3. If a second Watcher approaches from behind the rescuer during the revive, the situation becomes nearly unrecoverable.

**Proximity Voice Interaction:**
Proximity voice range is 40 studs. Players beyond this range cannot communicate. During fog, players within voice range can coordinate ("I can see one at my 2 o'clock, can you watch my 6?"). During separation events, silence on voice chat communicates isolation more effectively than any UI element.

---

## The Cave — Optional Area

### Overview

The Cave is a high-risk, high-lore-reward optional area accessible from the Ridge, near the Cliff Edge. It functions as Level 4's equivalent to the Psychiatric Ward in Level 1 — the area you don't need to enter, but the story lives there.

### Entrance

A fissure in the rock face, 3 studs wide, 6 studs tall. Cold air flows outward. The flashlight beam penetrates 10 studs into the darkness, revealing natural stone walls, damp surfaces, and the beginning of a downward slope. A rope is tied to a rock at the entrance — Vasik's rope. It descends into the dark.

### Layout

```
CAVE ENTRANCE (Ridge)
    │
    ↓ (Rope descent — 4s committed animation, Vasik's rope)
UPPER CHAMBER (20x20 studs)
    │   Natural cavern. Stalactites. Pool of dark water (shallow).
    │   Watcher: 1, standing in the pool. Motionless. Reflected in the water.
    │
    ↓ (Narrow passage — crouch required, 10 studs long)
PAINTED CHAMBER (15x25 studs)
    │   Cave paintings on every wall. Ancient. Thousands of years old.
    │   Vasik's field equipment: camera, notebooks, measuring tools.
    │   Watcher: 1, standing in the far corner, facing the paintings.
    │   Its back is to the player. The only time a Watcher is not facing the player.
    │
    ↓ (Descent — steep slope, 20 studs, movement speed -30%)
THE DEEP (10x10 studs, terminal room)
        Lowest point in the level. The walls here are not natural stone —
        they are smooth, worked, carved. The same symbols as The Ring.
        The floor vibrates faintly. A low, rhythmic sound: not mechanical.
        Organic. Like breathing. Coming from below.
        Watcher: 2, flanking the entrance. The player enters between them.
        A flat wall at the far end bears a single large carving.
```

### Cave Watchers

The Watchers in the Cave behave differently:

- **They do not relocate toward the player.** Cave Watchers are stationary set pieces. They stand in fixed positions and do not move regardless of observation state. They are Watchers that have been frozen for a very long time — possibly centuries. Their surfaces are covered in mineral deposits and calcium growths. They are becoming part of the cave.
- **They still trigger Proximity Fear.** Walking past them ramps effects to Tier 2-3.
- **One exception:** The Watcher in the Upper Chamber, standing in the pool. If the player looks away from it and back, it has not moved — but its reflection in the pool has. The reflection is now closer. The reflection reaches the edge of the pool even as the Watcher remains stationary. The reflection is not bound by the same rules. **This is a visual-only scare and does not affect gameplay.**

### Cave Paintings — Lore Series

The Painted Chamber contains ancient cave art depicting the following scenes (described as lore items, auto-collected on observation):

**Painting 1 — The Seal**
> Primitive figures gathered around a circular shape in the ground. Lines radiate from the circle — energy, force, something contained. The figures are placing objects around the circle: stones? Symbols? Carvings? They are creating a boundary.

**Painting 2 — The Reaching**
> From the circle, dark shapes extend upward — like fingers pushing through fabric. The shapes are taller than the figures. They stand among the figures. The figures are looking at the shapes. The shapes are motionless. The figures are arrayed in a ring around them, always facing inward. Always watching.

**Painting 3 — The Forest**
> Trees grow over the circle. Time has passed — many generations. The trees are the same trees as the Ring. The dark shapes stand among the trees. More of them now. Many more. The painted figures are gone. The shapes remain.

**Painting 4 — The Descent**
> A single figure descends from the surface, following the dark shapes downward. Below the surface: the circle again, but larger. Beneath the circle: something. The painting does not depict what is beneath. The space below the circle is scratched out — gouged, as if someone tried to destroy this part of the painting. Or as if the painting itself refused to show what was there.

**Painting 5 — [Unfinished]**
> The final section of cave wall is blank. But there are traces of paint — as if a painting was begun and then removed. By whom? Vasik's notebook is open at the base of this wall. Her final written words: "It's not imprisoned. It's sleeping. The Seal doesn't hold it in. The Seal keeps it asleep. The Watchers aren't escapes. They're dreams. It's dreaming of reaching the surface. And if it wakes up—"
> The notebook entry ends. Vasik's pen is on the floor. Vasik is not here.

### The Deep — Terminal Room

**Description:** The smallest room. The walls are carved, not natural. The carvings match The Ring. The Seal. Sub-Level D at Blackpoint. The sub-basement at St. Maren's. This cave descends to the same layer. Everything connects underground.

The vibration here is tangible — the player's screen has a persistent subtle shake (Tier 1 effect, always on). The breathing sound is constant: a slow inhale (8 seconds), pause (4 seconds), slow exhale (8 seconds). The rhythm is perfectly regular. It is not the sound of a creature breathing. It is the sound of something much, much larger.

The far wall bears a carving: the same figure from The Ring's north tree — the circle with shapes outside. But here, the carving includes what is inside the circle. A single shape, larger than all others, with no features except two dark recesses. Like the Watchers. But this is not a Watcher. This is what the Watchers are extensions of. The source. The Origin.

**Gameplay Function:**
- Terminal lore reward. The player now understands the narrative architecture of the entire game: the thing beneath St. Maren's is not a creature — it is an ancient, sleeping entity. The Seal keeps it asleep. The Watchers are its dreams manifested. Level 5's objective (reach the Seal, choose to reinforce or break it) is now emotionally loaded with this knowledge.
- No combat, no interaction, no mechanic. The player walks in, reads the lore, and walks out. The room exists to make the player feel small.

### Cave Loot

| Item | Probability | Location |
|------|-------------|----------|
| Battery | 100% | Vasik's equipment bag (Upper Chamber) |
| Medkit | 100% | Vasik's equipment bag (Upper Chamber) |
| Lore: Cave Paintings 1-5 | 100% | Painted Chamber walls |
| Lore: Vasik's Final Notebook Entry | 100% | Painted Chamber floor |

### Risk Assessment

The Cave itself is low-danger (Watchers inside are frozen set pieces). The danger is opportunity cost and re-entry:
- **Opportunity cost:** Time spent in the Cave is time the fog timer advances, and Watchers outside continue to escalate.
- **Re-entry:** The Cave entrance is on the Ridge. Entering requires the rope descent (4s committed animation, no observation). Exiting requires climbing back up (6s committed animation, no observation). During these animations, all exterior Watchers can move freely. The player emerges from the Cave into whatever has gathered at the entrance while they were underground.
- **Recommended timing:** Enter the Cave BEFORE completing the Radio Tower objective (Watcher count is lower, fog is less frequent). After the radio call, the Cave is significantly more dangerous to reach and exit.

---

## Proximity Fear Modifications

Level 4 modifies the standard Proximity Fear System to account for the Watchers' unique behavior:

### Modified Distance Tiers

| Tier | Standard Distance | Level 4 Distance | Rationale |
|------|-------------------|-------------------|-----------|
| 0 — SAFE | 80+ studs | 60+ studs | Open environment, threats visible at range |
| 1 — UNEASE | 50-80 | 40-60 | Watchers are visible but distant |
| 2 — DREAD | 25-50 | 20-40 | Watcher is within two "blinks" of kill range |
| 3 — PANIC | 10-25 | 8-20 | Watcher is within one "blink" of kill range |
| 4 — PROXIMITY | 0-10 | 0-8 | Kill imminent |

### Multi-Watcher Proximity

The Proximity Fear System in Level 4 accounts for **multiple Watchers**. The system uses the **nearest Watcher distance** as the primary tier, but applies a **presence multiplier** based on total Watchers within 60 studs:

| Watchers Within 60 Studs | Multiplier | Effect |
|--------------------------|------------|--------|
| 1 | 1.0x | Standard tier effects |
| 2 | 1.2x | Effects at one tier higher than distance suggests |
| 3 | 1.4x | Two tiers higher (capped at Tier 3) |
| 4+ | 1.6x | Permanent Tier 3 minimum, Tier 4 at 15 studs |

This means: even if no single Watcher is close, being surrounded by 4 Watchers at 50 studs produces Tier 3 PANIC effects. The player cannot relax in a crowd.

### Fog Interaction with Fear

During fog events, the Proximity Fear System behaves differently:
- Watchers hidden by fog still contribute to the fear calculation (the system knows where they are even if the player cannot see them).
- The fog itself adds a flat +0.5 tier to all fear calculations (UNEASE becomes DREAD, DREAD becomes PANIC).
- This means fog + hidden Watchers can produce Tier 3-4 effects even when the player cannot see any threat. The player feels the dread without knowing why. This is intentional — it mirrors the character's awareness that something is closing in.

### Level 4 Subliminal Flashes

The subliminal flash content for Level 4 is unique:
- A Watcher's face, extreme close-up, static-distorted (standard).
- The player's own back, as if viewed from directly behind them (someone is watching them from behind).
- A brief frame of a Watcher mid-movement — the one thing the player never sees in gameplay. The subliminal shows a Watcher in a blurred, motion-smeared transitional state. A glimpse of what they look like when they move. It is wrong. The shape is wrong. It is not walking. It is unfolding.
- An aerial view of the forest showing dozens of Watchers among the trees (revealing the true count — far more than the player encounters in gameplay).

---

## Audio Design Notes

### Ambient Soundscape

Level 4's audio design inverts all prior levels. Levels 1-3 have rich ambient soundscapes (hospital hum, subway echoes, lab ventilation). Level 4 has **silence**. The forest produces almost no ambient audio. This is the most unsettling audio design choice in the game.

| Element | Audio Treatment |
|---------|----------------|
| Wind | Absent at ground level. Present only on the Ridge and Watchtower. |
| Wildlife | None. No birds, insects, or animals. Complete biological silence. |
| Trees | No rustling. No creaking. The trees are motionless regardless of conditions. |
| Player footsteps | Unusually prominent in the mix. The player's own movement is the loudest sound. |
| Water (Creek Bed) | Only persistent ambient sound in the forest. Mixes with fog horn and Watcher movement audio. |
| Watchers (movement) | Stone-on-stone grinding. Brief (0.3s). Spatialized to new position. Radius: 8 studs. Masked by water/fog audio. |
| Watchers (stationary) | Dead silence. They produce no ambient sound. No breathing, no hum, no presence. Their silence is their audio signature. |
| Fog horn | Low, resonant, distant. 3-second duration. Non-directional. Signals fog onset. |
| Forest silence | The absence is mixed — a very faint, almost subliminal low-frequency room tone that communicates "this quiet is wrong." |

### Entity Audio — The Stone-Grinding Sound

The Watcher movement sound is critical and must be carefully designed:

- **Source:** Rough stone dragging against rough stone. Not grinding gears, not scraping metal. Organic mineral friction.
- **Duration:** 0.3 seconds per relocation. Brief enough to question whether you heard it.
- **Spatialization:** 3D spatial audio, positioned at the Watcher's NEW position. The player hears the sound where the Watcher is NOW, not where it was.
- **Variations:** 5-6 variations of the base sound to prevent recognition fatigue. Subtle pitch and timbre differences.
- **Radius:** 8 studs in normal conditions. 5 studs during fog (fog dampens sound). 12 studs in enclosed spaces (caves, cabins — reverberation).
- **Layering:** When multiple Watchers relocate simultaneously (common during fog), the sounds layer. 3+ simultaneous relocations create an unsettling chorus of grinding from multiple directions.

### Music

Level 4 has minimal composed music. The score is sparse, textural, and functions more as an extended sound design piece than a traditional soundtrack.

| Situation | Music Treatment |
|-----------|-----------------|
| Ranger Station | Faint, warm low drone — the last "safe" music in the level. Fades to nothing when the player enters the forest. |
| Forest traversal (clear) | Silence. No music. For up to 2-3 minutes of gameplay, the only sounds are the player's footsteps. |
| Watcher observation (close) | A held, dissonant string note. Single pitch. Enters at Tier 2, sustains through observation. Fades when Watcher is 40+ studs away. |
| Fog events | Low brass swell during the warning horn. During full fog: layered whispers (nonsense syllables, not words). |
| The Ring | A subtle, ancient-sounding tone — a resonance, as if the trees themselves are vibrating at a low frequency. Neither comforting nor threatening. Alien. |
| The Cave | Subsonic rumble (the breathing). Above it: a crystalline, high-frequency shimmer — the sound of the mineral-encrusted Watchers resonating. |
| Extraction drive | Building orchestral tension. The only full musical piece in the level. Crescendo as Watchers line the road. Cuts to silence when the player exits the forest. |

---

## Technical Notes

### Server Authority

- All Watcher positions, observation calculations, and relocation logic run server-side.
- The client sends camera direction (frustum data) to the server each frame.
- The server determines which Watchers are observed by which players and processes relocations accordingly.
- Anti-cheat: camera direction must be consistent with input (mouse/stick movement). Snapping the camera 180 degrees in one frame is flagged.

### Observation Calculation

```
-- Pseudocode for observation check (runs server-side per Watcher per player per tick)
function IsObserved(watcher, player)
    local distance = (watcher.Position - player.Camera.Position).Magnitude
    if distance > MAX_OBSERVATION_RANGE then return false end

    -- Fog check
    if FogSystem:IsActive() then
        local fogVisibility = FogSystem:GetVisibility()
        if distance > fogVisibility then return false end
    end

    -- Frustum check
    local direction = (watcher.Position - player.Camera.Position).Unit
    local cameraForward = player.Camera.CFrame.LookVector
    local angle = math.acos(direction:Dot(cameraForward))
    if angle > HALF_FOV then return false end

    -- Occlusion check (raycast)
    local ray = workspace:Raycast(player.Camera.Position, direction * distance, rayParams)
    if ray and ray.Instance ~= watcher.Model then return false end

    return true
end
```

### Performance Considerations

- Raycast occlusion checks are the most expensive operation. With 6-14 Watchers and 1-4 players, worst case is 56 raycasts per tick.
- Optimization: only run full occlusion checks for Watchers within MAX_OBSERVATION_RANGE. Watchers beyond range skip the frustum and raycast checks entirely.
- Fog visibility check is a simple distance comparison — nearly free.
- Watcher relocation is a single position set per server tick — no pathfinding required (they teleport, not navigate). Validate new position against NavMesh with a single query.
- The fog visual effect is client-side (Atmosphere.Density manipulation). Server sends fog state (active/inactive, density) to clients.

### Watcher Model

- Single mesh, no skeletal rig (no animations except head rotation for counting event).
- LOD: 2 levels. High-detail within 30 studs (visible surface texture, eye recesses). Low-detail beyond 30 studs (silhouette only — which is more frightening).
- No shadow casting. Watchers do not cast shadows. This is intentional and subtly wrong — the player may not consciously notice, but the absence of a shadow on a moonlit night is a subliminal unsettling detail.
- Collision: Watchers have collision when frozen (the player cannot walk through them). During relocation (server-side, instant), collision is temporarily disabled.

### Fog Implementation

- Uses Roblox `Atmosphere` service: `Density`, `Offset`, `Decay`, `Glare`, `Haze` properties.
- Fog state is a server-authoritative timer. Server sends fog phase (clear / warning / onset / full / dissipation) to clients.
- The Ring fog exclusion is achieved via a local `Atmosphere` override within the Ring's bounding volume (custom zone, not default Atmosphere — requires a clear-atmosphere zone inside the fog zone).
- Fog visibility distance for observation calculations is synced from server (determines which Watchers count as occluded by fog).

### Open World Streaming

- Level 4 is the largest level in the game (~600x600 studs). Streaming is required.
- Use Roblox StreamingEnabled with StreamingIntegrity set to PauseOutsideLoadedArea.
- Watcher models are always streamed (priority streaming) — the player must never have a Watcher "pop in" due to streaming lag. Watchers that appear suddenly must be intentional relocations, not loading artifacts.
- Terrain and tree models use standard streaming distances. Trees beyond 200 studs are LOD0 (flat cards).

---

## Appendix: Watcher Spawn Position Map

```
Legend:
  W = Watcher idle position (probability-weighted)
  T = Trail
  ◯ = Landmark
  ~ = Creek
  o = Ring tree

                              ◯ Radio Tower
                             W  W
                              │
                        ◯ Cliff Edge
                          W  │
                             T (Ridge Trail)
                          W  │  W
                             │
              W    W    ◯ Cabin Cluster    W
                        │ A │ B │ C │
                    W   └───┴───┴───┘   W
                              │
                W        ◯ Clearing        W
                         W ·  ·  · W
               W    W       ·  ·        W
                         o o o o o
              W         o  THE   o
                       o  RING    o       W
              W         o        o
                         o o o o o
                    W                  W
                   ◯ Campsite
                W    │    W
              ~~~~~~~│~~~~~~~  ◯ Creek
             ~ ~  W  T  W  ~ ~
              ~~~~~~~│~~~~~~~
                     │
                W    T    W
                     │
              ◯ Ranger Station
```

Position weights (probability of a given Watcher idling at each zone):
- Trail-adjacent (T): 60%
- Cabin perimeter: 15%
- Dense woods: 15%
- Clearing edge: 5%
- Creek bank: 3%
- Ridge: 2%

Watchers never idle inside: The Ring, cabin interiors (door closed), Root Cellar, Cave interior, Ranger Station compound (first 60s), the Clearing interior.
