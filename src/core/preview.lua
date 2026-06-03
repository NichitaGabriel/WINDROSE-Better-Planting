-- WINDROSE Better Planting
-- src/core/preview.lua
--
-- Preview Rendering module.
-- Renders the ghost grid overlay (Option B) and snap point indicator
-- (Option A) on the terrain using Windrose rendering / overlay APIs.
--
-- TODO: All engine rendering calls are placeholders. The specific approach
--       (decals, meshes, UI canvas, UE4SS draw calls, etc.) depends on
--       the confirmed Windrose modding runtime. Replace TODO blocks once
--       the rendering API is available.

local Preview = {}

Preview._config = nil
Preview._log = nil
Preview._activeCells = {}
Preview._snapPoint = nil

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

--- Initialise the preview module.
--- @param config table  The loaded mod configuration.
--- @param bridge table  Runtime adapter.
--- @param log table     Logger.
function Preview.init(config, bridge, log)
    Preview._config = config
    Preview._log = log
end

-- ---------------------------------------------------------------------------
-- Grid preview (Option B)
-- ---------------------------------------------------------------------------

--- Render cells from a validated cell list.
--- Valid cells are drawn in the configured valid_color; invalid cells in
--- invalid_color. Existing visuals are cleared before re-drawing.
---
--- @param cells table  List of cell tables with worldPos and valid fields.
function Preview.showGrid(cells)
    Preview._activeCells = cells or {}
end

--- Remove all rendered cell visuals.
function Preview.hide()
    Preview._activeCells = {}
end

--- Update existing cell visuals in-place (e.g. after validity re-check).
--- More efficient than hide() + show() if handles support color update.
---
--- @param cells table  Updated cell list with worldPos and valid fields.
function Preview.updateGrid(cells)
    Preview.showGrid(cells)
end

-- ---------------------------------------------------------------------------
-- Snap indicator (Option A)
-- ---------------------------------------------------------------------------

--- Show a snap point indicator at the given world position.
---
--- @param worldPos table  {x, y, z}
function Preview.showSnapPoint(worldPos)
    Preview._snapPoint = worldPos
end

--- Remove the snap point indicator.
function Preview.hideSnapPoint()
    Preview._snapPoint = nil
end

function Preview.getState()
    return {
        cells = Preview._activeCells,
        snapPoint = Preview._snapPoint,
    }
end

return Preview
