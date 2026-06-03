# WINDROSE Better Planting — Design Document

**Version:** 0.1 (scaffold)
**Status:** Draft — open questions unresolved, no engine hooks validated

---

## 1. Product Goal

**WINDROSE Better Planting** is a quality-of-life mod for the game *Windrose* that makes aesthetic, aligned planting straightforward.

The core goal is: **a player who wants a perfectly aligned orchard or crop grid should be able to achieve it without manual measurement or trial-and-error.**

This mod achieves that through two complementary modes:
- **Option A:** snap-assisted single placement — each click snaps to an aligned grid point.
- **Option B:** configurable ghost grid preview — a visual N×M grid overlay with per-cell validity coloring.

---

## 2. Non-Goals

The following are explicitly **out of scope** for this mod:

- Changing crop yield, growth speed, or any gameplay balance values.
- Bypassing Windrose's gameplay-intended spacing rules (though spacing values may be configurable).
- Automatic crop management or harvesting automation.
- Any form of cheat or exploit assistance.
- Cross-game compatibility (Windrose only).
- Full multiplayer synchronization of preview state (a future concern, not MVP).

---

## 3. MVP Scope

The minimum viable product (v0 prototype) is defined as:

1. The mod loads without crashing on game launch.
2. When a seed or tree is selected in the build menu, the mod detects the selection.
3. Option A: a snap point indicator appears near the cursor at aligned intervals.
4. Option B: pressing a configurable hotkey shows an N×M ghost grid on the terrain.
5. Valid cells are colored green; invalid cells are colored red.
6. The player can adjust grid size and spacing with hotkeys.
7. Clicking places a plant at the snap point (Option A) or confirms grid placement (Option B).
8. All behavior is toggleable and configurable via `config/default-config.json`.

---

## 4. User Stories

### Core planting experience

- **As a player**, I want to plant crops in perfect rows so that my farm looks clean and intentional.
- **As a player**, I want to plant trees in a symmetric orchard grid so that they are spaced evenly.
- **As a player**, I want to see which planting positions are valid before committing so that I don't waste seeds.

### Configuration

- **As a player**, I want to configure the grid spacing separately for crops and trees so that each plant type looks right.
- **As a player**, I want to save a favorite grid preset so that I don't have to reconfigure each session.
- **As a player**, I want to toggle the mod on or off without restarting the game so that it doesn't interfere with casual play.

### Accessibility / UX

- **As a player**, I want to use hotkeys to adjust the grid while in the build menu so that my hands stay on the keyboard/controller.
- **As a player**, I want the grid overlay to be subtle and non-intrusive so that it doesn't obscure the terrain.

---

## 5. Proposed Architecture

The mod is structured as a set of loosely-coupled Lua modules. Each module has a single responsibility and communicates through well-defined interfaces.

> **Note:** The specific runtime APIs used within each module are not yet determined. All engine calls are marked with `-- TODO` until Windrose modding hooks are confirmed. See Section 7 (Open Technical Questions).

### 5.1 `src/core/selection.lua` — Selection Detection

**Responsibility:** Detect which seed, crop, or tree is currently selected in the build/placement menu.

**Key functions:**
- `Selection.getSelected()` → returns current plant type or `nil`
- `Selection.isPlantable()` → returns `true` if the selection is a plant/seed/tree
- `Selection.onSelectionChange(callback)` → registers a listener for selection changes

**Dependencies:** Windrose build-menu API (unknown — TODO)

---

### 5.2 `src/core/placement.lua` — Placement Math

**Responsibility:** Compute snap points, grid anchor positions, and placement offsets from a given world position and config.

**Key functions:**
- `Placement.snapToGrid(worldPos, spacing)` → snapped world position
- `Placement.getGridOrigin(anchorPos, rows, cols, spacing)` → top-left grid world position
- `Placement.getCellPosition(origin, row, col, spacing, rotation)` → individual cell world position

**Dependencies:** `config`, math only — no engine API required.

---

### 5.3 `src/core/grid.lua` — Grid Generation

**Responsibility:** Generate a list of cell positions for a given grid configuration.

**Key functions:**
- `Grid.generate(config)` → returns a list of `{row, col, worldPos, valid}` entries
- `Grid.resize(grid, rows, cols)` → returns a resized grid
- `Grid.rotate(grid, angleDeg)` → returns a rotated grid

**Dependencies:** `placement`, `validation`

---

### 5.4 `src/core/validation.lua` — Validation Rules

**Responsibility:** Determine whether a given world position is a valid planting location.

**Key functions:**
- `Validation.isValid(worldPos, plantType)` → returns `true`/`false`
- `Validation.checkAll(cellList, plantType)` → returns the list with `valid` field populated

**Dependencies:** Windrose terrain/collision API (unknown — TODO)

---

### 5.5 `src/core/preview.lua` — Preview Rendering

**Responsibility:** Render the ghost grid overlay and snap point indicators on the terrain.

**Key functions:**
- `Preview.show(cellList)` → renders cells with validity colors
- `Preview.hide()` → removes all preview visuals
- `Preview.update(cellList)` → updates existing preview in-place
- `Preview.showSnapPoint(worldPos)` → Option A indicator

**Dependencies:** Windrose rendering/overlay API (unknown — TODO)

---

### 5.6 `src/core/input.lua` — Input Handling

**Responsibility:** Listen for hotkeys and mouse events related to grid adjustment and placement confirmation.

**Key functions:**
- `Input.register()` → bind all configured hotkeys
- `Input.unregister()` → unbind all hotkeys
- `Input.onGridResize(callback)` → called when resize hotkeys are pressed
- `Input.onConfirm(callback)` → called when placement is confirmed

**Dependencies:** Windrose input/hotkey API (unknown — TODO)

---

### 5.7 `src/ui/overlay.lua` — HUD Overlay

**Responsibility:** Display non-diegetic UI elements such as the grid dimension readout, spacing label, and settings panel.

**Key functions:**
- `Overlay.show()` / `Overlay.hide()`
- `Overlay.update(rows, cols, spacing)` → refreshes the displayed values
- `Overlay.showSettings()` → opens the settings panel

**Dependencies:** Windrose UI/widget API (unknown — TODO)

---

### 5.8 `src/main.lua` — Entry Point

**Responsibility:** Bootstrap the mod. Load config, initialize all modules, register with the game lifecycle.

**Flow:**
1. Load and validate `config/default-config.json`.
2. Initialize `Input`, `Selection`, `Preview`, `Overlay`.
3. Register `Selection.onSelectionChange` → drive grid/snap state.
4. Register `Input` hotkeys → adjust grid, toggle modes.
5. On game unload: clean up all overlays and bindings.

---

## 6. Configuration Schema

See [`config/default-config.json`](../config/default-config.json) for the full schema with comments.

Top-level keys:
- `enabled` — master on/off switch
- `mode` — `"snap"` (Option A), `"grid"` (Option B), or `"both"`
- `snap` — snap-assist settings
- `grid` — grid preview settings
- `presets` — named crop/tree spacing presets
- `hotkeys` — key bindings
- `preview` — visual styling

---

## 7. Open Technical Questions

These are the unresolved unknowns that must be answered before implementation can proceed. None of these are blockers for the scaffold, but they are blockers for functional code.

| # | Question | Impact | Notes |
|---|---|---|---|
| 1 | What is the Windrose mod runtime stack? (pak only / UE4SS / custom scripting) | Critical | Determines the entire implementation approach |
| 2 | Can we hook into the build/placement menu to detect the selected plant type? | Critical | Required for Option A and B |
| 3 | Is there a Lua or scripting API exposed by Windrose/UE4SS? | Critical | Determines whether these Lua stubs are correct |
| 4 | Can we spawn custom visual meshes or decals on the terrain at runtime? | High | Required for Option B ghost grid |
| 5 | Can we query terrain collision or buildability at an arbitrary world position? | High | Required for validity coloring |
| 6 | Does the game expose a world-space cursor position during placement? | High | Required for snap point calculation |
| 7 | Are there existing Windrose mod examples that do runtime UI overlays? | High | One example (Building with Glass) mentions UE4SS — needs inspection |
| 8 | What are the multiplayer sync requirements for placement actions? | Medium | Deferred to v1 |
| 9 | Is CurseForge the recommended distribution channel? | Low | For publishing only |

---

## 8. Milestones

### v0 — Scaffold (current)
- [x] Repository structure created
- [x] Design document written
- [x] Configuration schema defined
- [x] Source module stubs created
- [ ] Windrose modding research completed (see Section 7)

### Prototype — First Running Build
- [ ] Mod loads without crash
- [ ] Build-menu hook confirmed
- [ ] Plant selection detected
- [ ] Snap point displayed at cursor (Option A, visual only)
- [ ] Basic grid rendered (Option B, visual only, no validity)

### v0.5 — Functional MVP
- [ ] Validity checking implemented
- [ ] Snap placement works (Option A)
- [ ] Grid placement confirmed (Option B)
- [ ] Hotkeys functional
- [ ] Config loading from file
- [ ] First public test build on CurseForge (alpha)

### v1.0 — Public Release
- [ ] Both options stable and configurable
- [ ] Crop vs. tree presets
- [ ] Hotkeys for grid resize and spacing
- [ ] Settings UI in-game
- [ ] Documentation complete
- [ ] Multiplayer compatibility investigated
- [ ] CurseForge release
