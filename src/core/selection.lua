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

-- Internal state.
Selection._currentSelection  = nil
Selection._changeCallbacks   = {}
Selection._config            = nil

-- ---------------------------------------------------------------------------
-- Init / teardown
-- ---------------------------------------------------------------------------

--- Initialise the selection module.
--- @param config table  The loaded mod configuration.
function Selection.init(config)
    Selection._config = config
    Selection._currentSelection = nil

    -- TODO: Register with the Windrose build-menu open/close events so we
    --       can start and stop polling or listening for selection changes.
    -- e.g. Game.onBuildMenuOpen(Selection._startTracking)
    --      Game.onBuildMenuClose(Selection._stopTracking)

    print("[Selection] Initialised.")
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Return the name/type of the currently selected plantable item, or nil
--- if nothing plantable is selected.
---
--- @return string|nil
function Selection.getSelected()
    -- TODO: Read the current selection from the Windrose build-menu API.
    -- e.g. return Game.getBuildMenuSelection()
    return Selection._currentSelection
end

--- Return true if the current selection is a seed, crop, or tree (i.e.
--- something the mod should respond to).
---
--- @return boolean
function Selection.isPlantable()
    local sel = Selection.getSelected()
    if sel == nil then return false end

    -- TODO: Check against the Windrose plantable-item registry.
    -- For now, assume everything non-nil is plantable.
    return true
end

--- Register a callback to be invoked whenever the selected item changes.
--- The callback receives the new selection value (string or nil).
---
--- @param callback function  fn(plantType: string|nil)
function Selection.onSelectionChange(callback)
    table.insert(Selection._changeCallbacks, callback)
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
            print("[Selection] Callback error: " .. tostring(err))
        end
    end
end

-- TODO: Implement polling or event-based selection tracking once the
--       Windrose build-menu API is confirmed.
-- e.g.
-- function Selection._startTracking()
--     Selection._pollHandle = Game.registerTick(function()
--         local sel = Game.getBuildMenuSelection()
--         Selection._notify(sel)
--     end)
-- end
--
-- function Selection._stopTracking()
--     if Selection._pollHandle then
--         Game.unregisterTick(Selection._pollHandle)
--         Selection._pollHandle = nil
--     end
--     Selection._notify(nil)
-- end

return Selection
