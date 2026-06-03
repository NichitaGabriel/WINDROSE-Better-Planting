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
RuntimeBridge._mock = {
    selection = nil,
    cursor = nil,
    validity = nil,
}

function RuntimeBridge.init(config, log)
    RuntimeBridge._config = config
    RuntimeBridge._log = log
    RuntimeBridge._hooks = {}
    RuntimeBridge._bindings = {}
end

function RuntimeBridge.registerLifecycleHooks(hooks)
    RuntimeBridge._hooks = hooks or {}
end

function RuntimeBridge.registerInputBindings(bindings)
    RuntimeBridge._bindings = bindings or {}
end

function RuntimeBridge.getCurrentSelection()
    return RuntimeBridge._mock.selection
end

function RuntimeBridge.getCursorWorldPosition()
    return RuntimeBridge._mock.cursor
end

function RuntimeBridge.queryPlacementValidity(worldPos, plantType)
    if type(RuntimeBridge._mock.validity) == "function" then
        return RuntimeBridge._mock.validity(worldPos, plantType)
    end

    return nil, "Runtime validity query not implemented"
end

function RuntimeBridge.describeCapabilities()
    return {
        selection = false,
        placement_cursor = false,
        preview_rendering = false,
        placement_validation = false,
        input_binding = false,
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
end

function RuntimeBridge.setMockCursorWorldPosition(worldPos)
    RuntimeBridge._mock.cursor = worldPos
end

function RuntimeBridge.setMockValidityHandler(handler)
    RuntimeBridge._mock.validity = handler
end

return RuntimeBridge
