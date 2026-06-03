-- WINDROSE Better Planting
-- src/core/placement.lua
--
-- Placement Math module.
-- Pure math functions for computing snap points, grid anchor positions, and
-- individual cell world positions. No engine API calls — this module is
-- fully self-contained and can be unit-tested independently.

local Placement = {}

Placement._config = nil

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

--- Initialise the placement module.
--- @param config table  The loaded mod configuration.
function Placement.init(config)
    Placement._config = config
    print("[Placement] Initialised.")
end

-- ---------------------------------------------------------------------------
-- Snap (Option A)
-- ---------------------------------------------------------------------------

--- Snap a world position to the nearest aligned grid point given a spacing.
---
--- Grid points are defined as integer multiples of `spacing` along both axes,
--- relative to a global origin at (0, 0).
---
--- @param worldPos table  {x: number, y: number, z: number}
--- @param spacing  number  Grid cell size in world units.
--- @return table  {x: number, y: number, z: number}
function Placement.snapToGrid(worldPos, spacing)
    if spacing <= 0 then
        return worldPos
    end

    return {
        x = math.floor(worldPos.x / spacing + 0.5) * spacing,
        y = worldPos.y,  -- Preserve the original Y (height) — terrain conforming is separate.
        z = math.floor(worldPos.z / spacing + 0.5) * spacing,
    }
end

-- ---------------------------------------------------------------------------
-- Grid (Option B)
-- ---------------------------------------------------------------------------

--- Calculate the world position of the top-left anchor cell for a grid
--- centred on `anchorPos`.
---
--- @param anchorPos table   {x, y, z} centre of the desired grid.
--- @param rows      integer Number of rows.
--- @param cols      integer Number of columns.
--- @param spacing   number  Cell spacing in world units.
--- @return table  {x, y, z} — world position of the (0, 0) cell origin.
function Placement.getGridOrigin(anchorPos, rows, cols, spacing)
    local halfW = (cols - 1) * spacing / 2
    local halfH = (rows - 1) * spacing / 2

    return {
        x = anchorPos.x - halfW,
        y = anchorPos.y,
        z = anchorPos.z - halfH,
    }
end

--- Calculate the world position of a single cell in a grid, with optional
--- rotation around the grid centre.
---
--- @param origin     table    {x, y, z} — grid origin (top-left cell).
--- @param row        integer  Zero-based row index.
--- @param col        integer  Zero-based column index.
--- @param spacing    number   Cell spacing in world units.
--- @param rotationDeg number  Rotation of the entire grid in degrees (around Y axis).
--- @return table  {x, y, z}
function Placement.getCellPosition(origin, row, col, spacing, rotationDeg)
    -- Unrotated offset from origin.
    local dx = col * spacing
    local dz = row * spacing

    -- Apply rotation if non-zero.
    if rotationDeg and rotationDeg ~= 0 then
        local rad = math.rad(rotationDeg)
        local cos = math.cos(rad)
        local sin = math.sin(rad)
        local rx  = dx * cos - dz * sin
        local rz  = dx * sin + dz * cos
        dx = rx
        dz = rz
    end

    return {
        x = origin.x + dx,
        y = origin.y,
        z = origin.z + dz,
    }
end

--- Convenience: return all cell world positions for a grid configuration.
---
--- @param anchorPos   table    {x, y, z} centre position for the grid.
--- @param rows        integer
--- @param cols        integer
--- @param spacing     number
--- @param rotationDeg number
--- @return table  List of {row, col, worldPos} tables.
function Placement.getAllCellPositions(anchorPos, rows, cols, spacing, rotationDeg)
    local origin = Placement.getGridOrigin(anchorPos, rows, cols, spacing)
    local cells  = {}

    for r = 0, rows - 1 do
        for c = 0, cols - 1 do
            local pos = Placement.getCellPosition(origin, r, c, spacing, rotationDeg or 0)
            table.insert(cells, {
                row      = r,
                col      = c,
                worldPos = pos,
                valid    = nil,  -- Populated by validation.lua
            })
        end
    end

    return cells
end

return Placement
