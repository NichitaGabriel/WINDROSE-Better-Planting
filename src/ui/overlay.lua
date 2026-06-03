-- WINDROSE Better Planting
-- src/ui/overlay.lua
--
-- HUD Overlay module.
-- Displays a non-diegetic heads-up overlay showing the current grid
-- dimensions, spacing, and mode. Also manages the optional settings panel.
--
-- TODO: All engine UI / widget calls are placeholders. The actual widget
--       system (UMG, UE4SS canvas, immediate-mode UI, etc.) depends on
--       the confirmed Windrose modding runtime. Replace TODO blocks once
--       the UI API is available.

local Overlay = {}

Overlay._config = nil
Overlay._log = nil
Overlay._visible = false
Overlay._hudHandle = nil
Overlay._settingsHandle = nil
Overlay._lastState = nil

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

--- Initialise the overlay module.
--- @param config table  The loaded mod configuration.
--- @param log table     Logger.
function Overlay.init(config, log)
    Overlay._config = config
    Overlay._log = log
    Overlay._visible = false
end

function Overlay._safeLog(method, message)
    if Overlay._log and Overlay._log[method] then
        Overlay._log[method](message)
    end
end

-- ---------------------------------------------------------------------------
-- HUD show / hide / update
-- ---------------------------------------------------------------------------

--- Show the HUD overlay widget.
function Overlay.show()
    if Overlay._visible then return end

    Overlay._visible = true
end

--- Hide and destroy the HUD overlay widget.
function Overlay.hide()
    if not Overlay._visible then return end
    Overlay._visible = false
end

--- Update the displayed grid information in the HUD.
---
--- @param rows    integer  Current grid row count.
--- @param cols    integer  Current grid column count.
--- @param spacing number   Current grid spacing.
function Overlay.update(rows, cols, spacing)
    if not Overlay._visible then return end
    Overlay._lastState = {
        rows = rows,
        cols = cols,
        spacing = spacing,
    }
end

-- ---------------------------------------------------------------------------
-- Settings panel
-- ---------------------------------------------------------------------------

--- Open the settings panel (if available).
function Overlay.showSettings()
    Overlay._safeLog("info", "Settings panel requested. TODO: bind to verified UI runtime.")
end

--- Close the settings panel.
function Overlay.hideSettings()
    if Overlay._settingsHandle then
        Overlay._settingsHandle = nil
    end
end

function Overlay.updatePrototype(state)
    if not Overlay._visible then
        return
    end

    Overlay._lastState = state
end

function Overlay.getState()
    return Overlay._lastState
end

return Overlay
