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

Input._config         = nil
Input._resizeCallbacks = {}
Input._confirmCallbacks = {}
Input._registered     = false

-- ---------------------------------------------------------------------------
-- Init / teardown
-- ---------------------------------------------------------------------------

--- Initialise and register all configured hotkeys.
--- @param config table  The loaded mod configuration.
function Input.init(config)
    Input._config = config
    Input.register()
    print("[Input] Initialised.")
end

--- Bind all hotkeys defined in config.hotkeys.
function Input.register()
    if Input._registered then return end
    local keys = Input._config.hotkeys

    -- TODO: Use the Windrose / UE4SS input API to bind each key.
    -- Pattern: Game.bindKey(key, callback)
    -- Example:
    --
    -- Game.bindKey(keys.toggle_mod, function()
    --     Input._onToggleMod()
    -- end)
    --
    -- Game.bindKey(keys.increase_rows, function()
    --     Input._fireGridResize({rows = 1, cols = 0})
    -- end)
    --
    -- Game.bindKey(keys.decrease_rows, function()
    --     Input._fireGridResize({rows = -1, cols = 0})
    -- end)
    --
    -- Game.bindKey(keys.increase_cols, function()
    --     Input._fireGridResize({rows = 0, cols = 1})
    -- end)
    --
    -- Game.bindKey(keys.decrease_cols, function()
    --     Input._fireGridResize({rows = 0, cols = -1})
    -- end)
    --
    -- Game.bindKey(keys.confirm_placement, function()
    --     Input._fireConfirm()
    -- end)

    Input._registered = true
    print("[Input] Hotkeys registered. (TODO: engine API)")
end

--- Unbind all hotkeys (e.g. on mod shutdown).
function Input.unregister()
    if not Input._registered then return end
    local keys = Input._config.hotkeys

    -- TODO: Use the engine API to unbind keys.
    -- e.g. Game.unbindKey(keys.toggle_mod)

    Input._registered = false
    print("[Input] Hotkeys unregistered. (TODO: engine API)")
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

--- Register a callback for placement confirmation.
---
--- @param callback function
function Input.onConfirm(callback)
    table.insert(Input._confirmCallbacks, callback)
end

-- ---------------------------------------------------------------------------
-- Internal event dispatchers
-- ---------------------------------------------------------------------------

function Input._fireGridResize(delta)
    for _, cb in ipairs(Input._resizeCallbacks) do
        local ok, err = pcall(cb, delta)
        if not ok then
            print("[Input] GridResize callback error: " .. tostring(err))
        end
    end
end

function Input._fireConfirm()
    for _, cb in ipairs(Input._confirmCallbacks) do
        local ok, err = pcall(cb)
        if not ok then
            print("[Input] Confirm callback error: " .. tostring(err))
        end
    end
end

function Input._onToggleMod()
    -- TODO: Toggle the mod on/off globally and update the overlay.
    print("[Input] Toggle mod. (TODO: implement)")
end

return Input
