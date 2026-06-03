-- WINDROSE Better Planting
-- src/main.lua
--
-- Mod entry point and bootstrapper.
-- Loads configuration, initializes all core modules, and registers
-- with the Windrose game lifecycle hooks.
--
-- TODO: Replace all engine hook calls once the Windrose modding runtime
--       stack has been confirmed (pak / UE4SS / other scripting layer).

local Config    = require("config")
local Selection = require("core.selection")
local Placement = require("core.placement")
local Grid      = require("core.grid")
local Validation = require("core.validation")
local Preview   = require("core.preview")
local Input     = require("core.input")
local Overlay   = require("ui.overlay")

-- ---------------------------------------------------------------------------
-- Module state
-- ---------------------------------------------------------------------------

local BetterPlanting = {}
BetterPlanting._active     = false
BetterPlanting._currentGrid = nil
BetterPlanting._config     = nil

-- ---------------------------------------------------------------------------
-- Initialisation
-- ---------------------------------------------------------------------------

function BetterPlanting.init()
    -- Load and validate configuration from default-config.json.
    -- TODO: Determine the correct config file path for the Windrose mod runtime.
    BetterPlanting._config = Config.load("config/default-config.json")

    if not BetterPlanting._config.enabled then
        print("[BetterPlanting] Mod disabled in config. Skipping init.")
        return
    end

    -- Initialise core modules.
    Selection.init(BetterPlanting._config)
    Placement.init(BetterPlanting._config)
    Grid.init(BetterPlanting._config)
    Validation.init(BetterPlanting._config)
    Preview.init(BetterPlanting._config)
    Input.init(BetterPlanting._config)
    Overlay.init(BetterPlanting._config)

    -- Register callbacks.
    Selection.onSelectionChange(BetterPlanting._onSelectionChange)
    Input.onGridResize(BetterPlanting._onGridResize)
    Input.onConfirm(BetterPlanting._onConfirm)

    -- TODO: Register mod with game lifecycle (load / unload hooks).
    -- e.g. Game.onUnload(BetterPlanting.shutdown)

    print("[BetterPlanting] Initialised. Mode: " .. tostring(BetterPlanting._config.mode))
end

-- ---------------------------------------------------------------------------
-- Lifecycle callbacks
-- ---------------------------------------------------------------------------

--- Called when the player selects or deselects a plantable item in the
--- build menu.
---
--- @param plantType string|nil  Name of the selected plant, or nil if
---                              nothing plantable is selected.
function BetterPlanting._onSelectionChange(plantType)
    if plantType == nil then
        -- Nothing selected — clear preview and overlay.
        Preview.hide()
        Overlay.hide()
        BetterPlanting._active = false
        return
    end

    BetterPlanting._active = true

    -- Apply the appropriate preset for this plant type.
    local preset = Config.getPresetForPlant(BetterPlanting._config, plantType)
    BetterPlanting._currentGrid = Grid.generate(preset)

    -- Validate and render.
    Validation.checkAll(BetterPlanting._currentGrid.cells, plantType)
    Preview.show(BetterPlanting._currentGrid.cells)
    Overlay.show()
    Overlay.update(
        BetterPlanting._currentGrid.rows,
        BetterPlanting._currentGrid.cols,
        preset.spacing
    )
end

--- Called when the player uses hotkeys to resize the grid.
---
--- @param delta table  {rows = int, cols = int} — signed change values.
function BetterPlanting._onGridResize(delta)
    if not BetterPlanting._active or not BetterPlanting._currentGrid then
        return
    end

    local cfg = BetterPlanting._config.grid
    local newRows = math.max(1, BetterPlanting._currentGrid.rows + (delta.rows or 0))
    local newCols = math.max(1, BetterPlanting._currentGrid.cols + (delta.cols or 0))

    BetterPlanting._currentGrid = Grid.resize(BetterPlanting._currentGrid, newRows, newCols)

    -- Re-validate and redraw.
    local plantType = Selection.getSelected()
    Validation.checkAll(BetterPlanting._currentGrid.cells, plantType)
    Preview.update(BetterPlanting._currentGrid.cells)
    Overlay.update(newRows, newCols, cfg.spacing)
end

--- Called when the player confirms placement (mouse click / hotkey).
function BetterPlanting._onConfirm()
    if not BetterPlanting._active or not BetterPlanting._currentGrid then
        return
    end

    -- TODO: Place plants at all valid cells using the Windrose placement API.
    -- e.g. for _, cell in ipairs(BetterPlanting._currentGrid.cells) do
    --     if cell.valid then
    --         Game.placeObject(Selection.getSelected(), cell.worldPos)
    --     end
    -- end

    print("[BetterPlanting] Placement confirmed. (TODO: call engine API)")
end

-- ---------------------------------------------------------------------------
-- Shutdown
-- ---------------------------------------------------------------------------

function BetterPlanting.shutdown()
    Preview.hide()
    Overlay.hide()
    Input.unregister()
    print("[BetterPlanting] Shutdown complete.")
end

-- ---------------------------------------------------------------------------
-- Entry point
-- ---------------------------------------------------------------------------

BetterPlanting.init()

return BetterPlanting
