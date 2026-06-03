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

Preview._config        = nil
Preview._activeCells   = {}   -- Currently rendered cell handles.
Preview._snapHandle    = nil  -- Handle for the Option A snap indicator.

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

--- Initialise the preview module.
--- @param config table  The loaded mod configuration.
function Preview.init(config)
    Preview._config = config
    print("[Preview] Initialised.")
end

-- ---------------------------------------------------------------------------
-- Grid preview (Option B)
-- ---------------------------------------------------------------------------

--- Render cells from a validated cell list.
--- Valid cells are drawn in the configured valid_color; invalid cells in
--- invalid_color. Existing visuals are cleared before re-drawing.
---
--- @param cells table  List of cell tables with worldPos and valid fields.
function Preview.show(cells)
    Preview.hide()  -- Clear any existing visuals first.

    local cfg = Preview._config.preview
    local gcfg = Preview._config.grid

    for _, cell in ipairs(cells) do
        local color = cell.valid and gcfg.valid_color or gcfg.invalid_color

        -- TODO: Spawn a visual marker (decal / mesh / canvas circle) at
        --       cell.worldPos with the given color and opacity.
        -- e.g.
        -- local handle = Game.spawnOverlayCircle({
        --     position = cell.worldPos,
        --     radius   = cfg.cell_radius,
        --     color    = color,
        --     opacity  = gcfg.cell_opacity,
        -- })
        -- table.insert(Preview._activeCells, handle)

        -- Placeholder log (remove once engine API is available).
        -- print(string.format("[Preview] Cell (%d,%d) at %.1f,%.1f — %s",
        --     cell.row, cell.col, cell.worldPos.x, cell.worldPos.z, color))
    end

    Preview._activeCells = cells  -- Store for update/hide.
end

--- Remove all rendered cell visuals.
function Preview.hide()
    for _, handle in ipairs(Preview._activeCells) do
        -- TODO: Destroy the visual marker referenced by handle.
        -- e.g. Game.destroyOverlay(handle)
    end
    Preview._activeCells = {}
end

--- Update existing cell visuals in-place (e.g. after validity re-check).
--- More efficient than hide() + show() if handles support color update.
---
--- @param cells table  Updated cell list with worldPos and valid fields.
function Preview.update(cells)
    -- TODO: If the engine supports updating existing overlay handles, do so.
    --       Otherwise fall back to hide + show.
    Preview.show(cells)
end

-- ---------------------------------------------------------------------------
-- Snap indicator (Option A)
-- ---------------------------------------------------------------------------

--- Show a snap point indicator at the given world position.
---
--- @param worldPos table  {x, y, z}
function Preview.showSnapPoint(worldPos)
    Preview.hideSnapPoint()

    local cfg  = Preview._config.preview
    local scfg = Preview._config.snap

    -- TODO: Spawn a snap indicator visual at worldPos.
    -- e.g.
    -- Preview._snapHandle = Game.spawnOverlayCircle({
    --     position = worldPos,
    --     radius   = cfg.cell_radius,
    --     color    = scfg.indicator_color,
    --     opacity  = scfg.indicator_opacity,
    -- })

    print(string.format("[Preview] Snap indicator at %.2f, %.2f (TODO: engine API)",
        worldPos.x, worldPos.z))
end

--- Remove the snap point indicator.
function Preview.hideSnapPoint()
    if Preview._snapHandle then
        -- TODO: Destroy the snap indicator.
        -- e.g. Game.destroyOverlay(Preview._snapHandle)
        Preview._snapHandle = nil
    end
end

return Preview
