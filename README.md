# WINDROSE Better Planting

> **Status: Early Scaffold / WIP** — Windrose modding integration details are still under investigation. No specific engine hooks have been validated yet. This repository is implementation-ready structurally, but runtime behavior depends on research outcomes described below.

A Windrose game mod for **aesthetic planting assistance**, inspired by grid/snap planting helpers like those found in Don't Starve Together. The goal is to make planting crops and trees feel precise, aligned, and satisfying.

---

## What This Mod Does

**WINDROSE Better Planting** adds two optional planting modes on top of the standard Windrose build/placement flow:

### Option A — Snap-Assisted Single Placement
- When a seed or tree is selected, nearby snap points are highlighted.
- Clicking places the plant at the nearest valid aligned grid point.
- Supports row-by-row planting with a consistent spacing offset.
- Ideal for players who want clean rows without needing a full grid preview.

### Option B — Configurable Grid Preview Mode
- A hotkey activates a configurable N×M ghost grid over the terrain.
- Valid cells are shown in green, blocked or invalid cells in red.
- Grid size (rows × columns), spacing, and rotation are adjustable.
- Supports separate presets for crops vs. trees.
- Clicking confirms placement for visible valid cells.

Both modes are optional and independently configurable.

---

## Planned Features

- [ ] Snap-assisted single placement (Option A)
- [ ] Ghost grid preview with configurable rows/columns (Option B)
- [ ] Validity highlighting (green = valid, red = blocked)
- [ ] Spacing configuration per plant type (crops vs. trees)
- [ ] Rotation toggle
- [ ] Line mode and rectangle mode
- [ ] Save/load favorite spacing presets
- [ ] Hotkey support for grid adjustment during placement
- [ ] Terrain-aware validity checking
- [ ] Batch placement confirmation (place all valid cells at once)
- [ ] Multiplayer compatibility investigation

---

## Current Status / Research Status

This repository is an **early scaffold**. The project structure, design, and configuration schema are in place, but the following are still under investigation:

| Question | Status |
|---|---|
| Windrose mod runtime stack (pak vs. UE4SS/scripting) | 🔍 Researching |
| Hooking into the build/placement UI | 🔍 Researching |
| Reading the currently selected seed/plant type | 🔍 Researching |
| Spawning visual preview overlays | 🔍 Researching |
| Terrain validity and collision queries | 🔍 Researching |
| Multiplayer sync requirements | 🔍 Not started |

See [`docs/design.md`](docs/design.md) for a full list of open technical questions.

Progress will be updated here as research and prototyping advances.

---

## Repository Layout

```text
WINDROSE-Better-Planting/
├── README.md                   ← This file
├── LICENSE
├── docs/
│   └── design.md               ← Full design document
├── config/
│   └── default-config.json     ← Default mod configuration schema
└── src/
    ├── main.lua                ← Mod entry point / bootstrapper
    ├── core/
    │   ├── selection.lua       ← Detects currently selected plant/seed
    │   ├── placement.lua       ← Placement math (snap points, offsets)
    │   ├── grid.lua            ← Grid generation (N×M layout)
    │   ├── validation.lua      ← Per-cell validity checking
    │   ├── preview.lua         ← Ghost grid rendering
    │   └── input.lua           ← Input/hotkey handling
    └── ui/
        └── overlay.lua         ← HUD overlay and settings UI
```

---

## Getting Started (Early Development)

> There is no installable release yet. This is a scaffold only.

When the mod is ready for testing:

1. Identify the correct mod directory for your Windrose installation:
   ```
   Windrose\R5\Content\Paks\~mods\
   ```
2. Copy the packaged mod `.pak` file there, or follow UE4SS instructions if applicable.
3. Launch the game and look for the Better Planting indicators in the build menu.

Packaging instructions will be added once the runtime approach is confirmed.

---

## Contributing

Contributions are welcome, especially during this early research phase.

### How to contribute right now

- **Research:** If you have experience with Windrose modding, UE4SS, or Unreal Engine pak mods, open an issue or PR with findings. Any data on build-menu hooks, plant selection detection, or preview overlay support is extremely valuable.
- **Design feedback:** Open an issue to discuss planned features, scope, or UX ideas.
- **Code stubs:** The `src/` modules are placeholders. If you can implement a module based on confirmed Windrose APIs, PRs are welcome.
- **Testing:** Once early builds exist, playtest reports and screenshots are appreciated.

### Guidelines

- Do not invent Windrose APIs that have not been confirmed. Use `-- TODO` comments for unknowns.
- Keep commit messages descriptive.
- Open an issue before large changes to align on direction.
- Follow the existing file and naming structure under `src/`.

---

## License

[MIT](LICENSE) — Gabriel, 2026
