-- WINDROSE Better Planting
-- src/core/selection.lua
--
-- Selection Detection module.
-- Responsible for detecting which seed, crop, or tree is currently selected
-- in the Windrose build / placement menu, and notifying listeners when the
-- selection changes.
--
-- TODO: All engine API calls in this module are placeholders. The actual
--       hooks depend on the Windrose modding runtime (pak / UE4SS / other).
--       Replace each TODO block once confirmed hooks are available.

local Selection = {}

Selection._currentSelection = nil
Selection._changeCallbacks = {}
Selection._config = nil
Selection._bridge = nil
Selection._log = nil

-- ---------------------------------------------------------------------------
-- Init / teardown
-- ---------------------------------------------------------------------------

--- Initialise the selection module.
--- @param config table  The loaded mod configuration.
--- @param bridge table  Runtime adapter.
--- @param log table     Logger.
function Selection.init(config, bridge, log)
    Selection._config = config
    Selection._bridge = bridge
    Selection._log = log
    Selection._currentSelection = nil
end

function Selection._safeLog(method, message)
    if Selection._log and Selection._log[method] then
        Selection._log[method](message)
    end
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Return the name/type of the currently selected plantable item, or nil
--- if nothing plantable is selected.
---
--- @return string|nil
function Selection.getSelected()
    return Selection._currentSelection
end

--- Return true if the current selection is a seed, crop, or tree (i.e.
--- something the mod should respond to).
---
--- @return boolean
function Selection.isPlantable(selection)
    local sel = selection or Selection.getSelected()
    if sel == nil then
        return false
    end

    return true
end

--- Register a callback to be invoked whenever the selected item changes.
--- The callback receives the new selection value (string or nil).
---
--- @param callback function  fn(plantType: string|nil)
function Selection.onSelectionChange(callback)
    table.insert(Selection._changeCallbacks, callback)
end

--- Poll the runtime bridge for the latest selection and notify listeners if it changed.
function Selection.refresh()
    if not Selection._bridge or not Selection._bridge.getCurrentSelection then
        return Selection._currentSelection
    end

    Selection._notify(Selection._bridge.getCurrentSelection())
    return Selection._currentSelection
end

-- ---------------------------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------------------------

--- Called internally (or by a game hook) when the selection changes.
--- Updates internal state and fires all registered callbacks.
---
--- @param newSelection string|nil
function Selection._notify(newSelection)
    if newSelection == Selection._currentSelection then
        return  -- No change — skip.
    end

    Selection._currentSelection = newSelection

    for _, cb in ipairs(Selection._changeCallbacks) do
        local ok, err = pcall(cb, newSelection)
        if not ok then
            Selection._safeLog("warn", "Selection callback error: " .. tostring(err))
        end
    end
end

return Selection
