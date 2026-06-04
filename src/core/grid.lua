-- WINDROSE Better Planting
-- src/core/grid.lua
--
-- Grid Generation module.
-- Builds and manages the grid data structure: a list of cells with position
-- and validity information. Delegates position math to placement.lua and
-- validity checks to validation.lua.

local Placement = require("core.placement")

local Grid = {}
local DEFAULT_ANCHOR = {x = 0, y = 0, z = 0}

Grid._config = nil

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

--- Initialise the grid module.
--- @param config table  The loaded mod configuration.
function Grid.init(config)
    Grid._config = config
    print("[Grid] Initialised.")
end

-- ---------------------------------------------------------------------------
-- Grid generation
-- ---------------------------------------------------------------------------

--- Generate a grid from a preset configuration table.
---
--- @param preset table  Must contain: rows, cols, spacing, rotation_step_deg.
---                      The anchor position defaults to world origin (0, 0, 0)
---                      and is updated externally when the cursor moves.
--- @return table  Grid object: {rows, cols, spacing, rotation, cells[]}
function Grid.generate(preset)
    local rows = preset.rows or Grid._config.grid.rows
    local cols = preset.cols or Grid._config.grid.cols
    local spacing = preset.spacing or Grid._config.grid.spacing
    local rotation = preset.rotation or 0
    local anchor = preset.anchor or DEFAULT_ANCHOR

    local cells = Placement.getAllCellPositions(
        anchor,
        rows, cols, spacing, rotation
    )

    return {
        rows = rows,
        cols = cols,
        spacing = spacing,
        rotation = rotation,
        anchor = anchor,
        cells = cells,
    }
end

--- Update the anchor world position for an existing grid object.
--- Recomputes all cell world positions.
---
--- @param grid      table   Existing grid object (modified in place).
--- @param anchorPos table   {x, y, z} — new anchor (cursor) position.
--- @return table  The updated grid object.
function Grid.setAnchor(grid, anchorPos)
    return Grid.generate({
        rows = grid.rows,
        cols = grid.cols,
        spacing = grid.spacing,
        rotation = grid.rotation,
        anchor = anchorPos,
    })
end

--- Return a new grid with updated row and column counts, preserving the
--- current anchor position and spacing.
---
--- @param grid    table   Existing grid object.
--- @param newRows integer
--- @param newCols integer
--- @return table  New grid object.
function Grid.resize(grid, newRows, newCols)
    return Grid.generate({
        rows = newRows,
        cols = newCols,
        spacing = grid.spacing,
        rotation = grid.rotation,
        anchor = grid.anchor,
    })
end

--- Return a new grid rotated by `angleDeg` degrees (added to current rotation).
---
--- @param grid     table   Existing grid object.
--- @param angleDeg number  Degrees to add to the current rotation.
--- @return table  New grid object.
function Grid.rotate(grid, angleDeg)
    local newRotation = (grid.rotation + angleDeg) % 360
    return Grid.generate({
        rows = grid.rows,
        cols = grid.cols,
        spacing = grid.spacing,
        rotation = newRotation,
        anchor = grid.anchor,
    })
end

return Grid
