-- WINDROSE Better Planting
-- src/core/validation.lua
--
-- Validation Rules module.
-- Determines whether a given world position is a valid planting location
-- for a given plant type, using Windrose terrain and collision APIs.
--
-- TODO: All engine API calls here are placeholders. The actual terrain
--       query and collision functions depend on the confirmed Windrose
--       modding runtime. Replace TODO blocks once hooks are available.

local Validation = {}

Validation._config = nil

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

--- Initialise the validation module.
--- @param config table  The loaded mod configuration.
function Validation.init(config)
    Validation._config = config
    print("[Validation] Initialised.")
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Check whether a single world position is valid for planting.
---
--- Returns true if:
---   - The terrain at the position is walkable / plantable surface.
---   - There is no existing plant or obstacle too close.
---   - The position is within the player's reachable area.
---
--- @param worldPos  table   {x, y, z}
--- @param plantType string  Name/type of the plant to be placed.
--- @return boolean
function Validation.isValid(worldPos, plantType)
    -- TODO: Call the Windrose terrain surface query.
    -- e.g.
    -- if not Game.isTerrainPlantable(worldPos) then
    --     return false
    -- end

    -- TODO: Call the Windrose overlap / spacing check.
    -- e.g.
    -- if Game.hasTooCloseObjects(worldPos, plantType) then
    --     return false
    -- end

    -- TODO: Check if the position is within the player's placement reach.
    -- e.g.
    -- if not Game.isWithinPlacementRange(worldPos) then
    --     return false
    -- end

    -- Placeholder: assume all positions are valid until engine APIs are known.
    return true
end

--- Check validity for every cell in a cell list and populate the `valid` field.
--- Modifies the cell list in place.
---
--- @param cells     table   List of cell tables from grid.lua or placement.lua.
---                          Each cell must have a `worldPos` field.
--- @param plantType string  Name/type of the plant to be placed.
--- @return table  The same cell list, with `valid` populated on each entry.
function Validation.checkAll(cells, plantType)
    for _, cell in ipairs(cells) do
        cell.valid = Validation.isValid(cell.worldPos, plantType)
    end
    return cells
end

--- Return summary counts from a validated cell list.
---
--- @param cells table  Cell list with `valid` field populated.
--- @return table  {total, valid, invalid}
function Validation.summarise(cells)
    local total   = #cells
    local valid   = 0
    local invalid = 0

    for _, cell in ipairs(cells) do
        if cell.valid then
            valid = valid + 1
        else
            invalid = invalid + 1
        end
    end

    return {total = total, valid = valid, invalid = invalid}
end

return Validation
