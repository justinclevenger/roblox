# Level 5: The Origin (Beneath St. Maren's Hospital) — Detailed Design

## Table of Contents

- [Narrative Setup](#narrative-setup)
- [Map Layout](#map-layout)
- [Area-by-Area Details](#area-by-area-details)
  - [Entry](#entry)
  - [Upper Catacombs](#upper-catacombs)
  - [The Warren](#the-warren)
  - [The Sanctuary](#the-sanctuary)
  - [Extraction / Collapse Sequence](#extraction--collapse-sequence)
- [Entity Zones & Evolved Forms](#entity-zones--evolved-forms)
- [The Warren — Procedural Generation Design](#the-warren--procedural-generation-design)
- [The Seal — Choice Design](#the-seal--choice-design)
- [The Collapse / Timed Escape](#the-collapse--timed-escape)
- [The Throne / The Original Entity](#the-throne--the-original-entity)
- [Scripted Events](#scripted-events)
- [Loot Table Summary](#loot-table-summary)
- [Critical Path](#critical-path)
- [Timing](#timing)
- [Multiplayer Scaling](#multiplayer-scaling)
- [Lore Payoff](#lore-payoff)

---

## Narrative Setup

The player descends through the sub-basement door of St. Maren's Hospital — the same sealed steel door they first encountered in Level 1, the one that knocked from the other side. Four levels of escalating threat have led here. The hospital, the subway, the research station, the forest — all of them are symptoms. Level 5 is the disease.

### What Is The Origin?

Beneath St. Maren's Hospital lies a catacomb network that predates the hospital by centuries. Before the hospital was built in 1923, before the town of St. Maren existed, there was a chapel on this ground. Before the chapel, a monastery. Before the monastery, a site that predates written record. Every civilization that settled here did the same thing: they built downward. They built walls. They built seals. They were all trying to contain the same thing.

The Origin is not an entity. It is a wound — a place where the boundary between what is real and what is not has worn thin. The entities the player has faced across all five levels are not creatures that escaped; they are expressions of what leaks through the wound. The Patient is its loneliness. The Crawlers are its hunger. The Mimic is its deception. The Watchers are its attention. None of them are the thing itself. The thing itself sits on a throne in the deepest chamber, and it has been sitting there since before anyone built the first wall around it.

### Why Now?

Project ECHO — referenced in Level 3's Blackpoint Research Station — was a government-funded program to study the anomalous readings beneath St. Maren's. They drilled. They sampled. They breached the outer seal in 1987. What leaked out manifested first as Patient 31 — a man admitted to the psychiatric ward who stopped being a man. The entities multiplied. Blackpoint tried to contain them. The Watchers appeared in the forest when containment failed. By the time the hospital was evacuated, the seal had degraded further.

The player has been following the chain: Patient 31 led to the Crawlers in the subway (the subway tunnels intersect the catacomb network). The Mimic emerged at the research station built to study the phenomenon. The Watchers appeared at the surface perimeter, the outermost ring of influence. Now the player goes to the center. To the source. To the Seal itself.

### The Choice

The Seal can be reinforced or destroyed. Reinforcing it means containing the wound — shoving the boundary back into place, hoping the walls hold for another century. Destroying it means obliterating the wound entirely — collapsing the catacomb network, burying the site, ending it permanently. But destroying it means the structure comes down on everything, including whoever is still inside. The stakes of the choice are real. Reinforcing is the safer path but offers no guarantee. Destroying is the permanent solution but demands a price.

Both paths trigger a timed collapse. But they feel different. One is an escape. The other is a sacrifice.

---

## Map Layout

### Vertical Descent Structure

```
SURFACE — St. Maren's Hospital, Basement
    │
    │  Sub-Basement Door (from Level 1)
    │
    ▼
UPPER CATACOMBS (Depth: -1 to -3 floors)
    │
    │  Stone Corridors → Burial Chambers → Flooded Gallery → Chapel
    │  Linear with branching side rooms. Hand-authored.
    │
    ▼
THE WARREN (Depth: -3 to -6 floors)
    │
    │  Semi-procedural tunnel network. Different each run.
    │  Branching Tunnels → Echo Chambers → Mirror Room → The Narrow
    │  Graph-based generation with hand-authored tile sets.
    │
    ▼
THE SANCTUARY (Depth: -6 to -7 floors)
    │
    │  Central Chamber → Pillar Hall → The Throne → The Seal
    │  Hand-authored. Fixed layout. Cathedral scale.
    │
    ▼ (THEN REVERSAL)
EXTRACTION — ASCENT (All zones in reverse, collapsing)
    │
    │  Sanctuary → Warren (shortened) → Catacombs (altered) → Surface
    │
    ▲
SURFACE — Hospital Basement → Ground Floor → Exterior
```

### Horizontal Flow (Top-Down Approximation)

```
                    ┌─────────────────────────────────────┐
                    │       SUB-BASEMENT DOOR (ENTRY)      │
                    └─────────────────┬───────────────────┘
                                      │
              ┌───────────────────────┼───────────────────────┐
              │                 UPPER CATACOMBS                │
              │                                                │
              │   ┌──────────┐    ┌──────────┐                │
              │   │ STONE    ├────┤ BURIAL   │                │
              │   │CORRIDORS │    │CHAMBERS  │                │
              │   └────┬─────┘    └────┬─────┘                │
              │        │               │                       │
              │   ┌────┴───────────────┴─────┐                │
              │   │    FLOODED GALLERY        │                │
              │   │    (waist-deep water)     │                │
              │   └────────────┬──────────────┘                │
              │                │                               │
              │   ┌────────────┴──────────────┐                │
              │   │    DESECRATED CHAPEL      │                │
              │   │    (lore hub / gate)       │                │
              │   └────────────┬──────────────┘                │
              └────────────────┼───────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │   DESCENT PASSAGE   │
                    │  (one-way drop)     │
                    └──────────┬──────────┘
                               │
     ┌─────────────────────────┼─────────────────────────┐
     │                    THE WARREN                       │
     │              (Semi-Procedural Zone)                  │
     │                                                     │
     │   ┌───┐ ┌───┐ ┌───┐                               │
     │   │ T ├─┤ T ├─┤ T │  ← Branching Tunnels          │
     │   └─┬─┘ └─┬─┘ └─┬─┘    (graph-generated)          │
     │     │     │     │                                   │
     │   ┌─┴─────┴─────┴─┐                               │
     │   │ ECHO CHAMBERS  │  ← Sound loop zones           │
     │   └───────┬────────┘                               │
     │           │                                         │
     │   ┌───────┴────────┐                               │
     │   │  MIRROR ROOM   │  ← Mimic territory            │
     │   └───────┬────────┘                               │
     │           │                                         │
     │   ┌───────┴────────┐                               │
     │   │  THE NARROW    │  ← Crawlspace, forced crouch  │
     │   └───────┬────────┘                               │
     └───────────┼─────────────────────────────────────────┘
                 │
      ┌──────────┴──────────┐
      │  THRESHOLD GATE     │
      │  (point of no       │
      │   return marker)    │
      └──────────┬──────────┘
                 │
     ┌───────────┼─────────────────────────────────────────┐
     │                  THE SANCTUARY                       │
     │                                                     │
     │   ┌─────────────────────────────────────┐           │
     │   │        CENTRAL CHAMBER              │           │
     │   │  (underground cathedral, massive)   │           │
     │   └──────────────┬──────────────────────┘           │
     │                  │                                   │
     │   ┌──────────────┴──────────────────────┐           │
     │   │          PILLAR HALL                 │           │
     │   │  (Watchers among columns)           │           │
     │   └──────────────┬──────────────────────┘           │
     │                  │                                   │
     │        ┌─────────┴──────────┐                       │
     │        │    THE THRONE      │                       │
     │        │  (The Original     │                       │
     │        │   Entity)          │                       │
     │        └─────────┬──────────┘                       │
     │                  │                                   │
     │        ┌─────────┴──────────┐                       │
     │        │     THE SEAL       │                       │
     │        │  [CHOICE POINT]    │                       │
     │        │  Reinforce / Break │                       │
     │        └────────────────────┘                       │
     └─────────────────────────────────────────────────────┘
```

### Zone Connectivity Summary

| Zone | Connects To | One-Way? | Notes |
|------|------------|----------|-------|
| Entry (Sub-Basement Door) | Stone Corridors | No (until Collapse) | Players can retreat to hospital basement during catacombs |
| Stone Corridors | Burial Chambers, Flooded Gallery | No | Main catacomb hub |
| Burial Chambers | Stone Corridors | No | Side area, loops back |
| Flooded Gallery | Stone Corridors, Desecrated Chapel | No | Connects upper section to chapel |
| Desecrated Chapel | Flooded Gallery, Descent Passage | No → Yes | Chapel is gate; descent is one-way drop |
| Descent Passage | The Warren entry | Yes (drop) | ~3 stud drop, no return without collapse route |
| Warren (procedural) | Internal connections vary | Varies | Always solvable, always different |
| The Narrow | Warren tunnels, Threshold Gate | Forward only | Crawlspace forces commitment |
| Threshold Gate | The Sanctuary | Yes | Point of no return. Door seals behind. |
| Central Chamber | Pillar Hall | Both | Open architecture |
| Pillar Hall | The Throne | Both | Must cross to reach Throne |
| The Throne | The Seal | Both | Adjacent chambers |
| The Seal | Triggers Collapse | — | Choice triggers escape sequence |

---

## Area-by-Area Details

### Entry

**Through the Sub-Basement Door**

The same sealed steel door from Level 1's basement. In Level 1, it was bolted shut with a "RESTRICTED" stencil and knocked once if the player lingered. After completing Level 4, the locks have rusted through and the door hangs ajar. A cold draft pushes through from below.

**Description:**
A short industrial stairwell — poured concrete, fluorescent tube lights that buzz and die one by one as the player descends. Water stains on walls. The architecture transitions within 20 steps from 20th-century hospital infrastructure to older brickwork, then to rough-hewn stone. The last fluorescent light pops at the bottom of the stairs. From here, only the flashlight.

**Atmosphere:**
- Temperature shift — visible breath effect begins
- Hospital ambient sounds (HVAC hum, distant beeping) fade to nothing over 10 seconds
- Replaced by dripping water, stone echo, deep silence
- The sub-bass drone from the Proximity Fear System begins at Tier 0 — but it never fully disappears in Level 5. The baseline dread is permanent.

**Gameplay Function:**
- Transition zone. No enemies. 30 seconds of atmospheric descent.
- The player can retreat up these stairs during the Upper Catacombs section only. Once they enter the Warren, the catacombs become inaccessible until the Collapse Sequence.
- A small alcove at the base of the stairs contains a supply cache (the last easy loot in the level).

**Loot:**
- `1x Battery [guaranteed]`
- `1x Bandage [guaranteed]`
- `Lore: Excavation Log, 1987` — Blackpoint team notes on breaching the outer wall. "The drill bit came back wrong. The metal was fused. Dr. Harlan says it's molecular restructuring. I say the wall didn't want to be opened."

---

### Upper Catacombs

The Upper Catacombs are a hand-authored zone. Fixed layout, no procedural elements. This is the level's teaching zone — it reintroduces entity encounters in a controlled environment before the Warren strips away all predictability.

#### Stone Corridors

**Description:**
Rough-hewn stone passageways, 3-4 studs wide, 4 studs tall. The walls bear chisel marks from tools that predate modern metalwork. Alcoves cut into the walls at irregular intervals — some hold crumbled stone, some hold bones. The floor is uneven flagstone with accumulated grit that crunches underfoot. Torches in iron sconces line the walls at long intervals — they are unlit, but the sconces are not rusted. Someone maintained them.

Periodic archways mark intersections. Carved symbols above each arch — not any known language, but recurring across all archways. The same symbols appear in Patient 31's cell in Level 1 (the phrase repeated thousands of times on the padded walls).

**Atmosphere:**
- Flashlight beam catches dust motes constantly — particles drift in the beam, creating a visible cone of light
- Sound carries unpredictably — footsteps echo from wrong directions due to corridor geometry
- Ambient: distant dripping, settling stone, occasional deep groan (structural, not entity)
- Temperature: cold. Visible breath effect throughout.

**Gameplay Function:**
- Hub corridor connecting all Upper Catacomb sub-areas
- Three-way intersection at center: left to Burial Chambers, straight to Flooded Gallery, right loops back to a dead end with loot
- Corridor width supports hiding behind alcove pillars (press against wall, entity walks past if flashlight is off)
- The Patient (Evolved) begins patrolling here 45 seconds after the player enters the Catacombs

**Loot:**
- `1x Battery [50%]` — in a leather satchel wedged behind a stone block near the dead-end branch
- `Lore: Monastery Journal Fragment` — Latin text (translated in UI): "Brother Aldric writes that the singing from below has stopped. He says this is cause for relief. I say it is cause for greater concern. The singing meant it was still contained. The silence means it has found another way."

**Entity Presence:**
- The Patient (Evolved) — primary patrol zone
- Patrols the full corridor loop on a ~90-second cycle
- Sound propagation through corridors is extended — footsteps carry 50 studs instead of the usual 40

---

#### Burial Chambers

**Description:**
A series of interconnected rectangular rooms carved from the stone, each approximately 8x12 studs. The walls are lined with horizontal burial niches — rectangular slots cut into stone, 3 rows high, most sealed with crumbling mortar. Some are open: empty, or containing skeletal remains wrapped in degraded cloth. Each chamber connects to the next through low archways (player must crouch briefly to pass — 0.5s animation).

The deepest chamber contains a stone sarcophagus in the center, its lid displaced. Inside: empty, but the interior surface is covered in the same symbols from the corridors. Scratch marks on the inside of the lid.

**Atmosphere:**
- Near-total darkness. Flashlight range feels shorter here (visual trick — fog density increased, not actual range reduction)
- Complete silence except for the player's own sounds
- The burial niches create deep geometric shadows that the flashlight can't fully resolve
- One niche, randomly selected each run, has a hand visible at the edge of the opening. It withdraws when the flashlight beam crosses it. No entity. No damage. Just a hand.

**Gameplay Function:**
- Primary hiding area in the Catacombs. The open burial niches function as hiding spots — player climbs into one and pulls a stone slab partway across the opening.
- The Patient checks these hiding spots with medium frequency (50% check rate from the start — no learning grace period. Level 5 assumes mastery).
- Low archway transitions between chambers create natural chokepoints — the player is vulnerable during the crouch animation.
- The deepest chamber is a dead end. High-value loot but requires backtracking through the Patient's patrol zone.

**Hiding Spots:**
- 8 burial niches (2 per chamber, 4 chambers) — crouch-enter interaction, partially sealed from inside
- Stone sarcophagus (deepest chamber only) — climb inside, pull lid. Risky: loud stone scraping sound on entry/exit. The Patient will hear from 35 studs.

**Loot:**
- `1x Medkit [guaranteed]` — inside the sarcophagus (reward for the risk)
- `1x Battery [40%]` — in a niche in the second chamber
- `1x Flare [30%]` — on the floor of the third chamber
- `Lore: Blackpoint Field Report` — found on a modern clipboard next to the sarcophagus. "Subject recovered from primary sarcophagus shows zero cellular decay despite estimated interment of 400+ years. Tissue samples resist all analysis. Recommend immediate transfer to Coastal Facility." (This is Patient 31. This is where they found him.)

**Entity Presence:**
- The Patient (Evolved) — extends patrol into outer two chambers frequently, inner two chambers occasionally
- The hand in the burial niche is not an entity. It has no collision, no AI, no damage. It is atmospheric only. It is never explained.

---

#### Flooded Gallery

**Description:**
A long, vaulted gallery — 6 studs wide, 5 studs tall at the apex of the arch, extending ~60 studs in length. The floor descends gradually over the first 15 studs until the water begins. Murky, dark water — waist-deep on the player character (approximately 2.5 studs). Visibility below the waterline is zero. The water is cold; the visible breath effect intensifies here.

Stone columns rise from the water at 10-stud intervals, supporting the vaulted ceiling. Debris floats on the surface — wood fragments, cloth, unidentifiable matter. At the far end, a set of stone steps rises out of the water to the Desecrated Chapel entrance.

The water is not still. It ripples. Something moves beneath the surface.

**Atmosphere:**
- Water sounds dominate: sloshing with every step, dripping from the ceiling, distant gurgling from drainage channels
- The flashlight beam reflects off the water surface, creating moving light patterns on the ceiling and walls
- Underwater sound design: when the player enters the water, a low-pass filter engages on all audio — everything sounds muffled, submerged. Surface sounds (dripping, echoes) become distant. The player's own wading sounds become dominant.
- Periodic ripple events: water surface disturbs 10-20 studs from the player. No visible source. Frequency increases as the player nears the center of the gallery.

**Gameplay Function:**
- Wading through water is LOUD. Walking speed produces 30-stud sound radius (up from 12). Crouching is not possible (water level). Sprinting is not possible (water resistance). The player is locked to a slow wade — louder than walking, slower than walking, no sprint, no crouch. Maximum vulnerability.
- The Crawlers (Evolved — Aquatic Variant) inhabit this zone. They move beneath the water surface. The player cannot see them. The only warning is ripples converging on the player's position.
- Columns provide partial cover — the player can press against a column to break line of sight, but the Crawlers navigate by hearing in this zone, not vision. Staying still reduces sound output. Moving is necessary to progress. The tension is in the pace.
- A submerged side passage (fully underwater, 3 studs long) connects to a small dry alcove with high-value loot. Entering requires the player to go fully underwater for ~2 seconds (screen submerges, audio fully muffled, disorienting). The alcove is safe — no entity access.

**Loot:**
- `1x Battery [guaranteed]` — on a stone shelf at the gallery midpoint, above water level
- `1x Bandage [guaranteed]` — on the steps at the far end
- `1x Flare [guaranteed]` — in the submerged side alcove (reward for underwater risk)
- `1x Medkit [50%]` — in the submerged side alcove
- `Lore: Water-Damaged Journal` — partially legible. "The water rose when they opened the lower chambers. Not groundwater. It came from inside. It's warm deeper down, even though it shouldn't be. Harlan says the water is a defense mechanism. A barrier. We're draining it anyway."

**Entity Presence:**
- Crawlers (Evolved — Aquatic Variant) — 2-3 individuals
- Submerged. Not visible above waterline.
- Navigate by hearing only in this zone (vision disabled due to water)
- Attack pattern: converge on sound source, surface within 3 studs, lunge. 1 health pip damage per hit.
- Ripple warnings: 3-5 seconds before attack, visible ripple trail approaches player position
- Standing still for 5+ seconds causes them to lose tracking and resume idle (circling at distance)
- The player must move-stop-move-stop through the gallery. Pure tension pacing.

---

#### Desecrated Chapel

**Description:**
A stone chapel approximately 20x30 studs, with a vaulted ceiling reaching 8 studs at center. Originally a place of worship — now inverted. The altar at the far end has been flipped. The cross behind it hangs upside-down. Pews are arranged in a circle rather than rows, facing inward toward a depression in the center of the floor. The depression is a shallow basin, 4 studs in diameter, stained dark. The stain extends outward from the basin in branching patterns that follow the mortar lines between flagstones, like veins.

The walls bear frescoes — damaged, faded, but visible under flashlight examination. They depict a sequence:

1. People discovering a cave
2. Something emerging from the cave
3. People building walls around it
4. The walls failing
5. People building deeper walls
6. The cycle repeating, each iteration deeper
7. The final panel: a figure seated on a throne, surrounded by smaller figures that resemble the four entity types

Stained glass windows (underground — they depict scenes, not transmit light) line the upper walls. Each window shows one of the entity types in a stylized, almost religious iconographic rendering. They are being worshipped.

**Atmosphere:**
- The warmest room in the Catacombs. No visible breath. This should feel wrong — underground stone should be cold.
- Candles are lit. Dozens of them, on every surface. They should not be lit. No one has been here.
- The audio environment shifts — the ambient drone from the Proximity Fear System modulates here, even at Tier 0. A low, almost tonal hum, as if the room itself resonates.
- No entity sounds. The Patient does not enter this room. The Crawlers do not enter this room. Nothing hunts here. The absence of threat is itself unsettling.

**Gameplay Function:**
- Lore hub. This is where the player receives the narrative context for Level 5's objective. The frescoes and documents found here explain the cycle: discover, breach, contain, fail, build deeper. The player understands they are about to reach the deepest point.
- Safe room (no entity presence). Players can recover stamina, manage inventory, read lore. The last true safe space in the level.
- Gate to the Warren: the Descent Passage is accessed through a broken section of the chapel floor behind the inverted altar. A rough-hewn staircase descends into darkness. This is a one-way transition — a 3-stud drop at the bottom prevents climbing back up.
- Interactive element: the basin in the center. Examining it triggers a vision — a 5-second screen distortion showing the chapel as it was (intact, worshippers present, the basin full of dark liquid, a figure standing at the altar with its back to the viewer). The vision ends abruptly. The candles are out. They relight over 3 seconds.

**Loot:**
- `Lore: Chapel Fresco Notes` — player character's internal monologue describing each fresco panel (auto-collected on examining each panel, 7 entries)
- `Lore: Father Maren's Confession` — on the inverted altar. "I built the hospital above the monastery. I built the monastery above the chapel. I built the chapel above the seal. Each generation builds higher, trying to forget what is below. My name is on the building. My sin is underneath it. God forgive me, I heard it speak my name last night, and I answered."
- `1x Battery [guaranteed]` — on a pew
- `1x Bandage [guaranteed]` — in a stone alcove near the descent passage

**Entity Presence:**
- None. The chapel is a sanctuary. Entities will not enter. This is never explained and should not be. The player simply notices that pursuit stops at the chapel threshold. In co-op, veteran players will learn to retreat here — but the chapel is far from the objective, making it a strategic choice rather than an exploit.

---

### The Warren

The Warren is the level's signature zone — a semi-procedural tunnel network that changes layout each run. It represents the transition from the known (the hand-authored Catacombs) to the unknowable (the procedural labyrinth). The design goal is disorientation. Even experienced players cannot memorize the Warren. They must navigate it fresh every time.

See [The Warren — Procedural Generation Design](#the-warren--procedural-generation-design) for technical implementation details.

#### Branching Tunnels

**Description:**
The primary connective tissue of the Warren. Narrow tunnels (2.5-3 studs wide, 3.5 studs tall) carved from rough stone. The tunnels branch, intersect, loop, and dead-end according to the procedural generation rules. The visual language is consistent — rough stone walls, occasional timber shoring, dripping water — but the topology changes every run.

Tunnels vary in character:
- **Standard tunnels:** Stone walls, flat floor, 3 studs wide. Basic traversal.
- **Collapsed tunnels:** Partially caved in. Must crouch to pass through debris. Slower, louder.
- **Flooded tunnels:** Ankle-deep water. Increased sound radius (+10 studs). Not deep enough for aquatic Crawlers.
- **Shaft tunnels:** Short vertical transitions (ladders, 1-stud drops). Connect between the Warren's internal elevation layers.

**Atmosphere:**
- Disorientation is the primary atmospheric goal. The tunnels look similar enough that the player cannot easily build a mental map.
- The ambient soundscape shifts subtly between tunnel segments — some have dripping, some have air movement, some have a faint scraping sound from behind the walls.
- Dead-end tunnels sometimes have a faint glow at the far end that resolves into nothing when approached — the light is a procedurally placed false landmark.
- Graffiti appears on walls — modern spray paint, not ancient. "TURN BACK." "IT KNOWS." "3RD LEFT THEN RIGHT THEN LEFT" (the directions are wrong 50% of the time; they are correct 50% of the time — the player can never be sure).

**Gameplay Function:**
- Navigation challenge. The player must find the path from the Warren entry to the Warren exit (which leads to The Narrow, then the Sanctuary). The path always exists but is never obvious.
- Multiple routes exist per generation, but most lead to dead ends or loops. The correct path is neither the shortest nor the most obvious.
- Small environmental cues guide attentive players: airflow direction (particle effects drift toward the exit), faint warmth (the deeper areas are warmer — the screen color temperature shifts slightly), and structural changes (tunnels closer to the exit have more carved symbols, less raw stone).
- Entity encounters in the tunnels are claustrophobic. The narrow width means the player cannot pass an entity — they must flee, hide, or find an alternate route.

**Loot:**
- Loot spawns are placed by the procedural system at dead ends and junction rooms (see Procedural Generation section).
- Per run: `2-3x Battery`, `1-2x Bandage`, `0-1x Flare` distributed across the Warren tunnel network
- Lore items are fixed to specific tile types (see below) — not every tile type appears every run, so lore collection across the Warren requires multiple playthroughs.

**Entity Presence:**
- The Mimic (Evolved) — primary Warren threat
- The Patient (Evolved) — occasionally penetrates the outer Warren tunnels, does not go deep
- Entity spawn points are placed by the procedural system at distance thresholds from the player's entry point (see Procedural Generation section)

---

#### Echo Chambers

**Description:**
Larger cavities within the Warren — natural cave formations that the tunnels pass through. Approximately 12-15 studs in diameter, with irregular ceilings reaching 6+ studs. The acoustics in these chambers are distorted. Sound bounces unpredictably. The player's own footsteps echo from directions that don't correspond to the chamber geometry.

Each Echo Chamber has 2-4 tunnel exits. The echoes make it impossible to determine which tunnel an approaching entity is using based on sound alone. The player must rely on visual confirmation — flashlight sweeps of each tunnel entrance — or risk guessing.

**Atmosphere:**
- Echo audio processing: all diegetic sounds in an Echo Chamber are duplicated with randomized delay (0.3-1.2s) and spatialized to incorrect positions. The player hears their own footsteps from behind. They hear entity patrol sounds from the left when the entity is on the right.
- The chambers contain stalactites/stalagmites that cast long, distorted shadows when the flashlight beam hits them. Moving the flashlight creates shadow movement that mimics entity silhouettes.
- Dripping water pools on the floor. The drip echoes are spatialized — the player hears dripping from every direction simultaneously.

**Gameplay Function:**
- Sensory disruption. The hearing-based survival skills the player has developed over four levels are sabotaged. Sound direction is unreliable. The player must slow down, visually check each exit, and make decisions without their primary early-warning sense.
- The Echo Chamber is a decision point: multiple exits, each leading to different tunnel branches. One leads forward. Others loop or dead-end. The airflow particle cue is harder to read in the larger space but still present.
- The Mimic exploits Echo Chambers specifically — it may stand motionless in a tunnel exit, appearing as a shadow or silhouette. In the flickering light and distorted acoustics, the player cannot easily distinguish the Mimic from a stalactite shadow.
- Co-op: voice chat is distorted in Echo Chambers. Proximity voice gains the same echo processing — teammates sound like they're in wrong positions. Communication becomes difficult.

**Loot:**
- `1x Battery [70%]` — typically near the center of the chamber
- `Lore: Blackpoint Audio Transcript` (appears in one Echo Chamber variant) — "Playback of Recording 7-C. Dr. Harlan describes the acoustic anomaly: 'The cavities at depth -4 produce a resonance pattern that doesn't match their geometry. The echoes carry information. Not sound — information. If you listen long enough, the echoes start saying things the original sound never said.'"

**Entity Presence:**
- The Mimic (Evolved) — ambush predator in this zone
- Echo Chambers are the Mimic's preferred hunting ground. The acoustic distortion supports its deception.
- The Mimic may produce footstep sounds from a tunnel exit it is not in, luring the player toward a dead end while it approaches from behind.

---

#### Mirror Room

**Description:**
A single, large chamber within the Warren — 20x20 studs, 5 studs tall. The walls, floor, and portions of the ceiling are covered in reflective surfaces. Not glass mirrors — polished stone, dark and slightly warped, producing reflections that are accurate in shape but wrong in timing, color, or detail.

The room is always present in every Warren generation (it is a fixed node in the procedural graph — see Procedural Generation section). It appears approximately at the midpoint of the Warren path.

The reflections show the player character, but with discrepancies:
- The reflection moves with a 0.1-0.3s delay (varies, never consistent)
- The reflection's flashlight beam points in a slightly different direction
- Occasionally, the reflection performs an action the player did not (turning its head, lowering the flashlight, stopping while the player moves)
- In one reflection surface (randomly selected per run), the reflection is not alone. A second figure stands behind the reflected player. There is nothing behind the real player.

**Atmosphere:**
- Visually overwhelming. The reflective surfaces multiply the flashlight beam into dozens of light sources, creating a disorienting field of moving light and shadow.
- The audio layer adds a faint whispering — not from a direction, but from the reflections themselves. The whisper layer increases in volume as the player approaches a reflective wall.
- The temperature is warmer here than the surrounding tunnels.
- The Proximity Fear System baseline shifts to Tier 1 (UNEASE) in the Mirror Room regardless of entity distance. The room itself provokes dread.

**Gameplay Function:**
- The Mimic's primary arena. In the Mirror Room, the Mimic does not disguise itself as objects or loot — it disguises itself as the player's own reflection. It steps out of the reflective surface and approaches. The tell: the reflection that moves toward the player casts a shadow on the mirror surface. Real reflections do not cast shadows.
- Navigation: the room has 2 exits (entry and exit). The exit is on the opposite side. The reflective surfaces make distance and direction difficult to judge. The room feels larger than it is.
- In co-op: the Mimic may appear as a teammate's reflection stepping out of the wall. The tell is the same (shadow on mirror surface), but now players must also verify their teammate's position. Proximity voice helps — the Mimic's clone is silent or repeats the last voice line with distortion.
- The player must cross the room to continue. There is no alternate path around it.

**Loot:**
- `Lore: Patient 31 — Personal Effects` — a small, modern cardboard box sits in the center of the room, incongruous with the ancient stone. Inside: a photograph (Patient 31 before admission — a normal person, smiling), a hospital bracelet, and a handwritten note: "I can hear it in the mirrors. It shows me what I'm becoming. I don't want to look anymore but I can't close my eyes. My reflection won't let me."
- `1x Battery [guaranteed]` — near the exit

**Entity Presence:**
- The Mimic (Evolved) — this is its home territory
- The Mimic spawns in the Mirror Room when the player enters and despawns if the player exits without being caught
- In the Mirror Room, the Mimic's detection mechanics change: instead of disguising as objects, it emerges from reflections. The player must identify and avoid it while crossing the room.
- Attack pattern: emerges from a reflection, approaches at walk speed. If the player looks directly at it AND their flashlight is on it, it freezes for 3 seconds (a borrowed Watcher mechanic — the Mimic is learning from the other entities). After 3 seconds, or if the player looks away, it resumes approach. If it reaches melee range: 2 health pip damage and teleport back to a reflection.
- Maximum 2 simultaneous Mimic clones in the Mirror Room.

---

#### The Narrow

**Description:**
A crawlspace section — the ceiling drops to 2 studs. The player is forced into a permanent crouch for the entire traversal. The passage is 2 studs wide. There is no room to turn around. Forward or backward only. The distance is approximately 40 studs — at crouch-walk speed, this takes ~20 seconds to traverse.

The walls are rough stone that transitions to something organic-looking — not literal flesh, but stone that has a grain and texture reminiscent of bone or sinew. It's a geological formation. Probably. The surface is damp.

The passage is not straight. It curves, dips, narrows further in places (the player model squeezes through — a 1-second committed animation at two pinch points), and occasionally opens into small grottos (3x3 studs) that serve as brief respite areas where the player can catch their breath and manage inventory.

**Atmosphere:**
- Maximum claustrophobia. The camera pulls in close behind the player character. FOV narrows by 10 degrees. The walls are visible at the edge of the screen at all times.
- Sound: the player's breathing is loud, panicked, echoing in the tight space. Stone scraping sounds with each movement. The passage amplifies every sound.
- At the midpoint, the passage gets dark enough that the flashlight beam seems to be absorbed by the walls. Not a bug — the stone here does not reflect light normally. The beam extends 5 studs instead of the usual 15+.
- From behind the player: scraping sounds. Something else is in the crawlspace. It is behind them. They cannot turn to look.

**Gameplay Function:**
- Gauntlet. No hiding. No sprinting. No turning around (the passage is too narrow to reverse — the player must reach a grotto to turn). The only defense is speed (crouch-walk) and luck.
- The Crawlers (Evolved) inhabit the Narrow. They are smaller here — juvenile forms or compressed variants that fit the crawlspace. They approach from behind, signaled by scraping sounds that grow louder. The player must reach a grotto to find a side fissure to press into (hiding spot) or simply outpace them.
- The two pinch points (squeeze animations) are the highest-tension moments. The player is locked in a 1-second animation, unable to move, while the scraping behind them continues.
- Stamina does not drain during crouch-walk, but the player's movement is so slow that the Crawlers will catch up if the player hesitates at intersections (the grottos have 2 exits — forward and a side branch, one of which is always a dead end).
- This is the final obstacle before the Sanctuary. The passage exits into the Threshold Gate — a stone archway with the same carved symbols, leading to a short corridor and the Sanctuary entrance.

**Loot:**
- `1x Bandage [guaranteed]` — in the first grotto
- `1x Battery [50%]` — in the second grotto
- No lore items. The Narrow is pure gameplay.

**Entity Presence:**
- Crawlers (Evolved — Juvenile/Compressed Variant) — 1-2 individuals
- Approach from behind only. Never ahead of the player.
- Speed: slightly slower than player's crouch-walk, but the squeeze animations allow them to close the gap
- If a Crawler reaches the player: 1 health pip damage, player is shoved forward 2 studs, Crawler retreats 5 studs (brief reprieve before it approaches again)
- Hiding: the grottos have narrow fissures the player can press into (2 studs deep, Crawler passes by — 50% detection rate)
- The Crawlers do not follow the player past the Threshold Gate. They stop at the archway and retreat.

---

### The Sanctuary

The Sanctuary is the level's climax zone — a hand-authored, fixed-layout underground cathedral of immense scale. After the claustrophobia of the Warren, the Sanctuary's vast open space is disorienting in the opposite direction. The ceiling is so high the flashlight cannot reach it. The walls are so far apart the beam dissolves into darkness before touching them. After an hour of tight corridors, the player is suddenly exposed.

#### Central Chamber

**Description:**
An underground cathedral of staggering proportions — approximately 80x60 studs, with a ceiling height that exceeds flashlight range (20+ studs). The space is roughly oval, with the floor descending in broad, shallow steps toward the center like an amphitheater. The walls are carved stone, but the scale and precision suggest something beyond human craftsmanship — the curves are too perfect, the surfaces too smooth.

The floor is a single continuous slab of dark stone. Carved into its surface is a vast geometric pattern — concentric rings interlocked with radiating lines, covering the entire floor. The pattern is the same symbol that appears above the catacomb archways, on Patient 31's cell walls, and in the chapel frescoes — but here, at full scale, its complexity is visible. It is not a symbol. It is a diagram. A map. The rings correspond to the levels: hospital, subway, research station, forest, catacombs. The radiating lines are connections between them. The center of the diagram is the Seal.

Faint bioluminescence in the carved lines provides the only non-flashlight illumination — a cold blue-green glow that pulses slowly, like breathing.

**Atmosphere:**
- Awe and dread in equal measure. The space is beautiful and wrong.
- The ambient drone shifts to a low, resonant tone — the chamber itself vibrates at a frequency just below hearing. The player feels it in their chest.
- The bioluminescent glow creates enough ambient light that the flashlight feels unnecessary — but turning it off reveals that the glow is not constant. It pulses. And it pulses faster when the player moves.
- Sound in the Central Chamber is cathedral-scale: vast reverb, the player's footsteps echoing for seconds. This reverb carries to entities at extended range.
- The Proximity Fear System baseline is Tier 1 (UNEASE) throughout the Sanctuary.

**Gameplay Function:**
- Orientation and preparation. The Central Chamber is the Sanctuary's hub. From here, the player can see (at flashlight range) the entrance to the Pillar Hall on the far side. The Seal and the Throne are beyond the Pillar Hall.
- The open space is double-edged: the player can see threats at a distance, but threats can see the player at a distance. There is no cover in the Central Chamber except the shallow amphitheater steps (crouching behind a step breaks line of sight at close range only).
- The carved floor diagram is interactive — examining specific sections reveals lore entries that connect the five levels narratively. There are 5 examination points, one for each ring/level.
- No entities patrol the Central Chamber itself. It is a transitional space. But the Pillar Hall Watchers can see into it from the Pillar Hall entrance, and the Patient can follow the player down from the Warren if they were pursued.

**Loot:**
- `1x Battery [guaranteed]` — on the first amphitheater step
- `1x Bandage [guaranteed]` — on the opposite side of the chamber
- `1x Medkit [50%]` — at the base of the amphitheater steps, near center
- `Lore: Floor Diagram — Ring 1 (Hospital)` — "The first ring. Where it first wore a human face."
- `Lore: Floor Diagram — Ring 2 (Subway)` — "The second ring. Where it learned to multiply."
- `Lore: Floor Diagram — Ring 3 (Research Station)` — "The third ring. Where they tried to understand it. Where it learned to imitate."
- `Lore: Floor Diagram — Ring 4 (Forest)` — "The fourth ring. Where it learned to watch. To wait. To be patient."
- `Lore: Floor Diagram — Ring 5 (Catacombs)` — "The fifth ring. The oldest. Where it has always been."

**Entity Presence:**
- No dedicated entities. Transitional zone.
- The Patient may follow the player into this space from the Warren path.
- Watchers are visible at the Pillar Hall entrance — stationary, watching, not yet active until the player enters the Pillar Hall.

---

#### Pillar Hall

**Description:**
A rectangular hall — 50x20 studs, ceiling at 10 studs — filled with massive stone columns arranged in a grid pattern. The columns are 2 studs in diameter, spaced 5 studs apart, creating a forest of stone. There are approximately 40 columns. The far end of the hall has a raised platform with a wide archway leading to the Throne chamber.

The columns are carved. Each one bears relief carvings depicting scenes — some recognizable (hospital corridors, subway tunnels, forest clearings), some abstract (patterns, geometries, shapes that don't resolve). The carvings are not ancient. Some depict modern objects — a flashlight, a radio, a helicopter. The carvings depict events that haven't happened yet. Some depict the player.

**Atmosphere:**
- The columns create a visual maze. The flashlight beam is interrupted every 5 studs by another column. Sightlines are short and constantly broken.
- Sound is dampened — the columns absorb echoes, creating a flat, dead acoustic space. Footsteps don't echo. The player loses the audio cues they've relied on.
- Between the columns, the bioluminescent glow from the Central Chamber fades. It is dark here. Genuinely dark. The flashlight is essential.
- The Proximity Fear System shifts to Tier 2 (DREAD) baseline in the Pillar Hall. Heartbeat audio begins. It does not stop.

**Gameplay Function:**
- Watcher gauntlet. The Watchers (Evolved) are stationed among the pillars. 4 in solo, 6-8 in co-op. They stand between columns, motionless, facing random directions. When the player is not looking at them, they move. When the player looks at them, they freeze.
- The column grid means the player can never see all Watchers simultaneously. Moving through the hall requires constant flashlight sweeping — checking every angle between columns.
- Watchers in this zone are evolved: they move faster when unobserved (2x base speed), they can move while the player is blinking (the game simulates eye blink — a 0.15-second blackout every 30-45 seconds, signaled by a subtle eyelid animation at screen edges), and they produce no sound.
- Strategy: the player must identify a path through the columns that minimizes the number of Watchers they pass. Moving in a straight line is dangerous — too many columns block sightlines. Moving along the walls is safer (fewer approach angles) but slower.
- The flashlight is critical but also a liability — its beam signals the player's position to any entity that might be following from behind (the Patient, if it pursued into the Sanctuary).
- The Watchers do not pursue past the Pillar Hall. They are bound to this space.

**Mechanics — The Blink:**
- Every 30-45 seconds (randomized), the screen briefly dims at the edges, simulating an involuntary blink — 150ms of reduced visibility
- During the blink, Watchers can move even if the player's camera is facing them
- The blink interval is displayed nowhere. The player must internalize the rhythm.
- In co-op, players blink independently. Coordination ("I'm blinking, watch the left") becomes critical.

**Loot:**
- `1x Flare [guaranteed]` — at the hall midpoint. The flare's light briefly illuminates a wide area, freezing all visible Watchers for 8 seconds. Strategic use.
- `1x Battery [guaranteed]` — near the raised platform
- `Lore: Carved Column Fragment` — "The pillars record everything. Past, present, what will come. I found a carving of myself reading this carving. The next panel shows what happens after. I didn't look at the next panel."

**Entity Presence:**
- Watchers (Evolved) — 4 solo / 6-8 co-op
- Movement speed: 2x base (faster than standard Watchers from Level 4)
- Blink vulnerability: can move during simulated blink
- No sound. No Proximity Fear System contribution (they don't trigger proximity audio — the player gets no warning from the fear system)
- Attack: if a Watcher reaches melee range, instant 2 health pip damage + teleport to a new position among the columns
- They do not follow the player out of the Pillar Hall in either direction

---

#### The Throne

**Description:**
A circular chamber — 15 studs in diameter, domed ceiling at 8 studs. The floor is polished to a mirror sheen. In the center, on a raised stone dais, is a throne carved from a single block of dark stone. The throne faces the entrance.

Something sits on the throne.

It is humanoid. It is still. It has been still for a very long time. Its surface is the same dark stone as the throne — or the throne has grown around it. Or it has become the throne. The boundary between the figure and the seat is ambiguous. Its face is featureless — smooth stone where features should be. Its hands rest on the armrests, palms up, fingers slightly curled. It is approximately 7 feet tall if it stood.

It does not move. It does not react to the player's presence, flashlight, sound, or proximity. It is not an entity in the AI sense — it has no state machine, no pathfinding, no detection. It is a set piece. It is the source.

See [The Throne / The Original Entity](#the-throne--the-original-entity) for full lore details.

**Atmosphere:**
- The Proximity Fear System hits Tier 3 (PANIC) on entering the chamber, regardless of any entity proximity. The heartbeat is loud. The screen trembles. The flashlight flickers. But the thing on the throne does not move. The fear system is reacting to the room, not to an entity. The player's character is terrified. The player should be too.
- The air in the chamber is warm. Not comfortable warm — fever warm. The visible breath effect stops here. The temperature is wrong.
- Sound: near-silence, except for the player's panicked breathing and heartbeat. Underneath, barely audible: a vibration. Not a sound. A feeling. The controller vibrates subtly on supported devices. On PC, the sub-bass is felt through headphones.
- The flashlight beam, when pointed at the figure on the throne, dims. Not flickers — dims steadily, as if the light is being absorbed. The figure is always slightly darker than the flashlight should render it. The lighting engine cannot properly illuminate it.

**Gameplay Function:**
- Lore climax. This is the story's payoff. The player examines the figure, the throne, the dais, and the chamber walls to piece together the final narrative.
- The chamber has no entities, no hazards, no timer. The player can take as long as they want here. This is intentional — after the intensity of the Pillar Hall, the Throne offers a moment of contemplative dread.
- The Seal is in an alcove directly behind the Throne, accessible by walking around the dais.
- Examining the figure triggers a series of lore entries (see Lore section) and a final vision: a 10-second sequence where the player sees (first-person perspective) the view from the throne — looking out at the chamber entrance, seeing centuries of people entering, approaching, kneeling, fleeing, building walls, drilling, always coming back. The vision ends. The player is standing where they were. Nothing has changed. But the figure's hands are now palms-down on the armrests. The player did not see them move.

**Loot:**
- `Lore: The Throne Examination — 4 entries` (figure, throne, dais, chamber walls)
- `Lore: The Final Vision` — auto-collected after examining all 4 points
- No consumable loot. The player gets nothing practical here. The reward is understanding.

**Entity Presence:**
- None. The figure on the throne is not an entity. It has no AI. It cannot harm the player.
- However: the Proximity Fear System Tier 3 means subliminal flashes occur in this room. The flash content is unique to the Throne chamber: glimpses of the figure standing, the figure turning its head, the figure leaning forward. When the flash ends and the player looks — it is in the same position. Always. These are the player character's terror, not reality. Probably.

---

#### The Seal

**Description:**
Behind the Throne, through a narrow passage (3 studs wide, 5 studs long), is a small alcove — 8x8 studs. The floor, walls, and ceiling are covered in the carved symbols — dense, overlapping, layered over centuries. The symbols glow with the same bioluminescence as the Central Chamber floor, but brighter, pulsing faster.

In the center of the floor is the Seal itself: a circular stone slab, 3 studs in diameter, set into the floor and rimmed with iron bands. The iron is not rusted — it gleams. The symbols on the Seal are different from the walls — they are precise, geometric, mechanical-looking. This is not religious iconography. This is engineering. Someone designed this to contain something, and they knew exactly what they were doing.

The Seal has a visible crack. It runs from edge to center, irregular but deep. The bioluminescent glow is brightest at the crack — as if something is pressing through from the other side.

**Atmosphere:**
- The Proximity Fear System remains at Tier 3 (PANIC).
- The vibration/sub-bass from the Throne chamber is louder here. The crack in the Seal is the source.
- Standing near the crack: the player hears a voice. Not whispers — a voice. Clear, calm, speaking directly to the player. It says different things each run, pulled from a pool of 8 lines (see Scripted Events). It knows the player's in-game username. It says it by name.
- The glow pulses in sync with the player's heartbeat audio.

**Gameplay Function:**
- Choice point. The player interacts with the Seal and is presented with two options:
  - **REINFORCE THE SEAL** — push the crack closed, repair the containment
  - **DESTROY THE SEAL** — shatter it, end the cycle permanently

See [The Seal — Choice Design](#the-seal--choice-design) for full mechanical and narrative details.

**Loot:**
- None. This is a decision, not a scavenging opportunity.

---

### Extraction / Collapse Sequence

See [The Collapse / Timed Escape](#the-collapse--timed-escape) for full details.

---

## Entity Zones & Evolved Forms

Level 5 deploys all four entity types simultaneously — the first and only time in the game. Each entity occupies a primary zone but may overlap into transition areas. The "Evolved" designation indicates mechanical changes from their base-level versions.

### Entity Deployment Map

| Entity | Primary Zone | Secondary Zone | Absent From |
|--------|-------------|----------------|-------------|
| The Patient (Evolved) | Upper Catacombs (Stone Corridors, Burial Chambers) | Warren outer tunnels, Central Chamber (pursuit only) | Flooded Gallery, Mirror Room, The Narrow, Pillar Hall, Throne, Seal |
| Crawlers (Evolved — Aquatic) | Flooded Gallery | — | All other Catacomb areas, Warren, Sanctuary |
| Crawlers (Evolved — Juvenile) | The Narrow | — | All other areas |
| The Mimic (Evolved) | Warren (all sub-zones), Mirror Room | Echo Chambers | Catacombs, Sanctuary |
| Watchers (Evolved) | Pillar Hall | Central Chamber (line of sight only, do not enter) | Catacombs, Warren, Throne, Seal |

### Evolved Form Details

#### The Patient (Evolved)

The Patient has been the player's antagonist since Level 1. In Level 5, it is familiar — but wrong. Faster. Smarter. More aggressive. The evolutionary changes are subtle enough that the player recognizes it but can no longer rely on Level 1 strategies.

| Parameter | Level 1 | Level 5 (Evolved) |
|-----------|---------|-------------------|
| Patrol speed | Slow | Medium (1.4x base) |
| Chase speed | Medium | Fast (1.3x base) |
| Hearing radius | Standard | Extended (+15 studs all sources) |
| Detection ramp | 1.5s (forgiving) | 0.8s |
| Hiding spot check rate | Rare → learns | Medium from start, learns faster (2 uses = 80% check) |
| Electronics flatline range | 20 studs | 30 studs |
| Unique (Evolved) | — | **Resonance**: when the Patient enters HUNT state, all other active entities in adjacent zones also enter INVESTIGATE. The Patient alerts the network. |
| Visual change | — | The Patient's model is partially translucent — the stone/bone texture of the Throne figure is visible beneath its surface, as if its human disguise is failing. |

#### The Crawlers (Evolved — Aquatic Variant)

Deployed in the Flooded Gallery. These Crawlers have adapted to water — they are fully submerged, invisible, and navigate by hearing alone.

| Parameter | Level 2 | Level 5 (Aquatic) |
|-----------|---------|-------------------|
| Count | 3-5 | 2-3 (fewer but deadlier) |
| Movement | Surface (walls/ceiling) | Submerged (invisible) |
| Primary sense | Hearing | Hearing (exclusively — vision disabled) |
| Detection method | Sound + sight | Sound only (ripple warning system) |
| Warning system | Visible on surfaces | Ripples on water surface, 3-5s before attack |
| Attack | Lunge from surface | Surface from water, lunge, re-submerge |
| Damage | 1 pip | 1 pip |
| Counterplay | Sprint, hide, outmaneuver | Stand still (they lose tracking). Move in short bursts. Watch ripples. |
| Unique (Evolved) | — | **Echolocation pulse**: every 20 seconds, a brief sonar-like ping sound. After the ping, if the player is moving, the nearest Crawler orients directly toward them. Standing still during the ping makes the player invisible. |
| Visual change | — | Not visible. The water itself is the entity. Ripples and wake patterns are the only visual indicators. |

#### The Crawlers (Evolved — Juvenile Variant)

Deployed in The Narrow. Smaller, fitting the crawlspace geometry.

| Parameter | Level 2 | Level 5 (Juvenile) |
|-----------|---------|-------------------|
| Count | 3-5 | 1-2 |
| Size | Full | 60% scale (fits crawlspace) |
| Movement | Walls/ceiling | Floor only (crawlspace constraints) |
| Speed | Very fast | Slightly slower than player crouch-walk |
| Approach | Any direction | Behind only (they follow the player through the Narrow) |
| Attack | Lunge | Bite — 1 pip + shove player forward 2 studs |
| Counterplay | Sprint, hide | Maintain pace. Hide in grotto fissures. Do not stop. |
| Unique (Evolved) | — | **Persistence**: the Juvenile Crawler does not give up. It follows for the entire Narrow traversal. It is always behind. The scraping sound is always there. The player cannot fight it, cannot outrun it, cannot lose it. They can only keep moving. |
| Visual change | — | Barely visible in the confined space. Glimpsed only if the player looks backward at a grotto — a pale, angular shape pressed against the tunnel floor, too many joints in its limbs. |

#### The Mimic (Evolved)

Deployed throughout the Warren and its sub-zones. The Level 5 Mimic has expanded its repertoire beyond object and teammate mimicry.

| Parameter | Level 3 | Level 5 (Evolved) |
|-----------|---------|-------------------|
| Disguise type | Objects, loot, teammates | Reflections, sound, environmental features |
| Primary zone | Research Station interiors | Warren tunnels, Echo Chambers, Mirror Room |
| Detection tell | Wrong shadows, silence, repeated voice lines | Shadows on reflective surfaces, sound from wrong direction, impossible geometry |
| Attack trigger | Approach while disguised | Approach OR look away after visual contact |
| Damage | 1 pip | 2 pips (devastating in Level 5's scarce-loot environment) |
| Unique (Evolved) | — | **Acoustic Mimicry**: in Echo Chambers, the Mimic can reproduce any sound the player has made in the last 30 seconds. Footsteps, flashlight clicks, door interactions — played from the Mimic's position, making the player believe they are hearing their own echoes when they are actually hearing the Mimic's lure. |
| Unique (Evolved) | — | **Reflection Emergence** (Mirror Room only): the Mimic steps out of reflective surfaces as a copy of the player character. Tell: the copy casts a shadow on the mirror surface. Real reflections do not. |
| Visual change | — | The Mimic's true form (visible briefly during attack animation and when caught in direct flashlight at close range) shows its Level 3 appearance but degraded — the surface texture is unstable, shifting between materials like a texture glitch. It is trying to be everything and failing. |

#### The Watchers (Evolved)

Deployed in the Pillar Hall. The Level 4 mechanic is preserved but intensified.

| Parameter | Level 4 | Level 5 (Evolved) |
|-----------|---------|-------------------|
| Count | 2 → 6 (escalating) | 4-8 (high from start) |
| Movement speed (unobserved) | Medium | Fast (2x base) |
| Freeze behavior | Freezes when observed | Freezes when observed, BUT can move during blink |
| Blink mechanic | Not present | Simulated blink every 30-45s (150ms reduced visibility). Watchers can move during blink even if camera faces them. |
| Sound | Faint ambient | Silent. No proximity fear contribution. Zero audio warning. |
| Fog mechanic | Dynamic fog cuts sightlines | Not present (columns serve same function) |
| Attack | 1 pip | 2 pips + teleport to new position |
| Unique (Evolved) | — | **Column Merge**: Watchers can press against columns, becoming nearly indistinguishable from the carved stone. The player must sweep their flashlight carefully — the Watcher's silhouette is slightly wrong (too tall, too thin), but in peripheral vision it reads as a column. Direct flashlight contact reveals them (they reflect light differently from stone). |
| Visual change | — | The Level 5 Watchers resemble the Throne figure — smooth, featureless faces, dark stone texture. They are clearly the same substance as the Original Entity. They are its eyes. |

### Entity Overlap Behavior

In transition zones, entities may coexist. The interaction rules:

| Scenario | Behavior |
|----------|----------|
| Patient + Mimic (Warren outer tunnels) | The Patient ignores the Mimic. The Mimic does not disguise as the Patient. They hunt independently. Player must manage two distinct threat types simultaneously. |
| Patient enters HUNT → other entities | Patient's Resonance ability triggers INVESTIGATE in all entities in adjacent zones. This creates a cascade — one mistake propagates. |
| Watchers see the player from Central Chamber | Watchers at the Pillar Hall entrance can see into the Central Chamber. They do not leave the Pillar Hall, but they track the player's position. When the player enters the Pillar Hall, Watchers have pre-positioned based on the player's observed approach angle. |
| Multiple entity types during Collapse | All entities become CHASE-state during the Collapse Sequence. No stealth — pure flight. Entity collision boundaries are reduced so they don't block corridors entirely. |

---

## The Warren — Procedural Generation Design

### Architecture: Graph-Based Tile System

The Warren uses a graph-based procedural generation system with hand-authored tile sets. The goal is controlled randomness — the layout is different each run, but the quality, pacing, and solvability are guaranteed.

#### Tile Types

Each tile is a pre-built room/corridor segment authored in Studio. Tiles have defined connection points (doors/openings) on their edges.

| Tile Type | Dimensions (studs) | Connections | Count in Pool | Purpose |
|-----------|--------------------|-------------|---------------|---------|
| Straight Tunnel | 3x12 | 2 (ends) | 8 variants | Basic traversal |
| T-Junction | 8x8 | 3 | 4 variants | Branch points |
| Cross Junction | 8x8 | 4 | 3 variants | Major intersections |
| L-Bend | 8x8 | 2 (90-degree) | 6 variants | Direction changes |
| Dead End | 3x6 | 1 | 5 variants | Loot rooms, false paths |
| Echo Chamber | 15x15 (circular) | 2-4 | 3 variants | Sensory disruption zone |
| Mirror Room | 20x20 | 2 | 1 (fixed) | Mimic encounter (always present) |
| The Narrow (entry) | 2x8 | 1 in, 1 out (crawlspace) | 1 (fixed) | Crawler gauntlet (always present) |
| Shaft (vertical) | 4x4 | 2 (top/bottom) | 4 variants | Elevation changes |
| Grotto | 6x6 | 2-3 | 4 variants | Rest areas, loot |

#### Generation Algorithm

1. **Define graph skeleton:**
   - Place START node (Warren entry from Descent Passage)
   - Place END node (The Narrow entry, leading to Sanctuary)
   - Place REQUIRED nodes: Mirror Room (midpoint), 2 Echo Chambers (distributed)
   - Generate critical path: START → [3-5 intermediate nodes] → Mirror Room → [2-4 intermediate nodes] → END
   - Critical path length: 12-18 nodes

2. **Add branches:**
   - From each node on the critical path, 30% chance to spawn a branch
   - Branches extend 1-4 nodes before terminating in Dead End tiles
   - Branches may loop back to the critical path at a different node (15% chance per branch) — creates alternate routes
   - Total node count: 20-35 per generation

3. **Assign tile types:**
   - Critical path nodes: weighted toward Straight Tunnels and L-Bends (flow)
   - Branch nodes: weighted toward T-Junctions and Dead Ends (exploration)
   - Required nodes: fixed tile types (Mirror Room, Echo Chambers, The Narrow)
   - Variant selection within each type is randomized

4. **Validate:**
   - Pathfinding check: START to END must be reachable
   - No orphan nodes (every node connected to at least one other)
   - Mirror Room must be on critical path
   - Maximum 2 consecutive Straight Tunnel tiles (prevents monotonous stretches)
   - Minimum 1 branching path before Mirror Room, minimum 1 after
   - Entity patrol paths must be valid (see Entity Placement below)

5. **Instantiate:**
   - Tiles are placed in 3D space following the graph connections
   - Connection points are aligned and sealed (matching door frames, geometry cleanup)
   - Lighting, fog, particle effects applied per-tile from tile type defaults
   - Loot spawns placed (see below)

#### Ensuring Solvability

- The critical path is generated first, guaranteeing a valid route from START to END
- All branches are non-critical — the player never needs to explore a branch to progress (though branches contain loot)
- Validation pass confirms pathfinding before the level loads
- Fallback: if generation fails validation (rare, <2%), re-roll with a different seed

#### Environmental Navigation Cues

The Warren is designed to disorient, but not to be impossible. Attentive players can read subtle cues:

| Cue | Meaning | Reliability |
|-----|---------|-------------|
| Air particle drift | Particles drift toward the exit (the Sanctuary draws air downward) | High (always correct) |
| Wall carving density | More symbols = closer to Sanctuary | High |
| Temperature color shift | Warmer (screen shifts toward amber) = deeper = closer to exit | Medium |
| Graffiti directions | Modern spray-painted directions on walls | Low (50% correct, 50% deliberately wrong) |
| False light | Faint glow at dead ends | Anti-cue (always wrong — the glow is a trap/dead end marker) |
| Tunnel width | Tunnels narrow slightly as they approach the exit | Medium |

#### Entity Placement in Procedural Space

- Entity spawn points are not pre-placed on tiles. They are dynamically assigned after generation.
- **The Mimic:** 1 spawn per Echo Chamber + 1 spawn in Mirror Room. Additionally, 1-2 roaming spawns placed on the critical path at nodes that are 40%+ and 70%+ along the path distance from START.
- **The Patient:** 1 spawn at the Warren entry (if it has followed from the Catacombs). It patrols the first 3-4 nodes of the critical path and nearby branches. It does not go deeper than the first Echo Chamber.
- Entities use NavigationMesh pathfinding within their assigned tile set. They do not have foreknowledge of the procedural layout — they explore and patrol like the player does, within their zone constraints.
- Entity density is never zero on the critical path. At minimum, the player encounters: 1 Mimic in the first half, 1 Mimic in the Mirror Room, 1 Mimic in the second half, and the Crawlers in The Narrow.

#### Disorientation Mechanics

| Mechanic | Implementation | Effect |
|----------|---------------|--------|
| Echo distortion | Audio processing on diegetic sounds in Echo Chambers: duplicate with random delay (0.3-1.2s), spatialize to incorrect position | Player cannot use sound to navigate or locate entities in Echo Chambers |
| Repeating landmarks | 3-4 "landmark" props (distinctive rock formation, collapsed timber, skull pile) are reused across multiple tile variants. The player sees the same landmark in different locations, questioning whether they're going in circles. | Mental map disruption |
| Compass drift | If the player has acquired a compass (optional item from earlier levels), it spins erratically in the Warren. No reliable cardinal direction. | Removes external navigation tools |
| Flashlight range variation | Fog density varies per tile (8-15 stud effective flashlight range). The player cannot judge distance consistently. | Spatial awareness disruption |
| Sound bleed | Entity patrol sounds from one tile can be heard in non-adjacent tiles via sound propagation through the graph. The player hears the entity but cannot determine distance or direction. | Threat assessment disruption |

---

## The Seal — Choice Design

### The Choice

After examining the Throne and entering the Seal alcove, the player approaches the cracked Seal. An interaction prompt appears with two options:

**Option A: REINFORCE THE SEAL**
- The player places their hands on the Seal. A 10-second channeling animation begins. The crack glows brighter, then dims. The bioluminescent symbols pulse in sequence — a locking pattern. The crack closes visually (not fully — a hairline fracture remains). The Seal's glow stabilizes.
- The voice from the crack says: *"You are kind. It will not hold. But you are kind."*
- Narratively: the player is choosing to contain the threat, trusting that the seal will hold for another generation. They are continuing the cycle depicted in the chapel frescoes — build walls, hope they hold, pass the burden to the future.
- The Collapse is triggered by the reinforcement process itself — the energy released by resealing causes structural instability in the catacombs above.

**Option B: DESTROY THE SEAL**
- The player strikes the Seal. A 10-second destruction animation begins. The player lifts a loose iron band from the Seal's edge and drives it into the crack. The crack spreads. The entire Seal shatters outward. Beneath it: a void. Not darkness — absence. The bioluminescent glow dies in a wave radiating outward from the broken Seal through the walls, floor, ceiling. The carved symbols go dark. The vibration stops. Complete silence for 3 seconds.
- Then the collapse begins.
- The voice, before the Seal breaks, says: *"You are brave. It will cost you. But you are brave."*
- Narratively: the player is ending the cycle permanently. Destroying the Seal destroys the wound — the boundary between real and not-real closes permanently. But closing the wound means collapsing the space that existed around it. Everything built on top of this site — catacombs, hospital, all of it — loses its foundation.

### Multiplayer Choice Mechanics

| Players | Mechanic |
|---------|----------|
| Solo | Player makes the choice alone. Both options available. |
| 2 players | Both players must be in the Seal alcove. Each selects independently. If they agree: that choice executes. If they disagree: a 30-second deliberation timer starts. Players can change their selection. When the timer expires, the majority wins. In a tie (1v1), the first player to interact decides. |
| 3-4 players | All players present in the Seal alcove vote. Majority wins. Tie: first player's choice wins. Players not in the alcove (lost, dead, still in Pillar Hall) do not vote. If only 1 player reaches the Seal, they decide alone. |

This creates a co-op narrative moment: players may disagree. The deliberation timer forces a conversation. The game does not resolve the moral question for them.

### Mechanical Differences During Escape

| Element | Ending A (Reinforce) | Ending B (Destroy) |
|---------|---------------------|-------------------|
| Collapse timer | 4 minutes 30 seconds | 3 minutes 30 seconds |
| Collapse intensity | Gradual — ceiling dust, falling debris, cracks widening over time | Immediate and violent — entire sections collapse, entity behavior is frantic |
| Entity behavior | Entities flee upward (same direction as player). They are obstacles but not hunting — they are also trying to escape. Running alongside the player, through the same corridors. Terrifying but not directly hostile. | Entities are enraged. HUNT/CHASE state. They blame the player. They attack actively during the escape. |
| Warren shortcut | Warren procedural layout is preserved but a "fast path" is highlighted by fleeing entities (follow the Patient — it knows the way) | Warren partially collapses, creating a shorter but more hazardous direct route (rubble, unstable floors, fire). The procedural layout is overwritten with a fixed collapse corridor. |
| Visual tone | Dust, cracking stone, groaning structure. Controlled demolition feel. | Fire (from ruptured gas pockets), flooding (water rushing in from the Flooded Gallery), violent shaking. Catastrophic. |
| Entity density during escape | Lower (entities are fleeing, not hunting) | Higher (entities are hunting + new entities spawning from walls/floor — the wound is dying and everything inside is trying to get out) |

### Ending A: The Seal Holds

**Escape Sequence:**
The collapse is structural but measured. The player has 4 minutes 30 seconds. The route back is:
1. Seal → Throne (the figure on the throne is gone. The throne is empty. It was there. It is not there now.)
2. Throne → Pillar Hall (Watchers are gone — columns only. The columns are cracking.)
3. Pillar Hall → Central Chamber (bioluminescent glow is fading — the light is dying. Floor diagram cracks.)
4. Central Chamber → Warren (the Patient runs past the player through the Warren — follow it. It knows the path. It is not hunting. It is fleeing.)
5. Warren → Descent Passage (reversed — a collapsed section creates a ramp up to the chapel level)
6. Chapel (candles are out. The room is cold again. The frescoes are fading from the walls.)
7. Catacombs → Entry stairs → Hospital Basement

**Surface Emergence (Ending A):**
The player emerges through the sub-basement door into the hospital basement. The hospital is shaking — dust falling, lights flickering. They run up through the ground floor (lobby, reception — all recognizable from Level 1, now cracking and groaning) and out the main entrance.

Outside: dawn. The first natural light in the entire game. The hospital stands behind them, damaged but standing. Cracks in the foundation. The ambulance bay from Level 1's spawn point. The fog is gone.

The player stands in the light. The camera pulls back slowly to a wide shot. The hospital is intact. The ground beneath it is intact. The seal holds. For now.

**Final shot:** a slow zoom on the foundation of the hospital. A hairline crack. Too small to see from a distance. The crack glows, faintly, for a single frame. Cut to black.

**Post-credits text:** *"The cycle continues."*

### Ending B: The Seal Breaks

**Escape Sequence:**
The collapse is violent and immediate. The player has 3 minutes 30 seconds. The route back is:
1. Seal → Throne (the figure on the throne is standing. It is not looking at the player. It is looking at the broken Seal. Its featureless face somehow conveys sorrow. As the player passes, it crumbles to dust.)
2. Throne → Pillar Hall (Watchers are active — attacking. The columns are falling. The player must sprint through a gauntlet of collapsing architecture AND hostile Watchers.)
3. Pillar Hall → Central Chamber (the floor diagram shatters — pieces falling into a void below. The player sprints across a fragmenting floor. Missing sections. Jumps required.)
4. Central Chamber → Warren (the procedural layout is overwritten: a single collapse corridor, shorter but filled with hazards — fire, rubble, flooding, entities emerging from walls.)
5. Warren → Catacombs (Flooded Gallery is draining violently — whirlpools, debris. The Chapel is collapsed — bypass through a new crack in the wall.)
6. Catacombs → Entry stairs → Hospital Basement

**Surface Emergence (Ending B):**
The player emerges through the sub-basement door. The hospital is collapsing. Not shaking — actively falling apart. Ceiling sections dropping. Walls splitting. The player sprints through the ground floor (Level 1's lobby is unrecognizable — structural collapse, fire from burst pipes, debris everywhere).

Outside: dawn. But the ground behind the player is sinking. The hospital collapses into itself — a sinkhole consuming the building, pulling it underground. The catacombs beneath are caving in, and the hospital is going with them.

The player stands at the edge of the ambulance bay, watching St. Maren's Hospital disappear into the earth. The fog is gone. The sun is rising. The sinkhole stabilizes — a jagged pit where the hospital was, dust settling.

Nothing moves. Nothing emerges from the pit. It is over.

**Final shot:** the sun rising over the empty lot. No hospital. No foundation. Just earth. The player's character stands at the edge, alone. The camera holds. No glow. No crack. No hint. It is over.

**Post-credits text:** *"The cycle ends."*

### What Happens If You Don't Make It Out

- The timer expires. The screen shakes violently. A final collapse event buries the player.
- Death screen: differs by ending choice.
  - **Ending A (Reinforce) — failed escape:** *"The seal holds. You do not."* — The player is buried beneath the hospital. The seal is intact. The world is safe. They are not.
  - **Ending B (Destroy) — failed escape:** *"The cycle ends. So do you."* — The player is consumed by the collapse they triggered. The threat is ended. So is the player.
- Mechanically: death resets the run. The player must replay Level 5 from the Entry. However, the ending choice is logged — if the player successfully escapes on a subsequent run, the ending they chose on their first attempt is referenced in the ending narration (a single line: "You tried before. You came back. That takes [kindness / courage].")

---

## The Collapse / Timed Escape

### Timer

| Ending | Timer Duration | Display |
|--------|---------------|---------|
| A (Reinforce) | 4:30 | On-screen countdown, top center, large, impossible to miss. Pulses red below 60s. |
| B (Destroy) | 3:30 | Same display. Timer ticks faster visually below 60s (cosmetic — actual speed unchanged). |

The timer begins the moment the Seal interaction animation completes.

### Visual/Audio Escalation During Escape

The Collapse Sequence is the game's pacing reversal. The entire game has taught the player to be slow, cautious, stealthy. The Collapse demands the opposite: RUN.

| Time Remaining | Visual Effects | Audio Effects | Structural Events |
|----------------|---------------|---------------|-------------------|
| 4:30 - 3:00 | Dust falling from ceiling. Hairline cracks on walls. Camera micro-tremors. | Low rumble. Stone groaning. Distant crashes. | None. Purely atmospheric. |
| 3:00 - 2:00 | Cracks widen. Small debris falls (non-damaging). Lighting flickers. Bioluminescent glow dying. | Rumble intensifies. Crashes closer. Entity sounds overlap (fleeing or hunting depending on ending). Heartbeat audio at max. | Occasional corridor blockage (rubble falls, blocks a path — player must find alternate). One per zone traversal. |
| 2:00 - 1:00 | Large chunks falling (some damaging — 1 pip if hit, dodgeable). Walls visibly shifting. Floor cracking. | Deafening. Music layer: dissonant brass, escalating. Player character screaming/panting. Proximity Fear Tier 4 regardless of entity distance. | Multiple corridor collapses. The Warren's layout degrades — dead-end branches collapse, simplifying navigation but increasing urgency. |
| 1:00 - 0:30 | Near-total environmental destruction. The route behind the player is collapsing in real-time — the floor falls away 10-15 studs behind them. No going back. | All audio layers at maximum. Subliminal flashes every 5 seconds. The voice from the Seal (if Ending A) whispers the player's name repeatedly. | The collapse follows the player. They are outrunning a cave-in. Ceiling drops 2 studs behind them continuously. |
| 0:30 - 0:00 | Screen shake at maximum. Tunnel vision. The exit (hospital basement door) is visible. | Single sustained tone — all other audio cuts out. Heartbeat. Breathing. Nothing else. | The final corridor. Straight run. The ceiling is falling behind. If the player sprints, they have exactly enough stamina to reach the door at 0:00. |

### Route Back (Zone-by-Zone)

The escape route reverses the descent path but each zone is modified:

| Zone (Descent Order) | Escape Modification |
|----------------------|-------------------|
| Seal / Throne | Brief — 15 seconds max. Exit through Pillar Hall. |
| Pillar Hall | Ending A: Watchers gone, columns cracking, straight run. Ending B: Watchers active + columns falling. Sprint-dodge. ~30 seconds. |
| Central Chamber | Ending A: Floor intact, sprint across. Ending B: Floor fragmenting, jump across gaps. ~20 seconds. |
| The Warren | Ending A: Follow the fleeing Patient through the critical path (~90 seconds). Ending B: Collapse corridor replaces procedural layout (~60 seconds, shorter but hazardous). |
| Upper Catacombs | Chapel is bypassed (collapsed in Ending B, briefly traversed in Ending A). Flooded Gallery water level has dropped (Ending A) or drained violently (Ending B). Stone Corridors are collapsing. ~45 seconds. |
| Entry Stairs | Final sprint. The stairs are cracking. The hospital basement is above. ~15 seconds. |
| Hospital (Basement → Ground → Exit) | Straight path through Level 1's layout (shortened — most doors are open, direct route to main entrance). ~30 seconds. |

### Stamina During Escape

- Stamina drain rate is reduced by 30% during the Collapse Sequence (hidden, not communicated to the player). This is rubber-banding — the escape should be tight but achievable.
- Stamina recovery while walking (not sprinting) is increased by 50%.
- The player should need 3-4 sprint cycles to complete the escape, with brief walk/recovery intervals.
- At 1 health pip (limping), the speed penalty threatens the timer. Bandaging costs ~3 seconds — viable if the player has 60+ seconds remaining, suicidal below that.

---

## The Throne / The Original Entity

### What Is the Thing on the Throne?

It is not a creature. It is not a god. It is not a demon. It is the oldest expression of the wound — the first thing that leaked through the boundary when the boundary first weakened. It has been sitting in this chamber since before humans found this place. The civilizations that built above it gave it a throne because that was the only frame of reference they had for something that sat and watched and did not move.

It does not think. It does not want. It does not hate or love. It simply exists at the boundary point, and its existence causes the boundary to weaken further. The entities — Patient, Crawlers, Mimic, Watchers — are not its servants or its children. They are side effects. They are what leaks through the cracks the Original Entity's presence creates. If the Original Entity is a stone dropped in a pond, the entities are the ripples.

### Lore Entries (Throne Examination)

**Examination 1 — The Figure:**
*"It's stone. Or it was stone. Or the stone grew around it. The surface is warm — warmer than the air, warmer than skin. Where the stone meets the throne, there is no seam. It could have always been here. It could have arrived yesterday. There is no way to tell. Its face has no features. Not worn away — never had them. Whoever carved the frescoes in the chapel gave it a face in their paintings. They were wrong, or they were being kind."*

**Examination 2 — The Throne:**
*"The throne is carved from the bedrock. Not placed — carved in situ. Someone came down here and decided to give it a seat. Or it was always shaped like this and someone decided that shape meant 'throne.' The armrests bear the same symbols as the Seal. The same symbols as Patient 31's cell. The same symbols everywhere. They're not a language. They're a warning label. 'Do not touch.' 'Do not open.' 'Do not look.' We looked."*

**Examination 3 — The Dais:**
*"The platform beneath the throne is cracked. Not structurally — the cracks form a pattern. The same pattern as the floor diagram in the Central Chamber. The same pattern as the Seal. Five rings. Five levels. Hospital, subway, station, forest, catacombs. The pattern wasn't carved by the people who built above this place. The pattern was already here. They built above it because the pattern told them where to build. We didn't choose to put the hospital here. We were told to. We just didn't know who was telling us."*

**Examination 4 — The Chamber Walls:**
*"The walls are covered in handprints. Thousands of them. Different sizes, different ages. Some are painted in ochre. Some are carved. Some are pressed into the stone as if the wall was soft when the hand touched it. Each handprint has the same symbol carved in its palm. I put my hand against one. It was warm. I pulled away. For a moment — just a moment — I felt it pull back."*

**The Final Vision (auto-triggered after all 4 examinations):**
A 10-second first-person sequence. The player's perspective shifts to the throne — looking outward. Fast-forward montage: thousands of years of visitors. They enter the chamber with torches, candles, lanterns, flashlights. They approach. They kneel. They scream. They build walls. They drill. They study. They always come back. The montage ends on the player character, standing exactly where they are now, looking at the throne. The vision holds for 2 seconds. The player sees themselves from the throne's perspective. Then it ends.

When the vision clears, the figure's hands have moved. Palms down instead of palms up. The player did not see them move. Nothing else has changed.

---

## Scripted Events

First-playthrough triggers. These fire once per account — never on replay. They are designed to punctuate the level's pacing with moments of authored horror that the procedural/systemic design cannot replicate.

| # | Trigger | Event | Purpose |
|---|---------|-------|---------|
| 1 | Enter Sub-Basement Door | As the player descends, the door behind them slowly swings shut on its own. The bolts engage — the sound of old mechanisms locking. The player cannot return to the hospital (during this descent phase). | Commitment. No going back. Tone-setting. |
| 2 | First Burial Chamber entry | The player's flashlight illuminates a burial niche. A face is visible inside, eyes open, watching. The player blinks (simulated blink, 150ms). The niche is empty. The face was never there — or was it? | Introduce the unreliable perception theme. |
| 3 | Flooded Gallery midpoint | The water surface disturbs violently 5 studs from the player — a large splash, as if something surfaced and re-submerged. The ripples hit the player character. Nothing attacks. The Crawlers are not responsible (they don't splash — this was something else. It is never explained). | Threat escalation. The Crawlers are not the only thing in the water. |
| 4 | Examine the Chapel basin | The 5-second vision: the chapel intact, worshippers present, the basin full, the figure at the altar. When the vision ends, the candles are out. They relight slowly. The player's flashlight was off during the vision — it turns back on with the candle glow. | Lore delivery. Atmosphere. The chapel's history is active, not past. |
| 5 | First Echo Chamber entry | The player hears their own voice. Not breathing — voice. Their username spoken aloud in a flat, inflected tone. The sound comes from a tunnel the player has not entered. It repeats once, then silence. | Personalization. The Warren knows who you are. |
| 6 | Mirror Room — first reflection discrepancy | The player approaches a mirror surface. Their reflection makes eye contact (the reflected model's head turns to face the camera directly, even if the player model is not facing the mirror). Holds for 1 second. Reflection returns to normal. | The mirrors are watching. Setup for Mimic emergence. |
| 7 | The Narrow — squeeze point 1 | During the first squeeze animation (1 second, player locked), the sound behind the player surges — scraping, breathing, close. When the animation ends and the player can look around (in the tight space, only backward), nothing is visible. But the sound continues, slightly farther away. | The Narrow is being followed. No safety. |
| 8 | Enter the Sanctuary (Central Chamber) | The bioluminescent glow on the floor diagram activates in a wave from the player's feet outward — as if the diagram is responding to their presence. The wave reaches the walls and pulses once. The ambient drone shifts to a resonant tone. A sound like a deep breath — the chamber inhaling. | Awe. Scale shift. The Sanctuary is alive. |
| 9 | Throne — Final Vision completion | See Throne section. The hands move. Palms up to palms down. | The lore climax. The thing is aware. It acknowledged the player. |
| 10 | Seal — the voice speaks the player's name | When the player approaches the Seal for the final interaction, the voice from the crack says the player's in-game username. Then one of 8 randomly selected lines (see below). Then silence. The choice prompt appears. | Personalization. The final moment before the decision. |

### Seal Voice Lines (Randomly Selected, 1 Per Run)

1. *"You came further than the others."*
2. *"I have been waiting for someone who would choose."*
3. *"They built walls. You will do more. Or less."*
4. *"The seal is a door. All doors open eventually."*
5. *"I am not what you think. I am not what they think. I am what is underneath thinking."*
6. *"If you leave me here, I will still be here when they come again. And they will come again."*
7. *"If you break me open, you break everything open. The cracks don't stop at stone."*
8. *"Choose. I have waited long enough for someone to choose."*

---

## Loot Table Summary

Level 5 is resource-scarce by design. The player should feel the desperation of dwindling supplies. The loot economy is balanced so that a skilled player can survive with careful resource management, but there is no surplus. Every battery matters. Every bandage is a decision.

### Consumable Loot

| Item | Total Available | Guaranteed | Conditional | Per-Zone Distribution |
|------|----------------|------------|-------------|----------------------|
| Battery | 8-10 | 5 | 3-5 @ 40-70% | Entry: 1, Catacombs: 2-3, Warren: 2-3, Sanctuary: 2 |
| Bandage | 6-8 | 4 | 2-4 @ 30-50% | Entry: 1, Catacombs: 2, Warren: 1-2, Sanctuary: 1, Narrow: 1 |
| Medkit | 2-3 | 1 (Burial Chambers) | 1-2 @ 50% | Catacombs: 1-2, Sanctuary: 0-1 |
| Flare | 3-4 | 2 (Flooded Gallery, Pillar Hall) | 1-2 @ 30-50% | Catacombs: 1-2, Warren: 0-1, Sanctuary: 1 |

### Lore Items

| Item | Location | Content Summary |
|------|----------|----------------|
| Excavation Log, 1987 | Entry alcove | Blackpoint breaching the outer wall |
| Monastery Journal Fragment | Stone Corridors | Brother Aldric on the singing below |
| Blackpoint Field Report | Burial Chambers (sarcophagus) | Patient 31's recovery from the sarcophagus |
| Water-Damaged Journal | Flooded Gallery | The water as defense mechanism |
| Chapel Fresco Notes (x7) | Desecrated Chapel | Each fresco panel described |
| Father Maren's Confession | Desecrated Chapel (altar) | The founder's guilt. The hospital is penance. |
| Blackpoint Audio Transcript | Echo Chamber (variant-dependent) | Dr. Harlan on acoustic anomalies |
| Patient 31 — Personal Effects | Mirror Room | The person before the entity. Photograph, bracelet, note. |
| Carved Column Fragment | Pillar Hall | The columns record the future |
| Throne Examination (x4) | The Throne | Figure, throne, dais, walls |
| The Final Vision | The Throne (auto) | Centuries of visitors, seen from the throne |

**Total Lore Items: 18 (+ 5 floor diagram entries in Central Chamber = 23)**

This is the largest lore payload of any level. Full collection requires careful exploration under extreme threat. Players who find everything understand the complete narrative. Players who find nothing can still complete the level — they just won't know why.

### Resource Pacing Intent

| Phase | Battery State | Health State | Intended Feeling |
|-------|-------------|-------------|-----------------|
| Entry + Early Catacombs | Fresh battery, 1 spare | Full (4 pips) | Cautious confidence |
| Late Catacombs (Flooded Gallery) | First battery draining | 3-4 pips (Crawler encounters) | Tension rising |
| Warren (early) | Battery change needed | 2-4 pips depending on skill | Anxiety — resources dwindling |
| Warren (Mirror Room) | Second battery, maybe third | Variable — Mimic deals 2 pips | Desperation begins |
| The Narrow | Battery critical | Variable — no healing opportunity during traversal | Survival mode |
| Sanctuary | Last batteries | 1-3 pips, limited healing available | Final push |
| Collapse / Escape | Whatever remains | Whatever remains | No time to loot — run with what you have |

---

## Critical Path

```
SPAWN (Hospital Basement — Sub-Basement Door)
    ↓
DESCEND — Entry stairwell. Collect initial loot. Atmospheric transition.
    ↓
UPPER CATACOMBS — Stone Corridors → navigate past The Patient (Evolved)
    ↓                └── [Optional] Burial Chambers (Medkit + lore, high risk)
FLOODED GALLERY — Wade through, avoid Aquatic Crawlers
    ↓                └── [Optional] Submerged side alcove (Flare + Medkit)
DESECRATED CHAPEL — Safe room. Read lore. Prepare for the Warren.
    ↓
DESCENT PASSAGE — One-way drop. Point of no return from Catacombs.
    ↓
THE WARREN — Navigate semi-procedural tunnels
    ↓         ├── Echo Chambers (sensory disruption, Mimic ambush)
    ↓         ├── MIRROR ROOM (mandatory — Mimic reflection encounter)
    ↓         └── Read environmental cues: airflow, warmth, symbol density
    ↓
THE NARROW — Crawlspace gauntlet. Juvenile Crawlers. No hiding, no sprinting.
    ↓
THRESHOLD GATE — Point of no return from Warren. Door seals.
    ↓
THE SANCTUARY — Central Chamber. Examine floor diagram. [Optional lore x5]
    ↓
PILLAR HALL — Watcher gauntlet. Manage line of sight. Use flare if available.
    ↓
THE THRONE — Lore climax. Examine the Original Entity. [Lore x4 + vision]
    ↓
THE SEAL — CHOICE: Reinforce (Ending A) or Destroy (Ending B)
    ↓
COLLAPSE SEQUENCE — Timed escape. 4:30 (A) or 3:30 (B). Run.
    ↓
    ├── Sanctuary (modified) → Warren (shortcut/collapse) → Catacombs (collapsing)
    ↓
SURFACE — Emerge from Hospital. Dawn.
    ↓
ENDING A: Hospital stands. Seal holds. Crack glows.    "The cycle continues."
ENDING B: Hospital collapses. Seal broken. Nothing left. "The cycle ends."
```

---

## Timing

| Metric | Duration | Notes |
|--------|----------|-------|
| Minimum completion (experienced, no exploration) | ~15 minutes | Speedrun-viable. Skips all optional lore, minimal loot. Requires knowledge of Warren cue system. |
| Average first completion (with deaths) | ~35-50 minutes | Multiple deaths expected. Warren navigation takes 10-15 minutes on first run. |
| Full exploration (all lore, all optional areas) | ~55-70 minutes | Requires systematic Warren exploration (dead ends have lore), full Throne examination, all Catacomb side areas. |
| Collapse Sequence only | 3:30 - 4:30 | Timer-driven. Cannot extend. |

### Per-Zone Expected Duration (First Playthrough, No Deaths)

| Zone | Expected Time | Notes |
|------|--------------|-------|
| Entry | 1-2 min | Atmospheric, no threat |
| Upper Catacombs (all sub-areas) | 8-12 min | Patient encounters, Flooded Gallery tension, Chapel lore reading |
| The Warren (all sub-areas) | 10-18 min | Procedural navigation, Mirror Room, Echo Chambers. Highly variable. |
| The Narrow | 2-3 min | Fixed length, pure tension |
| The Sanctuary (all sub-areas) | 8-12 min | Pillar Hall Watcher gauntlet, Throne lore, Seal choice |
| Collapse Sequence | 3:30 - 4:30 | Timer-locked |
| **Total** | **~33-52 min** | Longest level in the game by 1.5-2x |

---

## Multiplayer Scaling

Level 5 has the most aggressive multiplayer scaling in the game. The design intent: co-op should not make Level 5 easier. More players means more noise, more entity aggression, more chaos. The advantage of having teammates is offset by the amplified threat.

### Entity Scaling

| Entity | Solo | 2 Players | 3 Players | 4 Players |
|--------|------|-----------|-----------|-----------|
| The Patient (Evolved) | 1 | 1 | 2 | 2 |
| Crawlers (Aquatic) | 2 | 3 | 4 | 5 |
| Crawlers (Juvenile) | 1 | 2 | 2 | 3 |
| The Mimic (Evolved) | 2 roaming + Mirror Room | 3 roaming + Mirror Room | 4 roaming + Mirror Room (2 clones) | 5 roaming + Mirror Room (3 clones) |
| Watchers (Evolved) | 4 | 6 | 7 | 8 |

### Mechanical Scaling

| Element | Solo | 2 Players | 3 Players | 4 Players |
|---------|------|-----------|-----------|-----------|
| Patient activation delay | 45s | 30s | 20s | 15s |
| Patient patrol speed | 1.4x base | 1.5x base | 1.6x base | 1.7x base |
| Warren critical path length | 12-18 nodes | 14-20 nodes | 16-22 nodes | 18-24 nodes |
| Mimic detection tells | More visible | Slightly less visible | Less visible | Minimum visibility |
| Watcher blink interval | 35-45s | 30-40s | 25-35s | 20-30s |
| Collapse timer (Ending A) | 4:30 | 4:15 | 4:00 | 3:45 |
| Collapse timer (Ending B) | 3:30 | 3:15 | 3:00 | 2:45 |
| Loot quantity | Base | +25% | +40% | +50% |
| Medkit spawns | 2-3 | 3-4 | 4-5 | 5-6 |

### Co-Op Specific Mechanics

| Mechanic | Implementation |
|----------|---------------|
| Separation Events | 2 mandatory (Warren entry splits party: 2 different tunnel entrances; Pillar Hall entry: staggered — players enter at 10-second intervals). 1 random (corridor collapse during Warren traversal). |
| Downed State | Active. Revive window: 30 seconds. Revived at 1 pip. Downed players' panicked breathing is audible to entities (50-stud radius). |
| Voice Chat Distortion | Echo Chambers distort proximity voice (echo processing). The Narrow muffles voice (low-pass filter). The Sanctuary adds reverb. The Mimic can replay voice snippets. |
| Seal Vote | See Choice Design section. Players vote. Majority wins. |
| Collapse: player death | If a player dies during the Collapse, they are dead — no downed state during the timed escape. Surviving players continue. If ALL players die, the run fails. |
| Extraction: partial survival | If at least 1 player escapes, the run is a success. Dead players receive the ending cinematic but with a different frame: they see the surface from below, fading to black. They did not make it out. Their sacrifice is acknowledged in the ending text. |

### Co-Op Unique Events

| Event | Trigger | Effect |
|-------|---------|--------|
| The Mimic speaks | A player speaks in proximity voice near a Mimic | The Mimic replays the voice line 15-30 seconds later from a different position. Slightly distorted. Players hear their teammate's voice from the wrong direction. |
| Patient Resonance cascade | Patient enters HUNT in co-op | All entities in adjacent zones enter INVESTIGATE. In 3-4 player games, this can cascade — one player's mistake triggers level-wide entity activation. |
| Warren split | 2+ players enter Warren | Players are routed to different tunnel entrances. They must navigate independently and reunite at the Mirror Room (or later). Proximity voice does not carry between separated Warren branches. |
| Pillar Hall stagger | 2+ players reach Pillar Hall | Only 1 player can enter at a time. 10-second delay between entries. Early players must manage Watchers while waiting for teammates. Late players enter a hall where Watchers have already repositioned. |
| Collapse: fall behind | A player is 40+ studs behind the group during Collapse | That player's screen adds a unique audio layer: the voice from the Seal whispering *"Hurry."* Repeated. Getting louder. |

---

## Lore Payoff

Level 5 connects every narrative thread from the campaign. A player who has collected lore across all five levels can assemble the complete story. A player who hasn't will still experience Level 5 as a coherent horror narrative, but the full picture requires the full collection.

### The Complete Story (For Internal Reference)

1. **The Wound**: Beneath what would become St. Maren, there has always been a place where reality is thin. Not a portal, not a gate — a wound. A place where the boundary between existence and not-existence is eroded. The wound has existed since before human settlement.

2. **The Original Entity**: The first thing to emerge from the wound. Not a creature — a crystallization of the boundary's instability. It sat at the wound's center and its presence widened the crack, slowly, over millennia. The civilizations that found it interpreted it through their own lenses: a god, a demon, a prisoner, a king. They built the throne. They built the seals. They built the walls. None of it contained the wound — it only slowed the leaking.

3. **Father Maren**: In the early 20th century, a priest named Maren discovered the catacombs beneath the monastery. He understood (partially) what was below. Rather than expose it, he built over it — literally. St. Maren's Hospital was constructed as a modern seal: a building full of people, full of light, full of life, placed directly on top of the wound. His theory: human presence strengthens the boundary. The hospital was penance and prison simultaneously.

4. **Project ECHO (1980s-2000s)**: The government became aware of anomalous readings beneath St. Maren's. Blackpoint, a covert research division, established the Coastal Research Station (Level 3) to study samples extracted from the catacombs. They drilled through the outer seal in 1987, accelerating the leaking. The entities began manifesting more frequently and more powerfully.

5. **Patient 31**: A Blackpoint researcher exposed to catacomb material during the 1987 breach. Admitted to St. Maren's psychiatric ward when his body began changing. He was the first modern human vessel for the wound's influence — not possessed, but overwritten. His cell writings (the symbols repeated thousands of times) were his attempt to reinforce the seal from inside his own mind. It failed. He became the Patient — the first entity to escape the sub-basement.

6. **The Crawlers (Subway — Level 2)**: The subway system's Line 13 tunnels intersect the catacomb network at depth. When the 1987 breach widened the wound, the boundary leaked into the tunnels. The Crawlers emerged — pack entities that represent the wound's hunger, its drive to spread and consume. The subway's confined spaces and flooding (from catacomb water systems) created their ideal habitat.

7. **The Mimic (Research Station — Level 3)**: At the Coastal Research Station, Blackpoint attempted to communicate with catacomb samples. The samples learned. The Mimic emerged as the wound's most sophisticated expression — an entity that understands human perception and exploits it. It learned to look like objects, people, safety. It is the wound's intelligence.

8. **The Watchers (Forest — Level 4)**: The outermost ring of influence. The Watchers appeared in Ashwood Forest when the wound's influence reached the surface perimeter. They are the wound's attention — passive observers that only act when unobserved, as if reality only breaks down when no one is looking. The Ring of trees they won't enter (Level 4) is the last natural barrier — old growth that predates human settlement, roots reaching deep enough to touch the intact portions of the boundary.

9. **The Seal**: Built and rebuilt by every civilization that settled here. The current Seal is a composite — layers of containment from different eras, different methods, different understandings. The iron bands are modern (Blackpoint, 1990s). The stone slab is medieval. The symbols are older than that. The crack is from the 1987 drill breach. The Seal does not contain the wound — it contains the Original Entity, which widens the wound. Remove the entity (by destroying the Seal and collapsing the site), and the wound closes naturally. Leave the entity (by reinforcing the Seal), and the wound remains — managed, not healed.

10. **The Choice**: Reinforcing the Seal is the compassionate choice — it preserves the status quo, prevents immediate destruction, but guarantees the cycle will repeat. Destroying the Seal is the ruthless choice — it ends the threat permanently but at the cost of everything above: the hospital, potentially lives, and the Original Entity itself (which, the lore hints, may be as much a victim as a threat — trapped at the wound's center, unable to leave, unable to die).

### Lore Thread Connections (What Players Piece Together)

| Thread | Introduced In | Resolved In Level 5 |
|--------|--------------|---------------------|
| Patient 31's identity | L1: Incident Report, Patient Chart | L5: Blackpoint Field Report (sarcophagus), Patient 31 Personal Effects (Mirror Room) — he was a researcher, recovered from the sarcophagus, overwritten |
| The symbols | L1: Patient 31's cell walls | L5: Chapel, Corridors, Seal — the symbols are containment engineering, not language |
| Blackpoint / Project ECHO | L3: Research Station logs | L5: Excavation Log, Audio Transcript, Field Report — ECHO's goal was to study and weaponize the wound. They failed. |
| The Sub-Basement Door | L1: Sealed door, single knock | L5: The player opens it. The knock was the Patient, returned to its origin, trying to come home. |
| The water | L2: Flooded subway tunnels | L5: Flooded Gallery, Water-Damaged Journal — the water is the wound's immune response, a barrier, not a flood |
| The forest ring | L4: Circle of trees entities won't enter | L5: Floor Diagram Ring 4 — the Ring's roots touch the intact boundary. Natural containment predating human efforts. |
| Father Maren | L1: Hospital name, chapel | L5: Father Maren's Confession — the hospital is a deliberate seal, not an innocent building |
| What the entities are | All levels (individual encounters) | L5: Frescoes, Throne examination — they are aspects of the wound, not separate creatures. Patient = loneliness, Crawlers = hunger, Mimic = intelligence, Watchers = attention. |

---

## Appendix A: Audio Design Notes

### Ambient Sound Layers (Per Zone)

| Zone | Layer 1 (Background) | Layer 2 (Environmental) | Layer 3 (Tension) |
|------|---------------------|------------------------|-------------------|
| Entry | Hospital HVAC fading out | Dripping water, stone settling | Sub-bass drone (Tier 0 baseline) |
| Stone Corridors | Deep silence with micro-echoes | Footstep reflections, distant groans | Sub-bass drone (constant) |
| Burial Chambers | Total silence | Player sounds only | Silence IS the tension layer |
| Flooded Gallery | Water ambience (lapping, dripping) | Wading sounds, underwater muffling | Ripple impacts, aquatic Crawler sonar ping |
| Desecrated Chapel | Warm resonance (the room hums) | Candle hiss, stone ambience | Tonal drone (not threatening — contemplative) |
| Warren Tunnels | Variable per tile (dripping, air movement, scraping) | Echo distortion in Echo Chambers | Mimic acoustic mimicry layer |
| Mirror Room | High-frequency whisper bed | Reflection discrepancy sounds (subtle) | Proximity Fear Tier 1 baseline |
| The Narrow | Amplified player breathing and movement | Stone scraping (Crawler behind) | Claustrophobia audio: compressed dynamics, tight reverb |
| Central Chamber | Cathedral reverb on all sounds | Bioluminescent pulse tone (sub-audible) | Proximity Fear Tier 1 baseline |
| Pillar Hall | Dead acoustics (no reverb, no echo) | — | Proximity Fear Tier 2 baseline. Heartbeat. |
| Throne | Near-silence | Sub-bass vibration (felt, not heard) | Proximity Fear Tier 3 baseline |
| Seal | Near-silence | Voice from the crack | Proximity Fear Tier 3 baseline |
| Collapse | Deafening — all layers at maximum | Structural collapse, debris, fire (Ending B) | Dissonant brass, sustained tones, player screaming |

### Music

Level 5 has no traditional music until the Collapse Sequence. The absence of music is deliberate — the player has had musical stings and tension cues in previous levels. Level 5 removes them. The drone, heartbeat, and environmental audio do all the work. The player misses the music subconsciously — its absence is part of the wrongness.

During the Collapse: a full orchestral/dissonant brass score kicks in. This is the first and only time Level 5 has music. It is overwhelming by design — the contrast with the preceding silence makes it feel like the world is ending. Because it is.

---

## Appendix B: Lighting Design Notes

### Light Sources

| Source | Zones | Behavior |
|--------|-------|----------|
| Player flashlight | All | Primary light source. ~15 stud range (reduced in some zones). Battery-dependent. |
| Bioluminescence | Central Chamber, Seal alcove | Cold blue-green glow. Pulses slowly. Responds to player movement (pulses faster). Provides ambient illumination — flashlight optional but visibility is low. |
| Chapel candles | Desecrated Chapel | Warm orange-yellow. Flickering. Provides full illumination in the chapel (the only well-lit room in the level). |
| Fire (Ending B Collapse) | Warren, Catacombs during Collapse | Warm orange. Bright but chaotic. Gas pocket ruptures create fire columns that illuminate and block corridors. |
| Dawn light (Surface) | Hospital exit, exterior | The first natural light in the entire game. Warm. Gradual. Beautiful. The relief is visual. |

### Darkness Philosophy

Level 5 is the darkest level in the game. The flashlight is life. Without it, the player sees nothing. The darkness is not decorative — it is functional. Enemies use darkness. The player's flashlight reveals and betrays simultaneously. The bioluminescence in the Sanctuary offers relief but is unreliable (it pulses, creating periods of near-darkness). The chapel candles are the only dependable light source, and they are in a room the player passes through once.

The dawn light at the end is earned. Five levels of darkness end with sunrise. It should feel like emerging from a nightmare. Because it is.

---

## Appendix C: Difficulty Modifiers (Unlockable)

After completing Level 5 at least once, players unlock difficulty modifiers for replay:

| Modifier | Effect | Reward Multiplier |
|----------|--------|-------------------|
| No Flashlight | Flashlight disabled. Bioluminescence and fire only. | 3x XP |
| Permadeath | No retry. One life. Death ends the run permanently (must restart from Level 5 entry). | 2.5x XP |
| Accelerated Collapse | Collapse timer reduced by 30%. | 2x XP |
| All Entities Enhanced | All evolved forms gain additional speed (+20%) and detection range (+20%). | 2x XP |
| The Warren Remembers | Warren procedural generation disabled. Fixed layout from first completion. Entities have pre-learned patrol routes. | 1.5x XP |
| True Darkness | All light sources except flashlight disabled. No bioluminescence. No candles. No fire. | 3x XP |
| Solo Mandatory | Co-op disabled for this run. | 1.5x XP |

Modifiers stack. A player running No Flashlight + Permadeath + Accelerated Collapse receives 7.5x XP. They will also probably die. This is expected.
