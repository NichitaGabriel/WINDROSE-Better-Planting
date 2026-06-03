-- WINDROSE Better Planting
-- src/core/grid.lua
--
-- Grid Generation module.
-- Builds and manages the grid data structure: a list of cells with position
-- and validity information. Delegates position math to placement.lua and
-- validity checks to validation.lua.

local Placement  = require("core.placement")
local Validation = require("core.validation")

local Grid = {}

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
    local rows     = preset.rows     or Grid._config.grid.rows
    local cols     = preset.cols     or Grid._config.grid.cols
    local spacing  = preset.spacing  or Grid._config.grid.spacing
    local rotation = preset.rotation or 0

    -- Cells are initially anchored at the world origin.
    -- The caller (main.lua) should call Grid.setAnchor() before displaying.
    local cells = Placement.getAllCellPositions(
        {x = 0, y = 0, z = 0},
        rows, cols, spacing, rotation
    )

    return {
        rows     = rows,
        cols     = cols,
        spacing  = spacing,
        rotation = rotation,
        cells    = cells,
    }
end

--- Update the anchor world position for an existing grid object.
--- Recomputes all cell world positions.
---
--- @param grid      table   Existing grid object (modified in place).
--- @param anchorPos table   {x, y, z} — new anchor (cursor) position.
--- @return table  The updated grid object.
function Grid.setAnchor(grid, anchorPos)
    grid.cells = Placement.getAllCellPositions(
        anchorPos,
        grid.rows,
        grid.cols,
        grid.spacing,
        grid.rotation
    )
    return grid
end

--- Return a new grid with updated row and column counts, preserving the
--- current anchor position and spacing.
---
--- @param grid    table   Existing grid object.
--- @param newRows integer
--- @param newCols integer
--- @return table  New grid object.
function Grid.resize(grid, newRows, newCols)
    -- Recalculate anchor as the centre of the current grid, then rebuild.
    -- For simplicity we keep the current first-cell origin as anchor basis.
    -- TODO: Optionally preserve the visual centre across resizes.
    local origin = grid.cells and grid.cells[1] and grid.cells[1].worldPos
                   or {x = 0, y = 0, z = 0}

    -- Offset origin to new centre.
    local newCells = Placement.getAllCellPositions(
        origin,
        newRows,
        newCols,
        grid.spacing,
        grid.rotation
    )

    return {
        rows     = newRows,
        cols     = newCols,
        spacing  = grid.spacing,
        rotation = grid.rotation,
        cells    = newCells,
    }
end

--- Return a new grid rotated by `angleDeg` degrees (added to current rotation).
---
--- @param grid     table   Existing grid object.
--- @param angleDeg number  Degrees to add to the current rotation.
--- @return table  New grid object.
function Grid.rotate(grid, angleDeg)
    local newRotation = (grid.rotation + angleDeg) % 360

    -- Derive anchor from the first cell (rough approximation — TODO: track
    -- the true grid centre explicitly).
    local origin = grid.cells and grid.cells[1] and grid.cells[1].worldPos
                   or {x = 0, y = 0, z = 0}

    local newCells = Placement.getAllCellPositions(
        origin,
        grid.rows,
        grid.cols,
        grid.spacing,
        newRotation
    )

    return {
        rows     = grid.rows,
        cols     = grid.cols,
        spacing  = grid.spacing,
        rotation = newRotation,
        cells    = newCells,
    }
end

return Grid
