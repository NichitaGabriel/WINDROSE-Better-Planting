# WINDROSE Better Planting

> **Status: Research + UE4SS-Oriented Prototype Vertical Slice** — Windrose modding integration details are still under investigation. No specific Windrose engine hooks have been validated yet. This repository now includes an honest UE4SS-style bootstrap, a mock/manual fallback path, and a runnable single-snap prototype flow.

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

This repository is in a **research + prototype vertical slice** phase.

The project structure is in place, the likely modding approaches are documented, and the prototype code now proves this first concrete objective:

> **When a planting-compatible item is selected, compute and expose one snapped candidate position based on configurable spacing.**

What this PR now enables:

- a UE4SS-oriented bootstrap entry at `ue4ss/Mods/WINDROSE-Better-Planting/Scripts/main.lua`
- a startup/debug signal in logs when the prototype loads
- a mock/manual anchor fallback so the snap flow can run before real Windrose hooks are known
- one snapped candidate stored in prototype state and surfaced through logs, preview state, and overlay state
- placeholder keybind descriptors for toggling mock mode and nudging the manual anchor

The following are still under investigation:

| Question | Status |
|---|---|
| Windrose mod runtime stack (pak vs. UE4SS/scripting) | 🔍 Researching |
| Hooking into the build/placement UI | 🔍 Researching |
| Reading the currently selected seed/plant type | 🔍 Researching |
| Spawning visual preview overlays | 🔍 Researching |
| Terrain validity and collision queries | 🔍 Researching |
| Multiplayer sync requirements | 🔍 Not started |

See:

- [`docs/design.md`](docs/design.md)
- [`docs/modding-research.md`](docs/modding-research.md)
- [`docs/runtime-setup.md`](docs/runtime-setup.md)
- [`docs/prototype-plan.md`](docs/prototype-plan.md)

Progress will be updated here as research and prototyping advances.

---

## Repository Layout

```text
WINDROSE-Better-Planting/
├── README.md                   ← This file
├── LICENSE
├── docs/
│   ├── design.md               ← Full design document
│   ├── modding-research.md     ← Confirmed facts vs assumptions/open questions
│   ├── runtime-setup.md        ← Runtime notes and verification checklist
│   └── prototype-plan.md       ← Concrete prototype objective and staged plan
├── config/
│   └── default-config.json     ← Default mod configuration schema
└── src/
    ├── main.lua                ← Research-phase prototype bootstrapper
    ├── config.lua              ← Embedded config defaults + helpers
    ├── log.lua                 ← Minimal prototype logger
    ├── core/
    │   ├── selection.lua       ← Detects currently selected plant/seed
    │   ├── placement.lua       ← Placement math (snap points, offsets)
    │   ├── grid.lua            ← Grid generation (N×M layout)
    │   ├── validation.lua      ← Per-cell validity checking
    │   ├── preview.lua         ← Ghost grid rendering
    │   └── input.lua           ← Input/hotkey handling
    ├── runtime/
    │   └── bridge.lua          ← Stub adapter for future engine hooks
    └── ui/
        └── overlay.lua         ← HUD overlay and settings UI
```

---

## Getting Started (Early Development)

> This is still a prototype, not a verified shipping mod. The current slice is meant to prove loading, debug observability, and one snapped planting candidate without claiming real Windrose placement hooks.

### What is real vs mocked right now

- **Real in this repo:** bootstrap flow, pure snap math, prototype state updates, logging, preview/overlay state, and manual mock anchor stepping
- **Still mocked/unverified:** real Windrose selection detection, real cursor/placement anchor hooks, real preview rendering, real validity queries, and real input registration inside the game runtime

### Beginner manual test goal

Success for this milestone is:

> **The prototype loads and emits a startup signal, and a snapped candidate position can be generated and observed through logs/debug state.**

### UE4SS-oriented local layout

The repo now includes a likely UE4SS entrypoint here:

```text
ue4ss/Mods/WINDROSE-Better-Planting/Scripts/main.lua
```

For a manual prototype test, stage the mod so that the final runtime layout looks like this:

```text
<UE4SS root>/
└── Mods/
    └── WINDROSE-Better-Planting/
        ├── Scripts/
        │   └── main.lua
        ├── src/
        │   └── ...
        └── config/
            └── default-config.json
```

The repository already contains those source folders; the important part is preserving that relative layout when you copy files into a UE4SS install.

### What to look for during the test

1. Start Windrose with UE4SS installed.
2. Watch the UE4SS/Lua log output for:
   - `WINDROSE-Better-Planting vertical slice loaded`
   - `UE4SS bootstrap entry loaded`
   - a `Prototype state [...]` log line that includes a mock anchor and snap position
3. If mock mode is active, the prototype should already expose one snap candidate from the configured mock anchor.
4. If your runtime later supports keybind registration, the placeholder debug actions are intended to:
   - toggle mock mode
   - nudge the mock anchor forward/back/left/right
   - reset the mock anchor

These paths and packaging steps still need verification. See [`docs/runtime-setup.md`](docs/runtime-setup.md) for the current checklist and the exact mock-mode behavior.

---

## Contributing

Contributions are welcome, especially during this early research phase.

### How to contribute right now

- **Research:** If you have experience with Windrose modding, UE4SS, or Unreal Engine pak mods, open an issue or PR with findings. Any data on build-menu hooks, plant selection detection, or preview overlay support is extremely valuable.
- **Design feedback:** Open an issue to discuss planned features, scope, or UX ideas.
- **Code stubs:** The `src/` modules are prototype-facing placeholders. If you can replace a stub with confirmed Windrose or UE4SS integration, PRs are welcome.
- **Testing:** Once early builds exist, playtest reports and screenshots are appreciated.

### Guidelines

- Do not invent Windrose APIs that have not been confirmed. Use `-- TODO` comments for unknowns.
- Keep research notes explicit about what is confirmed versus assumed.
- Keep commit messages descriptive.
- Open an issue before large changes to align on direction.
- Follow the existing file and naming structure under `src/`.

---

## License

[MIT](LICENSE) — Gabriel, 2026
