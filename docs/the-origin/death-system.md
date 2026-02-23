# The Origin — Death & Lives System

## Overview

Players have **3 lives** per run, represented by 3 heart icons. Each death triggers a full-screen death animation where a heart shatters and fades. The first two deaths respawn the player. The third is permanent — the run is over.

This replaces instant run-reset-on-death. It gives players breathing room to learn while making each death feel heavier than the last. By the third heart, every encounter is do-or-die.

---

## The Three Hearts

### HUD Display

Three heart icons in the bottom-left of the screen. Subtle, not intrusive. They pulse faintly in sync with the Proximity Fear heartbeat audio when in Tier 2+.

```
Normal state:      ♥  ♥  ♥     (warm red, faint glow)
After 1st death:   ♡  ♥  ♥     (first heart is cracked outline, dim)
After 2nd death:   ♡  ♡  ♥     (two cracked, one remaining — pulses faster)
```

The remaining hearts don't just sit there. As you lose them:
- **3 hearts:** Hearts pulse slowly, calm
- **2 hearts:** Hearts pulse slightly faster, faint crack veins visible on the intact hearts
- **1 heart:** The final heart pulses rapidly, glows brighter, hairline cracks spreading across its surface — it looks fragile, like it could break at any moment

---

## Death Animations

### First Death — "You've Died"

**Duration:** 5 seconds

1. **Impact** (0.0s) — Screen cuts to black on the killing blow. Sharp audio sting — a low, resonant thud like a stopped heartbeat.

2. **The Hearts** (0.5s) — Black screen. Three hearts fade in at center screen, glowing warm red. Arranged in a row. They pulse once, together, in sync.

3. **The Break** (1.5s) — The leftmost heart cracks. Not instantly — a fracture line spreads across it over 0.5 seconds, accompanied by a quiet, brittle cracking sound (like thin ice). Then it shatters. The fragments drift outward slowly, each piece dimming and fading to ash as they float. A faint ember trail follows each shard.

4. **The Text** (3.0s) — Below the remaining two hearts, text fades in:

   ```
   You've died.
   ```

   Font: thin, serif. White. No drama in the typography — the restraint makes it worse. The period matters. It's a statement, not an exclamation.

5. **Fade** (4.0s) — Everything fades. The two remaining hearts linger longest, then dim. Screen goes fully black.

6. **Respawn** (5.0s) — Player respawns at the most recent checkpoint/safe zone within the level. They keep their inventory and key items. The objective state is preserved. Only their position and health reset (full 4 pips).

**Audio during animation:**
- The heartbeat sound that was playing from the Proximity Fear system... stops. Dead silence during the heart display.
- The crack/shatter of the heart is the only sound.
- A single, low tone holds during the text — like a flatline, but deeper.
- As the screen fades, a faint exhale. Then silence until respawn.

---

### Second Death — "You've Died"

**Duration:** 6 seconds (slightly longer — it's getting worse)

1. **Impact** (0.0s) — Same black screen cut, but the audio sting is deeper, more distorted. A faint ringing in the ears.

2. **The Hearts** (0.5s) — Three hearts fade in. The first is already cracked and dim — its outline flickers weakly. The second and third glow. They pulse, but the rhythm is uneven now. Irregular. Anxious.

3. **The Break** (1.8s) — The second heart cracks. Slower this time. The fracture line crawls across the surface, branching, splitting. The cracking sound is louder, wetter — not ice anymore, something organic. It shatters. The fragments fall downward instead of drifting — heavier, darker. They don't fade to embers. They fade to dust.

4. **The Remaining Heart** (2.5s) — The last heart is alone. It pulses once — hard, desperate — then dims slightly. The cracks that were merely hairlines before are now visible. It's barely holding together.

5. **The Text** (3.5s) — Below the lone heart:

   ```
   You've died.
   ```

   Same font. Same restraint. But the text is slightly dimmer than before. Like the message itself is fading.

6. **Fade** (5.0s) — The last heart lingers on screen. It doesn't fade smoothly — it flickers, like a candle in wind, before finally going dark.

7. **Respawn** (6.0s) — Same respawn rules. But this time, the respawn environment is subtly different:
   - The ambient lighting is slightly darker than before
   - The background audio has an additional low-frequency layer
   - The player character's breathing is audible immediately, even in Tier 0
   - These persist for the rest of the run. You can feel that you're on borrowed time.

**Audio during animation:**
- Silence again, but this time there's a faint ringing/tinnitus underneath
- The crack is more visceral
- During the text, a second flatline tone joins — slightly detuned from the first, creating a dissonant interval
- The last heart's flickering has a faint, rapid ticking sound — like a clock running out

---

### Third Death — "You've Died Forever"

**Duration:** 10 seconds (this one lingers)

1. **Impact** (0.0s) — Screen doesn't cut to black. Instead, the camera lingers on the death for 1 full second — the entity catching the player, the hazard killing them — before a slow fade to black. The player sees it happen. No mercy cut.

2. **The Heart** (1.5s) — Only one heart fades in. Alone. Already cracked, glowing faintly, trembling. The two empty outlines of the lost hearts are barely visible on either side — ghosts.

3. **The Final Beat** (2.5s) — The heart pulses once. A full, strong beat — the brightest it's been all game. For one moment, it looks whole.

4. **The Break** (3.5s) — Then it shatters. Not a crack that spreads — it detonates. Fragments scatter across the entire screen, each piece trailing ember-light. The sound isn't a crack. It's a low, resonant boom — the sound of something ending. The fragments don't fade to ash or dust. They fade to nothing. They cease to exist.

5. **The Silence** (5.0s) — Empty black screen. No hearts. No outlines. Nothing. 2 full seconds of absolute silence. This is the worst part. The player sits with it.

6. **The Text** (7.0s) — Text fades in. Slower than before. Each letter appears individually, left to right, over 1.5 seconds:

   ```
   You've died forever.
   ```

   Same font. But the word "forever" is slightly offset — lower and to the right, as if it was added by a different hand. It's not quite the same white. Slightly warmer. Almost flesh-toned.

7. **Hold** (8.5s) — The text holds on screen. No fade-out prompt. No "press to continue." Just the words and the black. For 1.5 seconds the player has no control. They sit with it.

8. **Fade Out** (10.0s) — Text fades. After a brief pause, the player is returned to the Hub (Safe Room). The level is failed. Inventory is lost. Objective progress is reset.

**Audio during animation:**
- The lingering death moment has the entity's actual sound design — footsteps, breathing, whatever — then it cuts to silence
- The final heartbeat is a deep, physical bass hit — felt in the chest, not just heard
- The shatter is enormous but immediately swallowed by silence — like an explosion underwater
- During the empty 2 seconds: nothing. Not ambient nothing. Nothing nothing. If the player is wearing headphones, this void is deafening.
- As the text appears: a single, sustained tone. Not a flatline. A chord. Something almost beautiful. Almost like an elegy. It fades as the text fades.

---

## Respawn Mechanics

### What Resets on Death (Hearts 1 & 2)

| Resets | Preserves |
|---|---|
| Player position (to checkpoint) | Inventory (all items kept) |
| Health (back to 4 pips) | Key items (keys, keycards, fuel) |
| Injury states cleared | Objective progress (generator stays powered, doors stay unlocked) |
| Entity position (relocates to patrol start) | Loot already collected (rooms stay looted) |
| Proximity Fear tier (back to 0) | Lore documents found |
| | Adaptive AI memory (entity still remembers your hiding habits) |

### What Resets on Final Death (Heart 3)

Everything. Full run reset:
- Return to Hub
- All inventory lost
- All objective progress reset
- Loot tables re-randomized
- Entity patrol routes re-randomized
- Scripted events eligible to fire again (but only first-playthrough events stay completed across runs)
- **Permanent unlocks preserved** (lore journal, level unlocks, perks, cosmetics)
- **Adaptive AI resets** (fresh memory — the entity "forgets" your habits)

### Checkpoint Locations

Players don't manually save. Checkpoints are invisible and trigger when entering key areas:

**Level 1:**
- Ambulance Bay (spawn)
- Ground Floor Corridor (after first entity encounter)
- Upper Floor Hallway
- Basement Corridor

**Level 2:**
- Hargrove Street Station (spawn)
- Moorfield Station (midpoint)
- Deep Tunnels entry

**Level 3:**
- Helipad (spawn)
- Lab Level entry
- Deep Level entry

**Level 4:**
- Ranger Station (spawn)
- Cabin Cluster
- The Ridge

**Level 5:**
- Sub-Basement Entry (spawn)
- Warren Entry
- Sanctuary Entry

---

## Multiplayer Deaths

In co-op, lives are **per-player, not shared.**

### Downed State (Replaces Instant Death for Hearts 1 & 2)

When a player loses all 4 health pips in co-op:
1. Player enters **downed state** — crawling, limited vision, can call out via proximity voice
2. Teammates have 30 seconds to reach and revive (5-second hold interaction)
3. If revived: player stands up at 1 health pip. **No heart lost.**
4. If NOT revived within 30 seconds: heart breaks. Death animation plays for that player only. Respawn at checkpoint.
5. Other players see a brief notification: `[PlayerName] has fallen.` / `[PlayerName] has been revived.` / `[PlayerName] has died. (2 lives remaining)`

### Final Death in Co-op

When a player loses their third heart:
- Full "You've died forever" animation plays for that player
- They enter **spectator mode** — can watch remaining players from fixed cameras (the CCTV cameras in each level)
- They CANNOT communicate with living players (no voice, no text). They're gone.
- If all players die: run fails for everyone, return to Hub
- If surviving players extract: the dead player still gets completion credit and XP (reduced by 30%)

### The Social Horror

When one player dies permanently, the remaining players:
- Hear the absence. The voice that was there is gone.
- See the notification. They know it's final.
- Are now short-handed. Objectives are harder. Entity doesn't scale down.
- Face a choice: push forward or play it safe?

The dead player watching via cameras is its own horror. Seeing your friends struggle without you. Wanting to warn them. Unable to.

---

## Visual Design Notes

### Heart Style

The hearts should not look cartoonish or game-y. They should look:
- **Organic** — like a real heart abstracted into a symbol. Slightly asymmetric. Surface texture like polished stone or dark glass.
- **Luminous** — glowing from within, like embers. The red is deep and warm, not bright.
- **Fragile** — even at full health, they should look like they could break. Hairline imperfections. Micro-cracks catching the light.
- **Connected** — faint threadlike connections between the three hearts, like veins or roots. When one breaks, the threads to it snap and recoil.

### Shatter Physics

Each heart breaks into 12-16 fragments. The fragments have:
- Unique, irregular shapes (not geometric — organic fracture patterns)
- Individual rotation and drift trajectories
- Ember/particle trail that fades over distance
- Death 1: fragments drift upward and outward (departing, gentle)
- Death 2: fragments fall downward (heavy, gravity, loss)
- Death 3: fragments scatter in all directions (explosive, violent, final)

### Typography

```
"You've died."        — Garamond or similar thin serif
                       — White, ~70% opacity
                       — Centered, lower third of screen
                       — Fade in over 0.5s, hold 1.5s, fade out 0.5s

"You've died forever." — Same font, same position
                       — "You've died " in same white
                       — "forever." slightly lower, slightly warmer tone
                       — Letter-by-letter reveal over 1.5s
                       — Hold 2s before any fade
```

---

## Integration with Proximity Fear System

The death animation respects the Proximity Fear System:
- All proximity fear effects (desaturation, vignette, heartbeat audio) freeze at their current level during the death animation, then cut to clean black
- On respawn after deaths 1 & 2, the Proximity Fear system starts at Tier 0 regardless of entity proximity — brief grace period of 5 seconds before the system re-engages
- After death 2, the baseline ambient state shifts: even Tier 0 has 5% desaturation and barely perceptible vignette for the rest of the run. You never feel fully safe again.

## Integration with Jumpscare System

- Jumpscare cooldown resets on death (fresh scare timer on respawn)
- Category C scares (shock/hallucination) are **disabled for 30 seconds after respawn** — don't scare a player who just died
- After death 2 (on final life), Category D anomalies (slow burn) become 2x more frequent — the world feels more wrong, like it knows you're almost done
