-- WINDROSE Better Planting
-- src/config.lua
--
-- Embedded configuration helpers for the prototype phase.
-- The repository keeps a JSON config file for documentation and packaging
-- intent, but this Lua module also provides embedded defaults so the
-- prototype can boot without assuming a JSON parser is already available in
-- the target runtime.

local Config = {}

local function deepcopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, child in pairs(value) do
        copy[key] = deepcopy(child)
    end
    return copy
end

local function deepmerge(base, overrides)
    if type(overrides) ~= "table" then
        return overrides
    end

    local merged = deepcopy(base)
    for key, value in pairs(overrides) do
        if type(value) == "table" and type(merged[key]) == "table" then
            merged[key] = deepmerge(merged[key], value)
        else
            merged[key] = deepcopy(value)
        end
    end

    return merged
end

Config._loader = nil

Config._defaults = {
    enabled = true,
    mode = "both",
    prototype = {
        objective = "When a planting-compatible item is selected, compute and expose one snapped candidate position based on configurable spacing.",
        runtime_shape = "UE4SS-oriented Lua vertical slice",
        startup_signal = "WINDROSE-Better-Planting vertical slice loaded",
        default_active_mode = "snap",
        allow_mock_bridge = true,
        min_spacing = 0.5,
        log_state_transitions = true,
        mock = {
            enabled = true,
            selection = "debug_crop_seed",
            anchor = {
                x = 2.25,
                y = 0.0,
                z = 4.75,
            },
            anchor_step = 1.0,
        },
    },
    debug = {
        enabled = true,
        log_level = "debug",
        log_preview_cells = false,
    },
    snap = {
        enabled = true,
        spacing = 2.0,
        indicator_color = "#00FF88",
        indicator_opacity = 0.75,
        show_indicator = true,
    },
    grid = {
        enabled = true,
        rows = 3,
        cols = 3,
        spacing = 2.0,
        rotation_step_deg = 45,
        valid_color = "#00FF44",
        invalid_color = "#FF3333",
        cell_opacity = 0.55,
        show_grid_lines = true,
        grid_line_color = "#FFFFFF",
        grid_line_opacity = 0.25,
    },
    presets = {
        crops = {
            spacing = 2.0,
            rows = 4,
            cols = 4,
            rotation_step_deg = 90,
        },
        trees = {
            spacing = 3.5,
            rows = 3,
            cols = 3,
            rotation_step_deg = 45,
        },
        dense_crops = {
            spacing = 1.5,
            rows = 5,
            cols = 5,
            rotation_step_deg = 90,
        },
        orchard = {
            spacing = 4.0,
            rows = 2,
            cols = 5,
            rotation_step_deg = 0,
        },
    },
    active_preset = "crops",
    hotkeys = {
        toggle_mod = "F8",
        toggle_mode = "F9",
        mock_anchor_forward = "Up",
        mock_anchor_backward = "Down",
        mock_anchor_left = "Left",
        mock_anchor_right = "Right",
        reset_mock_anchor = "Home",
        increase_rows = "NumpadPlus",
        decrease_rows = "NumpadMinus",
        increase_cols = "RightBracket",
        decrease_cols = "LeftBracket",
        increase_spacing = "Equals",
        decrease_spacing = "Minus",
        rotate_cw = "Period",
        rotate_ccw = "Comma",
        confirm_placement = "MouseButton1",
        cancel = "Escape",
        open_settings = "F10",
    },
    preview = {
        show_hud = true,
        hud_position = "top_left",
        hud_opacity = 0.85,
        hud_font_size = 14,
        cell_shape = "circle",
        cell_radius = 0.4,
        highlight_anchor_cell = true,
        anchor_color = "#FFFF00",
    },
}

function Config.setLoader(loader)
    Config._loader = loader
end

function Config.getDefaults()
    return deepcopy(Config._defaults)
end

function Config.load(path)
    local config = Config.getDefaults()

    if not Config._loader then
        return config
    end

    local ok, overrides = pcall(Config._loader, path)
    if not ok or type(overrides) ~= "table" then
        return config
    end

    return deepmerge(config, overrides)
end

function Config.getPresetForPlant(config, plantType)
    local lower = type(plantType) == "string" and string.lower(plantType) or ""

    if lower:find("tree", 1, true) or lower:find("sapling", 1, true) then
        return deepmerge(config.grid, config.presets.trees or {})
    end

    return deepmerge(config.grid, config.presets[config.active_preset] or config.presets.crops or {})
end

function Config.getInitialMode(config)
    if config.mode == "snap" or config.mode == "grid" then
        return config.mode
    end

    return config.prototype.default_active_mode or "snap"
end

function Config.modeAllows(config, activeMode, feature)
    -- When config.mode is "both", activeMode represents the currently selected
    -- preview mode within this prototype scaffold ("snap" or "grid").
    if feature == "snap" then
        return config.snap.enabled and (config.mode == "snap" or activeMode == "snap")
    end

    if feature == "grid" then
        return config.grid.enabled and (config.mode == "grid" or activeMode == "grid")
    end

    return false
end

function Config.cycleMode(config, activeMode)
    if config.mode ~= "both" then
        return Config.getInitialMode(config)
    end

    if activeMode == "snap" then
        return "grid"
    end

    return "snap"
end

return Config
