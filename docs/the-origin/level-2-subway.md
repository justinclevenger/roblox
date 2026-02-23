# Level 2: Line 13 Subway System — Detailed Design

## Narrative

The player descends into the Hargrove Street subway entrance following coordinates extracted from the Blackpoint shipping manifests found in Level 1. The distress signal originated from a research team that was using the decommissioned Line 13 tunnel network as a transport corridor to a coastal facility. The line was shut down eighteen months ago after a series of "structural incidents" — collapses that killed eleven workers. Except the bodies were never recovered. And the collapses only happened in sections with no structural weakness. Something pulled the tunnels down on top of them.

Objective: Navigate three stations connected by the Line 13 tunnel network. Reroute power at the midpoint station (Moorfield) to unlock the extraction gate at Terminus station. Escape to the surface. Optionally: find the Nest — the source of the Crawlers — and recover the lore that explains what Blackpoint was transporting through these tunnels.

The player is no longer learning. Level 1 taught the rules. Level 2 breaks them. The Patient was one. The Crawlers are many. The Patient was slow. The Crawlers are fast. The Patient rarely checked hiding spots. The Crawlers always check. The hospital had wide corridors and multiple floors to create distance. The subway has narrow tunnels where something can sprint the full length in seconds. This level teaches a single lesson: you cannot outrun a pack. You must outsmart it.

---

## Floor Plan

```
HARGROVE STREET STATION (Entry)
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ┌──────────────────────────────────────────────┐                      │
│  │              TICKET HALL                      │                      │
│  │  [Spawn Point — street entrance stairs]       │                      │
│  │  Turnstiles, ticket machines, info boards     │                      │
│  └────────────┬─────────────┬───────────────────┘                      │
│               │             │                                           │
│  ┌────────────┴──┐  ┌──────┴───────────────────────────────────────┐   │
│  │  STAFF ROOM   │  │          MEZZANINE / CONCOURSE               │   │
│  │  [Map, hiding]│  │   Escalators (dead), stairs to platforms     │   │
│  └───────┬───────┘  └──────┬──────────────────────┬────────────────┘   │
│          │                 │                      │                     │
│          │         ┌───────┴────────┐   ┌────────┴─────────┐           │
│          │         │  PLATFORM A    │   │   PLATFORM B     │           │
│  ┌───────┴──────┐  │ [Abandoned     │   │  [Collapsed]     │           │
│  │ MAINTENANCE  │  │  train car,    │   │  Forces tunnel   │           │
│  │ CLOSET       │  │  lootable]     │   │  entry           │           │
│  │ [Supplies]   │  └───────┬────────┘   └────────┬─────────┘           │
│  └──────────────┘          │                     │                     │
│                            │     ┌───────────────┘                     │
└────────────────────────────┼─────┼─────────────────────────────────────┘
                             │     │
═══════════════════════════════════════════════════════════ TUNNEL LEVEL
                             │     │
TUNNEL NETWORK               │     │
┌────────────────────────────┼─────┼─────────────────────────────────────┐
│                            │     │                                     │
│  ┌─────────────────────────┴─────┴──────────────────────────────────┐  │
│  │                    MAIN TUNNEL                                    │  │
│  │  Long, straight, wide. No cover. Crawlers sprint full length.    │  │
│  │  ═══════════════════════════════════════════════════════════════  │  │
│  │  Parallel tracks. Emergency lights every 50 studs (dim red).     │  │
│  └─────────┬───────────────────────┬─────────────────────┬──────────┘  │
│            │                       │                     │              │
│  ┌─────────┴──────────┐  ┌────────┴─────────┐  ┌───────┴────────────┐ │
│  │  SERVICE TUNNEL    │  │ JUNCTION CHAMBER  │  │  VENTILATION       │ │
│  │  (Parallel)        │  │ [4-way crossing]  │  │  SHAFTS            │ │
│  │  Narrow. Slower    │  │  Open. Exposed.   │  │  [Crawlspace       │ │
│  │  for Crawlers.     │  │  4 entry points.  │  │   shortcuts]       │ │
│  │  Your escape       │  └────────┬──────────┘  └───────┬────────────┘ │
│  │  route.            │           │                     │              │
│  └─────────┬──────────┘  ┌────────┴──────────┐  ┌──────┴─────────────┐ │
│            │             │  FLOODED SECTION   │  │ COLLAPSED SECTION  │ │
│            │             │  Waist-deep water. │  │ Rubble. Squeeze    │ │
│            │             │  Wading is LOUD.   │  │ points. Buys time. │ │
│            │             └────────┬──────────┘  └──────┬─────────────┘ │
│            │                      │                    │               │
└────────────┼──────────────────────┼────────────────────┼───────────────┘
             │                      │                    │
═══════════════════════════════════════════════════════════ MOORFIELD
             │                      │                    │
MOORFIELD STATION (Midpoint)        │                    │
┌────────────┼──────────────────────┼────────────────────┼───────────────┐
│            │                      │                    │               │
│  ┌─────────┴──────────────────────┴────────────────────┴────────────┐  │
│  │                       PLATFORM                                   │  │
│  │  Stalled train — doors open and close on their own.              │  │
│  │  6 cars. Crawlers inside/on top.                                 │  │
│  └──────────┬─────────────────────────────────────┬─────────────────┘  │
│             │                                     │                    │
│  ┌──────────┴───────────┐          ┌──────────────┴──────────────────┐ │
│  │    CONTROL ROOM      │          │         CONCOURSE               │ │
│  │  [OBJECTIVE:         │          │  Wider area. Vending machines.  │ │
│  │   Reroute power]     │          │  Breather. They're still in     │ │
│  │  3-step process.     │          │  the tunnels. For now.          │ │
│  └──────────────────────┘          └──────────────┬──────────────────┘ │
│                                                   │                    │
└───────────────────────────────────────────────────┼────────────────────┘
                                                    │
═══════════════════════════════════════════════════════ DEEP TUNNELS
                                                    │
DEEP TUNNELS                                        │
┌───────────────────────────────────────────────────┼────────────────────┐
│                                                   │                    │
│  ┌────────────────────────────────────────────────┴─────────────────┐  │
│  │                 UNFINISHED EXTENSION                              │  │
│  │  Raw concrete. No lighting infrastructure. Pitch black.          │  │
│  │  Construction equipment. Dead end branches.                      │  │
│  └──────────┬──────────────────────────────────┬────────────────────┘  │
│             │                                  │                       │
│  ┌──────────┴───────────┐        ┌─────────────┴────────────────────┐  │
│  │      THE NEST        │        │      DRAINAGE SYSTEM             │  │
│  │  [OPTIONAL — LORE]   │        │  Connects to Terminus.           │  │
│  │  Where they come     │        │  Echoes carry everything.        │  │
│  │  from. Suicidal to   │        │  Final approach.                 │  │
│  │  explore.            │        │                                  │  │
│  └──────────────────────┘        └─────────────┬────────────────────┘  │
│                                                │                       │
└────────────────────────────────────────────────┼───────────────────────┘
                                                 │
═══════════════════════════════════════════════════════ TERMINUS
                                                 │
TERMINUS STATION (Extraction)                    │
┌────────────────────────────────────────────────┼───────────────────────┐
│                                                │                       │
│  ┌─────────────────────────────────────────────┴────────────────────┐  │
│  │                       PLATFORM                                   │  │
│  │  [Extraction Point — power must be on from Moorfield]            │  │
│  └──────────┬──────────────────────────────┬────────────────────────┘  │
│             │                              │                           │
│  ┌──────────┴───────────┐      ┌───────────┴────────────────────────┐  │
│  │   EMERGENCY EXIT     │      │        SEALED DOOR                 │  │
│  │  Stairs to surface.  │      │  Blackpoint Research logo.         │  │
│  │  One-way. Once       │      │  Connects to Level 3.              │  │
│  │  you're out, you're  │      │  Player cannot open.               │  │
│  │  out.                │      │  Lore breadcrumb.                  │  │
│  └──────────────────────┘      └────────────────────────────────────┘  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Room Details

### Hargrove Street Station (Entry)

#### Ticket Hall (Spawn)

- Player descends a flight of concrete stairs from street level. Rain sounds fade behind them. A metal security gate rolls shut at the top — no going back.
- Wide open space: tiled floor, smashed ticket machines, dead turnstiles, faded transit map on the wall. Emergency lighting casts a sickly amber wash that reaches about 60% of the room, leaving corners in shadow.
- One turnstile is bent outward — something came through from the platform side with significant force. Claw marks scored into the metal.
- Newspaper dispenser: headline reads "LINE 13 SERVICE SUSPENDED INDEFINITELY — STRUCTURAL INVESTIGATION ONGOING." Date is eighteen months ago.
- Transit authority poster partially torn: safety notice about "reporting unusual sounds from service tunnels."
- Scattered belongings near the entrance — a dropped backpack, a single shoe, a phone with a cracked screen (interactable: shows a half-typed text message that was never sent: "something is moving in the ce").
- The room feels safe. Wide sightlines, multiple exits, good lighting. This is deliberate. It will not feel safe for long.
- Two exits: stairs down to Mezzanine/Concourse, staff-only door to Staff Room (unlocked, slightly ajar).
- Loot: `1x Battery [guaranteed]`, `1x Bandage [guaranteed]`, `1x Flare [40%]` (inside dropped backpack)

#### Mezzanine / Concourse

- Intermediate level between Ticket Hall and platforms. Two dead escalators flank a central staircase.
- Advertising boards line the walls — most display normal transit ads, but one has been defaced with scratched symbols matching the ones from Patient 31's cell in Level 1.
- Information board with full Line 13 route map — annotates all three stations. Player can study this to understand the level layout.
- A busker's guitar case sits open near the escalators. Coins scattered. Guitar smashed against the wall.
- Sound design: the acoustics shift here. The station amplifies sound — footsteps echo. The player's own movement sounds louder than expected. This is a mechanical warning: sound carries in this level.
- Exit left: Platform A. Exit right: Platform B. Stairs up: Ticket Hall.
- Loot: `1x Battery [50%]` (in guitar case)

#### Platform A

- Standard subway platform. Tiled walls, bench seating, destination board (flickering, stuck cycling between "MOORFIELD" and "TERMINUS" and "DO NOT BOARD").
- An abandoned train car sits on the tracks — doors forced open. Interior is lootable but claustrophobic. Six rows of seats, dim emergency strips along the floor.
- While inside the train car: ambient scratching sounds from inside the walls/ceiling of the tunnel. Rhythmic. Stops when the player stops moving. Resumes when they move. No entity is present yet — this is atmospheric foreshadowing.
- The far end of the train car has a door ripped off its hinges from the outside. Something peeled it open.
- Platform edge: player can drop down to track level (1.5s vault animation, moderate noise). This leads into the Main Tunnel.
- Yellow safety line along platform edge — interactable sign: "MIND THE GAP."
- Loot: `1x Bandage [guaranteed]` (train car seat), `1x Battery [60%]` (train car driver's cabin), `Lore: Transit Worker's Journal` (describes sounds in the tunnels weeks before closure — "skittering, like a dozen hands on concrete")

#### Platform B (Collapsed)

- The ceiling has partially collapsed. Concrete debris, rebar, shattered tiles. The platform is impassable beyond the first 10 studs.
- A construction barricade blocks the collapse with "DANGER — STRUCTURAL FAILURE" tape. Behind it, the tunnel mouth is blocked by rubble.
- The collapse forces the player toward Platform A to enter the tunnels — there is no other way forward.
- Visible through a gap in the rubble: a hard hat with a headlamp still on, illuminating a small pocket of space. Something dark and wet is smeared on the inside of the rubble. Not paint.
- The collapse groans periodically — ambient sound, no actual danger. But it keeps the player moving.
- Loot: `1x Bandage [30%]` (near barricade), `Lore: Incident Report — Collapse B` (official report listing eleven missing workers, signed by Blackpoint Structural Division)

#### Staff Room

- Behind the staff-only door off the Ticket Hall. Small break room: table, chairs, lockers, microwave, a corkboard.
- The corkboard has a full schematic map of Line 13 — all three stations, both tunnel routes (main and service), and the junction points. Studying it marks waypoints on the player's mental map / compass. This is the most important lore-functional item in the first station.
- Four lockers: two open (loot), one locked (no key exists — red herring), one welded shut with a handwritten note taped to it: "DON'T OPEN. IT GOT IN THROUGH THE VENTS."
- Microwave has dried food inside. Clock on the wall stopped at 3:47 AM.
- Hiding spot: under the table (tablecloth drapes to the floor) or inside open lockers.
- The door doesn't latch properly — it swings open on its own after 15-20 seconds. This becomes relevant when Crawlers activate: the player cannot secure this room.
- Loot: `1x Battery [guaranteed]`, `1x Bandage [50%]`, `Lore: Staff Duty Roster` (one name highlighted: "Weaver, R. — Reassigned to Blackpoint Coastal. DO NOT CONTACT.")

#### Maintenance Closet

- Accessed from a side corridor between the Mezzanine and Platform A. Heavy door, but the lock is broken — the bolt doesn't engage. The door can be pulled shut but will not hold if pushed from outside.
- Small room: utility shelving, cleaning supplies, a mop bucket, electrical panel (non-functional).
- Hiding spot: behind the shelving unit (player squeezes into a gap). Effective but the Crawlers' always-check behavior means this is a gamble.
- A ventilation grate in the ceiling is loose — it rattles when air moves through. Or when something moves through the shaft above it. This grate connects to the ventilation shaft network but is too high for the player to reach (it is an entry point for Crawlers, not the player).
- Loot: `2x Battery [guaranteed]`, `1x Flare [50%]`

---

### Tunnel Network

The tunnel network is the connective tissue of the level. It sits between Hargrove Street and Moorfield stations. The player must traverse it twice: once going to Moorfield, and once continuing to the Deep Tunnels and Terminus. The tunnels are where the Crawlers are most dangerous — tight spaces, limited escape routes, amplified sound.

#### Main Tunnel

- A straight, wide railway tunnel approximately 200 studs long. Two sets of tracks, concrete walls, overhead cable infrastructure. Emergency lighting every 50 studs — dim red LEDs that create pools of faint visibility separated by stretches of near-total darkness.
- The critical design feature: **no hiding spots**. No alcoves, no side rooms, no cover. If a Crawler enters the Main Tunnel while the player is inside, the only options are to reach one end before it reaches them, or duck into the Service Tunnel access points.
- Three Service Tunnel access doors are spaced along the Main Tunnel's length (at roughly 50, 100, and 150 studs). These are heavy metal doors that screech when opened (30 stud sound radius).
- Track-side detritus: abandoned maintenance carts (cannot hide behind — too low), cable spools, tool caches left by workers.
- Sound design: footsteps echo aggressively. The player can hear Crawlers moving in the Service Tunnel through the walls — skittering, clicking, the scrape of claws on concrete. The sound bounces, making directionality unreliable.
- At the midpoint (100 studs): a maintenance cart with a dead transit worker's belongings. Radio (dead), thermos, lunchbox with a photo of his family inside.
- Loot: `1x Battery [40%]` (in maintenance cart), `Lore: Worker's Last Radio Log` (portable recorder — final transmission describing "movement on the ceiling, three — no, four of them, moving together")

#### Service Tunnel (Parallel)

- Runs parallel to the Main Tunnel for its full length. Narrow — barely wide enough for the player to sprint, and too narrow for the player to pass a Crawler without contact. Pipe-lined walls, dripping condensation, flickering work lights strung on temporary cable.
- The Service Tunnel is the player's escape route. Crawlers can enter but move at 60% of their normal speed due to the confined space (they cannot use wall/ceiling climbing). The player moves at 80% of normal speed (no sprinting — the ceiling is too low in sections).
- Three access doors connect to the Main Tunnel (matching the Main Tunnel entries). Each door is heavy and loud.
- Branching maintenance alcoves every 30 studs — small cutouts with fuse boxes and valve wheels. Just deep enough to press into and let a Crawler pass if the player goes still and kills the flashlight. Not a formal hiding spot (no interaction prompt) — the player must manually crouch, turn off the flashlight, and pray. The Crawler's vision cone in the narrow tunnel makes this a 70/30 survival chance.
- One section has a burst pipe spraying water across the tunnel. Walking through it produces splash sounds (15 stud radius). Crouching through: 8 stud radius.
- The tunnel dead-ends at the Moorfield end — the player must exit via the last access door back into the Main Tunnel to reach the station.
- Loot: `1x Bandage [guaranteed]` (hanging from a first aid station on the wall), `1x Battery [50%]`

#### Junction Chamber

- A large octagonal chamber where the Main Tunnel, Service Tunnel, a ventilation shaft, and the passage toward the Flooded Section all converge. Approximately 40x40 studs. Ceiling height is 30 studs — tall enough for Crawlers to use the ceiling effectively.
- Four entry points: Main Tunnel (north), Service Tunnel (west), Flooded Section passage (south), Ventilation Shaft access (east, elevated — requires climbing a maintenance ladder).
- Central feature: a large ventilation fan unit (non-operational). The blades are jammed. The housing provides partial cover but not a hiding spot.
- Emergency lighting is slightly better here — a battery-powered work lamp left by the construction crew still functions, casting harsh white light in a 15-stud radius around the center. This light makes the player visible from any entry point.
- The player can shoot out the work lamp with a thrown object (any item in inventory, item is consumed) to plunge the room into darkness. This reduces Crawler detection range but also leaves the player blind without a flashlight.
- The open nature of this room is its danger. A Crawler can enter from any of the four passages. The player is exposed from every direction. Moving through quickly is essential.
- Graffiti on the wall near the ventilation shaft access: a transit worker scrawled "THEY COME FROM BELOW" in marker. Below it, someone else wrote "NO. THEY COME FROM THE DARK."
- Loot: `1x Flare [guaranteed]` (critical placement — player needs this for the Flooded Section or deeper), `1x Bandage [40%]`

#### Ventilation Shafts

- Accessed from the Junction Chamber (east wall, maintenance ladder to elevated grate) and from two other points: one near the Moorfield Platform, one inside the Collapsed Section.
- Crawlspace dimensions: the player moves in a forced-crouch animation. Movement speed is 40% of normal walk. No sprinting. Flashlight beam is compressed by the narrow space, illuminating only 5-8 studs ahead.
- The shafts are shortcuts — they bypass sections of the main tunnel network. But the critical design tension: **Crawlers move at full speed in ventilation shafts.** They were designed for this space. The player was not.
- The player enters a vent and hears something moving ahead. Or behind. The echo makes it impossible to tell. The shaft branches at two points — left or right. One leads forward. The other leads to a dead end where a Crawler may be waiting.
- Shaft layout:
  - **Branch A:** Junction Chamber → Moorfield Platform (bypass the Flooded Section entirely — but longer crawl)
  - **Branch B:** Junction Chamber → Collapsed Section (shortcut, but exits into a tight space)
  - **Dead End C:** A branch that terminates at a grate overlooking the Main Tunnel. The player can see through but cannot exit. Useful for scouting. Terrible if a Crawler followed them in.
- Environmental detail: the shafts are lined with scratch marks. Thousands of them. The Crawlers have been using this network for months.
- At one junction inside the shafts, a desiccated rat hangs from the ceiling by webbing that isn't spider silk. It's organic but wrong — translucent, fibrous, faintly warm to the touch.
- Loot: `1x Battery [guaranteed]` (wedged against a vent grate, left by a previous explorer)

#### Flooded Section

- A 60-stud stretch of tunnel where a water main burst (or was broken). The water is waist-deep, opaque, dark. The surface reflects the player's flashlight beam back at them, destroying forward visibility.
- **Core mechanic: wading is loud.** Every step produces a sloshing sound with a 35-stud radius — equivalent to sprinting on dry ground. There is no quiet way through. Crouching submerges the player to chin-level and reduces sound to 20 studs, but movement becomes agonizingly slow (25% normal speed) and the player cannot use the flashlight (hand holding it above water).
- The Crawlers can navigate the Flooded Section by climbing the walls and ceiling above the waterline. They are silent on the walls. The player is loud in the water. This inversion is the point.
- Submerged obstacles: the player bumps into unseen objects below the surface — shopping carts, debris, a body (the player's hand touches it during a forced animation, it shifts, it's not a body, it's a bundle of the same organic webbing from the vents).
- A section of pipe runs along the wall at head-height — the player can grab it and pull themselves along (faster than wading, same noise level, but both hands occupied — no flashlight).
- Halfway through: a dry platform (a collapsed section of elevated walkway that sits above the waterline). The player can rest here, manage inventory, catch their breath. But the platform is small and exposed.
- Ambient sound: water dripping from everywhere. Occasional distant splashing that is not the player. Gurgling from submerged drains.
- Loot: `1x Medkit [guaranteed]` (on the dry platform — critical heal placement before Moorfield), `Lore: Waterlogged Field Notes` (plastic-wrapped, partially legible — Blackpoint survey team documenting "biological contamination in the water table, source unknown, recommend immediate quarantine of Line 13 subsections")

#### Collapsed Section

- A stretch of tunnel where the ceiling has partially given way. Concrete chunks, rebar, dust. The path forward requires navigating through squeeze points — narrow gaps in the rubble that the player must press through via a 2-second committed animation.
- **Key mechanic: squeeze points buy time.** Crawlers can fit through squeeze points but must transition from wall/ceiling movement to ground level and squeeze through one at a time. This takes them 4-5 seconds per Crawler. In a chase with a pack of 3-5, this creates a staggered pursuit where the player gains 10-20 seconds of lead.
- Three squeeze points in sequence, each tighter than the last. The third requires the player to exhale (button prompt) and push through — 3-second animation, completely vulnerable.
- Between squeeze points: small pockets of open space with rubble. One contains a construction worker's helmet with a still-functioning headlamp (cosmetic only — atmospheric). Another contains a collapsed support beam with tool marks — someone was trying to shore up the tunnel. They didn't finish.
- A fissure in the collapsed ceiling reveals a vertical shaft going up. Too narrow to climb. But something is moving up there — the sound of claws on rock, ascending.
- Emergency exit sign on the wall, arrow pointing forward, partially buried. The sign is wrong — it points toward the Deep Tunnels, not toward any exit.
- Loot: `1x Bandage [guaranteed]`, `1x Battery [60%]`, `1x Flare [30%]`

---

### Moorfield Station (Midpoint)

#### Platform

- The player emerges from the tunnel network onto Moorfield's platform. It is wider and more modern than Hargrove Street — renovated in the last decade, with tiled mosaic walls and LED strip lighting (dead, except for one section that flickers in a rhythmic pattern that almost looks deliberate).
- A six-car train sits on the tracks. It arrived at Moorfield and never left. Doors on cars 1, 3, and 5 are open. Doors on cars 2, 4, and 6 are closed — but they open and close on their own at irregular intervals (every 20-45 seconds), producing a pneumatic hiss that mimics the sound of breathing.
- The train is both a resource and a trap:
  - **Cars 1 and 3:** Lootable. Seats, luggage racks, overhead compartments. Standard abandoned-in-a-hurry scenario — bags, coats, a child's toy.
  - **Car 2:** Locked. Windows are smeared with something dark from inside. Banging from within on the player's first approach (one-time event). Nothing further.
  - **Car 4:** Contains a body slumped against the window. Transit worker uniform. ID badge reads "Chen, A. — Line 13 Operations." Carrying a maintenance key (opens the Control Room's backup panel).
  - **Car 5:** The roof has been peeled open from above. Claw marks radiate outward from the breach. This is how the Crawlers access the train — and the platform. A Crawler can drop from the breach at any time during a patrol pass.
  - **Car 6:** Empty. Emergency intercom activated — plays a looping automated message: "Service on Line 13 has been suspended. Please proceed to the nearest exit. Service on Line 13 has been suspended. Please—" The recording degrades each loop, growing more distorted until it sounds like a voice saying something else entirely.
- Platform furniture: benches (hiding spots — player lies flat underneath), a newspaper stand (knocked over), a transit map display.
- The platform's east end connects to the Concourse via stairs. The west end connects back to the tunnel network.
- Loot: `Car 1: 1x Battery [guaranteed], 1x Bandage [50%]` | `Car 3: 1x Flare [40%], Lore: Passenger's Diary` (describes the train stopping, lights dying, something on the roof, screaming, then silence) | `Car 4: Maintenance Key [guaranteed]`

#### Control Room

- Accessed from a locked security door on the platform level (Maintenance Key from Car 4, or the player can force the door — 5-second animation, extremely loud, 50-stud sound radius).
- The Control Room is the primary objective space. A compact room filled with switching panels, route diagrams, monitor banks (mostly dead), and a central control desk.
- **Objective: Reroute Power to Terminus** — Three-step process:
  1. **Locate the Terminus circuit** on the switching panel. The panel has 12 circuits labeled with station codes. The player must find "TRM-13" — it's behind a detached panel cover that must be removed (5s interaction, quiet).
  2. **Reroute power** by pulling three breaker switches in the correct sequence. The sequence is displayed on a faded maintenance card pinned to the wall — but two of the three numbers are legible. The third must be found: it's scratched into the underside of the control desk by a previous survivor. Pulling breakers in the wrong order trips a fuse that resets the sequence (loud electrical pop, 40-stud sound radius, 10-second reset delay).
  3. **Engage the main bus** — a large lever that sends power down the line to Terminus. This produces a building electrical hum that peaks in a loud transformer bang (60-stud radius). All Crawlers immediately enter INVESTIGATE toward Moorfield. The player has approximately 20 seconds before the first Crawler reaches the platform.
- Monitor bank: one functional screen shows a security camera feed from Terminus station. The platform is dark. When power engages in step 3, the Terminus lights flicker on — and for one frame, something is visible on the platform before the feed cuts to static.
- Filing cabinet: Blackpoint internal memo discussing "biological asset transport via Line 13 — containment protocols for specimen transit between coastal facility and primary research station." Signed by someone named Director Voss.
- Loot: `Lore: Blackpoint Transit Memo [guaranteed]`, `1x Battery [guaranteed]`, `1x Bandage [guaranteed]`

#### Concourse

- The widest open space in Moorfield. A proper station concourse with a vaulted ceiling, ticket gates (open), directional signage, and two shuttered retail units (a coffee shop and a newsagent).
- This is a deliberate breather space. After the tunnel network, the player needs a moment of reduced tension. The Concourse provides wider sightlines, multiple exits, and a sense of space. The Crawlers are still in the tunnels at this point (pre-objective). The player can hear them — distant skittering through the walls — but the Concourse itself is temporarily safe.
- Coffee shop: shutter is half-open. Player can crouch under to enter. Inside: overturned tables, a smashed espresso machine, and a functional sink (ambient water sound — covers footsteps slightly). Hiding spot behind the counter.
- Newsagent: shutter locked. Can be forced open (loud). Inside: magazines, a cashbox with nothing useful, and a transit worker's jacket with a name tag ("HARLOW") and a note in the pocket: "If you're reading this, don't go past Moorfield. Turn around. The deeper tunnels are where they nest."
- Directional signage: "DEEP TUNNELS — AUTHORIZED PERSONNEL ONLY" points toward the south exit. The "AUTHORIZED PERSONNEL" text has been crossed out and replaced with "NO ONE" in handwriting.
- Public phone on the wall. Interactable. Dial tone. Player can dial numbers. One specific number (scrawled on the wall next to the phone: 0-4-7-3-1) connects to a recording: a Blackpoint automated system that reads coordinates and a designation — "Specimen Transport Alpha. Status: Containment breach. Quarantine failed. Recommend total site lockdown." Then the line goes dead. Dialing any other number: busy signal.
- The Concourse connects to the Deep Tunnels via a security gate (unlocked — the lock was ripped apart from the tunnel side).
- Loot: `1x Battery [50%]` (coffee shop counter), `1x Bandage [guaranteed]` (newsagent first aid box), `Lore: Harlow's Warning Note [guaranteed]`

---

### Deep Tunnels

The Deep Tunnels represent the second half of the level's traversal. They connect Moorfield to Terminus but pass through unfinished construction — tunnels that were being extended when Line 13 shut down. This is Crawler territory. The lighting infrastructure was never installed. The player's flashlight is the only light source. Battery management becomes critical.

#### Unfinished Extension

- Raw concrete walls, exposed rebar, construction scaffolding, abandoned heavy equipment (a boring machine sits dormant, covered in dust and the organic webbing). No emergency lighting. No overhead cables. No tiled walls. This is a tunnel that was never finished, and it shows.
- The darkness here is absolute. Without the flashlight, the player sees nothing. This is the first time in the game where there is zero ambient light. The proximity fear system's flashlight-flicker effects at Tier 2-3 become devastating here — the player's only light source becomes unreliable precisely when they need it most.
- The Extension branches. The main path continues toward the Drainage System and Terminus. A side branch leads to the Nest (optional). A dead-end branch contains construction supplies and lore.
- **Dead End Branch:** 30 studs deep. Ends at a concrete wall with drill marks where the boring machine stopped. A small construction office (portable cabin) is set up here: desk, blueprints, radio equipment.
  - Blueprints show the full tunnel network including a section labeled "VOID — DO NOT EXCAVATE" at the exact location of the Nest. The blueprints are Blackpoint documents, not transit authority.
  - Radio equipment is modified — it's not standard construction kit. Frequencies are tuned to ranges used for biological monitoring equipment.
  - A personal log from the site foreman: "They told us to stop digging when we broke through into the cavity. Then Blackpoint showed up. Took over the site. Brought in their own crew. Sealed everything. We were reassigned. But I went back. I had to see. The cavity goes down further than our survey showed. And it's not empty."
- Heavy equipment and scaffolding create a maze-like environment. Sightlines are broken every 10-15 studs. The Crawlers can navigate overhead on scaffolding and the ceiling while the player is forced to ground level.
- Sound carries strangely — the raw concrete reflects sound in unpredictable ways. The player's footsteps seem to come from multiple directions.
- Loot: `Dead End: 2x Battery [guaranteed], 1x Medkit [guaranteed], Lore: Foreman's Log [guaranteed], Lore: Blackpoint Blueprints [guaranteed]` | `Main Path: 1x Bandage [50%], 1x Flare [30%]`

#### The Nest (Optional — High Risk)

- **This area is designed to be avoided on a normal run. Entering it is a deliberate choice to pursue lore at extreme personal risk. The game never requires the player to enter. NPCs, notes, and environmental cues all warn against it. The player who enters does so out of curiosity or completionism. The game respects that decision by rewarding it with critical lore — and punishing it with the most dangerous encounter in Level 2.**
- Access: a jagged breach in the tunnel wall, 20 studs down the Nest side-branch from the Unfinished Extension. The breach is ringed with the organic webbing — thicker here, layered, almost structural. It's warm. It pulses faintly, like a slow heartbeat.
- The breach leads into a natural cavity beneath the tunnel — not man-made. The player descends via a broken scaffolding ladder into a space roughly 60x40 studs with a 50-stud ceiling that disappears into darkness.
- **The Nest environment:**
  - The walls are covered in organic material. The webbing here is dense, layered, architectural. It forms structures — pillars, arches, chambers. The Crawlers built this. It is deliberate. It is organized.
  - The floor is uneven — natural rock mixed with concrete fragments and bones. Animal bones. Most of them. Not all of them.
  - Small alcove-chambers line the perimeter — each one roughly body-sized. Some contain desiccated husks that might have been human. Some contain something that is clearly mid-transformation — partially encased in webbing, features distorted, limbs wrong.
  - The center of the Nest contains a larger structure: a mound of webbing roughly 8 studs tall. At its base, something organic pulses. This is not a Crawler. It is something else. It does not move. It does not react to the player. But it is alive.
  - On the far side of the mound: a Blackpoint containment unit. Military-grade, reinforced. Its door has been ripped open from the inside. Inside: empty restraint systems sized for something much larger than a Crawler, manifests listing "Specimen Alpha — Origin: St. Maren's Sub-Basement," and a data drive.
  - The data drive is the key lore item. It contains research logs describing what Blackpoint was transporting through Line 13: biological specimens recovered from beneath St. Maren's Hospital. The Crawlers are not the specimen — they are what the specimen produces. The containment breach happened during transit. The specimens were being moved to the coastal facility for study when one escaped. Then they all escaped. Then the Crawlers appeared.
- **Entity behavior in the Nest:**
  - 2 Crawlers are always present — one dormant on the ceiling (IDLE state, activates on sound or light), one in slow patrol along the perimeter walls.
  - If the player enters the Nest, all other Crawlers on the map begin migrating toward it. Within 90 seconds, the full pack will arrive.
  - The dormant ceiling Crawler has a reduced detection range (it's asleep — 5-stud sound radius, 4-stud vision) but if activated, immediately enters CHASE with no INVESTIGATE/HUNT intermediary.
  - The patrol Crawler moves on the walls — circling the room at ceiling height. Its patrol path passes directly over the containment unit. The player must time their approach to the lore items.
  - If the player triggers a chase in the Nest, the exit breach is the only way out. The scaffolding ladder climb is a 3-second committed animation. If a Crawler is within 10 studs when the player starts climbing, it reaches them before they escape.
- **Sound design in the Nest:** organic. Wet. Breathing sounds from the webbing. A low vibration that comes through the floor. The proximity fear system is permanently at Tier 1 (UNEASE) minimum while inside, regardless of actual Crawler distance. The space itself is wrong.
- Loot: `Lore: Blackpoint Data Drive [guaranteed]` (the critical item — connects Level 1's Patient to Level 2's Crawlers to Level 3's facility), `Lore: Specimen Transit Manifest [guaranteed]`, `1x Medkit [guaranteed]` (near exit — mercy placement for the escape)

#### Drainage System

- The final traversal section connecting the Deep Tunnels to Terminus station. A large storm drain / utility drainage corridor running beneath the train tunnels. The player drops down through a maintenance hatch in the Unfinished Extension floor.
- Circular cross-section, approximately 15 studs in diameter. The bottom third is covered in shallow running water (ankle-deep — less noise than the Flooded Section but still audible at 12-stud radius when walking, 6 studs when crouching).
- The drainage system's critical feature: **echoes carry everything.** The circular cross-section and hard surfaces create an echo chamber. The player's footsteps bounce back at them from multiple directions. The Crawlers' sounds do the same. Directionality is almost impossible to determine by audio alone.
- The player cannot tell if a sound is ahead, behind, or above. This is the one area where the sound system actively works against the player's ability to locate threats.
- The drainage system is 80 studs long with two right-angle bends. Each bend is a blind corner. At each bend, a vertical access shaft goes up — the Crawlers can enter from above at any bend.
- Midway through: a junction where a smaller pipe feeds in from the side. Too small for the player. Not too small for a Crawler. They can emerge from these feeder pipes without warning.
- The water in the drainage system is discolored. The same dark fluid from the Nest. It's flowing away from the Nest's direction — whatever is in the Nest is seeping into the water table.
- The exit is a ladder up into Terminus station's sub-platform level. 4-second climb, committed animation. The player is vulnerable during the climb but the drainage system's echo makes it hard for Crawlers to pinpoint them.
- Loot: `1x Battery [guaranteed]`, `1x Bandage [50%]`

---

### Terminus Station (Extraction)

#### Platform

- The player emerges onto the Terminus platform from a maintenance hatch in the floor. Terminus is the end of Line 13 — a smaller station, clearly newer construction, with a minimalist design that feels more corporate than public transit. Blackpoint's influence is visible: security cameras (dead), reinforced doors, biometric scanners on walls (non-functional).
- If the player completed the power reroute at Moorfield, the station has partial power: overhead lights flicker at 40% brightness, escalators hum but don't move, electronic signage displays garbled text that occasionally resolves into "BLACKPOINT TRANSIT CORRIDOR — AUTHORIZED ACCESS ONLY."
- If the player did NOT complete the power reroute (impossible in normal play, but relevant for sequence break attempts): the station is completely dark and the extraction gate is sealed. The player must return to Moorfield.
- The platform is the extraction trigger zone. A service elevator at the far end connects to the Emergency Exit. Interacting with the elevator call button begins the extraction sequence (see Scripted Events).
- The platform has minimal cover: two support pillars, a bench, and a knocked-over vending machine. A single Crawler is visible on the far wall when the player first enters — it is watching them. It does not move. It watches for 5 seconds, then skitters into a ventilation grate and disappears. This is a psychological beat: it knows you're here. It's telling the others.
- Loot: `1x Battery [50%]`, `1x Bandage [30%]`

#### Emergency Exit

- The service elevator (activated by the extraction sequence) takes the player up one level to a concrete stairwell. The stairwell leads to a surface exit — a heavy fire door that opens onto a rain-soaked street.
- The stairwell is the final gauntlet. During the extraction sequence, the Crawlers converge on Terminus. The elevator takes 15 seconds to arrive. The stairwell is 30 studs of vertical climb — two flights of stairs with a landing in between.
- The fire door at the top is mechanically locked — a push-bar release that requires 3 seconds of interaction. The player hears the Crawlers in the stairwell behind them during this animation.
- Once through the fire door, it slams shut and auto-locks. The player is on the surface. Rain. Streetlights. A waiting emergency vehicle with headlights on. The player approaches it.
- As the player reaches the vehicle: the sound of scratching from below the street. From the drainage grates. From inside the walls of the buildings around them. A final audio sting. Then silence.
- **One-way exit. Once through the fire door, the level is complete. The player cannot return to the subway.**
- Loot: None. This is pure extraction.

#### Sealed Door

- Located on the Terminus platform level, opposite the Emergency Exit elevator. A heavy reinforced door with the Blackpoint Research logo — a stylized black circle with a break in the circumference.
- The door has a biometric scanner (non-functional), a keycard reader (requires a card the player does not have in Level 2), and a manual override panel (sealed behind welded steel).
- The player cannot open this door. Interacting with it produces a text prompt: "BLACKPOINT COASTAL RESEARCH FACILITY — TRANSIT ACCESS. SECURITY CLEARANCE: LEVEL 7 REQUIRED."
- Through a small reinforced window in the door, the player can see a corridor stretching into darkness. It's clean. Clinical. Fluorescent lights flicker at the far end. Something moves across the distant light for a single frame.
- This door connects to Level 3's Blackpoint Research Station. It is a lore breadcrumb — the player now knows where they're going and why.
- On the floor near the door: a dropped Blackpoint ID badge. The photo shows a woman — Dr. Elena Voss, Director, Special Projects Division. The badge's clearance level has been manually scratched out and re-marked: "REVOKED."
- Loot: `Lore: Dr. Voss ID Badge [guaranteed]`

---

## Entity Behavior (Level 2 Specific)

### The Crawlers — Overview

The Crawlers are a pack-hunting entity. Unlike The Patient's singular, predictable stalking pattern, the Crawlers operate as a coordinated group of 3-5 individuals that communicate, flank, and corner the player. They are fast, aggressive, and relentless.

**Physical behavior:**
- Quadrupedal movement (arms and legs, low to the ground). Roughly human-sized but elongated — limbs are too long, joints bend wrong.
- Can transition between floor, walls, and ceiling seamlessly. The transition animation takes 0.5s and is near-silent.
- On walls/ceilings, they move at 90% of their ground speed. In tight tunnels, they use ceiling movement to pass over the player.
- Eyes reflect flashlight beams — two points of light in the dark that blink independently.

**Sound signature:**
- Skittering: rapid, light tapping of claws on hard surfaces. Audible at 30 studs. Faster tempo = faster movement.
- Clicking: a rhythmic jaw-clicking used for pack communication. When one clicks, others respond. The player learns to count the responses to estimate pack size nearby.
- Breathing: wet, shallow, rapid. Audible at 10 studs. Indicates a Crawler that is stationary and listening.
- Hissing: aggression vocalization when transitioning to CHASE. Heard at 40 studs. Once you hear this, you're already running.

### Spawn Timing

| Phase | Timing | Count | Behavior |
|-------|--------|-------|----------|
| Entry | 0-120s | 0 | No Crawlers. Player explores Hargrove Street safely. Ambient sounds suggest presence. |
| Awakening | 120s | 1 | A single Crawler activates on Platform A. First encounter is scripted (see Scripted Events). |
| Escalation | 180s | 3 | Two additional Crawlers spawn in the tunnel network. Pack behavior activates. |
| Full Pack | Player enters Moorfield OR 300s (whichever first) | 4-5 | Maximum pack size. Full coordination. Nest garrison (2) activates if Nest is entered. |
| Objective Spike | Power reroute completed | All | All Crawlers enter INVESTIGATE toward Moorfield. 20s grace period before arrival. |
| Extraction | Elevator called at Terminus | All | All Crawlers converge on Terminus. Chase-speed movement. No INVESTIGATE phase — straight to HUNT. |

### Patrol Routes (3 Variants — Randomized Per Run)

**Route Alpha — Tunnel Focused**
- Crawler 1: Main Tunnel → Junction Chamber → Flooded Section → Junction Chamber → Main Tunnel (loop)
- Crawler 2: Service Tunnel full length, pausing at each alcove for 5-8s
- Crawler 3: Ventilation shaft network → drops into Junction Chamber → returns to shafts
- Crawlers 4-5 (if active): Hargrove Platform A → tunnel mouth → Main Tunnel first 50 studs → return

**Route Beta — Station Focused**
- Crawler 1: Hargrove platforms → tunnel network → Moorfield platform (if accessible) → tunnel network → return
- Crawler 2: Moorfield train cars (moves through cars via roof breach in Car 5) → platform → concourse → platform
- Crawler 3: Junction Chamber → Collapsed Section → Junction Chamber → Ventilation Shafts
- Crawlers 4-5 (if active): Deep Tunnels — Unfinished Extension, patrolling scaffolding and ceiling

**Route Charlie — Aggressive Sweep**
- All Crawlers sweep in the same direction: Hargrove → tunnels → Moorfield → Deep Tunnels → loop
- Staggered timing: 30-second gap between each Crawler entering a section
- Creates a wave pattern — the player can move against the flow but encounters Crawlers sequentially
- Full sweep loop: ~4 minutes

### Pack Coordination Mechanics

The Crawlers communicate via clicking sounds. This is not just atmospheric — it drives actual AI coordination:

**Calling:**
- When one Crawler detects evidence of the player (sound, glimpse, light), it produces a click pattern. All Crawlers within 80 studs receive this as a waypoint and begin moving toward the location.
- The click is audible to the player at 30 studs. The player can hear the response clicks from other Crawlers — providing information about how many are nearby and from which directions.

**Flanking:**
- When a Crawler enters CHASE, it broadcasts the player's last-known direction. Other Crawlers within 100 studs do not converge on the same point — they move to cut off likely escape routes.
- Specifically: if the player is fleeing north through the Main Tunnel, one Crawler chases from behind while others enter the Service Tunnel and Ventilation Shafts to intercept at the next junction.
- The flanking Crawlers move at patrol speed, not chase speed — they're positioning, not pursuing.

**Cornering:**
- If two or more Crawlers have line-of-sight on the player simultaneously, the closest one engages (CHASE) while others hold position at exits. This creates a trap — the player must break past a stationary blocker or find a route none of them are covering.
- Blocker Crawlers hold position for 15 seconds, then resume CHASE if the player hasn't been caught.

**Ceiling Drops:**
- In rooms with sufficient ceiling height (Junction Chamber, station platforms, the Nest), Crawlers can position on the ceiling directly above the player's path. They drop when the player passes beneath — a 0.5s attack that the player can avoid only with sprint-burst timing.
- Audio cue: a single, quiet click directly above the player, 1 second before the drop. Players who learn this sound can dodge. Players who don't, can't.

### Detection Parameters (Level 2 Specific)

| Parameter | Value | Comparison to Level 1 |
|-----------|-------|----------------------|
| Vision cone | 80 degrees | Wider (Level 1: 60 degrees) |
| Vision range (lit) | 35 studs | Slightly further |
| Vision range (dark) | 10 studs | Further (they see better in the dark) |
| Detection ramp (visual) | 0.3s | Much faster (Level 1: 0.5-1s) |
| Hearing range (sprint) | 45 studs | Further |
| Hearing range (walk) | 15 studs | Slightly further |
| Hearing range (crouch) | 5 studs | Further (Level 1: 3 studs, ignored) |
| Hiding spot check | Always | Level 1: Rare early, learned over time |
| Flashlight detection range | 55 studs | Slightly further |
| Blood trail follow | Yes, full speed | Same |
| Water wading detection | 35 studs (walk), 20 studs (crouch-wade) | New mechanic |
| Pack communication range | 80 studs | N/A — Level 1 was solo entity |

### Wall and Ceiling Climbing

- Crawlers can seamlessly transition between floor, wall, and ceiling surfaces. Transition takes 0.5 seconds and produces a brief scraping sound (8-stud radius).
- On walls: Crawlers move at 90% ground speed. Their vision cone rotates to match their orientation — a wall-crawling entity looking down the tunnel has the same detection capability as one on the floor.
- On ceilings: Crawlers move at 80% ground speed but are harder for the player to detect — the player's flashlight typically illuminates at eye-level or below. Looking up requires deliberate camera movement. Players must train themselves to check the ceiling.
- In the Ventilation Shafts: Crawlers use all surfaces — floor, walls, ceiling — interchangeably. They move at full speed in these spaces. The player is locked to the floor at 40% speed. This asymmetry is the primary tension driver in the vent sections.
- Climbing Crawlers are slightly quieter — the skittering sound is reduced to 20-stud radius (from 30 on the ground). Ceiling Crawlers are the hardest to hear.

### How The Crawlers Differ From The Patient

| Aspect | The Patient (Level 1) | The Crawlers (Level 2) |
|--------|----------------------|------------------------|
| Count | 1 | 3-5 |
| Speed | Slow patrol, medium chase | Fast patrol, very fast chase |
| Detection | Forgiving ramp (1.5s) | Brutal ramp (0.3s) |
| Hiding spots | Rarely checks early | Always checks |
| Movement | Ground only | Floor, walls, ceiling |
| Sound signature | Heavy footsteps, breathing | Light skittering, clicking |
| Warning system | Electronics flicker near it | Pack clicking communication |
| Adaptation | Learns hiding spots over time | Coordinates in real-time |
| Atmosphere | Slow dread, being watched | Frantic, surrounded, hunted |
| Player response | Wait, hide, time movements | Sprint, route-plan, manage stamina |

---

## Scripted Events (First Playthrough Only)

| # | Trigger | Event |
|---|---------|-------|
| 1 | Enter Platform A train car | Scratching sounds from inside the tunnel walls. Player's flashlight dims for 2 seconds. When it returns, fresh claw marks have appeared on the inside of the train car window that weren't there before. Something dragged its claws across the glass while the light was out. |
| 2 | First time entering the Main Tunnel | The emergency lights ahead go out in sequence — one by one, approaching the player's position, then stopping 30 studs away. A single clicking sound from the darkness ahead. Silence. The lights do not come back on. |
| 3 | 120s after level start (Awakening) | Wherever the player is, they hear a Crawler's hiss echo through the station. On Platform A, a Crawler drops from the ceiling onto the tracks, looks directly at the player for 2 seconds (first visual confirmation), then sprints into the tunnel darkness at full speed. It does not attack. It's announcing itself. |
| 4 | First time entering the Junction Chamber | All four tunnel entrances echo with clicking simultaneously. The player is surrounded by sound. The work lamp in the center of the room flickers and dies for 3 seconds. When it returns, a Crawler is visible at the edge of the light, on the ceiling, watching. It retreats when the player's flashlight hits it. |
| 5 | First time entering the Flooded Section | The player's first step into the water produces a loud splash. The water ripples from ahead — something else is in the water, submerged, moving away from the player. The ripples lead to a wall where something exits the water and skitters up the wall, disappearing. The player is now aware: they share the water. |
| 6 | Entering Moorfield train Car 2 area | Banging from inside locked Car 2. Three heavy impacts against the window from inside. The glass cracks but holds. A face presses against the cracked glass — not a Crawler. A person. Mouth open. No sound. Then they're pulled backward into the dark interior. The banging stops. This is a one-time event with no further interaction. Car 2 never opens. |
| 7 | Power reroute completed (Moorfield Control Room) | All station lights surge to full brightness for 5 seconds — blinding after the darkness. Every door in Moorfield slams open simultaneously. The automated PA crackles: "Power restored to Line 13. Next service: [static]. Please stand clear of the [static]." Then, from the tunnels: a chorus of clicking. Not from one direction. From all of them. The lights drop to 40%. |
| 8 | Elevator called at Terminus (extraction) | The elevator machinery engages — grinding, loud, mechanical. From the drainage system hatch the player entered through: skittering. Fast. Getting louder. From the ventilation grate on the wall: clicking. From inside the sealed Blackpoint door: a single, heavy impact. Not a Crawler. Something bigger. Then the elevator arrives. |

---

## Loot Table Summary

| Item | Total Available | Guaranteed | Locations | Purpose |
|------|----------------|------------|-----------|---------|
| Battery | 14-16 | 7 | Ticket Hall, Staff Room, Maintenance Closet (x2), Vent Shafts, Moorfield Car 1, Control Room, Deep Tunnels Dead End (x2), Drainage System + probabilistic spawns | Flashlight fuel (critical — pitch black sections) |
| Bandage | 10-13 | 5 | Ticket Hall, Platform A, Service Tunnel, Collapsed Section, Concourse Newsagent, Control Room + probabilistic spawns | Heal 1 pip |
| Medkit | 3 | 3 | Flooded Section (dry platform), Deep Tunnels Dead End, Nest (near exit) | Full heal + stop bleed |
| Flare | 3-5 | 1 | Junction Chamber (guaranteed) + Ticket Hall, Maintenance Closet, Collapsed Section, Moorfield Car 3, Deep Tunnels (probabilistic) | Distraction (8s) |
| Maintenance Key | 1 | Yes | Moorfield Train Car 4 | Opens Control Room |
| Lore Documents | 10 | All fixed | See individual room entries | Story + Evidence Wall |

### Lore Document Index

| Document | Location | Content |
|----------|----------|---------|
| Transit Worker's Journal | Platform A train car | Describes sounds in tunnels before closure |
| Incident Report — Collapse B | Platform B | Official report on missing workers |
| Staff Duty Roster | Staff Room | Blackpoint reassignment of personnel |
| Worker's Last Radio Log | Main Tunnel maintenance cart | Eyewitness account of Crawlers (audio) |
| Waterlogged Field Notes | Flooded Section dry platform | Blackpoint survey — biological contamination |
| Passenger's Diary | Moorfield Train Car 3 | First-person account of the train incident |
| Blackpoint Transit Memo | Moorfield Control Room | Confirms biological asset transport via Line 13 |
| Harlow's Warning Note | Moorfield Concourse newsagent | Warning not to go past Moorfield |
| Foreman's Log | Deep Tunnels dead end | Discovery of the cavity / Blackpoint takeover |
| Blackpoint Blueprints | Deep Tunnels dead end | Full tunnel network including the Nest void |
| Specimen Transit Manifest | The Nest | Details on what was being transported |
| Blackpoint Data Drive | The Nest | Key lore — connects Levels 1, 2, and 3 |
| Dr. Voss ID Badge | Terminus Sealed Door | Introduces Level 3's antagonist |

---

## Critical Path

```
SPAWN (Hargrove Street — Ticket Hall)
    ↓
EXPLORE HARGROVE STREET (safe — no Crawlers for 120s)
    ↓   └── Loot Ticket Hall, Staff Room (get map), Maintenance Closet
    ↓   └── Explore Platform A train car (loot + lore)
    ↓   └── Discover Platform B is collapsed — tunnels are the only way
    ↓
ENTER TUNNEL NETWORK (Crawlers activate at 120s)
    ↓   └── Choose route: Main Tunnel (fast, exposed) or Service Tunnel (slow, safer)
    ↓   └── Navigate Junction Chamber (high exposure, get flare)
    ↓   └── Traverse Flooded Section OR use Ventilation Shafts to bypass
    ↓   └── Pass through Collapsed Section (squeeze points buy time if pursued)
    ↓
ARRIVE AT MOORFIELD STATION
    ↓   └── Explore platform — loot train cars
    ↓   └── Obtain Maintenance Key from Car 4
    ↓   └── [Optional] Explore Concourse for supplies and lore
    ↓
COMPLETE OBJECTIVE — CONTROL ROOM
    ↓   └── Open Control Room (key or force door)
    ↓   └── Locate TRM-13 circuit (remove panel)
    ↓   └── Find breaker sequence (wall card + desk scratch)
    ↓   └── Pull breakers in correct order
    ↓   └── Engage main bus → POWER TO TERMINUS
    ↓   └── All Crawlers converge — ESCAPE MOORFIELD (20s window)
    ↓
ENTER DEEP TUNNELS
    ↓   └── Navigate Unfinished Extension (pitch black — flashlight only)
    ↓   └── [OPTIONAL] Enter the Nest — extreme risk, critical lore
    ↓   └── Drop into Drainage System
    ↓   └── Navigate echoing tunnels to Terminus
    ↓
ARRIVE AT TERMINUS STATION
    ↓   └── Confirm power is active
    ↓   └── [Optional] Examine Sealed Door (Level 3 breadcrumb)
    ↓
EXTRACTION
    ↓   └── Call elevator (triggers final convergence)
    ↓   └── Survive until elevator arrives (15s)
    ↓   └── Ride elevator to Emergency Exit stairwell
    ↓   └── Climb stairs, open fire door (3s interaction)
    ↓
SURFACE — LEVEL COMPLETE
```

---

## Timing

| Metric | Duration |
|--------|----------|
| Minimum completion (experienced, skip optional) | ~10 minutes |
| Average first completion | ~20-30 minutes (with deaths) |
| Full exploration (all lore, Nest included) | ~35-45 minutes |
| Nest detour (entry to exit, if survived) | ~5-8 minutes |

---

## Multiplayer Scaling

| Element | Solo | 2 Players | 3-4 Players |
|---------|------|-----------|-------------|
| Crawler activation delay | 120s | 90s | 60s |
| Pack size | 3 | 4 | 5 |
| Crawler patrol speed | Base | +10% | +20% |
| Crawler chase speed | Base | +5% | +10% |
| Detection ramp (visual) | 0.3s | 0.25s | 0.2s |
| Power reroute breaker pulls | 3 | 4 | 5 |
| Extraction elevator wait | 15s | 20s | 30s |
| Loot quantity | Base | +30% | +50% |
| Hiding spot check rate | Always | Always + faster | Always + fastest |
| Flooded Section wading noise | 35 studs | 40 studs | 45 studs |
| Nest garrison (dormant Crawlers) | 2 | 3 | 4 |
| Nest convergence timer | 90s | 70s | 50s |
| Separation events | None | 1 (tunnel collapse isolates players on different sides of Junction Chamber, 45s) | 2 (tunnel collapse + Moorfield train doors trap a player inside Car 5 for 30s with ceiling breach above) |

### Multiplayer-Specific Mechanics

**Split Pathing:** The tunnel network's parallel structure (Main Tunnel + Service Tunnel) naturally encourages player splitting in co-op. One player scouts the Main Tunnel while another moves through the Service Tunnel. This is effective but means each player faces Crawlers alone. The game rewards this tactic with faster traversal but punishes it with isolated encounters.

**Downed State in Tunnels:** A downed player in a narrow tunnel blocks the path. Teammates must either revive (exposing themselves) or climb over (2s animation, loud). In the Flooded Section, a downed player's head is at water level — the revive timer is reduced to 20 seconds (from 30) to represent drowning risk.

**Pack Splitting:** With 2+ players, the Crawler pack may split — 2 Crawlers pursue one group while the remainder pursue the other. The pack always assigns at least 2 Crawlers per detected player group. Solo players in co-op (separated from team) draw the full pack's attention.

**Proximity Voice in Tunnels:** The echo mechanics affect proximity voice chat — teammates' voices bounce and distort in the tunnels, making communication difficult. In the Drainage System, voice chat is nearly unusable due to echo (by design — the players must rely on the game's audio cues, not verbal coordination).

---

## The Nest — Design Deep Dive

The Nest is the signature optional area of Level 2. It serves three critical functions:

1. **Lore Hub:** Contains the documents that connect Level 1 (St. Maren's) to Level 2 (the subway) to Level 3 (Blackpoint Coastal). Without the Nest lore, the player understands that Crawlers exist. With it, they understand why — and what comes next.

2. **Skill Test:** The Nest is the most dangerous enclosed space in Level 2. Two resident Crawlers, a 90-second convergence timer, and a single exit create a puzzle: how quickly can the player locate the lore items, collect them, and escape before the full pack arrives? Experienced players can clear the Nest in 60-70 seconds. First-timers will panic.

3. **Tone Setter:** The Nest communicates that the Crawlers are not random monsters. They build. They organize. They reproduce. The organic webbing, the transformation chambers, the pulsing central mound — this is biology, not supernatural chaos. Blackpoint was studying something from beneath St. Maren's, and that something creates Crawlers. The Nest makes the player understand: there are more of these things than the 3-5 they've been running from. Many more.

### Recommended Nest Strategy (for design reference — not communicated to player)

1. Arrive with at least 1 flare, 1 medkit, and 50%+ flashlight battery.
2. Enter the Nest. Immediately crouch. Kill flashlight.
3. Wait 10 seconds to identify the patrol Crawler's position by sound (wall-skittering).
4. When patrol Crawler is on the far side, move to the containment unit (center-rear of the room). Use brief flashlight pulses — 1 second on, 3 seconds off.
5. Collect the Data Drive and Manifest (5s interaction each). Time this between patrol passes.
6. If the dormant ceiling Crawler activates: throw flare to opposite side of room. The flare draws both Crawlers for 8 seconds. Sprint to exit.
7. Climb scaffolding ladder (3s). Sprint through breach. Do not stop until you reach the Drainage System.
8. Total Nest time: 60-90 seconds optimal.

### Nest Discovery Design

The Nest should feel like the player found something they weren't supposed to find. Environmental cues:
- The Blackpoint Blueprints in the dead end branch mark the Nest as "VOID — DO NOT EXCAVATE" — this is both a warning and an invitation.
- Harlow's note in the Concourse says "don't go past Moorfield." The Nest is past Moorfield.
- The organic webbing increases in density as the player approaches the Nest branch. It goes from occasional strands to thick layers — a gradient that communicates "you are approaching the source."
- The breach in the tunnel wall has a faint warm glow from within (the bioluminescence of the organic material). In a level defined by pitch darkness, a source of light that isn't the player's is immediately compelling.

Players who ignore all warnings and enter the Nest are rewarded with the game's deepest lore. Players who heed the warnings and skip it miss the lore but have a significantly easier path to extraction. Both are valid. Neither is wrong.

---

## Atmosphere and Audio Design Notes

### Sound Palette

| Sound | Context | Function |
|-------|---------|----------|
| Skittering (claws on concrete) | Crawler movement | Primary threat indicator. Faster = closer. |
| Clicking (jaw communication) | Crawler pack coordination | Tells player how many Crawlers are nearby. Count the responses. |
| Water dripping | Flooded sections, drainage | Ambient masking. Helps and hurts. |
| Metal groaning | Tunnel infrastructure | Atmospheric. Sometimes accompanies Crawler wall-climbing on metal surfaces. |
| Train door pneumatics | Moorfield platform | False positive — sounds like breathing, creates paranoia around the train. |
| Distant rumble | Throughout tunnels | Suggests movement of something large, deep underground. Never explained. |
| Echo / reverb scaling | Varies by space | Tight tunnels = close reverb. Stations = wide reverb. Drainage = extreme echo. Teaches player to read spaces by sound. |
| Organic sounds (Nest) | The Nest only | Wet breathing, membrane stretching, fluid movement. Alien. Biological. |

### Lighting Design

| Area | Lighting | Player Flashlight Dependency |
|------|----------|------------------------------|
| Hargrove Street Ticket Hall | Emergency amber — 60% coverage | Low |
| Hargrove Street Platforms | Emergency amber — 40% coverage | Medium |
| Main Tunnel | Red emergency LEDs every 50 studs | High (between LEDs) |
| Service Tunnel | Temporary work lights (flickering) | High |
| Junction Chamber | Single work lamp (destroyable) | Medium → High if lamp destroyed |
| Flooded Section | None (water reflects flashlight) | Total |
| Collapsed Section | None | Total |
| Moorfield Platform | Emergency blue-white (post-power: 40%) | Medium |
| Moorfield Concourse | Emergency blue-white (post-power: 50%) | Low-Medium |
| Unfinished Extension | None | Total |
| The Nest | Faint bioluminescence (2-3 stud radius glow from webbing) | Near-total |
| Drainage System | None | Total |
| Terminus Platform | Pre-power: None. Post-power: 40% overhead fluorescent | Pre: Total. Post: Medium |

### Battery Economy

The level is designed around flashlight battery management. With ~3 minutes per battery and 7 guaranteed batteries (14-16 total including probabilistic), the player has approximately 21-48 minutes of flashlight time. Given average completion of 20-30 minutes, battery management is tight but not impossible.

The critical tension point: the Deep Tunnels (Unfinished Extension, Nest, Drainage System) have zero ambient light and represent approximately 8-15 minutes of traversal. If the player has burned through batteries in the earlier sections, they will face the darkest part of the level with a dying flashlight. This is intentional.

**Design rule:** The player should never be completely battery-less for more than 30 seconds unless they mismanaged resources. There is always a battery within reach — but reaching it in the dark, with Crawlers, is the challenge.

---

## Environmental Storytelling — Narrative Thread

The lore documents in Level 2, when assembled, tell the following story:

1. **Line 13 was a public transit line** that Blackpoint secretly co-opted for transporting biological specimens between their research station (Level 3) and St. Maren's Hospital sub-basement (where the specimens originated).

2. **The specimens are not the Crawlers.** The specimens are something else — something recovered from deep beneath St. Maren's. The Crawlers are a byproduct. The specimens produce Crawlers the way a queen produces workers. Blackpoint was transporting the queens.

3. **A containment breach during transit** released one or more specimens into the Line 13 tunnel network. The tunnel collapses weren't structural failures — they were the specimens nesting, reshaping the tunnels to suit their biology.

4. **The missing workers** weren't killed by collapses. They were taken. The transformation chambers in the Nest suggest they became raw material.

5. **Blackpoint covered it up** by decommissioning Line 13 under the pretense of structural investigation. They sealed the tunnels. They reassigned the transit workers who knew too much. They thought containment held.

6. **It didn't hold.** The Crawlers have been multiplying in the dark for eighteen months. The Nest the player finds is one of many. The clicking the player hears echoing from deep below suggests a network of Nests extending far beyond Line 13.

7. **Dr. Elena Voss** (Level 3's key figure) was the director overseeing the specimen transport. Her revoked badge at Terminus suggests she either went rogue, was silenced, or is still inside the research station. The player now has a reason to go to Level 3.

This thread is only complete if the player collects all lore documents including the Nest items. A player who skips the Nest will have gaps — they'll know Blackpoint was involved and something was being transported, but they won't know about the queens or the transformation. The Nest lore recontextualizes the Crawlers from "scary monster" to "symptom of something much worse."
