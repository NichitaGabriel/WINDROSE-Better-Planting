# WINDROSE Better Planting — Runtime Setup Notes

## Purpose

This repository is currently in a **research + prototype vertical slice** phase.

The Lua files under `<repo_root>/src` are structured as a UE4SS-style runtime mod, and the repo now includes a UE4SS-oriented bootstrap entry under `<repo_root>/ue4ss/Mods/WINDROSE-Better-Planting/Scripts/main.lua`.

This still does **not** claim that Windrose-specific engine hooks are verified.

---

## Expected runtime directions

### Direction A — UE4SS / Lua runtime scripting

This is the most likely direction for the first interactive prototype because it can potentially support:

- live selection polling or event hooks
- cursor/placement target tracking
- hotkey bindings
- preview rendering
- runtime logging

### Direction B — Unreal PAK packaging

This may still be needed for distribution or for data/asset overrides, but it should currently be treated as a secondary path until the interactive runtime behavior is proven.

---

## Preliminary mod install paths

These paths are included as **research notes only** and still need verification:

- Client:
  - `Windrose\R5\Content\Paks\~mods\`
- Dedicated server:
  - `Windrose\R5\Builds\WindowsServer\R5\Content\Paks\~mods\`

If the final mod uses PAKs, these are likely candidate install paths. If the final mod uses UE4SS, the exact layout may differ.

---

## Repository runtime structure

Current prototype-facing modules:

- `ue4ss/Mods/WINDROSE-Better-Planting/Scripts/main.lua`
  - UE4SS-oriented entrypoint that resolves module paths and loads the prototype
- `src/main.lua`
  - bootstraps the prototype flow
- `src/config.lua`
  - provides embedded defaults and config helpers
- `src/log.lua`
  - minimal debug logger
- `src/runtime/bridge.lua`
  - explicit adapter/stub layer for unknown engine hooks
- `src/core/selection.lua`
  - selection polling and change notifications
- `src/core/placement.lua`
  - pure placement math
- `src/core/grid.lua`
  - grid generation and anchor updates
- `src/core/preview.lua`
  - preview state holder for snap/grid output
- `src/core/validation.lua`
  - validation adapter with placeholder fallback
- `src/core/input.lua`
  - input binding registration and mode-toggle callbacks
- `src/ui/overlay.lua`
  - HUD/status state for prototype reporting

---

## Prototype-friendly local validation

Because Windrose and UE4SS are not part of this repository, the prototype uses a stub runtime bridge.

The bridge intentionally supports **mock state** so the Lua code can be sanity-checked without claiming a real game integration:

- mock selection
- mock cursor world position
- optimistic mock validity responses
- lifecycle tick dispatch
- debug toggle for mock mode
- manual anchor stepping for a single snapped candidate

This is only for local verification of module flow and math.

---

## Beginner-friendly manual test flow

The current milestone is intentionally narrow:

> **Load the prototype, generate one snapped planting candidate, and observe it through logs/debug state.**

### Expected staged layout

When copying the prototype into a UE4SS install, preserve this layout:

```text
<UE4SS root>/
└── Mods/
    └── WINDROSE-Better-Planting/
        ├── Scripts/
        │   └── main.lua
        ├── src/
        │   ├── main.lua
        │   ├── runtime/bridge.lua
        │   ├── core/...
        │   └── ui/overlay.lua
        └── config/
            └── default-config.json
```

### What happens on load

If the vertical slice loads, it should:

1. emit a startup signal:
   - `WINDROSE-Better-Planting vertical slice loaded`
   - `UE4SS bootstrap entry loaded`
2. enable mock prototype mode by default
3. force a planting-compatible mock selection (`debug_crop_seed`)
4. seed a manual anchor from config
5. compute one snapped candidate from that anchor and expose it through:
   - logs (`Prototype state [...]`)
   - preview state (`getPrototypeState().preview.snapPoint`)
   - overlay state (`getPrototypeState().overlay.snapCandidate`)

### Debug actions in this slice

The prototype now registers keybind-oriented descriptors for these actions:

- `toggle_debug`
- `mock_anchor_forward`
- `mock_anchor_backward`
- `mock_anchor_left`
- `mock_anchor_right`
- `reset_mock_anchor`

These descriptors are safe even before real input registration is verified. If a runtime cannot bind them yet, the loaded module still exposes `simulateDebugAction(action)` for local/manual smoke testing in a Lua-capable environment.

### Success criterion

Treat the milestone as successful when:

- the prototype emits its startup signal
- mock mode is clearly reported as active
- one snapped candidate is present in the prototype state
- moving or resetting the mock anchor changes the reported snapped candidate

Do **not** treat this milestone as proof of real in-game placement integration.

---

## Verification checklist before claiming real runtime support

Do **not** mark Windrose integration as working until all of the following are verified against the actual game/runtime:

- [ ] Mod entry file is loaded by the chosen runtime
- [ ] Current plantable selection can be detected reliably
- [ ] Cursor or placement anchor world position is available
- [ ] A visible preview indicator can be rendered
- [ ] Placement validity can be queried or delegated to the game
- [ ] Multiplayer behavior is understood well enough for public release notes
