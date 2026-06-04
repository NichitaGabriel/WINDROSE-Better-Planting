-- WINDROSE Better Planting
-- UE4SS-oriented bootstrap entrypoint for the prototype vertical slice.
--
-- This file intentionally avoids assuming any Windrose-specific hooks.
-- It only resolves Lua module paths and then loads src/main.lua.

local function dirname(path)
    local normalised = path:gsub("[/\\]+$", "")
    return normalised:match("^(.*)[/\\][^/\\]+$") or "."
end

local function climb(path, levels)
    local current = path
    for _ = 1, levels do
        current = dirname(current)
    end
    return current
end

local source = debug.getinfo(1, "S").source or ""
if source:sub(1, 1) == "@" then
    source = source:sub(2)
end

local scriptDir = dirname(source)
local modRoot = dirname(scriptDir)
-- Expected staged layout:
--   Mods/WINDROSE-Better-Planting/Scripts/main.lua
-- with sibling src/ and config/ directories under WINDROSE-Better-Planting/.
-- repoRoot is only a convenience fallback so this bootstrap also works from
-- the repository checkout before files are staged into a UE4SS install.
local repoRoot = climb(modRoot, 3)
local pathEntries = {
    modRoot .. "/src/?.lua",
    modRoot .. "/src/?/?.lua",
    repoRoot .. "/src/?.lua",
    repoRoot .. "/src/?/?.lua",
}

package.path = table.concat(pathEntries, ";") .. ";" .. package.path

local ok, BetterPlanting = pcall(require, "main")
if not ok then
    print("[WINDROSE-Better-Planting][ERROR] UE4SS bootstrap failed: " .. tostring(BetterPlanting))
    return nil
end

print("[WINDROSE-Better-Planting][INFO] UE4SS bootstrap entry loaded.")
return BetterPlanting
