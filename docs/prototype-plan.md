# WINDROSE Better Planting — Prototype Plan

## First concrete objective

The first prototype objective for this repository is:

> **When a planting-compatible item is selected, compute and expose one snapped candidate position based on configurable spacing.**

This objective is deliberately narrow and useful:

- it proves the placement math path
- it exercises selection handling
- it creates a clear handoff point for future preview rendering
- it avoids pretending that final Windrose hooks are already known

---

## Prototype stages

### Stage 1 — Bootstrap and debug flow

- load config defaults
- initialize logging
- initialize the runtime bridge
- initialize selection, placement, grid, validation, preview, input, and overlay modules
- register lifecycle and input callbacks

### Stage 2 — Single snapped candidate

- react to selection changes
- obtain a cursor/anchor position from the runtime bridge
- compute a snapped candidate using configurable spacing
- expose that candidate through preview/overlay state
- keep the code path valid even when runtime hooks are still missing

### Stage 3 — Grid preview skeleton

- generate an anchored grid from the same snapped anchor
- validate cells through the validation adapter
- expose rows/cols/spacing/rotation state
- support mode toggles and grid adjustments

### Stage 4 — Real integration follow-up

- replace bridge stubs with verified Windrose or UE4SS hooks
- confirm rendering approach
- confirm placement validation path
- determine multiplayer-safe behavior

---

## Prototype module responsibilities

### `src/runtime/bridge.lua`

Owns all unknown engine-facing hooks.

This file should remain the only place where future Windrose runtime assumptions are wired in. If an API is not verified, it should stay as a stub or TODO here.

### `src/main.lua`

Owns prototype orchestration:

- boot
- selection-driven state updates
- tick-driven preview refresh
- mode switching
- prototype objective reporting

### `src/core/placement.lua`

Owns deterministic math only. This is the safest part of the prototype and should stay engine-agnostic.

---

## Known non-goals for this prototype pass

This PR does **not** claim any of the following:

- a working in-game Windrose hook
- real build-menu interception
- real overlay rendering
- real multiplayer-safe placement
- final packaging instructions

Those remain follow-up tasks after real runtime verification.

