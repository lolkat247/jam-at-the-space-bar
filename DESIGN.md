# Design

## Format

- 2D pixel art, 32×32 tile/sprite size

## Core Loop

1. **Forage** — enter an overworld scene and catch as many fruits as you can in ~30 seconds
2. **Brew** — return to the bar and combine fruits into a jar via the rhythm minigame
3. **Serve** — serve the jar to a customer and receive a rating based on the brew

### Failure Criteria
- Too many unsatisfied customers
- A low critic rating

## Scenes

Navigate between scenes with teleporters that are colored and lined up in the bar.

### Overworld
- One scene per fruit type (passed as props)
- Player must catch fruits via the foraging minigame — not picked up freely

### Bar
- Home base for brewing and serving
- Player combines collected fruits into jars
- Customers are seated here and rate the result

## Minigames

### Foraging (Overworld)
- Crypt of the NecroDancer-style: everything moves on the beat
- Player and fruits share a grid; intercept a fruit by landing on its tile on-beat
- ~30 second rounds — grab as much as you can
- Countdown: 1, 2, 3, go

### Brewing (Bar)
- Triggered when combining fruits into a jar at the bar
- Each fruit contributes MIDI tracks to the rhythm sequence
  - More complex/rare fruits = more tracks = harder rhythm
- Result quality affects customer rating

## Fruits

- Each fruit has **traits**
- Traits map to specific MIDI tracks in the brewing minigame
- Tooltips on fruits explain trait → track associations so players learn over time

## Customers

- **Regulars** — request specific jams; straightforward to satisfy
- **Critics** — harder to please; judge based on trait complexity and brew quality

## Additional Features

- Upgrade shop ?