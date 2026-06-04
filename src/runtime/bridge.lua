-- WINDROSE Better Planting
-- src/runtime/bridge.lua
--
-- Explicit adapter/stub layer for Windrose runtime integration.
-- Real engine hooks belong here once the community modding path is verified.
-- Mock helpers are included only so the repository can exercise prototype
-- flow locally without claiming a confirmed in-game integration.

local RuntimeBridge = {}

RuntimeBridge._config = nil
RuntimeBridge._log = nil
RuntimeBridge._hooks = {}
RuntimeBridge._bindings = {}
RuntimeBridge._mock = {}

local function cloneVector(worldPos)
    if type(worldPos) ~= "table" then
        return nil
    end

    return {
        x = worldPos.x or 0,
        y = worldPos.y or 0,
        z = worldPos.z or 0,
    }
end

local function vectorToString(worldPos)
    if type(worldPos) ~= "table" then
        return "nil"
    end

    return string.format("(%.2f, %.2f, %.2f)", worldPos.x or 0, worldPos.y or 0, worldPos.z or 0)
end

local function safeLog(method, message)
    if RuntimeBridge._log and RuntimeBridge._log[method] then
        RuntimeBridge._log[method](message)
    end
end

local function shouldEnableMockMode(prototypeConfig, mockConfig)
    return prototypeConfig.allow_mock_bridge == true and (mockConfig.enabled == nil or mockConfig.enabled == true)
end

function RuntimeBridge.init(config, log)
    RuntimeBridge._config = config
    RuntimeBridge._log = log
    RuntimeBridge._hooks = {}
    RuntimeBridge._bindings = {}
    local prototypeConfig = (config and config.prototype) or {}
    local mockConfig = prototypeConfig.mock or {}
    local mockEnabled = shouldEnableMockMode(prototypeConfig, mockConfig)
    local defaultCursor = cloneVector(mockConfig.anchor) or {x = 0, y = 0, z = 0}

    RuntimeBridge._mock = {
        enabled = mockEnabled,
        selection = mockConfig.selection,
        cursor = cloneVector(defaultCursor),
        default_selection = mockConfig.selection,
        default_cursor = cloneVector(defaultCursor),
        step = mockConfig.anchor_step or 1.0,
        validity = nil,
    }

    safeLog("info", "Runtime bridge ready. WINDROSE hooks remain unverified; mock fallback is " .. (mockEnabled and "enabled" or "disabled") .. ".")
    if mockEnabled then
        safeLog("info", "Mock planting selection seeded as '" .. tostring(RuntimeBridge._mock.selection) .. "' at anchor " .. vectorToString(RuntimeBridge._mock.cursor) .. ".")
    end
end

function RuntimeBridge.registerLifecycleHooks(hooks)
    RuntimeBridge._hooks = hooks or {}
end

function RuntimeBridge.registerInputBindings(bindings)
    RuntimeBridge._bindings = bindings or {}
    if #RuntimeBridge._bindings > 0 then
        safeLog("debug", "Registered " .. tostring(#RuntimeBridge._bindings) .. " prototype input binding descriptors.")
    end
end

function RuntimeBridge.getCurrentSelection()
    if RuntimeBridge._mock.enabled then
        return RuntimeBridge._mock.selection
    end

    return nil
end

function RuntimeBridge.getCursorWorldPosition()
    if RuntimeBridge._mock.enabled then
        return cloneVector(RuntimeBridge._mock.cursor)
    end

    return nil
end

function RuntimeBridge.queryPlacementValidity(worldPos, plantType)
    if type(RuntimeBridge._mock.validity) == "function" then
        return RuntimeBridge._mock.validity(worldPos, plantType)
    end

    if RuntimeBridge._mock.enabled then
        return true, "Mock validity fallback"
    end

    -- TODO: Replace this placeholder once a verified Windrose/UE4SS placement
    -- validity query is available.
    return nil, "Placement validity check not available"
end

function RuntimeBridge.describeCapabilities()
    return {
        selection = false,
        selection_mock = RuntimeBridge._mock.enabled,
        placement_cursor = false,
        placement_cursor_mock = RuntimeBridge._mock.enabled,
        preview_rendering = false,
        placement_validation = false,
        placement_validation_mock = RuntimeBridge._mock.enabled,
        input_binding = false,
        input_binding_descriptors = #RuntimeBridge._bindings,
        runtime_shape = RuntimeBridge._config and RuntimeBridge._config.prototype and RuntimeBridge._config.prototype.runtime_shape or "prototype",
        mock_mode = RuntimeBridge._mock.enabled,
    }
end

function RuntimeBridge.tick()
    local onTick = RuntimeBridge._hooks.onTick
    if onTick then
        onTick()
    end
end

function RuntimeBridge.shutdown()
    local onShutdown = RuntimeBridge._hooks.onShutdown
    if onShutdown then
        onShutdown()
    end
end

function RuntimeBridge.setMockSelection(selection)
    RuntimeBridge._mock.selection = selection
    safeLog("info", "Mock selection set to '" .. tostring(selection) .. "'.")
end

function RuntimeBridge.setMockCursorWorldPosition(worldPos)
    RuntimeBridge._mock.cursor = cloneVector(worldPos)
    safeLog("info", "Mock anchor set to " .. vectorToString(RuntimeBridge._mock.cursor) .. ".")
end

function RuntimeBridge.setMockValidityHandler(handler)
    RuntimeBridge._mock.validity = handler
end

function RuntimeBridge.isMockModeEnabled()
    return RuntimeBridge._mock.enabled == true
end

function RuntimeBridge.toggleMockMode()
    RuntimeBridge._mock.enabled = not RuntimeBridge._mock.enabled
    if RuntimeBridge._mock.enabled then
        RuntimeBridge._mock.selection = RuntimeBridge._mock.selection or RuntimeBridge._mock.default_selection
        RuntimeBridge._mock.cursor = cloneVector(RuntimeBridge._mock.cursor or RuntimeBridge._mock.default_cursor)
    end

    safeLog("info", "Mock prototype mode " .. (RuntimeBridge._mock.enabled and "enabled" or "disabled") .. ".")
    return RuntimeBridge._mock.enabled
end

function RuntimeBridge.nudgeMockCursor(delta)
    if not RuntimeBridge._mock.enabled then
        safeLog("warn", "Ignoring mock anchor nudge because mock prototype mode is disabled.")
        return nil
    end

    RuntimeBridge._mock.cursor = cloneVector(RuntimeBridge._mock.cursor or RuntimeBridge._mock.default_cursor or {x = 0, y = 0, z = 0})
    RuntimeBridge._mock.cursor.x = (RuntimeBridge._mock.cursor.x or 0) + (delta.x or 0)
    RuntimeBridge._mock.cursor.y = (RuntimeBridge._mock.cursor.y or 0) + (delta.y or 0)
    RuntimeBridge._mock.cursor.z = (RuntimeBridge._mock.cursor.z or 0) + (delta.z or 0)
    safeLog("info", "Mock anchor nudged to " .. vectorToString(RuntimeBridge._mock.cursor) .. ".")
    return cloneVector(RuntimeBridge._mock.cursor)
end

function RuntimeBridge.resetMockCursor()
    RuntimeBridge._mock.cursor = cloneVector(RuntimeBridge._mock.default_cursor)
    safeLog("info", "Mock anchor reset to " .. vectorToString(RuntimeBridge._mock.cursor) .. ".")
    return cloneVector(RuntimeBridge._mock.cursor)
end

function RuntimeBridge.getMockState()
    return {
        enabled = RuntimeBridge._mock.enabled,
        selection = RuntimeBridge._mock.selection,
        cursor = cloneVector(RuntimeBridge._mock.cursor),
        step = RuntimeBridge._mock.step,
    }
end

return RuntimeBridge
