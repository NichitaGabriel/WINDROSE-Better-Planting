-- WINDROSE Better Planting
-- src/main.lua
--
-- Prototype bootstrapper.
-- This file wires together the current research-phase modules without
-- pretending that Windrose runtime hooks have already been verified.

local Config = require("config")
local Log = require("log")
local RuntimeBridge = require("runtime.bridge")
local Selection = require("core.selection")
local Placement = require("core.placement")
local Grid = require("core.grid")
local Validation = require("core.validation")
local Preview = require("core.preview")
local Input = require("core.input")
local Overlay = require("ui.overlay")

local BetterPlanting = {}
BetterPlanting._active = false
BetterPlanting._currentGrid = nil
BetterPlanting._currentSnap = nil
BetterPlanting._currentPreset = nil
BetterPlanting._config = nil
BetterPlanting._placementMode = "snap"

function BetterPlanting.init()
   BetterPlanting._config = Config.load("config/default-config.json")
   Log.init(BetterPlanting._config.debug)
   RuntimeBridge.init(BetterPlanting._config, Log)
   BetterPlanting._placementMode = Config.getInitialMode(BetterPlanting._config)

   if BetterPlanting._config.enabled == false then
       Log.warn("Mod disabled in config. Skipping init.")
       return
   end

   Selection.init(BetterPlanting._config, RuntimeBridge, Log)
   Placement.init(BetterPlanting._config)
   Grid.init(BetterPlanting._config)
   Validation.init(BetterPlanting._config, RuntimeBridge, Log)
   Preview.init(BetterPlanting._config, RuntimeBridge, Log)
   Input.init(BetterPlanting._config, RuntimeBridge, Log)
   Overlay.init(BetterPlanting._config, Log)

   Selection.onSelectionChange(BetterPlanting._onSelectionChange)
   Input.onGridResize(BetterPlanting._onGridResize)
   Input.onModeToggle(BetterPlanting._onModeToggle)
   Input.onSpacingAdjust(BetterPlanting._onSpacingAdjust)
   Input.onRotate(BetterPlanting._onRotate)
   Input.onConfirm(BetterPlanting._onConfirm)
   Input.onCancel(BetterPlanting._onCancel)

   RuntimeBridge.registerLifecycleHooks({
       onTick = BetterPlanting.tick,
       onShutdown = BetterPlanting.shutdown,
   })

   Log.info("Initialised prototype bootstrap.")
   Log.info("Prototype objective: " .. BetterPlanting._config.prototype.objective)
end

function BetterPlanting._onSelectionChange(plantType)
   BetterPlanting._currentSelection = plantType

   if not Selection.isPlantable(plantType) then
       BetterPlanting._active = false
       BetterPlanting._currentGrid = nil
       BetterPlanting._currentSnap = nil
       Preview.hide()
       Preview.hideSnapPoint()
       Overlay.hide()
       return
   end

   BetterPlanting._active = true
   BetterPlanting._currentPreset = Config.getPresetForPlant(BetterPlanting._config, plantType)
   BetterPlanting._currentGrid = Grid.generate(BetterPlanting._currentPreset)
   Overlay.show()
   BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

function BetterPlanting._onGridResize(delta)
   if not BetterPlanting._active or not BetterPlanting._currentGrid then
       return
    end

    local newRows = math.max(1, BetterPlanting._currentGrid.rows + (delta.rows or 0))
    local newCols = math.max(1, BetterPlanting._currentGrid.cols + (delta.cols or 0))
    BetterPlanting._currentGrid = Grid.resize(BetterPlanting._currentGrid, newRows, newCols)
    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

function BetterPlanting._onModeToggle()
    BetterPlanting._placementMode = Config.cycleMode(BetterPlanting._config, BetterPlanting._placementMode)
    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

function BetterPlanting._onSpacingAdjust(delta)
    if not BetterPlanting._currentPreset then
        return
    end

    local spacing = math.max(0.5, (BetterPlanting._currentPreset.spacing or 2.0) + delta)
    BetterPlanting._currentPreset.spacing = spacing

    if BetterPlanting._currentGrid then
        BetterPlanting._currentGrid.spacing = spacing
        BetterPlanting._currentGrid = Grid.resize(
            BetterPlanting._currentGrid,
            BetterPlanting._currentGrid.rows,
            BetterPlanting._currentGrid.cols
        )
    end

    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

function BetterPlanting._onRotate(delta)
    if not BetterPlanting._currentGrid then
        return
    end

    BetterPlanting._currentGrid = Grid.rotate(BetterPlanting._currentGrid, delta or 0)
    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

function BetterPlanting._onConfirm()
    if not BetterPlanting._active then
        return
    end

    Log.info("Placement confirm requested. TODO: route through verified Windrose placement API.")
end

function BetterPlanting._onCancel()
    Preview.hide()
    Preview.hideSnapPoint()
    Overlay.hide()
end

function BetterPlanting._refreshPrototypeState(anchorPos)
    if not BetterPlanting._active or not BetterPlanting._currentPreset then
        return
    end

    if not anchorPos then
        Overlay.updatePrototype({
            objective = BetterPlanting._config.prototype.objective,
            mode = BetterPlanting._placementMode,
            selection = BetterPlanting._currentSelection,
            status = "Waiting for runtime cursor/placement anchor hook",
        })
        return
    end

    local snapPoint = Placement.snapToGrid(anchorPos, BetterPlanting._currentPreset.spacing)
    BetterPlanting._currentSnap = Validation.getCandidate(snapPoint, BetterPlanting._currentSelection)

    if Config.modeAllows(BetterPlanting._config, BetterPlanting._placementMode, "snap") then
        Preview.showSnapPoint(BetterPlanting._currentSnap.worldPos)
    else
        Preview.hideSnapPoint()
    end

    if BetterPlanting._currentGrid then
        BetterPlanting._currentGrid.spacing = BetterPlanting._currentPreset.spacing
        BetterPlanting._currentGrid = Grid.setAnchor(BetterPlanting._currentGrid, snapPoint)
        Validation.checkAll(BetterPlanting._currentGrid.cells, BetterPlanting._currentSelection)

        if Config.modeAllows(BetterPlanting._config, BetterPlanting._placementMode, "grid") then
            Preview.showGrid(BetterPlanting._currentGrid.cells)
        else
            Preview.hide()
        end
    end

    Overlay.update(BetterPlanting._currentGrid.rows, BetterPlanting._currentGrid.cols, BetterPlanting._currentPreset.spacing)
    Overlay.updatePrototype({
        objective = BetterPlanting._config.prototype.objective,
        mode = BetterPlanting._placementMode,
        selection = BetterPlanting._currentSelection,
        snapCandidate = BetterPlanting._currentSnap,
        gridSummary = BetterPlanting._currentGrid and Validation.summarise(BetterPlanting._currentGrid.cells) or nil,
    })
end

function BetterPlanting.tick()
    Selection.refresh()

    if not BetterPlanting._active then
        return
    end

    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

function BetterPlanting.shutdown()
    Preview.hide()
    Preview.hideSnapPoint()
    Overlay.hide()
    Input.unregister()
    Log.info("Shutdown complete.")
end

function BetterPlanting.getPrototypeState()
    return {
        active = BetterPlanting._active,
        selection = BetterPlanting._currentSelection,
        mode = BetterPlanting._placementMode,
        snapCandidate = BetterPlanting._currentSnap,
        grid = BetterPlanting._currentGrid,
        preview = Preview.getState(),
        overlay = Overlay.getState(),
        capabilities = RuntimeBridge.describeCapabilities(),
    }
end

BetterPlanting.init()

return BetterPlanting
