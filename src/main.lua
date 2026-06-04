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
BetterPlanting._lastStateSignature = nil

local function vectorToString(worldPos)
    if type(worldPos) ~= "table" then
        return "nil"
    end

    return string.format("(%.2f, %.2f, %.2f)", worldPos.x or 0, worldPos.y or 0, worldPos.z or 0)
end

local function getPrototypeConfig()
    return (BetterPlanting._config and BetterPlanting._config.prototype) or {}
end

function BetterPlanting._logState(reason)
    local prototypeConfig = getPrototypeConfig()
    if not BetterPlanting._config or prototypeConfig.log_state_transitions == false then
        return
    end

    local snapWorldPos = BetterPlanting._currentSnap and BetterPlanting._currentSnap.worldPos or nil
    local mockState = RuntimeBridge.getMockState()
    local snapValid = BetterPlanting._currentSnap and BetterPlanting._currentSnap.valid
    local snapValidText = snapValid == nil and "nil" or tostring(snapValid)
    local signature = table.concat({
        tostring(reason),
        tostring(BetterPlanting._active),
        tostring(BetterPlanting._placementMode),
        tostring(BetterPlanting._currentSelection),
        snapValidText,
        vectorToString(snapWorldPos),
        tostring(mockState.enabled),
        vectorToString(mockState.cursor),
    }, "|")

    if signature == BetterPlanting._lastStateSignature then
        return
    end

    BetterPlanting._lastStateSignature = signature
    Log.info(string.format(
        "Prototype state [%s] active=%s mode=%s selection=%s mock=%s anchor=%s snap=%s valid=%s",
        tostring(reason),
        tostring(BetterPlanting._active),
        tostring(BetterPlanting._placementMode),
        tostring(BetterPlanting._currentSelection),
        tostring(mockState.enabled),
        vectorToString(mockState.cursor),
        vectorToString(snapWorldPos),
        snapValidText
    ))
end

function BetterPlanting.init()
   BetterPlanting._config = Config.load("config/default-config.json")
   Log.init(BetterPlanting._config.debug, "BetterPlanting")
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
   Input.onDebugToggle(BetterPlanting._onDebugToggle)
   Input.onAnchorNudge(BetterPlanting._onAnchorNudge)
   Input.onAnchorReset(BetterPlanting._onAnchorReset)

   RuntimeBridge.registerLifecycleHooks({
       onTick = BetterPlanting.tick,
       onShutdown = BetterPlanting.shutdown,
   })

   local prototypeConfig = getPrototypeConfig()
   Log.info((prototypeConfig.startup_signal or "WINDROSE-Better-Planting vertical slice loaded") .. " (" .. (prototypeConfig.runtime_shape or "prototype") .. ").")
   Log.info("Initialised prototype bootstrap.")
   Log.info("Prototype objective: " .. tostring(prototypeConfig.objective))
   Selection.refresh()
   BetterPlanting._logState("startup")
end

function BetterPlanting._onSelectionChange(plantType)
   BetterPlanting._currentSelection = plantType
   Log.info("Selection changed to: " .. tostring(plantType))

   if not Selection.isPlantable(plantType) then
       BetterPlanting._active = false
       BetterPlanting._currentGrid = nil
       BetterPlanting._currentSnap = nil
       Preview.hide()
       Preview.hideSnapPoint()
       Overlay.hide()
       BetterPlanting._logState("selection-cleared")
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
    BetterPlanting._logState("mode-toggle")
end

function BetterPlanting._onSpacingAdjust(delta)
    if not BetterPlanting._currentPreset then
        return
    end

    local minSpacing = BetterPlanting._config.prototype.min_spacing or 0.5
    local spacing = math.max(minSpacing, (BetterPlanting._currentPreset.spacing or 2.0) + delta)
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
    BetterPlanting._logState("spacing-adjust")
end

function BetterPlanting._onRotate(delta)
    if not BetterPlanting._currentGrid then
        return
    end

    BetterPlanting._currentGrid = Grid.rotate(BetterPlanting._currentGrid, delta or 0)
    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
    BetterPlanting._logState("rotate")
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
    BetterPlanting._logState("cancel")
end

function BetterPlanting._onDebugToggle()
    local mockEnabled = RuntimeBridge.toggleMockMode()
    Selection.refresh()

    if mockEnabled then
        BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
        BetterPlanting._logState("mock-enabled")
        return
    end

    BetterPlanting._active = false
    BetterPlanting._currentSnap = nil
    Preview.hide()
    Preview.hideSnapPoint()
    Overlay.hide()
    BetterPlanting._logState("mock-disabled")
end

function BetterPlanting._onAnchorNudge(delta)
    local anchorPos = RuntimeBridge.nudgeMockCursor(delta or {x = 0, y = 0, z = 0})
    if not anchorPos then
        return
    end

    BetterPlanting._refreshPrototypeState(anchorPos)
    BetterPlanting._logState("anchor-nudge")
end

function BetterPlanting._onAnchorReset()
    local anchorPos = RuntimeBridge.resetMockCursor()
    BetterPlanting._refreshPrototypeState(anchorPos)
    BetterPlanting._logState("anchor-reset")
end

function BetterPlanting._refreshPrototypeState(anchorPos)
    if not BetterPlanting._active or not BetterPlanting._currentPreset then
       return
    end

    if not anchorPos then
       local prototypeConfig = getPrototypeConfig()
       BetterPlanting._currentSnap = nil
       Preview.hideSnapPoint()
       Preview.hide()
       Overlay.updatePrototype({
           objective = prototypeConfig.objective,
           mode = BetterPlanting._placementMode,
           selection = BetterPlanting._currentSelection,
           status = "Waiting for runtime cursor/placement anchor hook",
           runtimeShape = prototypeConfig.runtime_shape,
           mockState = RuntimeBridge.getMockState(),
           capabilities = RuntimeBridge.describeCapabilities(),
       })
       BetterPlanting._logState("waiting-anchor")
       return
    end

    local snapPoint = Placement.snapToGrid(anchorPos, BetterPlanting._currentPreset.spacing)
    BetterPlanting._currentSnap = Validation.getCandidate(snapPoint, BetterPlanting._currentSelection)

    if BetterPlanting._currentSnap and Config.modeAllows(BetterPlanting._config, BetterPlanting._placementMode, "snap") then
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
    local prototypeConfig = getPrototypeConfig()
    Overlay.updatePrototype({
        objective = prototypeConfig.objective,
        mode = BetterPlanting._placementMode,
        selection = BetterPlanting._currentSelection,
        status = RuntimeBridge.isMockModeEnabled() and "Mock anchor active for single snap candidate." or "Runtime anchor active for single snap candidate.",
        snapCandidate = BetterPlanting._currentSnap,
        gridSummary = BetterPlanting._currentGrid and Validation.summarise(BetterPlanting._currentGrid.cells) or nil,
        runtimeShape = prototypeConfig.runtime_shape,
        mockState = RuntimeBridge.getMockState(),
        capabilities = RuntimeBridge.describeCapabilities(),
    })
    BetterPlanting._logState("candidate-updated")
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
        mock = RuntimeBridge.getMockState(),
    }
end

function BetterPlanting.simulateDebugAction(action)
    return Input.simulateAction(action)
end

function BetterPlanting.setMockSelection(selection)
    RuntimeBridge.setMockSelection(selection)
    Selection.refresh()
    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

function BetterPlanting.setMockAnchor(worldPos)
    RuntimeBridge.setMockCursorWorldPosition(worldPos)
    BetterPlanting._refreshPrototypeState(RuntimeBridge.getCursorWorldPosition())
end

-- Intentional for the prototype phase: loading the module immediately boots
-- the stubbed runtime flow so it can be exercised by a UE4SS-style loader or
-- local mock validation without extra wiring.
BetterPlanting.init()

return BetterPlanting
