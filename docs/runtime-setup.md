# WINDROSE Better Planting — Runtime Setup Notes

## Purpose

This repository is currently in a **research + prototype** phase.

The Lua files under `/tmp/workspace/NichitaGabriel/WINDROSE-Better-Planting/src` are structured like a likely UE4SS-style runtime mod, but they do **not** claim to already have verified Windrose engine hooks.

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
- mock validity responses
- lifecycle tick dispatch

This is only for local verification of module flow and math.

---

## Verification checklist before claiming real runtime support

Do **not** mark Windrose integration as working until all of the following are verified against the actual game/runtime:

- [ ] Mod entry file is loaded by the chosen runtime
- [ ] Current plantable selection can be detected reliably
- [ ] Cursor or placement anchor world position is available
- [ ] A visible preview indicator can be rendered
- [ ] Placement validity can be queried or delegated to the game
- [ ] Multiplayer behavior is understood well enough for public release notes

