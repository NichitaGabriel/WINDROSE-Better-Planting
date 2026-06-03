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

Overlay._config    = nil
Overlay._visible   = false
Overlay._hudHandle = nil   -- Engine handle for the HUD widget.
Overlay._settingsHandle = nil

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

--- Initialise the overlay module.
--- @param config table  The loaded mod configuration.
function Overlay.init(config)
    Overlay._config  = config
    Overlay._visible = false
    print("[Overlay] Initialised.")
end

-- ---------------------------------------------------------------------------
-- HUD show / hide / update
-- ---------------------------------------------------------------------------

--- Show the HUD overlay widget.
function Overlay.show()
    if Overlay._visible then return end

    local cfg = Overlay._config.preview

    -- TODO: Create and display the HUD widget using the Windrose UI API.
    -- e.g.
    -- Overlay._hudHandle = Game.createWidget("BetterPlantingHUD", {
    --     position = cfg.hud_position,
    --     opacity  = cfg.hud_opacity,
    --     fontSize = cfg.hud_font_size,
    -- })

    Overlay._visible = true
    print("[Overlay] HUD shown. (TODO: engine API)")
end

--- Hide and destroy the HUD overlay widget.
function Overlay.hide()
    if not Overlay._visible then return end

    -- TODO: Destroy the HUD widget.
    -- e.g. if Overlay._hudHandle then
    --          Game.destroyWidget(Overlay._hudHandle)
    --          Overlay._hudHandle = nil
    --      end

    Overlay._visible = false
    print("[Overlay] HUD hidden. (TODO: engine API)")
end

--- Update the displayed grid information in the HUD.
---
--- @param rows    integer  Current grid row count.
--- @param cols    integer  Current grid column count.
--- @param spacing number   Current grid spacing.
function Overlay.update(rows, cols, spacing)
    if not Overlay._visible then return end

    -- TODO: Update the HUD widget text fields.
    -- e.g.
    -- Game.setWidgetText(Overlay._hudHandle, "rows",    tostring(rows))
    -- Game.setWidgetText(Overlay._hudHandle, "cols",    tostring(cols))
    -- Game.setWidgetText(Overlay._hudHandle, "spacing", string.format("%.1f", spacing))

    print(string.format("[Overlay] HUD updated — %dx%d, spacing %.1f (TODO: engine API)",
        rows, cols, spacing))
end

-- ---------------------------------------------------------------------------
-- Settings panel
-- ---------------------------------------------------------------------------

--- Open the settings panel (if available).
function Overlay.showSettings()
    -- TODO: Create and display the settings panel widget.
    -- e.g.
    -- Overlay._settingsHandle = Game.createWidget("BetterPlantingSettings", {})

    print("[Overlay] Settings panel opened. (TODO: engine API)")
end

--- Close the settings panel.
function Overlay.hideSettings()
    if Overlay._settingsHandle then
        -- TODO: Destroy the settings panel widget.
        -- e.g. Game.destroyWidget(Overlay._settingsHandle)
        Overlay._settingsHandle = nil
    end
end

return Overlay
