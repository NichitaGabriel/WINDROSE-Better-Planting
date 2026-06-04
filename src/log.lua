-- WINDROSE Better Planting
-- src/log.lua
--
-- Minimal console logger for the prototype phase.

local Log = {}

Log._enabled = true
Log._level = "info"
Log._prefix = "BetterPlanting"
Log._levels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
}

function Log.init(config, prefix)
    config = config or {}
    Log._enabled = config.enabled ~= false
    Log._level = config.log_level or "info"
    Log._prefix = prefix or Log._prefix
end

function Log._shouldLog(level)
    if not Log._enabled then
        return false
    end

    return (Log._levels[level] or 99) >= (Log._levels[Log._level] or 2)
end

function Log._print(level, message)
    if not Log._shouldLog(level) then
        return
    end

    print(string.format("[%s][%s] %s", Log._prefix, string.upper(level), tostring(message)))
end

function Log.debug(message)
    Log._print("debug", message)
end

function Log.info(message)
    Log._print("info", message)
end

function Log.warn(message)
    Log._print("warn", message)
end

function Log.error(message)
    Log._print("error", message)
end

return Log
