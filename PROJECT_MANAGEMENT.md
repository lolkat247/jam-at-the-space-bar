# Project Management

## MVP

Single customer, 3 fruits (one type), no brew minigame, just foraging minigame. No critics.

### Stories

- A single customer enters the bar.
- A customer asks for a jam requiring of 3 of the same fruit
- A player can teleport to a fruit world
- A player can forage for fruits
- A player can simply craft a jam
- A player can give a jam to a customer
- A customer walks away when their order is fulfilled
- A customer rejects misc. jams
- A player can throw away a jam

## Priorities

### P0

- One fruit (Basketball fruit)
  - Godot Scene
  - Sprite
  - Traits (P1)
- One customer
  - Sprite
  - Dialoge
  - Textbox
- One jam
  - Sprite
  - Color as parameter
  - Name as parameter
- Tavern / Bar
  - Trash can
  - Bar area (for customers)
  - Teleporter area
  - Jam Making area
- Overworld
  - Tiles
  - Music
  - Movement
- HUD
  - Inventory
  - Current Order

### P1

- Title Screen (Done)
  - Background music
  - High score
- The Jammer

TODO: Add more

## Critical Path

Fruit & Overworld → Forage Minigame
Jam → Customer Order
Teleporter → Overworld → Forage Minigame

## Individual Tasks

Example:

```
[ ] Title
	- Description:
	- Assignee: 
```

### MVP Tasks

[x] Global beat clock autoload
- Desc: Autoload singleton that emits a beat signal driven by the background music BPM. Everything on-beat depends on this.
- Assignee: Ethan
- Status: Done

[x] Player — sprite + scene
- Desc: Basic player scene with placeholder or final sprite.
- Assignee: Jake
- Status: Done

[x] Player — grid movement (on beat for forage)
- Desc: Player moves one tile per beat using arrow keys and space bar. Listens to beat clock signal.
- Assignee: Jake (started), Ethan (completed)
- Status: Done

[ ] Player — grid movement collision check
- Desc: Add collision detection to grid movement so the player can't walk through walls/obstacles. Depends on tilemap collision layers being set up. Uses move_and_collide or raycast against the tilemap.
- Assignee: Noah
- Status: In Progress

[ ] Overworld — tilemap + tile assets
- Desc: Grid-based tilemap for the foraging scene. Needs walkable tiles and boundaries.
- Assignee: Noah
- Status: In Progress

[x] Overworld — background music
- Desc: Music track that plays in the overworld and drives the beat clock BPM. Placeholder song for now?
- Assignee: Jake
- Status: Done

---

[x] Basketball Fruit — sprite + scene
- Desc: Single fruit type. Scene with sprite. No traits yet (P1).
- Assignee: Noah
- Status: Done

[ ] Fruit — grid movement behavior
- Desc: Fruit moves one tile per beat in a pattern (random or fixed TBD). Listens to beat clock.
- Assignee: Ethan
- Status: Done - But no collision with foreground

[ ] Fruit — spawner
- Desc: Places fruits on random tiles when the overworld round starts.
- Assignee: Ethan
- Status: Done - But no collsion with foreground

[ ] Player — beat detection (catch fruit)
- Desc: When player lands on same tile as a fruit on-beat, fruit is caught and added to inventory.
- Assignee:
- Status: Not Started

[ ] Player — inventory
- Desc: Tracks how many of each fruit the player is holding.
- Assignee: Anthony
- Status: In Progress

---

[ ] Overworld — 30s countdown timer
- Desc: Timer starts on round start. When it expires, round ends.
- Assignee:
- Status: Not Started

[ ] Overworld — round start sequence
- Desc: "1, 2, 3, go" countdown display before round begins.
- Assignee:
- Status: Not Started

[ ] Overworld — round end
- Desc: On timer expiry, freeze player, tally inventory, transition back to bar.
- Assignee:
- Status: Not Started

[x] Teleporter — Bar → Overworld transition
- Desc: Interaction zone in the bar that triggers scene transition to the overworld.
- Assignee: Jake
- Status: Done

---

[ ] Game state manager
- Desc: Tracks whether the player is in the bar phase or overworld phase. Autoload or singleton.
- Assignee:
- Status: Not Started

[ ] Bar — layout + tilemap
- Desc: Tilemap for the bar scene with designated zones: customer area, teleporter, jam-making, trash.
- Assignee: Jake
- Status: In Progress (background sprite generated, tilemap not built)

[ ] Bar — jam-making area
- Desc: Interaction zone where player crafts a jam from inventory fruits.
- Assignee:
- Status: Not Started

[x] Bar — teleporter pad
- Desc: Visual indicator and interaction zone for teleporting to the overworld.
- Assignee: Jake
- Status: Done

[ ] Bar — trash can
- Desc: Interaction zone that discards a held jam.
- Assignee:
- Status: In Progress (sprite done, no object or functionality)

---

[ ] Jam — sprite (color as param)
- Desc: Jam scene with a sprite that accepts a color parameter to differentiate jam types visually.
- Assignee: Jake
- Status: In Progress (basketball jam sprite generated, scene not built)

[ ] Jam — name as param
- Desc: Jam scene accepts a name string displayed in UI and customer orders.
- Assignee:
- Status: Not Started

[ ] Jam — craft action
- Desc: Consumes 3 fruits from inventory and produces a jam. No rhythm minigame for MVP just button press.
- Assignee:
- Status: Not Started

---

[ ] Customer — sprite + scene
- Desc: Single customer NPC with sprite.
- Assignee:
- Status: Not Started

[x] Customer — order display
- Desc: Textbox that shows the customer's current jam request.
- Assignee: Anthony
- Status: Done

[ ] Customer — enter bar sequence
- Desc: Customer walks in and sits when the bar scene loads.
- Assignee:
- Status: Not Started

[ ] Customer — accept jam
- Desc: When given the correct jam, customer reacts positively and walks away.
- Assignee:
- Status: Not Started

[ ] Customer — reject jam
- Desc: When given the wrong jam, customer shows rejection dialogue. Jam is returned to player.
- Assignee:
- Status: Not Started

---

[x] HUD — inventory display
- Desc: CanvasLayer overlay showing current fruit counts.
- Assignee: Anthony
- Status: Done

[ ] HUD — current order display
- Desc: Shows the active customer's order on screen at all times while in the bar.
- Assignee:
- Status: Not Started

---

[ ] Customer — walk away animation
- Desc: Customer plays a walk-off animation before being removed from the scene.
- Assignee:
- Status: Not Started
