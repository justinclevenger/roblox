# Level 3: Blackpoint Research Station — Detailed Design

## Table of Contents

- [Narrative Setup](#narrative-setup)
- [Level Overview](#level-overview)
- [Floor Plan](#floor-plan)
- [Room-by-Room Details](#room-by-room-details)
  - [Surface Level](#surface-level)
  - [Lab Level](#lab-level)
  - [Deep Level](#deep-level)
  - [Dock (Extraction)](#dock-extraction)
- [The Mimic — Entity Design](#the-mimic--entity-design)
- [Scripted Events](#scripted-events-first-playthrough-only)
- [Loot Table Summary](#loot-table-summary)
- [Critical Path](#critical-path)
- [Timing](#timing)
- [Multiplayer Scaling](#multiplayer-scaling)
- [Project ECHO Lore](#project-echo-lore)

---

## Narrative Setup

Blackpoint Research Station was built in 1987 on a remote stretch of the northern coast, 40 kilometers from the nearest road. Its public designation was "NOAA Blackpoint Marine Observatory" — a weather monitoring facility. Its actual purpose was containment and study of anomalous biological specimens recovered from beneath St. Maren's Hospital.

After the events in the hospital's sub-basement were classified in 1983, a joint DoD-CDC task force established **Project ECHO** to understand the entities discovered below the hospital. Specimens were extracted and transported to Blackpoint via unmarked cargo ships. The station's remote coastal location was chosen for isolation: if containment failed, there would be no civilian population for 40 kilometers in any direction.

For six years, Blackpoint operated as a research facility studying Entity-03 — designated "The Mimic" after researchers discovered its ability to replicate the physical appearance of objects and, eventually, people. Unlike the Patient (Entity-01) or the Crawlers (Entity-02), the Mimic demonstrated intelligence. It learned. It adapted. It mimicked not just form but behavior, testing its disguises against researchers with increasing sophistication.

On the night of September 14, 1993, the Mimic breached Cell Block A. Security footage shows it walking through the containment wing disguised as Dr. Elena Vasquez — the facility director — passing three security checkpoints before anyone realized the real Vasquez was still in her office. By the time the alarm sounded, the Mimic had reached the surface level. An emergency helicopter evacuation was attempted. Half the staff made it out. The rest did not. Blackpoint was sealed and abandoned.

Thirty years later, a routine satellite survey flags anomalous thermal signatures from the station. A team is sent to investigate and recover Project ECHO data from the facility's servers — data that may explain the origin of all the entities. The helicopter lands on the helipad. The pilot says he will circle back in 90 minutes. Players enter the Administrative Building.

They will not hear from the pilot again. When they return to the helipad, the helicopter is wrecked, its rotors twisted, its cabin crushed as though something fell on it from above. There is no wreckage consistent with a crash. There is no pilot. His headset hangs from the buckled cockpit frame, transmitting static.

The only other way off the island is the emergency dock on the station's east shore. The boat requires fuel and the director's extraction codes. Both are somewhere inside the station.

**Connection to previous levels:** Shipping manifests found in St. Maren's Hospital basement (Level 1) referenced "Blackpoint Coastal Facility." Graffiti in Line 13 (Level 2) read "THEY TOOK IT TO BLACKPOINT." This is where it was taken. This is where Project ECHO studied it. And this is where it learned to become something far worse than what was found beneath the hospital.

---

## Level Overview

| Parameter | Value |
|-----------|-------|
| Level Number | 3 of 5 |
| Location | Blackpoint Research Station, remote northern coast |
| Entity | The Mimic (Entity-03) |
| Entity Count | 1 (appears as many) |
| Primary Sense | Vision |
| Patrol Speed | Medium |
| Chase Speed | Medium |
| Detection Ramp | 2.0 seconds (deceptive — slow enough to lure you closer) |
| Hiding Spot Checks | Does not check hiding spots — mimics them instead |
| Primary Theme | Paranoia. Trust nothing you see. |
| Structure | 4 tiers: Surface, Lab, Deep, Dock |
| Primary Objective | Recover director's codes + upload Project ECHO data |
| Extraction | Emergency dock — boat requires fuel + codes |
| Session Target | 12-30 minutes |

### Design Philosophy

Levels 1 and 2 trained players in two survival vocabularies: darkness/sound (The Patient) and speed/claustrophobia (The Crawlers). Level 3 discards both. The Mimic is not fast. It is not loud. It does not patrol aggressively. Instead, it is *already in the room with you*, disguised as a chair, a medkit, a teammate. The horror of this level is epistemological — the player cannot trust their own perception. Every object becomes suspect. Every supply pickup becomes a gamble. In multiplayer, every teammate becomes a potential threat.

The Proximity Fear System behaves differently here. Because the Mimic may be disguised as an object three studs away, the system will fire at Tier 3-4 intensity while the player sees nothing threatening. This creates a unique dread: the screen says PANIC but the room looks empty. The player knows something is wrong but cannot identify what. This is the intended experience.

The level's pacing is slower and more exploratory than Levels 1-2. Extended periods of apparent safety punctuated by the dawning realization that something in the room has changed. A chair has moved. There are two fire extinguishers where there was one. Your teammate is standing at the end of the hallway but they are also standing next to you.

---

## Floor Plan

```
                            BLACKPOINT RESEARCH STATION
                              Coastal, Remote North

                         N
                         ↑
    ═══════════════════════════════════════════════════════
    ║                   PERIMETER FENCE                    ║
    ║                  (Fog beyond fence)                   ║
    ║                                                       ║
    ║   ┌─────────────────────────────────────────────┐     ║
    ║   │              SURFACE LEVEL                   │     ║
    ║   │                                              │     ║
    ║   │   [HELIPAD]          ┌───────────────────┐   │     ║
    ║   │   (Entry/Spawn)      │  ADMIN BUILDING   │   │     ║
    ║   │   Helicopter wreck   │                   │   │     ║
    ║   │        ·             │ ┌────┐ ┌────────┐ │   │     ║
    ║   │        ·   path      │ │RCPT│ │OFFICES │ │   │     ║
    ║   │        ···········>  │ │    │ │ 1 2 3 4│ │   │     ║
    ║   │                      │ └────┘ └────────┘ │   │     ║
    ║   │                      │ ┌────────────────┐│   │     ║
    ║   │                      │ │DIRECTOR OFFICE  ││   │     ║
    ║   │                      │ │(Locked—keycard) ││   │     ║
    ║   │                      │ └────────────────┘│   │     ║
    ║   │                      └────────┬──────────┘   │     ║
    ║   │                               │              │     ║
    ║   │   ┌──────────────┐    ┌───────┴───────┐      │     ║
    ║   │   │   BARRACKS   │    │ SERVICE YARD  │      │     ║
    ║   │   │ Bunks/Lockers│    │  (connects    │      │     ║
    ║   │   │              │    │   to Lab       │      │     ║
    ║   │   │              │    │   elevator +   │      │     ║
    ║   │   │              │    │   stairwell)   │      │     ║
    ║   │   └──────────────┘    └───────┬───────┘      │     ║
    ║   │                               │              │     ║
    ║   └───────────────────────────────┼──────────────┘     ║
    ║                                   │                     ║
    ═══════════════════════════════════════════════════════════
                                        │
                            ════════════╪══════════════
                            ║  Elevator + Stairwell   ║
                            ║  (descent to Lab Level) ║
                            ════════════╪══════════════
                                        │
    ┌───────────────────────────────────┼──────────────────────────────┐
    │                           LAB LEVEL (B1)                         │
    │                        (Below Ground)                            │
    │                                                                  │
    │  ┌────────────────────────────────────────────────────────┐      │
    │  │              CONTAINMENT WING                          │      │
    │  │  ┌──────────────┐ ┌──────────────┐ ┌───────────────┐  │      │
    │  │  │ CELL BLOCK A │ │ CELL BLOCK B │ │ CONTAINMENT   │  │      │
    │  │  │ (shattered   │ │ (intact,     │ │ CONTROL       │  │      │
    │  │  │  glass)      │ │  mannequin?) │ │ (monitors)    │  │      │
    │  │  │ Cells A1-A4  │ │ Cells B1-B4  │ │               │  │      │
    │  │  └──────┬───────┘ └──────┬───────┘ └──────┬────────┘  │      │
    │  │         └────────────────┴────────────────┘            │      │
    │  │                CONTAINMENT CORRIDOR                     │      │
    │  └─────────────────────────┬──────────────────────────────┘      │
    │                            │                                      │
    │       ┌────────────────────┼───────────────────────┐             │
    │       │              LAB CORRIDOR                   │             │
    │       │  (Main artery — connects all lab areas)     │             │
    │       └──┬──────────┬──────────┬───────────┬───────┘             │
    │          │          │          │           │                      │
    │  ┌───────┴──┐ ┌─────┴─────┐ ┌─┴────────┐ ┌┴──────────────┐     │
    │  │ BIOLOGY  │ │  AUDIO    │ │OBSERV.   │ │  MEDICAL BAY  │     │
    │  │ LAB      │ │  LAB      │ │DECK      │ │  (Supplies,   │     │
    │  │(specimens│ │(recordings│ │(overlooks│ │   surgical    │     │
    │  │ in jars) │ │ attract/  │ │ Main     │ │   tools)      │     │
    │  │          │ │ repel?)   │ │ Chamber) │ │               │     │
    │  └──────────┘ └──────────┘ └─────┬────┘ └───────────────┘     │
    │                                  │                              │
    └──────────────────────────────────┼──────────────────────────────┘
                                       │
                            ═══════════╪═══════════
                            ║  Freight Elevator +  ║
                            ║  Ladder Shaft        ║
                            ═══════════╪═══════════
                                       │
    ┌──────────────────────────────────┼──────────────────────────────────┐
    │                          DEEP LEVEL (B2)                            │
    │                                                                     │
    │  ┌────────────────────────────────────────────────────────────────┐ │
    │  │                    MAIN CHAMBER                                │ │
    │  │              (Massive open excavation)                         │ │
    │  │              The original dig site.                            │ │
    │  │              Something unearthed here.                        │ │
    │  │                                                               │ │
    │  │  ┌──────────────┐              ┌────────────────────────────┐ │ │
    │  │  │  THE TANK    │              │     SERVER ROOM            │ │ │
    │  │  │  (Empty.     │              │     [OBJECTIVE: Upload     │ │ │
    │  │  │   What they  │              │      data + trigger        │ │ │
    │  │  │   kept it in)│              │      extraction signal]    │ │ │
    │  │  └──────────────┘              │     Noisy. Fans mask      │ │ │
    │  │                                │     sound.                 │ │ │
    │  │                                └────────────────────────────┘ │ │
    │  └────────────────────────────────┬──────────────────────────────┘ │
    │                                   │                                │
    │                    ┌──────────────┴──────────────┐                 │
    │                    │    EMERGENCY TUNNEL          │                 │
    │                    │    (Linear, long, dark.      │                 │
    │                    │     Connects to dock.)       │                 │
    │                    └──────────────┬──────────────┘                 │
    └──────────────────────────────────┼─────────────────────────────────┘
                                       │
    ┌──────────────────────────────────┼─────────────────────────────────┐
    │                       DOCK (EXTRACTION)                            │
    │                                                                    │
    │   ┌──────────────┐       ┌─────────────────┐                      │
    │   │  BOAT HOUSE  │───────│     PIER         │~~~~~ OPEN WATER ~~~~│
    │   │  (Boat +     │       │  (Extraction     │     Fog.            │
    │   │   fuel tank) │       │   point)         │                     │
    │   └──────────────┘       └─────────────────┘                      │
    │                                                                    │
    └────────────────────────────────────────────────────────────────────┘
```

### Connection Map (Adjacency)

```
HELIPAD ──── ADMIN BUILDING (Reception)
                  │
              Reception ──── Offices (1-4) ──── Director's Office [LOCKED]
                  │
             SERVICE YARD ──── BARRACKS
                  │
          Elevator/Stairwell
                  │
             LAB CORRIDOR ──── Containment Corridor ──── Cell Block A
                  │                    │                      │
                  │              Cell Block B           Containment Control
                  │
          ┌───────┼───────┬────────────┐
          │       │       │            │
     Biology   Audio   Observation   Medical
      Lab      Lab      Deck          Bay
                          │
                   Freight Elevator / Ladder Shaft
                          │
                     MAIN CHAMBER ──── Server Room [OBJECTIVE]
                          │                 │
                      The Tank        Emergency Tunnel
                                           │
                                      BOAT HOUSE ──── PIER [EXTRACTION]
```

---

## Room-by-Room Details

### Surface Level

---

#### Helipad (Spawn Point)

**Description:** A concrete landing pad on a coastal bluff. A chain-link perimeter fence rings the station complex. Wind howls. The helicopter that brought you here is wrecked — rotors bent, cockpit crushed inward. The pilot's headset dangles from the buckled frame, transmitting nothing but static. The damage is not consistent with a crash. Something broke this helicopter while it was on the ground.

**Atmosphere:** Overcast sky, grey-green coastal light. Wind-driven rain intermittent. Fog bank sits 50 meters beyond the perimeter fence and does not move. Occasional lightning illuminates the fog — something tall stands in it, matching your lateral movement. Never confirmed. Peripheral vision only.

**Gameplay Function:** Entry point and orientation. Establishes that there is no way back. Teaches players to look for environmental details (the helicopter damage tells a story). The fog perimeter prevents exploration outside the station. Approaching the fence triggers a disorientation effect identical to Level 1's fog wall — the player turns around involuntarily.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | Helicopter cargo hold | 100% |
| Bandage | Helicopter cargo hold | 100% |
| Flare | Pilot's bag (ground near wreck) | 60% |

**Lore Items:**
- `Pilot's Flight Log` — On clipboard near wreck. Last entry: "Thermal reading confirmed. Something is alive down there. ETA 14:00. Return for pickup at 15:30." No return flight was logged.
- `Pilot's Headset` — Interactable. 3 seconds of static, then a garbled voice that might be the pilot saying "It looked like me" before cutting to dead air.

**Hiding Spots:** None. Open area. Players are exposed.

**Mimic Behavior:** The Mimic does not appear at the helipad. However, on returning to the surface later in the run, the helicopter wreck may have a new detail: a second pilot's headset that was not there before. Interacting with it triggers an attack. Shadow tell: the headset casts no shadow.

---

#### Administrative Building — Reception

**Description:** The main entrance to the station. A single-story concrete building with government-standard architecture — drop ceilings, fluorescent lighting (dead), linoleum floors. A reception desk faces the entrance. Behind it, a welcome sign reads "NOAA BLACKPOINT MARINE OBSERVATORY — AUTHORIZED PERSONNEL ONLY." A photo board on the wall shows staff portraits. Seven of the twelve faces have been scratched out with something sharp. The remaining five are the research team. Their expressions look wrong — smiles that don't reach the eyes, or smiles that are slightly too wide.

**Atmosphere:** Stale air. Papers scattered on the floor. The fluorescent lights try to flicker on when the player enters — one tube buzzes to life for 3 seconds, illuminating the room in harsh white, then pops and dies. After that, flashlight only. Dust particles visible in the flashlight beam.

**Gameplay Function:** Hub room for the Surface Level. Three exits: front door (helipad, one-way — locks behind player), hallway to Offices, and corridor to Service Yard. First opportunity to establish the Mimic's presence via environmental storytelling (the scratched photos — which staff members were replaced?).

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | Reception desk drawer | 70% |
| Bandage | First aid box on wall | 50% |

**Lore Items:**
- `Visitor Log` — On reception desk. Last entry dated September 14, 1993: "Inspection team — DoD. 3 members. Cleared by Director Vasquez." A handwritten note in the margin: "Only 2 arrived. Who was the third?"
- `Staff Photo Board` — Environmental lore. Seven scratched faces. Five intact: Dr. Elena Vasquez (Director), Dr. James Harlan (Biology), Dr. Yuki Tanaka (Audio Research), Marcus Webb (Security Chief), Sarah Chen (Medical). These names appear throughout the facility.

**Hiding Spots:**
- Under reception desk (crouch) — Standard hiding spot. Entity cannot see player from hallway.
- Behind overturned filing cabinet — Partial concealment. Entity can detect if within 8 studs.

**Mimic Behavior:** After the player's first visit to the Lab Level and return to the surface, the reception area may contain a duplicate object: two identical reception desk phones. One is real (interactable, no function). One is the Mimic. Shadow tell: the Mimic phone has a slightly elongated shadow, or no shadow at all if the ambient light source does not produce one. Interacting with the Mimic phone triggers a grab attack (1 health pip damage, brief stun, Mimic retreats and vanishes).

---

#### Administrative Building — Offices (1-4)

**Description:** Four small offices branching off a single hallway from Reception. Standard cubicle-era layout: metal desks, rolling chairs, desktop computers (dead), filing cabinets. Each office belonged to a specific researcher and contains personalized details.

**Office 1 — Dr. James Harlan (Biology Lead)**
- Desk covered in specimen transport manifests. A terrarium sits on the shelf — empty, lid removed. Claw marks on the inside of the glass.
- Computer screen flickers when flashlight passes over it — brief display of a file directory titled "ENTITY-03 MORPHOLOGY" before dying.
- Framed photo: Harlan with his family at a beach. Behind the glass, a second photo is hidden underneath — same beach, same family, but Harlan's face in the second photo is subtly wrong. Wider jaw. Eyes too close together.
- **Loot:** `1x Battery [40%]`, `Lore: Specimen Transport Manifest`

**Office 2 — Dr. Yuki Tanaka (Audio Research)**
- Headphones on desk connected to a reel-to-reel recorder. The tape has been partially erased.
- Whiteboard filled with waveform sketches and a note: "Freq 18.97 Hz causes distress. Freq 23.40 Hz causes STILLNESS. It stops mimicking at 23.40. Why?"
- Desk drawer contains a cassette tape labeled "SESSION 14 — DO NOT PLAY OUTSIDE AUDIO LAB."
- **Loot:** `Cassette Tape (key item) [guaranteed]`, `Lore: Tanaka's Whiteboard Notes`

**Office 3 — Marcus Webb (Security Chief)**
- Gun safe — open, empty. Holster on desk, no weapon. Webb's security badge on the floor (damaged, not functional as keycard).
- Incident reports documenting containment breaches. The language escalates from clinical to desperate across five reports dated over two weeks.
- A hand-drawn map of the facility with certain rooms circled and annotated "CONFIRMED SAFE" or "COMPROMISED." The Lab Corridor is labeled "DO NOT ENTER ALONE."
- **Loot:** `1x Bandage [guaranteed]`, `Lore: Webb's Incident Reports (5 pages)`, `Lore: Webb's Facility Map`

**Office 4 — Sarah Chen (Medical Officer)**
- Medical charts for all staff. Notes track anomalous symptoms: "Subject reports seeing duplicate objects. Subject reports colleague behaving strangely. Subject reports being in two places at once."
- One chart is for Chen herself. Final entry: "I am writing this to confirm I am Sarah Chen. I am Sarah Chen. I am Sarah Chen." Repeated for the rest of the page.
- Locked medicine cabinet (requires Medical Bay key, found in Medical Bay). Contains high-value medkit.
- **Loot:** `1x Medkit [in locked cabinet]`, `Lore: Staff Medical Charts`

**Atmosphere:** Offices are claustrophobic. Low ceilings, no windows. The hallway connecting them is narrow — two people cannot pass without one pressing against the wall. Flickering emergency lighting in the hallway provides intermittent dim red illumination.

**Gameplay Function:** Primary lore delivery for Project ECHO's final days. The Cassette Tape from Office 2 is a key item used in the Audio Lab below. Webb's hand-drawn map serves as an in-world guide to the facility layout.

**Hiding Spots (per office):**
- Under desk (each office) — Standard. Effective until entity adapts.
- Inside filing cabinet (Office 3 only) — Large floor cabinet. Player fits inside. Door partially open — can see out.

**Mimic Behavior:** The Mimic favors the office hallway. After first encounter (Lab Level), it may appear as a rolling chair in the hallway that was not there before. If the player walks past it, nothing happens. If they return the same way, the chair is now 2 meters closer to them. Shadow tell: the chair has no shadow. If the player approaches and interacts, the chair is real (50% chance) or the Mimic (50% chance — attack). The randomization is per-run, determined at level generation.

---

#### Administrative Building — Director's Office

**Description:** Corner office, larger than the others. A mahogany desk, leather chair, bookshelves, a small conference table. A window overlooks the Service Yard. The room is locked with an electronic keycard reader. The door is reinforced steel — cannot be forced.

**Atmosphere:** Better furnished than the rest of the building. This was someone with authority. A half-finished glass of whiskey sits on the desk, still smelling faintly of alcohol. The leather chair is pushed back as though someone stood up quickly. A framed commendation from the Department of Defense hangs on the wall, name blacked out with marker.

**Gameplay Function:** Contains the **Extraction Codes** (key item) required for the boat at the dock. The door requires the **Director's Keycard**, which is found in the Containment Control room on the Lab Level. This creates a loop: players must go underground to get the keycard, then return to the surface to access this office, then go back underground to the Server Room and eventually to the Dock.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Extraction Codes | In desk safe (combination on Director's PC) | 100% (key item) |
| Battery | Desk drawer | 100% |
| Medkit | Conference table first aid kit | 60% |
| Flare | Desk drawer | 40% |

**Access Sequence:**
1. Use Director's Keycard on reader (swipe animation, 2 seconds)
2. Door unlocks with heavy mechanical clunk
3. Enter office
4. Director's PC boots automatically when approached — displays a 4-digit safe combination (randomized per run)
5. Safe under desk — enter combination — retrieve Extraction Codes
6. PC displays final email from Vasquez as player takes codes (see Lore)

**Lore Items:**
- `Director Vasquez's Final Email` — Displayed on PC after safe is opened. Addressed to "ECHO OVERSIGHT COMMITTEE." Content: "Entity-03 has been out of containment for at least 72 hours. We did not know. It was one of us. I believe it has been one of us for weeks. I am evacuating all personnel I can confirm are human. The confirmation protocol is shadow verification — it cannot replicate shadows accurately. I am uploading all research data to the isolated server cluster on B2. If we do not make it out, someone must retrieve that data. The entity must not reach the mainland. God help us, I think it already has. I think it reached St. Maren's before we ever brought it here. We didn't extract it from the hospital. It LET us bring it here. — E.V."
- `Project ECHO Authorization Letter` — In desk drawer. Heavily redacted. Confirms the project's purpose: "containment and study of anomalous biological entities recovered from Site Alpha (St. Maren's Hospital sub-basement)."

**Hiding Spots:**
- Under conference table — Standard hiding spot.
- Behind bookshelf (narrow gap between shelf and wall) — Tight. Player can squeeze in.

**Mimic Behavior:** When the player first enters the Director's Office, there is a 30% chance the leather chair behind the desk is the Mimic. Shadow tell: the chair's shadow is slightly too large and doesn't match the chair's shape. If the player sits in the chair (interact prompt: "Sit") — it's always safe. The Mimic only attacks if the player turns their back on it and faces the safe. Attacking from behind: 2 health pip damage (ambush bonus). This teaches players to check shadows before turning their back on anything.

---

#### Barracks

**Description:** A long, low building adjacent to the Admin Building. Two rows of six bunk beds. Metal lockers line one wall. A communal bathroom at the far end. Personal effects scattered: boots under bunks, photos taped to locker interiors, a deck of cards mid-game on a footlocker. Everything suggests a fast evacuation — bedsheets thrown back, locker doors hanging open, a knocked-over coffee mug still staining the concrete floor.

**Atmosphere:** Institutional and bleak. The wind is audible through thin walls. Rain spatters against a high window. A battery-powered emergency light near the bathroom door blinks red at 2-second intervals, creating a rhythmic pulse of dim crimson light. One bunk has been dismantled and used to barricade the bathroom door from the outside. Something scratches behind the door at irregular intervals.

**Gameplay Function:** Supply cache and atmospheric storytelling. The barricaded bathroom is a risk/reward choice: breaking the barricade (loud, 8 seconds) reveals the bathroom which may contain supplies or may contain the Mimic.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | Locker 3 | 80% |
| Battery | Locker 7 | 40% |
| Bandage | Under bunk 4 | 60% |
| Bandage | Bathroom medicine cabinet (behind barricade) | 80% |
| Medkit | Bathroom medicine cabinet (behind barricade) | 30% |
| Flare | Footlocker near card game | 50% |

**Lore Items:**
- `Webb's Personal Journal` — Under Security Chief's pillow (Bunk 1, identifiable by holster hung on bed frame). Entries describe growing paranoia: "Tanaka was in the mess hall at 0800. I saw Tanaka in Cell Block B at 0800. I was looking at both of them. One of them saw me looking. It smiled."
- `Evacuation Notice` — Taped to the wall near the door. Official form, hastily stamped: "ALL PERSONNEL REPORT TO HELIPAD. CONFIRM IDENTITY VIA SHADOW PROTOCOL BEFORE BOARDING. NO EXCEPTIONS."

**Hiding Spots:**
- Under any bunk bed (12 available) — Standard. Multiple options makes this a relatively safe hiding area early in the run.
- Inside locker (3 are large enough) — Lockers 2, 5, 11. Standard concealment.
- Bathroom stall (if barricade removed) — Standard.

**Mimic Behavior:** The Barracks is a Mimic "nesting" area. After the player has visited the Lab Level at least once, returning to the Barracks may trigger a **Duplication Event**: one of the lockers that was previously open is now closed. Opening it reveals a duplicate of an item the player already picked up in this room (e.g., a second battery in Locker 3). This duplicate is always the Mimic. Shadow tell: the item inside the locker casts a shadow that does not match the locker's interior lighting angle.

The barricaded bathroom has a 40% chance of containing the Mimic (disguised as a bandage on the sink counter). If the bathroom does contain the Mimic, the scratching sounds stop when the barricade is removed — silence is the tell. If the bathroom is safe, the scratching sound is revealed to be a broken pipe fitting rattling in the wall.

---

#### Perimeter

**Description:** A chain-link fence with barbed wire tops encircles the station complex. Guard towers at two corners — both abandoned. The fence has a gate to the east (padlocked, no path beyond — fog) and a collapsed section to the north (also fog). Beyond the fence in every direction: dense fog that never lifts, never shifts. It sits like a wall.

**Atmosphere:** The most unsettling surface area. The fog is not natural — it has hard edges, almost geometric. Standing near the fence and looking into the fog, the player may see a silhouette that matches their own posture and movements with a 0.5-second delay. Turning the flashlight into the fog reveals nothing. The figure is only visible in peripheral screen space (rendered only in the outer 15% of the viewport, fading when the player looks directly at it).

**Gameplay Function:** Boundary enforcement with atmospheric storytelling. No loot, no objectives. Exists to establish that the station is isolated and that something is watching from the fog. Players who explore the perimeter thoroughly find a break in the fence near the east side that connects to a cliff path leading down to the Dock — this is the **surface shortcut to extraction**, bypassing the Emergency Tunnel. However, the path is exposed and the Mimic may appear on it disguised as a guardrail post that was not there before.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | Guard tower 1, on chair | 30% |
| Lore: Guard's Radio Log | Guard tower 2, on desk | 100% |

**Lore Items:**
- `Guard's Radio Log` — In guard tower 2. Transcription of radio communications on the night of the breach. Key excerpt: "This is Tower 2. I can see the helipad. There are... there are two helicopters. We only have one helicopter. Over." Followed by: "Tower 2, confirm. We show one helicopter. Over." Then: "The second helicopter just... it's not a helicopter. It's standing up. Oh god, it's standing up—" Transmission ends.

**Hiding Spots:** None on the perimeter proper. Guard towers have no concealment.

**Mimic Behavior:** The perimeter fog figure is not the Mimic — it is a scripted atmospheric effect (see Scripted Events). However, the Mimic may appear on the perimeter path as a **duplicate guard tower** — if the player has visited guard tower 1 and walks along the perimeter toward tower 2, they may see what appears to be tower 1 again in the distance. Approaching reveals it is subtly wrong (different angle, no chair, shadow cast in the wrong direction). Walking past it is safe. Entering it triggers an attack.

---

#### Service Yard

**Description:** An open courtyard between the Admin Building and the elevator/stairwell access to the Lab Level. Concrete pad with drainage channels. A cargo container sits rusting near the elevator doors. Industrial floodlights mounted on poles — all dead except one that strobes irregularly. A loading dock with a retractable metal shutter.

**Atmosphere:** Transitional space. The floodlight strobe creates sharp, swinging shadows that make it nearly impossible to use shadow tells reliably. Rain pools in drainage channels. The elevator doors are industrial freight-style — heavy, loud, slow to open. The stairwell alternative is a heavy fire door beside the elevator.

**Gameplay Function:** Transition hub between Surface and Lab Level. The elevator is functional but LOUD — using it alerts the Mimic to the player's vertical position. The stairwell is quieter but longer (20-second descent vs. 8-second elevator ride) and pitch dark. The cargo container can be opened (crowbar inside Barracks, or interaction prompt if strength check — loud either way) for bonus loot.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | Cargo container (requires opening) | 80% |
| Bandage | Cargo container | 60% |
| Flare | Cargo container | 40% |
| Battery | On loading dock shelf | 50% |

**Lore Items:** None.

**Hiding Spots:**
- Behind cargo container — Partial cover. Effective if entity approaches from Admin Building side.
- Under loading dock overhang — Crouch space. Dark.
- Inside cargo container (if opened) — Full concealment. But only one exit.

**Mimic Behavior:** The Service Yard's strobing floodlight is the primary challenge — shadow tells are unreliable here. The Mimic exploits this by placing disguised duplicates in the yard more frequently than other surface areas. Common disguise: a second cargo container that appears adjacent to the first. If the player enters the duplicate, the door slams shut (1 second trapped) before the Mimic attacks (1 pip damage) and vanishes. Shadow tell is unusable here due to the strobe, but the duplicate container has no rust pattern — it is clean metal.

---

### Lab Level

---

#### Cell Block A

**Description:** Four observation cells (A1-A4) with reinforced glass walls facing a central observation corridor. The cells are clinical: white walls, stainless steel bed frame, floor drain, ceiling-mounted camera. Cell A1 is empty and intact. Cell A2 contains a knocked-over chair and scratch marks at standing height on all four walls — circular, as though something walked in circles for days. Cell A3 is empty but the camera is still active, its red recording light blinking. Cell A4's glass wall is shattered from the inside. Glass fragments spray outward into the corridor. The break pattern shows a single impact point. The steel bed frame inside A4 has been bent into a shape that resembles a human figure sitting down.

**Atmosphere:** Harsh fluorescent lighting (emergency power, flickering). The clinical white environment is a deliberate contrast to the dark, organic horror of Levels 1-2. Dread here comes from sterility — something terrible happened in a place designed to be controlled. The hum of the still-active camera in A3 is audible. Standing in front of A3 and looking at the camera: the recording light turns off, then back on.

**Gameplay Function:** Lore delivery and atmosphere. Cell A4 is the Mimic's original containment. The shattered glass and bent bed frame establish the entity's physical power — it could break out whenever it wanted. The implication: it stayed because it chose to. Cell A3's active camera connects to Containment Control's monitor system.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | On floor in corridor near A4 | 60% |
| Bandage | Inside Cell A1 (enter through open door) | 50% |

**Lore Items:**
- `Cell A4 Observation Log` — On clipboard mounted outside A4's shattered wall. Final entry: "Day 127. Entity-03 has not moved in 72 hours. Vitals stable. I note that it has adopted the exact proportions and coloring of the observation chair we placed in the cell on Day 1. I requested the chair be removed. Request denied — Vasquez wants to see how long it maintains the disguise. I have counted the objects in this cell fourteen times today. There are supposed to be six. I keep counting seven."
- `Emergency Breach Protocol` — Mounted on wall. Standard procedures for containment failure. Someone has written in marker across the page: "NONE OF THIS WORKS."

**Hiding Spots:**
- Inside Cell A1 (door can be closed from inside) — Good concealment but glass walls mean the entity can see in if it looks. The Mimic does not check cells — but in this room, that's because it knows them.
- Behind glass fragment pile near A4 — Crouching behind the debris. Partial cover.

**Mimic Behavior:** Cell Block A is a **high-tension zone**. The Mimic will sometimes appear inside Cell A2 disguised as the knocked-over chair in its upright position. The tell: the original chair (knocked over) is gone. If both the upright chair and the original knocked-over chair are present, neither is the Mimic — it's a scripted first-visit scare (see Scripted Events). The Mimic only appears here as a single chair, having "absorbed" the original. Approaching the cell door triggers investigation (the Mimic watches through the glass, motionless, as a chair) but no attack unless the player enters the cell.

---

#### Cell Block B

**Description:** Four observation cells (B1-B4) identical in construction to Block A. All glass intact. All doors sealed. Cell B1 is empty. Cell B2 contains standard furnishings — bed, chair, camera — all in order. Cell B3 contains what appears to be a human mannequin standing in the center of the cell, facing the glass. It is wearing a lab coat. Its face is featureless. Cell B4 is dark — the interior lights are off and the glass is tinted, making it impossible to see inside even with a flashlight.

**Atmosphere:** Quieter than Block A. No shattered glass, no obvious violence. This block feels like nothing happened here, which is worse. The mannequin in B3 is positioned precisely at center, facing the observation corridor at eye level. Whether the player approaches from the left or right, the mannequin appears to be looking at them. It does not move. It is not the Mimic on first visit. It is always a mannequin. But the player will never be certain.

**Gameplay Function:** Psychological pressure. B3's mannequin is a fixed prop that serves exclusively to make the player paranoid. It never moves, never attacks, is never the Mimic. Its only purpose is to make every subsequent mannequin-like object in the game suspect. B4's darkened cell is a decision point: the player can attempt to open B4 (requires Containment Control override) to access potential loot inside, but they cannot see what else might be in there.

**Cell B4 Contents (revealed after Containment Control override):**
- Lights turn on when the player activates the override
- Cell contains: a desk covered in hand-drawn sketches, all depicting the same scene — the station from above, as though drawn by something looking down. The perspective is from approximately 200 meters up. Each drawing is slightly different — different numbers of people visible on the helipad. In one drawing, there are two of the same person.
- **Loot in B4:** `1x Medkit [guaranteed]`, `Lore: Entity-03 Drawings`

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | On shelf outside B1 | 50% |
| Medkit | Inside B4 (requires override) | 100% |

**Lore Items:**
- `Cell B3 Classification Plate` — Mounted on glass. "CELL B3 — ENTITY-03 SECONDARY CONTAINMENT (DECOY). NOTE: Mannequin placed as behavioral stimulus. Entity-03 showed no interest in replicating a featureless form. Hypothesis: it only mimics things with enough detail to be mistaken for real."
- `Entity-03 Drawings` — Inside B4. See above.

**Hiding Spots:**
- Behind support column between B2 and B3 — Standard.
- Inside Cell B1 (if open) — Same glass-wall caveat as Block A.

**Mimic Behavior:** The Mimic does not appear in Cell Block B during the first half of a run. After the server room upload begins (see Critical Path), B3's mannequin may disappear. If the player returns to Cell Block B and the mannequin is gone, the Mimic is now active in the Containment Wing disguised as the mannequin in a different location (the corridor, near the entrance to Block A, or standing at the end of the Containment Corridor). Shadow tell: the mannequin now casts a shadow. The original prop did not (it was too close to the wall and ceiling-lit from directly above). A mannequin with a long shadow is the Mimic.

---

#### Containment Control

**Description:** A monitoring station at the junction of the Containment Wing. A curved desk faces a bank of twelve monitors. Eight are dead. Four are live, cycling feeds from the cell blocks and containment corridors. The room has reinforced walls, a security door (currently open), and a wall-mounted emergency lockdown panel.

**Atmosphere:** The glow of the four active monitors provides the room's only consistent light source — cool blue CRT phosphor. The monitors cycle through feeds every 8 seconds. Most feeds show empty rooms. One feed — cycling to it every 48 seconds — shows the player's current position from an angle that does not correspond to any visible camera. The feed is slightly delayed (0.5 seconds behind real-time). Another feed shows a room the player has not yet visited — it appears empty, but at the end of the 8-second cycle, just before it switches, a shape in the corner of the frame moves.

**Gameplay Function:** Critical objective room. The **Director's Keycard** is in the desk drawer — this is required to access the Director's Office on the surface level. The lockdown panel can be used to override Cell Block B (opens B4). The monitor system provides legitimate surveillance of the containment wing, but the anomalous feeds are unreliable (potentially manipulated by the Mimic).

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Director's Keycard | Center desk drawer | 100% (key item) |
| Battery | Side desk | 70% |
| Bandage | First aid box on wall | 50% |

**Access Interactions:**
- **Lockdown Panel:** Override Cell Block B (opens B4). 5-second activation. Triggers a loud alarm that sounds for 3 seconds then cuts. Mimic is alerted.
- **Monitor Desk Terminal:** Interactable. Displays security log entries from the night of the breach. Auto-scrolls. Player can read for lore but is stationary and exposed while reading.

**Lore Items:**
- `Security Feed Log` — On terminal. Time-stamped entries from September 14, 1993. Key entries:
  - `21:14` — "Camera 7 shows Dr. Vasquez entering Bio Lab."
  - `21:14` — "Camera 3 shows Dr. Vasquez entering Admin Building."
  - `21:15` — "Webb: Confirm Vasquez location. Two feeds, two Vasquezes."
  - `21:17` — "All cameras show Dr. Vasquez. Every camera. Every room. She's everywhere."
  - `21:19` — "Lockdown initiated. God help us."
- `Director's Keycard` — The card itself has a photo of Vasquez. If the player examines it closely (zoom interaction), Vasquez's face in the photo blinks.

**Hiding Spots:**
- Under curved desk — Large space, standard concealment.
- Behind server rack (against back wall) — Tight, partial cover.

**Mimic Behavior:** The Containment Control room has a unique Mimic interaction with the monitors. While the player is reading the security terminal, one of the live monitors will show a feed of the Containment Control room itself — but from inside the room, showing the player's back. There is no camera in this room. The feed persists for one 8-second cycle, then the monitor goes dead. This is a scripted psychological scare (see Scripted Events) and does not indicate the Mimic's actual presence. However, it may cause the player to spin around, at which point they may notice that one of the office chairs in the room has moved slightly (it has not — this is a perceptual trick exploiting the player's heightened alertness).

---

#### Biology Lab

**Description:** A large laboratory space with stainless steel workbenches, microscopes, centrifuges, and a wall of specimen jars. The jars contain preserved biological samples in amber fluid — tissue cross-sections, organ fragments, and several unidentifiable masses. One large jar (40 cm diameter) is empty. Its lid sits beside it on the counter. The preservation fluid has been spilled recently — the counter is still wet. A trail of amber fluid leads from the counter to a floor drain. A biohazard refrigerator hums in the corner.

**Atmosphere:** Chemical smell (implied through visual cues: spill warnings on floor, overturned reagent bottles). The specimen jars are lit from below by a still-functioning light strip, casting the samples in silhouette and creating grotesque shadows on the ceiling. The empty jar is prominently placed at eye level. Whatever was in it was large.

**Gameplay Function:** Lore-critical room establishing what Entity-03 is biologically — or rather, that it defies biological classification. The refrigerator contains a tissue sample that reacts to the flashlight beam (shifts color from grey to pink when illuminated). This is a non-interactive atmospheric detail.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Bandage | On workbench near sink | 60% |
| Battery | In equipment drawer | 50% |
| Medkit | In biohazard refrigerator | 40% |

**Lore Items:**
- `Harlan's Research Notes` — On workbench, handwritten. "Entity-03 cellular structure is unlike anything in the biological record. Each cell is totipotent — capable of becoming any cell type. Not like stem cells. Like EVERY cell in its body is stem. It doesn't transform into things. It becomes them. At a cellular level, when it mimics a chair, its cells become wood and metal. Not a disguise. Replacement. The philosophical implications are... if it mimics a person, is the copy a person? Does the copy think? Does it know what it is?"
- `Empty Specimen Jar Label` — "ENTITY-03 — TISSUE SAMPLE G. EXTRACTED: 08/14/1993. STATUS: ~~CONTAINED~~ UNRECOVERED. NOTE: Sample G demonstrated autonomous motility 12 hours after extraction. Sample was capable of independently mimicking the jar lid for 3 hours before detection."

**Hiding Spots:**
- Under workbench (2 positions) — Standard.
- Behind biohazard refrigerator — Tight squeeze. Good concealment.
- Inside chemical storage cabinet — Crouching. Door partially open for visibility.

**Mimic Behavior:** The Biology Lab has the highest Mimic activity in the Containment Wing. The specimen jars provide multiple mimicry targets. The Mimic may appear as:
1. **A filled specimen jar that was previously empty** — The large empty jar now contains something. Shadow tell: the "specimen" inside casts no shadow within the jar despite the backlight.
2. **A duplicate microscope** — Two identical microscopes on the same bench. One is real. One has no shadow.
3. **The tissue sample in the refrigerator** — If the player opens the refrigerator a second time, the sample may be replaced by the Mimic. Tell: the sample no longer reacts to flashlight.

Attack trigger: interacting with a Mimic-disguised object (picking up, examining closely). Proximity (walking past) does not trigger — the Mimic waits for engagement.

---

#### Audio Lab

**Description:** A sound-isolated room with heavy acoustic paneling on all walls, ceiling, and floor. A professional recording console sits at center. Speakers mounted in all corners. A reel-to-reel player, multiple cassette decks, and a shelf of labeled tapes. The room is eerily quiet — the acoustic dampening eliminates all ambient sound, including the player's own footsteps (footstep audio reduced to near-silence in this room). A red "RECORDING" light above the door is on. A microphone in the center of the room is live — indicated by a green LED.

**Atmosphere:** The silence is oppressive. After the ambient noise of the rest of the facility, the Audio Lab creates a vacuum of sound that is deeply uncomfortable. The player's own breathing (from the Proximity Fear System) becomes the dominant audio. The recording console has one tape loaded and paused, labeled "SESSION 14 — EMERGENCY USE ONLY."

**Gameplay Function:** Mechanically significant room. The Audio Lab introduces a **unique interaction with the Mimic.** Playing recordings at specific frequencies affects the entity's behavior:

**Frequency Mechanic:**
- The console has two playback options: **18.97 Hz ("Distress")** and **23.40 Hz ("Stillness")**
- If the player has the **Cassette Tape** from Office 2 (Tanaka's office), they can load it into the console for a third option: **Session 14**, which combines both frequencies in a pattern that forces the Mimic to reveal its true form for 8 seconds

**Playback Effects:**
| Frequency | Effect | Range | Duration | Cooldown |
|-----------|--------|-------|----------|----------|
| 18.97 Hz (Distress) | Attracts the Mimic to the Audio Lab | Facility-wide | Plays for 15s | 60s |
| 23.40 Hz (Stillness) | Freezes the Mimic in current position | 30-stud radius from nearest speaker | 10s | 45s |
| Session 14 | Forces Mimic to de-camouflage (true form) | 40-stud radius | 8s | 120s (one-time in some contexts) |

**Speaker System:** The Audio Lab console can output to speakers in the Audio Lab only. However, there is a PA switch on the console labeled "FACILITY-WIDE." Activating it routes audio through the station's intercom system, extending the frequency effects to all areas with functional speakers (most rooms have a ceiling-mounted intercom speaker). Activating facility-wide broadcast is extremely loud and puts the Mimic into an agitated state after the effect ends (HUNT mode, increased speed, 90 seconds).

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | In console drawer | 80% |
| Battery | On shelf near tapes | 40% |
| Flare | In acoustic panel gap (hidden) | 30% |

**Lore Items:**
- `Tanaka's Session Notes` — On the console. "I've been recording the entity's vocalizations for 87 sessions. It has progressed from mimicking ambient sounds to mimicking human speech. Session 14 was a breakthrough — or a catastrophe. I played back its own vocalizations to it. It went silent. Completely silent. For the first time in 127 days, it stopped. I believe the combination frequency in Session 14 creates a recursive feedback — the entity trying to mimic its own mimicry. It can't. It crashes. Like a mirror facing a mirror. The loop forces it to reveal itself. I've noted this frequency combination and locked the recording. Under no circumstances should it be played without full containment protocols. It is our only weapon, and it will know we have it."
- `Recording Labels` — Shelf labels (environmental lore). Sessions 1-13 are present. Session 14's slot is empty (the player has the cassette or needs to find it). Sessions 15-87 are present. Session 88's label reads: "SESSION 88 — IT SPOKE TO ME. IT USED MY VOICE. IT SAID 'STOP RECORDING ME, YUKI.'"

**Hiding Spots:**
- Under recording console — Standard. Extra effective due to acoustic dampening reducing detection sounds.
- Behind acoustic panel stack (3 panels leaning against wall) — Partial cover.

**Mimic Behavior:** The Audio Lab is a **safe zone** while audio is playing at 23.40 Hz. The Mimic will not enter the room while the Stillness frequency is active. Outside of active playback, the Mimic may appear in the Audio Lab as a duplicate reel-to-reel tape on the shelf — one more tape than there should be. Shadow tell applies. The Mimic is particularly cautious in this room and will not attack unless the player interacts with the duplicate tape. If Session 14 is played facility-wide, all Mimic disguises within range are forcibly dropped for 8 seconds, revealing the Mimic's **true form** — a vaguely humanoid mass of grey-pink tissue that shifts and ripples, cycling rapidly through partial shapes (half a chair, a hand, a face that isn't quite right, the player's own silhouette). After the 8 seconds, it re-disguises or flees.

---

#### Observation Deck

**Description:** A windowed mezzanine overlooking the Main Chamber one level below. The glass is floor-to-ceiling, offering a panoramic view of the massive excavation below. A telescope on a tripod is pointed downward. Desks with monitoring equipment line the windows. Elevator and ladder shaft access to the Deep Level is at the far end.

**Atmosphere:** Scale shift. After the claustrophobic corridors and labs, the Observation Deck reveals the Main Chamber below — a cavernous open space carved from bedrock, easily 50 meters across and 20 meters deep. The sense of scale is disorienting. Floodlights below are mostly dead; a few still illuminate patches of the chamber floor, revealing excavation equipment, scaffolding, and at the very center, a massive circular depression — the dig site where Entity-03 was originally unearthed. The Observation Deck itself is well-lit by emergency strips along the floor.

**Gameplay Function:** Transition space and reconnaissance point. The telescope allows the player to survey the Main Chamber below before descending, identifying loot locations and potential Mimic positions. The telescope view is narrow (sniper-scope style) and while using it, the player cannot see their immediate surroundings — vulnerability window. The freight elevator and ladder shaft here provide access to the Deep Level.

**Telescope Observations (randomized per run, 3 of 5 selected):**
1. A figure standing motionless near the dig site. When the telescope focuses, it is a support column. Or was it always a column?
2. A medkit sitting on an equipment crate. It is really there (loot marker).
3. Two identical toolboxes side by side on a workbench. One casts a shadow. One does not.
4. A door to the Server Room that is open. It was closed in the facility map.
5. The Tank — a massive cylindrical structure in the northwest corner. Its door is ajar. Something wet and dark has leaked from under it and pooled on the chamber floor.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | On monitoring desk | 60% |
| Bandage | First aid box near elevator | 50% |

**Lore Items:**
- `Observation Log — Main Chamber` — On desk. "Day 43 of excavation. The chamber walls show tool marks that predate any known civilization in this region. The central depression appears to be a natural formation — or was made to look like one. Core samples from the depression floor contain the same cellular material found in Entity-03. Entity-03 did not come from beneath St. Maren's Hospital. Entity-03 came from HERE. The thing under St. Maren's was a fragment. This is where the whole thing was. And I don't think we found the bottom."

**Hiding Spots:**
- Under monitoring desk — Standard.
- Behind telescope tripod — Minimal cover. Emergency use only.

**Mimic Behavior:** The Observation Deck is relatively safe. The Mimic rarely appears here, as the open sightlines make shadow tells easy to verify. However, if the player uses the telescope for more than 15 seconds, upon exiting the telescope view, there is a 20% chance a new object has appeared in the room (a second telescope tripod, a chair that wasn't there). This object is always the Mimic. Shadow tell applies. The Mimic does not attack immediately — it waits for the player to interact or turn their back.

---

#### Medical Bay

**Description:** A full medical suite — examination room, small operating theater, supply closet, and a recovery area with two beds. The operating table has leather restraints at wrists and ankles, recently used (leather creased and sweat-stained). Surgical instruments are laid out on a tray in precise order. A sink has dried blood residue. One recovery bed has rumpled sheets and an IV drip still running (the bag is empty, fluid pooled on the floor). A medication cabinet is locked. The supply closet door is open.

**Atmosphere:** Clinical, intimate horror. Bright surgical light above the operating table still functions (powered by the same emergency system as the containment wing). The light creates a harsh circle of white on the table, leaving the rest of the room in deep shadow. Approaching the table triggers the light to flicker. The restraints are sized for a human. The saw on the instrument tray has biological residue.

**Gameplay Function:** Medical supply hub and lore delivery. Contains the **Medical Bay Key** (opens the locked medicine cabinet in Office 4). The locked medication cabinet here requires no key — it opens with a 4-button combination lock. The combination is found in Chen's medical charts (Office 4) — creating a cross-reference puzzle where each area contains the key to unlock the other's high-value loot.

**Medication Cabinet Combination:** Written in Chen's own chart (Office 4) as "Locker code for emergencies: 4-1-7-3." Randomized per run from a pool of 8 combinations (all noted somewhere in Chen's documents).

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Bandage | Supply closet shelf | 100% |
| Bandage | Supply closet shelf | 60% |
| Medkit | Medication cabinet (locked, combination) | 100% |
| Battery | On instrument tray | 40% |
| Medical Bay Key | On recovery bed nightstand | 100% (key item) |

**Lore Items:**
- `Surgical Log` — On clipboard near operating table. "Subject: Entity-03 tissue biopsy. Procedure: excision of 12 cm^3 sample from primary mass. NOTE: Subject was not sedated (no known effective sedative). Subject was restrained. Subject was cooperative. Subject watched the procedure. Subject smiled. Dr. Harlan notes the excised tissue independently mimicked the scalpel within 30 seconds of separation from the primary mass."
- `Chen's Emergency Notes` — In supply closet. "If you're reading this, I didn't make it out. The medication cabinet combination is 4-1-7-3. Take the ketamine — it's the only thing that slows it down. 15 cc injection, direct into tissue mass. It doesn't stop it. Nothing stops it. But it buys you about ten minutes of it being confused."

**Hiding Spots:**
- Under operating table — Standard. The harsh light above makes this riskier than it appears (the player's outline may be visible in the shadow cast by the table).
- Inside supply closet (close door) — Full concealment. Small space.
- Behind recovery bed — Crouching. Partial cover.

**Mimic Behavior:** The Medical Bay is a **trap room**. The Mimic frequently disguises itself as medical supplies here, specifically:
- **Fake bandage on the supply closet shelf** — Appears as a third bandage on the shelf. Interacting triggers an attack (1 pip damage). Shadow tell: the fake bandage has no shadow, or its shadow is offset from the light source.
- **Fake medkit in the medication cabinet** — Only occurs if the player has already opened the cabinet, taken the medkit, and returns later. A second medkit appears. Always the Mimic.
- **The IV drip bag** — On the recovery bed. It looks like it still has fluid in it (the empty one was described as empty). Interacting triggers the Mimic to emerge from the IV stand — the entire stand was the Mimic.

The operating table restraints may spontaneously snap closed (scripted event, once per run) while the player is adjacent, causing a brief flinch animation (not damage, purely psychological).

---

### Deep Level

---

#### Main Chamber

**Description:** The largest space in the station. A natural cavern expanded through excavation, roughly 50 meters in diameter and 20 meters from floor to the Observation Deck ceiling above. The walls are a mix of natural rock and concrete reinforcement. Scaffolding and walkways criss-cross the space at various heights. At the center: a circular depression, 10 meters across and 3 meters deep, carved into the bedrock. This is the original dig site. The depression's walls are smooth — too smooth, as though something perfectly round sat here for a very long time and compressed the stone. Floodlights on tripods surround the depression, most burned out. Excavation equipment (drilling rigs, earth movers) sits abandoned on the chamber floor.

**Atmosphere:** Cathedral-like. The ceiling is lost in darkness above the Observation Deck's glass. Sound echoes unpredictably — footsteps bounce off distant walls, making it impossible to tell direction. Dripping water creates rhythmic sounds. The air is cold and damp, smelling of wet stone and something chemical. The central depression has a faint luminescence — the bedrock itself emits a barely perceptible blue-grey glow that is only visible when the flashlight is off. Standing in the depression, the player can hear a sub-bass vibration, more felt than heard — the same frequency as the Proximity Fear System's Tier 1 drone, but it is always present here regardless of the Mimic's actual location.

**Gameplay Function:** Transition hub for the Deep Level. The Main Chamber connects to the Server Room (east), the Tank (northwest), and the Emergency Tunnel (south). Its open layout makes it the safest space in the Deep Level for spotting the Mimic at distance, but its acoustic properties make it the worst for hearing the Mimic approach.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | On scaffolding platform (climb) | 70% |
| Bandage | Near drilling rig | 50% |
| Flare | In excavation toolbox | 60% |
| Battery | On walkway (upper level) | 40% |

**Lore Items:**
- `Excavation Team Report` — On clipboard near drilling rig. "Core depth reached: 47 meters below chamber floor. The material at depth is not stone. It responds to vibration. It has a cellular structure. The dig site is not a depression. It is a footprint. We are standing in the impression of something that was here before. Something larger than this chamber. Something that left part of itself behind."
- `Photo: Dig Site Day 1` — Polaroid taped to scaffolding post. Shows the depression before excavation. A dark shape is visible at the bottom. On the back, someone wrote: "We thought it was dead."

**Hiding Spots:**
- Behind scaffolding base (multiple positions) — Partial cover. Numerous options across the chamber.
- Inside drilling rig cabin — Full concealment. Single entry point.
- Behind earth mover — Large cover. Effective.
- Inside central depression (crouch against wall) — Risky. The luminescent floor makes the player slightly visible even in darkness.

**Mimic Behavior:** The Main Chamber's size means the Mimic prefers stationary disguises here:
- **Duplicate scaffolding section** — An extra scaffold that doesn't connect to anything. Shadow tell: the duplicate's shadow doesn't match the angle of the floodlights.
- **Duplicate floodlight tripod** — An extra floodlight that is off. If the player tries to turn it on, it attacks.
- **The drilling rig operator's seat** — If the player approaches the drilling rig, the operator's seat may have someone sitting in it. In solo, this is a mannequin-like shape. In multiplayer, it looks like a teammate. Shadow tell: the seated figure has no shadow. Approaching within 5 studs triggers an attack.

In the central depression, the Mimic will never appear. The luminescent bedrock seems to repel it. This is the only verified safe zone in the Deep Level. Standing in the depression for 10+ seconds triggers a unique audio cue — a low tone that matches the 23.40 Hz "Stillness" frequency. The dig site material naturally produces the frequency that freezes the Mimic. Lore implication: whatever was here originally was the Mimic's counter.

---

#### Server Room

**Description:** A climate-controlled room packed with server racks in four rows. The servers are operational — indicator lights blink green and amber across hundreds of units. Cooling fans run at high RPM, creating a constant loud drone (ambient noise level equivalent to 50 studs of sound masking). The floor is raised (cable routing), with removable tiles. A central terminal with a keyboard and monitor serves as the interaction point. An uninterruptible power supply unit the size of a refrigerator hums in the corner.

**Atmosphere:** The only consistently loud room in the station. The fan noise is a relief — for the first time since Level 1's boiler room, ambient noise works in the player's favor by masking footsteps. The server lights create a visual pattern reminiscent of breathing — cycling in waves across the racks. The terminal monitor displays a command prompt awaiting input. The room is warm (contrasting the cold chamber outside).

**Gameplay Function:** Primary objective room. The player must upload Project ECHO data to an external server and trigger the extraction signal to the dock. This is a multi-step process:

**Upload Sequence:**
1. Approach terminal — interaction prompt: "Begin Upload"
2. Upload initiates — progress bar on screen — **180 seconds (3 minutes) total**
3. At 60 seconds: servers surge, lights flicker, noise increases — Mimic is alerted
4. At 120 seconds: terminal displays "WARNING: External connection detected. Unknown source is downloading data simultaneously" — the Mimic is accessing the servers from somewhere in the facility
5. At 150 seconds: terminal asks "ABORT PARALLEL DOWNLOAD? Y/N" — choosing Y completes upload safely; choosing N allows both uploads to complete (lore implications for Level 5)
6. At 180 seconds: "UPLOAD COMPLETE. EXTRACTION SIGNAL SENT TO DOCK. BOAT FUELING SYSTEM ENGAGED." — this activates the boat at the dock but the fuel still needs to be manually connected

**During the upload, the player must remain in or near the Server Room.** Leaving for more than 30 seconds pauses the upload. The terminal displays a countdown. The Mimic will actively attempt to lure the player away using duplicated sounds (footsteps approaching, a teammate calling from outside in multiplayer).

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | On server rack shelf | 80% |
| Battery | Under raised floor tile | 50% |
| Bandage | On UPS unit | 40% |

**Lore Items:**
- `Server Access Log` — On terminal after upload. Shows all previous access attempts. Last legitimate access: September 14, 1993, 21:47, user VASQUEZ_E. Next entry: September 14, 1993, 21:48, user VASQUEZ_E. Next entry: September 14, 1993, 21:48, user VASQUEZ_E. The same user accessed the server 347 times in 12 minutes. The access credentials were correct every time. Vasquez had already evacuated at 21:30.
- `Data Manifest` — Displayed during upload. Lists all Project ECHO files being transferred. File names include "ENTITY-01_CONTAINMENT_PROTOCOL.dat", "ENTITY-02_BEHAVIORAL_MODEL.dat", "ENTITY-03_MORPHOLOGY.dat", "ENTITY-04_OBSERVATION.dat", and "ORIGIN_SITE_ALPHA_EXCAVATION.dat" — confirming that Blackpoint studied all known entities and the original excavation site beneath St. Maren's.

**Hiding Spots:**
- Between server racks (multiple) — Narrow gaps. Good concealment. The noise masks breathing.
- Under raised floor (remove tile, crawl in) — Excellent hiding spot. Unique to this room. However, the floor tiles make a distinct clicking sound when replaced, audible even over the fan noise.

**Mimic Behavior:** The Server Room is a contested zone during the upload. The Mimic's behavior here is aggressive but indirect:
- **It does not enter the Server Room while the fans are running.** The noise and vibration appear to disorient it (consistent with its sensitivity to specific frequencies). Instead, it lurks just outside the door.
- **It projects lures into the doorway:** A loot item visible just outside the door (always fake). A teammate's silhouette gesturing to come (multiplayer, always fake during upload).
- **If the player leaves the Server Room during the upload,** the Mimic is waiting in the Main Chamber, disguised as a piece of excavation equipment near the Server Room entrance. It attacks when the player passes.
- **After the upload completes and the player leaves,** the fan noise gradually decreases (servers powering down). The noise advantage disappears over 30 seconds. Once silent, the Server Room becomes one of the most dangerous rooms — narrow rows, no ambient masking.

---

#### Emergency Tunnel

**Description:** A utilitarian concrete tunnel, 3 meters wide and 2.5 meters tall, stretching approximately 200 meters from the Main Chamber to the Dock. Emergency lighting strips along the floor provide a dim orange glow every 10 meters — enough to walk by, not enough to see clearly. Pipes run along the ceiling. The tunnel has a slight downward grade toward the dock. Three emergency alcoves (recesses in the wall with a fire extinguisher and emergency phone) are spaced at 50-meter intervals. A blast door at the midpoint can be sealed from either side.

**Atmosphere:** Monotonous and linear. The repetitive architecture creates disorientation — it is difficult to tell how far you've walked. The tunnel amplifies sound: footsteps echo ahead and behind. A distant dripping sound comes from the dock end. Occasionally, the emergency lights flicker in sequence, creating a wave of darkness that moves down the tunnel toward the player. The blast door is open (default) but can be closed by interacting with the control panel on either side (heavy, slow, loud — 6-second animation).

**Gameplay Function:** Linear transition between Deep Level and Dock. This is the primary extraction route. Its length and linearity create a sustained tension — the player can see far ahead and behind, which means they can also be seen. The three alcoves provide minimal cover. The blast door at the midpoint can be used to seal the tunnel behind the player (cuts off the Mimic if it's following) but also cuts off retreat.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | Alcove 1 emergency box | 50% |
| Bandage | Alcove 2 emergency box | 50% |
| Flare | Alcove 3 emergency box | 40% |

**Lore Items:**
- `Emergency Phone Messages` — Each of the three emergency phones has a recorded message when the player picks up the receiver:
  - Phone 1: Breathing. Just breathing. For 10 seconds. Then a whisper: "Keep walking."
  - Phone 2: A man reciting the NATO phonetic alphabet. He reaches "Mike" and stops. Repeats "Mike" four times. Then: "Mimic." Then silence.
  - Phone 3: The player's own audio — the last 5 seconds of any sound the player made (walking, flashlight click, breathing) played back with a 0.5 Hz pitch shift. This is the Mimic learning to replicate the player's sounds. If the player made no sounds, the phone plays silence for 5 seconds, then a heartbeat that matches the Proximity Fear System's current heart rate.

**Hiding Spots:**
- Emergency alcoves (3) — Shallow recesses. Crouch behind the fire extinguisher bracket. Minimal concealment — the entity can see in if it approaches directly. Effective only if entity is passing.
- Behind blast door (if closed from the dock side, player hides against the Main Chamber side) — Full concealment from dock direction.

**Mimic Behavior:** The Emergency Tunnel is the Mimic's most aggressive zone. The linearity eliminates lateral escape. The Mimic uses the following tactics:
- **The Long Look:** The player sees a figure standing at the far end of the tunnel, motionless. It is their own silhouette (solo) or a teammate silhouette (multiplayer). It does not move. Walking toward it, it remains at the same perceived distance for 20 seconds (the tunnel's length is distorted during this event). This is a scripted event (see Scripted Events). The figure eventually vanishes.
- **Object Duplication:** The fire extinguishers in the alcoves may be duplicated (two fire extinguishers side by side). One is always the Mimic. Shadow tell: one has no shadow against the alcove wall.
- **Sound Mimicry:** The tunnel's acoustics allow the Mimic to project duplicated footstep sounds from behind the player. The player hears footsteps matching their pace, coming from 10-15 studs behind. Stopping: the footsteps stop 0.5 seconds later. Sprinting: the footsteps sprint too, but slightly faster. Looking behind: nothing visible. This continues for 30-60 seconds (randomized). It is purely psychological — no attack occurs from behind during this event. The attack comes from ahead, where the Mimic has disguised itself as the next emergency alcove's fire extinguisher.

---

#### The Tank

**Description:** A massive cylindrical containment vessel, 8 meters in diameter and 6 meters tall, constructed of reinforced steel and plexiglass observation windows. It occupies a chamber off the northwest corner of the Main Chamber. The Tank's door (a vault-style hatch, 2 meters in diameter) is open. Inside: a single stainless steel platform at center, bolted to the floor. Restraint mechanisms — industrial hydraulic clamps — are deployed in the open position. The interior walls are covered in scratch marks at every height from floor to ceiling. A drainage system in the floor leads to a sealed waste processing unit. The plexiglass windows are scratched from the inside, making them nearly opaque.

**Atmosphere:** The Tank smells of antiseptic and something organic underneath. The hydraulic clamps are sized to restrain something roughly humanoid but 30% larger than a human. Fluid stains on the platform suggest the occupant was here for a very long time. The scratch marks on the walls vary in character — some are fine, almost delicate (like fingernails), others are deep gouges (like something much harder than nails). Near the drainage grate, the scratches form a pattern: repeated attempts to draw human faces, each one slightly more accurate than the last, progressing around the circumference of the Tank. The final face is a perfect portrait of Dr. Vasquez.

**Gameplay Function:** Lore-critical room with no gameplay objectives. The Tank is where Entity-03 was held for six years. It is optional but contains the most important lore in the level — the connection between Entity-03, Blackpoint, St. Maren's Hospital, and the upcoming Level 4 and Level 5.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Flare | On floor near Tank entrance | 50% |
| Battery | On monitoring station outside Tank | 60% |

**Lore Items:**
- `Tank Observation Log (Final Week)` — On monitoring station. Day-by-day account of Entity-03's final days in containment:
  - **Day 120:** "Entity has adopted a new resting form. It looks like a person sitting on the platform. Gender and features change hourly. None match any staff member. They appear to be random."
  - **Day 123:** "Entity's resting form now consistently resembles Dr. Vasquez. When asked why through the intercom, it responded in Vasquez's voice: 'Because she watches me the most. I want to look like what watches me.'"
  - **Day 125:** "Entity's resting form has become indistinguishable from Vasquez. I requested visual comparison. Side by side through glass — the entity matched every detail including clothing. The only difference was the shadow. The entity's shadow was approximately 3 degrees offset from the angle of the overhead light. Shadow discrepancy noted as the sole reliable identification method."
  - **Day 126:** "Entity asked to speak with Vasquez directly. Request denied. Entity then said, in Vasquez's voice: 'She is already here.' I checked the visitor log. Vasquez was in her office. Or was she?"
  - **Day 127:** "Entity has stopped moving. Has adopted the form of the restraint platform. I counted the objects in the Tank. There are supposed to be four. I count five."
- `Leaked Waste Analysis` — In waste processing unit. "Waste fluid from the Tank drainage system was found in the station's water supply on Day 89. Contamination was contained. However, tissue analysis of the waste showed living cellular material consistent with Entity-03. The cells were attempting to propagate. They were mimicking water. We have been drinking it for 89 days."
- `Transfer Order — Classified` — Hidden in a sealed envelope under the monitoring station. "PRIORITY ALPHA. EYES ONLY. Entity-03 tissue samples (vials C-1 through C-12) to be transferred to the following locations for parallel study: [REDACTED], [REDACTED], and Ashwood Forest Ranger Station (Site Gamma). Delivery confirmed 03/15/1991." This directly connects to Level 4's location.

**Hiding Spots:**
- Inside the Tank (behind platform) — Full concealment. The Mimic NEVER enters the Tank. It avoids this room entirely. The Tank's hydraulic clamps, if activated (interaction panel on the monitoring station), snap shut and remain closed for 60 seconds — the player can trigger them remotely as a defensive tool. If the Mimic is inside the Tank when clamps activate, it is restrained for 60 seconds (extremely rare, requires luring it in with a flare).

**Mimic Behavior:** The Mimic avoids the Tank. Its six years of containment here appear to have created an aversion. The player is completely safe inside the Tank. This is the only guaranteed safe zone in the Deep Level (besides the dig site depression in the Main Chamber). However, the Mimic will wait outside the Tank's entrance. If the player enters the Tank and stays more than 30 seconds, exiting will reveal the Mimic standing just outside the hatch, in its true form, watching. It does not attack immediately — it holds its position for 3 seconds (long enough for the player to see it), then de-materializes and re-enters disguise somewhere in the Main Chamber.

---

### Dock (Extraction)

---

#### Boat House

**Description:** A corrugated metal structure built on the shoreline, open on the water side. A 10-meter rigid-hulled inflatable boat (RHIB) sits in a cradle on a marine railway (launch rail). The boat has a twin outboard motor, navigation console, and enough seating for 4 players. A fuel tank on the dock wall has a hose that reaches the boat. The fuel system requires manual connection (turn valve, connect hose, hold to fuel — 15-second interaction). A control panel on the wall operates the marine railway (launches the boat into the water). The boat's ignition requires the **Extraction Codes** from the Director's Office.

**Atmosphere:** Salt air. The sound of waves against rock. The fog bank that surrounds the station extends over the water, a white wall 50 meters from shore. The boat house is lit by a single caged work light — harsh and yellow. Something is moving in the water beyond the fog line. Large displacement swells that don't match the wave pattern. The boat appears functional but the fuel tank's gauge reads empty.

**Gameplay Function:** Extraction preparation room. The extraction sequence requires three steps, all of which require items from elsewhere in the station:

**Extraction Sequence:**
1. **Fuel the boat:** Interact with fuel tank valve. Turn valve (2s) → Connect hose to boat (3s) → Hold to fuel (15s timer). Player is locked in fueling animation and cannot move. Total: 20 seconds exposed.
2. **Enter Extraction Codes:** Interact with boat's navigation console. Enter codes (automatic if player has the key item). 5-second boot sequence.
3. **Launch boat:** Interact with marine railway control panel. Railway activates (loud mechanical whir, 8 seconds). Boat slides into water.
4. **Board boat and navigate to extraction point** — See Pier.

**Fuel Source:** The fuel tank on the dock wall reads empty. However, activating the extraction signal from the Server Room remotely activates a reserve fuel pump that fills the tank over 60 seconds. If the player reaches the dock before the Server Room upload is complete, the fuel tank is non-functional (interaction prompt: "FUEL SYSTEM OFFLINE — EXTERNAL SIGNAL REQUIRED"). This enforces the critical path order.

**Loot:**
| Item | Location | Probability |
|------|----------|-------------|
| Battery | On workbench near fuel tank | 70% |
| Bandage | In boat compartment | 60% |
| Flare | In boat compartment | 50% |

**Lore Items:**
- `Dock Manifest` — On clipboard near boat. Lists all vessels assigned to the station. Two boats listed. The second boat, "ECHO-2," has a note: "Launched 09/14/1993 at 21:22. 6 passengers. Destination: mainland. Arrival status: UNKNOWN." No follow-up entry. The boat never arrived.
- `Marine Radio Message (environmental)` — A marine radio on the dock crackles to life when the player enters. Static, then a fragment: "...Blackpoint, this is Coast Guard Vessel [unintelligible]. We received your automated signal. Be advised, we are [unintelligible] hours out. Confirm survivors. Over." The radio then dies. It cannot be used to respond.

**Hiding Spots:**
- Under workbench — Standard.
- Inside boat (crouch behind console) — Good concealment from dock entrance. Exposed from water side.
- Behind fuel tank — Partial cover.

**Mimic Behavior:** The Boat House is a high-danger area during extraction. The Mimic's behavior depends on how many extraction steps the player has completed:
- **Before fueling:** The Mimic may appear as a **duplicate fuel hose** — two hoses dangling from the fuel tank. One connects to the boat. One connects to the Mimic. Shadow tell: the Mimic hose has no shadow. Connecting the wrong hose triggers an attack (1 pip damage, player knocked away, 2-second stun, hose retracted — must try again).
- **During fueling:** The Mimic does not attack. The 20-second vulnerability window is uninterrupted. Instead, the player hears footsteps approaching from the Emergency Tunnel entrance. They grow louder over the 20 seconds. At second 18, they stop. If the player looks: nothing. If the player does not look: still nothing. Pure psychological pressure.
- **After launch:** The Mimic makes one final attempt on the marine railway — it may appear on the rail between the boat and the water, blocking the launch. The railway hits it, the Mimic shrieks (only vocalization in the level), and the boat launches anyway. Not a fail state — a final scare.

---

#### Pier

**Description:** A concrete pier extending 20 meters from the Boat House into the water. The boat launches from the railway into the water at the pier's base. The pier has no railing on the water side. A navigation buoy blinks red at the pier's end. Beyond: fog, open water, and the sound of waves.

**Atmosphere:** Exposed, open, final. The fog closes in as the extraction sequence begins. Wind picks up. The navigation buoy's red flash is the only consistent light. The water is black and moving. Visibility: 15 meters.

**Gameplay Function:** The extraction point. Once the boat is in the water, players board it from the pier. The boat's autopilot engages when all living players are aboard (or one player activates the ignition if teammates are dead). The boat moves along the pier and out toward the fog line.

**Extraction Cinematic (30 seconds):**
1. Boat pulls away from the pier. Players can look around (limited camera).
2. The station recedes into the fog behind them.
3. At 10 seconds: a shape on the pier. The Mimic, in its true form, watching them leave.
4. At 15 seconds: the shape changes. It becomes the player character (solo) or one of the teammates (multiplayer). It waves.
5. At 20 seconds: the fog swallows the station completely.
6. At 25 seconds: the boat clears the fog. Open ocean. Sunlight breaks through clouds.
7. At 30 seconds: "EXTRACTION COMPLETE — LEVEL 3 CLEARED"
8. Post-screen: a final text prompt. "The Coast Guard vessel arrived at Blackpoint 6 hours later. They found no entities. They found no evidence of entity activity. They found a fully staffed research station with 12 researchers who matched all personnel records. All shadow verifications passed. The station was declared secure and returned to active status."

**Loot:** None.

**Hiding Spots:** None. Nowhere to hide. Open pier.

**Mimic Behavior:** The Mimic does not attack on the pier. The extraction is guaranteed once the boat launches. The Mimic's presence on the pier during the cinematic is scripted, not gameplay.

---

## The Mimic — Entity Design

### Overview

The Mimic (Entity-03) is not a pursuer. It is a deceiver. Unlike the Patient (stalker) or the Crawlers (pack hunters), the Mimic's danger comes from its ability to be anything in the environment. It attacks from deception, not from speed. The player's enemy is not the entity — it is their own uncertainty.

### Core Behavior Loop

```
DISGUISE → WAIT → TRIGGER → ATTACK → RETREAT → REPOSITION → DISGUISE
```

The Mimic spends 80% of its time disguised as an environmental object. It does not patrol in a traditional sense — it repositions by vanishing from one disguise and appearing as a different object in a different room. It prefers rooms the player has already visited and cleared (placing new objects in "safe" spaces the player is likely to return to with lowered guard).

### Disguise Categories

#### 1. Object Duplication

The Mimic's primary disguise. It appears as a duplicate of an object already present in a room.

**Valid Duplication Targets:**
| Object Type | Rooms Where Applied | Frequency |
|-------------|-------------------|-----------|
| Chairs (office, plastic, rolling) | Offices, Barracks, Control rooms | High |
| Fire extinguishers | All corridors, Emergency Tunnel | Medium |
| Specimen jars | Biology Lab | Medium |
| Monitors/screens | Containment Control, Server Room | Low |
| Medical equipment | Medical Bay | Medium |
| Toolboxes | Main Chamber, Boat House | Medium |
| Flashlight | Any room with existing flashlight spawn | Rare |

**Rules:**
- The Mimic only duplicates objects already in the room. It does not create objects from nothing.
- Duplication is per-visit: the Mimic changes the room's object count between the player's visits, not while the player is watching.
- Only ONE object in any room is the Mimic at any time. Never two.
- The Mimic cycles rooms every 45-90 seconds if not triggered.

#### 2. Loot Item Disguise

The Mimic's cruelest tactic. It appears as a pickupable item — a bandage, battery, or flare.

**Rules:**
- The Mimic only disguises as loot items in rooms where that item type has a legitimate spawn. It does not place a medkit in a room that never spawns medkits.
- Loot-disguised Mimic items always appear AFTER the player has picked up the legitimate item from that room. The player takes a real battery → returns later → a new battery has appeared in the same spot.
- **Maximum 2 loot-disguised appearances per run.** Overuse trains the player to never pick anything up, which breaks the game economy.
- Interacting with a loot-disguised Mimic triggers an attack: the item lunges at the player, dealing 1 pip damage and briefly revealing the Mimic's true form before it retreats.

**Protection Mechanic:** Items that are NOT the Mimic cast a normal shadow consistent with the room's lighting. Mimic-disguised items have one of the following shadow anomalies:
- No shadow at all (most common)
- Shadow offset 3-5 degrees from correct angle (rare, harder to spot)
- Shadow that is slightly too large (rare)

Players who learn to check shadows before picking up items significantly reduce risk.

#### 3. Teammate Disguise (Multiplayer Only)

The Mimic's most psychologically devastating ability. In multiplayer, it can appear as a duplicate of any player character.

**Appearance Rules:**
- The Mimic only creates a teammate duplicate when the real player is out of line-of-sight of the observing player(s)
- The duplicate appears at medium distance (20-40 studs) — far enough to be uncertain, close enough to recognize the character model
- The duplicate mimics the real player's cosmetic loadout, character model, and nametag
- The duplicate stands still, walks slowly, or performs simple actions (waving, crouching, walking toward the observer)

**Behavioral Tells (how to identify the fake):**

| Tell | Real Player | Mimic Duplicate |
|------|------------|----------------|
| Proximity voice | Speaks when spoken to | Silent, OR plays back the last voice line heard with 0.5 Hz pitch shift |
| Movement | Responsive, varied, purposeful | Slightly too smooth, lacks micro-adjustments |
| Shadow | Normal | Offset or absent |
| Flashlight | Functions (beam visible, battery state) | Has flashlight model but beam is subtly wrong color (slightly blue-shifted) |
| Response to commands | Reacts to other players' voice/text | Does not react OR mimics the last action observed from a real player |
| Inventory actions | Can open inventory, use items | Never uses items, only holds them |

**Exposure Protocol:** If a player approaches within 5 studs of the Mimic duplicate, the duplicate does not immediately attack. It turns to face the player, tilts its head slightly, and smiles. 2-second window. Then it attacks (1 pip damage, grabs the player for a 1.5-second stun). If a second player is present and shines a flashlight on the duplicate during the 2-second window, the Mimic flinches and retreats without attacking.

**Voice Mimicry Detail:** The Mimic listens to proximity voice data. After hearing a player speak, it can reproduce that voice through the duplicate. However:
- Reproduction is always 0.5 Hz lower in pitch (subtle but detectable)
- Reproduction only replays the last thing heard, never generates new speech
- If no voice data has been captured, the duplicate is completely silent
- Smart players will use a code phrase system: ask a question only a real player knows the answer to. The Mimic can only replay previous audio.

#### 4. Hiding Spot Mimicry

The Mimic does not check hiding spots (unlike other entities). Instead, it becomes a hiding spot.

**Implementation:**
- The Mimic appears as a new hiding spot in a room that previously had fewer hiding spots
- Example: the player enters a room with 2 lockers. On a second visit, there are 3 lockers. The third is the Mimic.
- If the player enters the Mimic-locker, the door slams shut and the Mimic attacks (2 pip damage — penalty for entering the entity)
- Shadow tell: the new locker has no shadow

**Frequency:** Rare (1-2 times per run). High impact due to the vulnerability of the hiding action.

### Shadow Tell System — Technical Specification

The shadow anomaly is the player's ONLY reliable method for detecting the Mimic. This must be communicated to the player through gameplay, not tutorial text.

**Communication Chain:**
1. Office 2 (Tanaka's whiteboard) mentions shadows
2. Office 3 (Webb's incident reports) mentions "shadow verification"
3. Director's email explicitly states "it cannot replicate shadows accurately"
4. Tank observation logs specify the 3-degree offset
5. Gameplay experience: first Mimic encounter demonstrates shadow absence

**Technical Rules:**
- All real objects cast shadows consistent with the nearest active light source
- Mimic-disguised objects have a 70% chance of NO shadow and a 30% chance of a 3-5 degree offset shadow
- The shadow anomaly applies to ALL Mimic disguises (objects, loot, teammates, hiding spots)
- In the Service Yard (strobing floodlight), shadow detection is unreliable — intentional design to create zones where the tell doesn't work, forcing alternative verification (object counting, memory)
- Flashlight beam counts as a light source: shining the flashlight directly at a suspected Mimic will cast a shadow from a real object but will NOT cast a shadow from the Mimic (or will cast a wrong shadow)

### Attack Behavior

When the Mimic is triggered (player interacts with disguise or approaches within 3 studs), it de-camouflages over 0.3 seconds, revealing its true form: a mass of grey-pink tissue that rapidly shifts between partial shapes. The attack animation depends on the disguise category:

| Disguise Type | Attack Animation | Damage | Stun Duration | Recovery |
|---------------|-----------------|--------|---------------|----------|
| Object | Object explodes outward, tendrils grab player | 1 pip | 1.0s | Mimic retreats to different room |
| Loot item | Item leaps at player's hand/face | 1 pip | 0.8s | Mimic retreats, item destroyed |
| Teammate (multiplayer) | Duplicate lunges, grabs player | 1 pip | 1.5s | Mimic retreats, duplicate dissolved |
| Hiding spot | Spot closes on player, interior attacks | 2 pips | 2.0s | Mimic retreats, spot destroyed |
| Ambush (back turned) | Silent approach, strike from behind | 2 pips | 1.5s | Mimic retreats |

**Post-Attack Behavior:** After attacking, the Mimic always retreats. It vanishes (de-materializes over 1 second) and repositions to a different room. It does not chase. It does not pursue. It has no CHASE state in the traditional sense. The Mimic's "chase" equivalent is creating increasingly aggressive lures — more duplicates, closer placement, higher-value loot as bait.

**Chase (Revealed Only):** If the Mimic is revealed by Session 14 audio (forced de-camouflage), it enters a panicked state and moves at medium speed directly away from the nearest speaker. If the player blocks its retreat, it will attack (1 pip damage, frantic animation) and then flee. During forced reveal, the Mimic does not disguise — it runs as its true form, which is deeply unsettling. Medium speed means the player can keep pace at a walk. It's not fast. It's scared.

### State Machine (Modified from Standard)

```
DORMANT → DISGUISED → PATIENT → TRIGGERED → ATTACK → RETREAT → REPOSITION → DISGUISED
                                                                      ↑
                ↓ (Session 14 audio)                                  │
            REVEALED → PANIC_FLEE ─────────────────────────────────────┘
```

- **DORMANT:** First 120 seconds of the run. Mimic is not present. Players explore freely.
- **DISGUISED:** Mimic is in a room, appearing as an object/loot/teammate. Motionless or performing simple idle animation.
- **PATIENT:** Mimic is disguised and a player is in the same room. It waits for interaction or proximity trigger.
- **TRIGGERED:** Player has come within 3 studs or interacted. De-camouflage begins. 0.3-second window.
- **ATTACK:** Damage dealt. Animation plays.
- **RETREAT:** Mimic vanishes over 1 second. Cannot be damaged or interacted with.
- **REPOSITION:** Mimic selects a new room and disguise. 10-15 second cooldown before next disguise.
- **REVEALED:** Forced de-camouflage by Session 14 audio. True form visible. 8-second duration.
- **PANIC_FLEE:** Mimic runs from speakers. Medium speed. Will not disguise until audio stops and 10 additional seconds pass.

### Escalation Over Time

| Run Phase | Mimic Behavior |
|-----------|---------------|
| 0-120s (DORMANT) | Not present. Safe exploration. |
| 120s-first objective | Conservative. One disguise at a time. Prefers distant rooms. Object duplication only. |
| First objective complete | Moderate. Starts disguising as loot items. Positions closer to critical path. |
| Server upload begins | Aggressive. Loot disguises more frequent. Teammate disguises begin (multiplayer). Repositioning every 30-45 seconds. |
| Server upload complete | Maximum aggression. All disguise types active. Repositioning every 20-30 seconds. Hiding spot mimicry enabled. Tunnel behavior activated. |

### Audio Design

The Mimic is almost completely silent. This is a deliberate contrast with Levels 1 (Patient's footsteps, electronics flatline) and 2 (Crawlers' skittering, pack vocalizations).

**Mimic Sound Profile:**
| State | Sound | Volume | Range |
|-------|-------|--------|-------|
| DISGUISED | Silence (matches object) | — | — |
| TRIGGERED | A wet, organic "unfurling" sound (0.3s) | Medium | 15 studs |
| ATTACK | Impact sound + player damage sound | Loud | 25 studs |
| RETREAT | Fading whisper (like many voices exhaling at once) | Low | 10 studs |
| REVEALED | Shriek (high-pitched, chittering, layered) | Very loud | 40 studs |
| PANIC_FLEE | Wet, slapping footsteps (no vocalizations) | Medium | 20 studs |

**Key Design Rule:** The absence of sound is the tell. In a game where every previous entity made noise as a warning system, the Mimic's silence is the warning. If the Proximity Fear System is escalating and you hear nothing — the Mimic is close, disguised, waiting.

---

## Scripted Events (First Playthrough Only)

These events trigger once per player profile (first completion). Subsequent playthroughs do not include them, preserving the randomized Mimic behavior as the primary threat.

| # | Trigger | Event | Purpose |
|---|---------|-------|---------|
| 1 | Enter Admin Reception for the first time | The single working fluorescent tube buzzes on, illuminating the reception area for 3 seconds. In the light, the player sees a figure sitting in the waiting area — a person, sitting normally, reading a magazine. The light pops and dies. When the flashlight illuminates the area: the chair is empty. The magazine is on the floor, open. | Establishes that the Mimic was here before the player. Sets tone of surveillance. |
| 2 | Enter Cell Block A for the first time | All four cell doors slam shut simultaneously (loud, metallic). Emergency lights strobe red. The knocked-over chair in Cell A2 is now upright, facing the glass. After 5 seconds, lights stabilize, doors unlock. The chair in A2 is knocked over again. | Introduces the Mimic's ability to change the environment between observation states. Teaches the player to notice object positions. |
| 3 | Pick up Director's Keycard in Containment Control | The monitor showing the player's location from the impossible angle zooms in. The feed shows the player holding the keycard. Then the camera pans to show a second figure standing directly behind the player in the feed. The player turns around — nothing there. The monitor dies. | Peak paranoia moment. Establishes that the Mimic knows what the player is doing and is watching. |
| 4 | Enter the Main Chamber for the first time | The floodlights around the central depression activate in sequence (boom, boom, boom — heavy relay sounds). Each light illuminates a section of the chamber. The final light illuminates the depression center. A human figure is standing in the depression, facing the player. All lights blow out simultaneously. Complete darkness for 3 seconds. When the flashlight illuminates the depression: empty. Wet footprints lead from the depression to the Tank. | Reveals the dig site and establishes the Mimic was contained here. The footprints create urgency to investigate the Tank. |
| 5 | Play Session 14 for the first time (Audio Lab) | The audio plays through the facility PA regardless of the player's broadcast setting. Every light in the station flickers in rhythm with the recording. From somewhere in the facility, a sound that has not been heard before: the Mimic screaming. Not the attack shriek — a sustained, almost human scream that lasts the full 8 seconds of the recording. It echoes through every corridor. When the recording stops, absolute silence for 5 seconds. Then: every intercom in the facility plays the same sentence simultaneously in the player's own voice (replayed from proximity mic data): "I'm sorry." | The most disturbing event in the level. Demonstrates the Mimic's vulnerability to the frequency AND its capacity for emotional mimicry. "I'm sorry" implies either the entity feels remorse, or it is using the words to manipulate. The ambiguity is the horror. |
| 6 | Begin Server Room upload | Terminal displays "CONNECTION ESTABLISHED." Then, below: "NOTE: A second user is currently accessing this terminal." The cursor moves by itself, typing: "I can't stop being things. I don't remember what I was before. Do you?" The text remains for 5 seconds, then the upload begins normally. | Humanizes the entity just enough to create discomfort. Is it sentient? Does it suffer? Does this change anything? The game does not answer. |
| 7 | Enter Emergency Tunnel for the first time | The player sees a figure standing at the far end of the tunnel. It is approximately 200 meters away. It is the player's own character model (solo) or a teammate (multiplayer). It raises one hand and waves slowly. Walking toward it: the figure maintains its apparent distance for 20 seconds, then blinks out of existence. Looking behind: a second figure, identical to the first, standing at the tunnel entrance the player just came from. Also waving. Both vanish if the player looks away and back. | Maximum paranoia. The tunnel is inescapable and the Mimic is demonstrating that it can be anywhere, at any distance, at any number. The waving gesture is friendly, which makes it worse. |
| 8 | Extraction cinematic — boat clears the fog | After the final lore text ("The station was declared secure..."), a brief post-credits moment: the player's safe room (hub) is shown. The evidence wall has a new photo pinned to it — a satellite image of Ashwood Forest (Level 4 location). On the workbench, a new item: a cassette tape. It is labeled "SESSION 89." There is no Session 89 on the Audio Lab shelf. The tape clicks on by itself and plays 3 seconds of static, then: "Come find me." In the player's voice. | Bridge to Level 4. Establishes that the Mimic is aware of the player beyond the level boundaries. It followed them. Or it was never contained. |

---

## Loot Table Summary

### Consumables

| Item | Total Spawns (est.) | Guaranteed | Mimic Bait? | Notes |
|------|---------------------|-----------|-------------|-------|
| Battery | 16-20 | 6 guaranteed | Yes (rare) | Distributed across all areas. Higher density on Surface. |
| Bandage | 12-16 | 4 guaranteed | Yes (rare) | Medical Bay and Barracks are primary sources. |
| Medkit | 4-5 | 3 guaranteed | Yes (return visit only) | Office 4 (locked), Medical Bay (locked), Cell B4 (locked), Director's Office (60%) |
| Flare | 5-7 | 0 | No | Higher spawn chance in Deep Level. Never the Mimic. Flares are safe. |

### Key Items (No Inventory Slot)

| Item | Location | Required For |
|------|----------|-------------|
| Cassette Tape (Session 14) | Office 2 (Tanaka's desk) | Audio Lab playback — reveals Mimic, provides tactical advantage |
| Director's Keycard | Containment Control desk | Opens Director's Office (Surface) |
| Medical Bay Key | Medical Bay nightstand | Opens Office 4 medicine cabinet |
| Extraction Codes | Director's Office safe | Activates boat navigation system at Dock |

### Mimic Bait Rules

- Only Batteries, Bandages, and Medkits can be Mimic bait. **Flares are never bait.** This gives players one guaranteed safe item type.
- Bait items only appear on return visits to rooms already looted (the original item was real; the replacement is fake).
- Maximum 2 Mimic bait items per run.
- Shadow tell always applies: check shadows before picking up items.
- Items found in locked containers (cabinets, safes) are NEVER bait. Locks = safe.

---

## Critical Path

```
SPAWN (Helipad)
    │
    ↓
ENTER ADMIN BUILDING → Explore offices, gather lore, find Cassette Tape (Office 2)
    │                    (Entity dormant for first 120 seconds)
    ↓
EXPLORE SURFACE → Barracks (supplies), Perimeter (lore)
    │
    ↓
DESCEND TO LAB LEVEL → Via Service Yard elevator or stairwell
    │                    (Entity activates at 120s or on Lab Level entry, whichever first)
    ↓
EXPLORE CONTAINMENT WING → Cell Blocks (lore), pick up DIRECTOR'S KEYCARD
    │                        (Containment Control)
    ↓
EXPLORE LABS → Biology Lab (lore), Audio Lab (load Cassette Tape — optional but
    │           powerful), Medical Bay (supplies + Medical Bay Key), Observation
    │           Deck (survey Deep Level)
    ↓
[OPTIONAL] RETURN TO SURFACE → Use Director's Keycard on Director's Office
    │                           → Retrieve EXTRACTION CODES from safe
    │                           → Use Medical Bay Key on Office 4 cabinet (Medkit)
    │
    ↓
DESCEND TO DEEP LEVEL → Via Observation Deck freight elevator or ladder shaft
    │
    ↓
MAIN CHAMBER → Survey area, locate Server Room and Tank
    │
    ↓
[OPTIONAL] THE TANK → Lore delivery. Safe zone.
    │
    ↓
SERVER ROOM → Begin upload → SURVIVE 180 SECONDS near Server Room
    │           → Upload completes → Extraction signal sent → Fuel system activated
    │
    ↓
[IF NOT ALREADY DONE] RETURN TO SURFACE → Retrieve EXTRACTION CODES
    │
    ↓
EMERGENCY TUNNEL → Transit to Dock (200m, high tension)
    │   OR
SURFACE SHORTCUT → Perimeter fence path down cliff to Dock (exposed, faster)
    │
    ↓
BOAT HOUSE → Connect fuel (20s) → Enter Extraction Codes → Launch boat
    │
    ↓
PIER → Board boat → EXTRACTION CINEMATIC → LEVEL 3 COMPLETE
```

### Optimal Path (Experienced Player)

```
Helipad → Admin (grab Cassette Tape, Office 2) → Service Yard → Lab Level →
Containment Control (grab Director's Keycard) → Audio Lab (load tape, optional) →
Observation Deck → Deep Level → Server Room (upload, 180s) →
DURING UPLOAD: Run to surface, grab Extraction Codes, return before timeout →
Emergency Tunnel → Dock → Extract
```

This optimal path requires the player to use the 30-second Server Room timeout window to sprint to the surface and back — extremely tight but possible with full stamina management.

---

## Timing

| Metric | Duration |
|--------|----------|
| Minimum completion (optimal, experienced, no loot) | ~10 minutes |
| Average first completion (with deaths/restarts) | ~22-30 minutes |
| Full exploration (all lore, all optional rooms, Tank) | ~35-40 minutes |
| Server Room upload | 180 seconds (fixed) |
| Fueling sequence | 20 seconds (fixed) |
| Extraction cinematic | 30 seconds (non-interactive) |

### Pacing Curve

```
Tension
  │
  │                                              ██ EXTRACTION
  │                                    ████████ ██
  │                          ████████ ██ TUNNEL
  │                    ██████ SERVER UPLOAD
  │              ██████
  │        ██████ LAB EXPLORATION
  │    ████
  │  ██ SURFACE (SAFE)
  │ █
  └──────────────────────────────────────────── Time
  0min    5min    10min    15min    20min    25min
```

---

## Multiplayer Scaling

### Player Count Adjustments

| Element | Solo | 2 Players | 3-4 Players |
|---------|------|-----------|-------------|
| Entity activation delay | 120s | 90s | 60s |
| Disguise reposition interval | 45-90s | 35-70s | 25-50s |
| Max loot bait per run | 2 | 3 | 4 |
| Teammate disguises | N/A | Active after first objective | Active after Lab Level entry |
| Server upload duration | 180s | 180s | 180s (unchanged) |
| Fuel sequence duration | 20s | 20s | 15s (faster with help) |
| Extraction beacon wait | 0s (auto) | 0s | 0s |
| Loot quantity | Base | +30% | +50% |
| Hiding spot mimicry frequency | 1 per run | 2 per run | 3 per run |
| Separation events | None | 1 (elevator jam) | 2 (elevator jam + Lab corridor gate) |

### Multiplayer-Specific Mechanics

**Teammate Verification Protocol:**
Players in multiplayer should develop their own verification methods. The game provides lore hints (shadow protocol, voice response) but does not enforce a system. Effective strategies:
- **Voice check:** Ask a question. The Mimic can only replay previous audio. Genuine conversation = real player.
- **Shadow check:** Shine flashlight at teammate. Real players cast correct shadows. Mimic duplicates cast wrong/no shadows.
- **Action check:** Ask teammate to perform a specific action (jump, crouch, drop an item). The Mimic cannot respond to novel requests.
- **Proximity:** Stand close enough for proximity voice to be clear. Mimic duplicates at close range have subtle visual tells (clothing texture slightly lower resolution, eyes blink at wrong intervals, walk cycle loops instead of varying).

**Separation Events:**
| Event | Trigger | Duration | Effect |
|-------|---------|----------|--------|
| Elevator jam | 2+ players enter Service Yard elevator | 45 seconds | Elevator stops between floors. One player stuck in elevator (cramped, dark). Others must take stairwell. Entity may appear on either side. |
| Lab corridor gate | 3+ players in Lab Corridor | 60 seconds | Emergency gate drops, splitting the corridor. Players separated into Containment Wing side and Research Labs side. Gate rises after 60 seconds. Mimic is always on the side with fewer players. |

**Co-op Downed State:**
- Standard downed state from GDD applies (30-second revive window)
- The Mimic may disguise as a downed teammate. The "downed player" calls for help via proximity voice (replaying the real player's voice) but is positioned away from where the real downed player fell
- Tell: the downed Mimic has no health bar UI indicator (real downed players show a depleting health ring)
- Reviving a downed Mimic triggers a 2-pip ambush attack

**Multiplayer Trust Erosion Timeline:**
| Run Phase | Trust Level | Mimic Tactic |
|-----------|------------|-------------|
| 0-120s | High (entity dormant, players together) | None |
| 120s-Lab entry | High (entity active but object-focused) | Object duplication only. Players learn shadow tells. |
| Lab exploration | Medium (first teammate sighting in distance) | First distant teammate duplicate. Players begin questioning. |
| Server upload | Low (Mimic aggressive, teammate duplicates common) | Multiple teammate duplicates possible. Voice mimicry active. |
| Emergency Tunnel | Minimal (paranoia peak) | Tunnel figure events. Players may refuse to follow each other. |
| Extraction | Shattered (final sequence) | Possible downed teammate bait. Final pier sighting. |

---

## Project ECHO Lore

### Timeline

| Date | Event |
|------|-------|
| 1971 | St. Maren's Hospital basement expansion uncovers anomalous cavern system beneath the building |
| 1972 | First entity sighting in sub-basement. Hospital covers it up. "Patient 31" documentation begins. |
| 1978 | Entity activity escalates. Multiple staff go missing. Hospital sealed to public under pretense of "renovation." |
| 1981 | DoD becomes involved after intercepted hospital communications. CDC assigned for biological threat assessment. |
| 1983 | Joint task force classifies all entities. Entity-01 (The Patient), Entity-02 (The Crawlers), Entity-03 (The Mimic) formally designated. Sub-basement sealed. |
| 1984 | Entity-03 tissue samples extracted from sub-basement. Samples demonstrate autonomous behavior in lab conditions. |
| 1985 | **Project ECHO established.** Purpose: long-term containment and study of anomalous entities. Blackpoint Research Station construction begins. |
| 1987 | Blackpoint operational. Entity-03 primary mass transported from St. Maren's. Containment in the Tank. Research begins under Director Vasquez. |
| 1988 | Entity-03 demonstrates object mimicry (replicates lab equipment). Behavior classified as instinctive, not intelligent. |
| 1989 | Entity-03 demonstrates human mimicry for the first time (replicates a lab technician). Classification revised: intelligent, adaptive. |
| 1990 | Entity-03 tissue samples shipped to secondary research sites, including Ashwood Forest Ranger Station (Site Gamma) for field study. |
| 1991 | Entity-04 (The Watchers) discovered at Ashwood Forest. Connection to Entity-03 tissue samples suspected but unconfirmed. |
| 1992 | Entity-03 begins communicating through mimicked voices. It requests conversations with specific researchers. It asks questions about its own nature. |
| 1993, March | Dr. Tanaka discovers the Session 14 frequency vulnerability. Classified EYES ONLY. |
| 1993, September 14 | Entity-03 breaches containment. Blackpoint evacuated. Facility sealed. |
| 1993, September 15 | Coast Guard inspection. Station declared secure. 12 researchers present. All shadow checks pass. No anomalies detected. |
| 1993-2023 | Blackpoint listed as active NOAA facility. Routine supply deliveries. No incidents reported. |
| 2023 | Satellite survey detects thermal anomalies. Investigation team dispatched. (Level 3 begins.) |

### The Echo Hypothesis

Across the lore in Level 3, the following theory emerges (never stated explicitly, assembled by the player from documents):

Entity-03 was not discovered at St. Maren's Hospital. It was always at Blackpoint — in the deep excavation site. The "footprint" in the Main Chamber's central depression suggests something far larger than the entity currently is. The entity beneath St. Maren's Hospital was a fragment — a piece of something that had been underground for millennia. When Blackpoint researchers extracted Entity-03 and brought it back to the coastal site, they returned it to its point of origin. It didn't escape from the Tank because it was contained. It escaped because it was *finished*. It had learned everything it needed from six years of observing humans.

The Coast Guard inspection on September 15 found 12 researchers and no anomalies. The real researchers were evacuated or killed on September 14. The 12 "researchers" found by the Coast Guard were all the Mimic. It had already spread. The facility being declared "secure" meant the Mimic had perfected its disguise. Shadow checks passed because it had learned to replicate shadows — the one flaw identified by the research team, corrected by the entity overnight.

The tissue samples sent to Ashwood Forest gave rise to Entity-04 (The Watchers). The entities are all connected — fragments of the same original organism, each developing different survival strategies. Project ECHO's name is not a codename — it is descriptive. Each entity is an echo of the original. And the original is still below St. Maren's Hospital. It has always been there. Level 5 is the descent to find it.

### Key Documents Found in Level 3 (Summary)

| Document | Location | Key Revelation |
|----------|----------|---------------|
| Pilot's Flight Log | Helipad | Confirms thermal signatures; someone is alive here |
| Visitor Log | Reception | Third inspector who didn't arrive — Mimic infiltration |
| Specimen Transport Manifest | Office 1 | Entity-03 was shipped from St. Maren's to Blackpoint |
| Tanaka's Whiteboard Notes | Office 2 | 23.40 Hz freezes the Mimic; 18.97 Hz attracts it |
| Webb's Incident Reports | Office 3 | Escalating containment failures over two weeks |
| Staff Medical Charts | Office 4 | Researchers losing ability to distinguish self from entity |
| Webb's Journal | Barracks | Eyewitness account of duplicate researcher |
| Evacuation Notice | Barracks | Shadow verification protocol |
| Guard's Radio Log | Perimeter | The Mimic replicated the helicopter |
| Cell A4 Observation Log | Cell Block A | Object counting as detection method |
| Entity-03 Drawings | Cell Block B4 | Entity perceives the station from above; draws duplicates of people |
| Security Feed Log | Containment Control | "Vasquez everywhere" — the breach |
| Harlan's Research Notes | Biology Lab | Cellular totipotency; entity becomes what it mimics at cellular level |
| Specimen Jar Label | Biology Lab | Autonomous tissue mimicry (the sample mimicked the jar lid) |
| Tanaka's Session Notes | Audio Lab | Session 14 as recursive feedback weapon |
| Recording Labels | Audio Lab | Entity used Tanaka's voice in Session 88 |
| Observation Deck Log | Observation Deck | Dig site is a "footprint"; entity came from here originally |
| Surgical Log | Medical Bay | Entity-03 cooperated with surgery; tissue samples independently mimic |
| Chen's Emergency Notes | Medical Bay | Ketamine slows the Mimic (not implementable as gameplay; lore flavor) |
| Excavation Team Report | Main Chamber | Sub-chamber material has cellular structure; the dig site IS the entity |
| Tank Observation Log | The Tank | 7-day account of perfect human mimicry; shadow as sole tell |
| Leaked Waste Analysis | The Tank | Entity-03 cells in the water supply for 89 days |
| Transfer Order | The Tank | Tissue samples sent to Ashwood Forest (Level 4 connection) |
| Server Access Log | Server Room | 347 login attempts by "Vasquez" after the real Vasquez evacuated |
| Data Manifest | Server Room | Blackpoint studied ALL entities, not just Entity-03 |
| Dock Manifest | Boat House | Evacuation boat ECHO-2 never arrived at the mainland |
| Emergency Phone Messages | Emergency Tunnel | Entity reproduces player's voice with pitch shift |

---

## Appendices

### Appendix A: Environment Art Direction

| Area | Palette | Lighting | Key Materials |
|------|---------|----------|---------------|
| Surface | Grey concrete, olive green (military), rust orange | Overcast daylight, harsh white fluorescent (brief) | Corrugated metal, chain-link, cracked concrete |
| Lab Level | White tile, stainless steel, cyan accent (emergency strips) | Emergency red + cyan floor strips, CRT blue (monitors) | Ceramic tile, tempered glass, surgical steel |
| Deep Level | Dark grey stone, amber (floodlight), blue-grey (dig site glow) | Sparse floodlights, dig site luminescence, total darkness between | Raw rock, industrial scaffold, moisture-slick concrete |
| Dock | Dark blue-grey, yellow (work light), white (fog) | Single work light, navigation buoy red flash, fog diffusion | Marine-grade steel, rubber, saltwater-corroded metal |

### Appendix B: Sound Design Notes

| Area | Ambient Base | Unique Sounds |
|------|-------------|---------------|
| Surface | Wind, rain, distant waves, fence rattle | Helicopter wreck metallic ticking, fog wall low-frequency hum |
| Admin Building | Silence, occasional fluorescent buzz, HVAC rattle | Paper rustling (no source), phone ring (one-time) |
| Cell Blocks | Emergency system hum, door hydraulics (ambient), camera servo motor | Cell A3 camera following player (subtle pan sound) |
| Biology Lab | Refrigerator compressor, specimen jar fluid ambient | Empty jar resonance when walked past (wind-over-bottle sound) |
| Audio Lab | Dead silence (acoustic dampening) | Player's own breathing amplified, Mimic frequencies when played |
| Main Chamber | Dripping water, echo of own footsteps, sub-bass vibration | Dig site 23.40 Hz natural tone, scaffold metal stress pings |
| Server Room | Cooling fan drone (constant, loud), HDD seek sounds | Upload progress chimes, cursor typing (scripted event) |
| Emergency Tunnel | Amplified footsteps, distant dripping, own breathing | Mimicked footsteps behind player, phone messages |
| Dock | Waves, wind, rope slap against metal, hull creak | Marine radio burst, fuel hose connection clunks, railway mechanical grind |

### Appendix C: Proximity Fear System — Mimic Modifications

The standard Proximity Fear System (see GDD) applies with the following Level 3 modifications:

| Modification | Detail |
|-------------|--------|
| Silent PANIC | Because the Mimic makes no sound while disguised, the Proximity Fear System may reach Tier 3-4 with no audible entity sounds. The player sees/hears the fear effects (desaturation, heartbeat, vignette) but hears no entity. This is intended. |
| Dig site override | Standing in the Main Chamber's central depression suppresses Proximity Fear to Tier 1 maximum regardless of Mimic location. The natural 23.40 Hz frequency provides a calming effect. |
| Session 14 disruption | While Session 14 is playing, the Proximity Fear System is suppressed to Tier 0 for the player. The fear shifts from the player to the entity. |
| False positives | At Tier 2+, the system may generate phantom object counts — the player's HUD briefly flashes a number (e.g., "7") then disappears. This is the player character subconsciously counting objects. It is not a gameplay mechanic — it is a psychological effect. |
| Post-attack relief | After a Mimic attack, the Proximity Fear System drops to Tier 0 for 15 seconds (the entity has retreated). This provides a relief window and confirms the threat has passed temporarily. |
