-- WINDROSE Better Planting
-- src/core/input.lua
--
-- Input Handling module.
-- Registers hotkeys for toggling the mod, adjusting grid dimensions,
-- changing spacing, rotating the grid, and confirming/cancelling placement.
--
-- TODO: All engine input registration calls are placeholders. The specific
--       API (UE4SS input hooks, Windrose keybind system, etc.) depends on
--       the confirmed modding runtime. Replace TODO blocks once confirmed.

local Input = {}
local DEFAULT_ROTATION_STEP = 45

Input._config = nil
Input._bridge = nil
Input._log = nil
Input._resizeCallbacks = {}
Input._modeCallbacks = {}
Input._spacingCallbacks = {}
Input._rotateCallbacks = {}
Input._confirmCallbacks = {}
Input._cancelCallbacks = {}
Input._registered = false

-- ---------------------------------------------------------------------------
-- Init / teardown
-- ---------------------------------------------------------------------------

--- Initialise and register all configured hotkeys.
--- @param config table  The loaded mod configuration.
--- @param bridge table  Runtime adapter.
--- @param log table     Logger.
function Input.init(config, bridge, log)
    Input._config = config
    Input._bridge = bridge
    Input._log = log
    Input.register()
end

--- Bind all hotkeys defined in config.hotkeys.
function Input.register()
    if Input._registered then return end
    local keys = Input._config.hotkeys

    if Input._bridge and Input._bridge.registerInputBindings then
        Input._bridge.registerInputBindings({
            {action = "toggle_mode", key = keys.toggle_mode},
            {action = "increase_rows", key = keys.increase_rows},
            {action = "decrease_rows", key = keys.decrease_rows},
            {action = "increase_cols", key = keys.increase_cols},
            {action = "decrease_cols", key = keys.decrease_cols},
            {action = "increase_spacing", key = keys.increase_spacing},
            {action = "decrease_spacing", key = keys.decrease_spacing},
            {action = "rotate_cw", key = keys.rotate_cw},
            {action = "rotate_ccw", key = keys.rotate_ccw},
            {action = "confirm_placement", key = keys.confirm_placement},
            {action = "cancel", key = keys.cancel},
        })
    end

    Input._registered = true
end

--- Unbind all hotkeys (e.g. on mod shutdown).
function Input.unregister()
    if not Input._registered then return end
    Input._registered = false
end

-- ---------------------------------------------------------------------------
-- Public callback registration
-- ---------------------------------------------------------------------------

--- Register a callback for grid resize events.
--- The callback receives a delta table: {rows = int, cols = int}.
---
--- @param callback function
function Input.onGridResize(callback)
    table.insert(Input._resizeCallbacks, callback)
end

function Input.onModeToggle(callback)
    table.insert(Input._modeCallbacks, callback)
end

function Input.onSpacingAdjust(callback)
    table.insert(Input._spacingCallbacks, callback)
end

function Input.onRotate(callback)
    table.insert(Input._rotateCallbacks, callback)
end

--- Register a callback for placement confirmation.
---
--- @param callback function
function Input.onConfirm(callback)
    table.insert(Input._confirmCallbacks, callback)
end

function Input.onCancel(callback)
    table.insert(Input._cancelCallbacks, callback)
end

-- ---------------------------------------------------------------------------
-- Internal event dispatchers
-- ---------------------------------------------------------------------------

function Input._fireGridResize(delta)
    for _, cb in ipairs(Input._resizeCallbacks) do
        local ok, err = pcall(cb, delta)
        if not ok then
            if Input._log and Input._log.warn then
                Input._log.warn("GridResize callback error: " .. tostring(err))
            end
        end
    end
end

function Input._fireModeToggle()
    for _, cb in ipairs(Input._modeCallbacks) do
        local ok, err = pcall(cb)
        if not ok then
            if Input._log and Input._log.warn then
                Input._log.warn("ModeToggle callback error: " .. tostring(err))
            end
        end
    end
end

function Input._fireSpacingAdjust(delta)
    for _, cb in ipairs(Input._spacingCallbacks) do
        local ok, err = pcall(cb, delta)
        if not ok then
            if Input._log and Input._log.warn then
                Input._log.warn("Spacing callback error: " .. tostring(err))
            end
        end
    end
end

function Input._fireRotate(delta)
    for _, cb in ipairs(Input._rotateCallbacks) do
        local ok, err = pcall(cb, delta)
        if not ok then
            if Input._log and Input._log.warn then
                Input._log.warn("Rotate callback error: " .. tostring(err))
            end
        end
    end
end

function Input._fireConfirm()
    for _, cb in ipairs(Input._confirmCallbacks) do
        local ok, err = pcall(cb)
        if not ok then
            if Input._log and Input._log.warn then
                Input._log.warn("Confirm callback error: " .. tostring(err))
            end
        end
    end
end

function Input._fireCancel()
    for _, cb in ipairs(Input._cancelCallbacks) do
        local ok, err = pcall(cb)
        if not ok then
            if Input._log and Input._log.warn then
                Input._log.warn("Cancel callback error: " .. tostring(err))
            end
        end
    end
end

function Input.simulateAction(action)
    if action == "toggle_mode" then
        return Input._fireModeToggle()
    end
    if action == "increase_rows" then
        return Input._fireGridResize({rows = 1, cols = 0})
    end
    if action == "decrease_rows" then
        return Input._fireGridResize({rows = -1, cols = 0})
    end
    if action == "increase_cols" then
        return Input._fireGridResize({rows = 0, cols = 1})
    end
    if action == "decrease_cols" then
        return Input._fireGridResize({rows = 0, cols = -1})
    end
    if action == "increase_spacing" then
        return Input._fireSpacingAdjust(0.5)
    end
    if action == "decrease_spacing" then
        return Input._fireSpacingAdjust(-0.5)
    end
    local rotationStep = (Input._config and Input._config.grid and Input._config.grid.rotation_step_deg) or DEFAULT_ROTATION_STEP
    if action == "rotate_cw" then
        return Input._fireRotate(rotationStep)
    end
    if action == "rotate_ccw" then
        return Input._fireRotate(-rotationStep)
    end
    if action == "confirm_placement" then
        return Input._fireConfirm()
    end
    if action == "cancel" then
        return Input._fireCancel()
    end
end

return Input
