# WINDROSE Better Planting — Modding Research

## Status

This document captures **preliminary research** for Windrose modding. It is intended to guide prototyping in this repository, not to serve as official game documentation.

Use the labels below consistently:

- **Confirmed in-repo:** backed by this repository's current code or docs
- **Preliminary community research:** reported by the user or community sources, but still needs hands-on verification
- **Open question:** unknown and still blocking implementation details

---

## Confirmed in-repo

The following points are confirmed by the current repository direction:

- This project targets two user-facing modes:
  - **Option A:** snap-assisted single placement
  - **Option B:** configurable grid preview mode
- The existing scaffold is intentionally Lua-oriented.
- No verified Windrose runtime hook has been implemented in this repository yet.
- The first safe prototype target is:
  - **When a planting-compatible item is selected, compute and expose one snapped candidate position based on configurable spacing.**

---

## Preliminary community research

The following points are useful working assumptions, but they still need verification against a real Windrose install and current community tooling:

### Likely modding approaches

1. **UE4SS + Lua runtime scripting**
   - Likely useful for:
     - reading live game state
     - reacting to build/placement mode
     - detecting selected placeables
     - drawing or driving preview indicators
     - handling hotkeys or runtime toggles
   - This is the most likely path for Option A and the interactive parts of Option B.

2. **PAK-based overrides / asset or data replacement**
   - Likely useful for:
     - overriding data tables
     - replacing balance assets
     - adjusting static planting rules if those rules live in editable assets or data
   - This may help with spacing values or rule tuning, but it is unlikely to be enough on its own for an interactive snap/grid UX.

### Likely install paths

These install paths are **preliminary** and should be verified before release instructions are treated as final:

- Client / single-player:
  - `Windrose\R5\Content\Paks\~mods\`
- Dedicated server / multiplayer host:
  - `Windrose\R5\Builds\WindowsServer\R5\Content\Paks\~mods\`

These paths are currently treated as community-sourced guidance, not guaranteed official documentation.

---

## Why runtime scripting is probably required

Some planting behavior may eventually be adjustable through data or PAK edits, but this project's core UX almost certainly needs a runtime-capable layer.

### Option A — snap-assisted single placement

To support Option A cleanly, the mod likely needs to:

- detect that a planting-compatible item is selected
- read a live cursor or placement target position
- compute a snapped candidate in real time
- show feedback before placement
- optionally validate the snapped position before the player clicks

That workflow is interactive and strongly suggests runtime scripting rather than static asset replacement.

### Option B — configurable grid preview

Option B almost certainly needs runtime behavior because it depends on:

- hotkey-driven row/column/spacing changes
- dynamic preview rendering
- per-cell validity feedback
- selection-aware presets
- possibly client-local overlay state that should not be treated as authoritative game state

Static PAK overrides may still be part of the final packaging story, but the preview and placement-assist behavior itself probably needs UE4SS-style scripting or another runtime bridge.

---

## Main unknowns

These are the major unanswered technical questions for the prototype:

1. **Selection detection**
   - How do we detect the currently selected plantable item?
   - Is the build menu selection exposed directly, indirectly, or not at all?

2. **Placement-mode hook**
   - How do we know the player is actively in placement mode?
   - Is there a placement tick, build-menu event, or actor/component we can observe?

3. **Preview rendering**
   - Can Windrose or UE4SS render world-space preview indicators?
   - If yes, should the first prototype use decals, meshes, widgets, or debug draw calls?

4. **Placement validation**
   - Can we query buildability/plantability at an arbitrary world position?
   - Can we reproduce or reuse the game's own spacing checks?

5. **Client-side vs multiplayer-safe behavior**
   - Which parts are safe to keep purely client-side?
   - Which placement actions must defer to the game's normal validation for multiplayer safety?

6. **Packaging model**
   - Is the final mod a pure Lua/UE4SS package, a pure PAK mod, or a hybrid?

---

## Working conclusion for this repository

Until verified otherwise, this repository should treat the project as a **runtime-script-first prototype** with optional future support for PAK/data packaging.

That means the near-term goal is not "ship a finished hook," but rather:

- document assumptions clearly
- keep engine integration behind explicit adapter/stub modules
- prove the placement math and prototype flow without pretending the Windrose APIs are already known

