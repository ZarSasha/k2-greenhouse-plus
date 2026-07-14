---------------------------------------------------------------------------------------------------
--  ┏┓┳┓┏┳┓┳┏┳┓┓┏
--  ┣ ┃┃ ┃ ┃ ┃ ┗┫
--  ┗┛┛┗ ┻ ┻ ┻ ┗┛
---------------------------------------------------------------------------------------------------
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds      = require("__base__.prototypes.entity.sounds")
---------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------------------------------------------
-- Create pipe connections.
local function dir(d, p) return
    { flow_direction="input-output", direction = defines.direction[d], position = p }
end
-- Specify surface conditions.
local function cond(Property, Min, Max) return
    {property = Property, min = Min, max = Max}
end
-- Create circuit wire connections.
local cn = { variation = 18, main_offset = util.by_pixel(27, 22),
             shadow_offset = util.by_pixel(38, 28), show_shadow = true }
circuit_connector_definitions["k2gp-greenhouse"] = circuit_connector_definitions.create_vector(
    universal_connector_template, { cn, cn, cn, cn }
)
---------------------------------------------------------------------------------------------------
-- GREENHOUSES: WOOD, YUMAKO & JELLYNUT
---------------------------------------------------------------------------------------------------
local function createGreenhouse(Variant)
    -- GRAPHICS --
    local GraphicsGreenhouse = {
        filename = ASSETS_ENTITY.."greenhouse-"..Variant..".png",
        width = 512, height = 512, scale = 0.5
    }
    local GraphicsGreenhouseShadow = {
        filename = ASSETS_ENTITY.."greenhouse-shadow.png",
        width = 512, height = 512, scale = 0.5,
        shift = { 0.32, 0 }, draw_as_shadow = true
    }
    local GraphicsGreenhouseLight = {
        filename = ASSETS_ENTITY.."greenhouse-light.png",
        width = 512, height = 512, scale = 0.5, draw_as_light = true
    }
    local GraphicsGreenhouseWorking = {
        filename = ASSETS_ENTITY.."greenhouse-"..Variant.."-working.png",
        width = 512, height = 512, scale = 0.5
    }
    -- AUXILIARY TABLES --
    local Emissions = {
        ["tree"]        = {pollution = -1.125}, -- Same as 37.5/2 trees.
        ["yumako-tree"] = {spores = 19.5 * SETTING.OUTPUT_RATE["yumako-tree"]},
        ["jellystem"]   = {spores = 19.5 * SETTING.OUTPUT_RATE["jellystem"]  }
    }
    local Conditions = {
        ["tree"]        = {cond("solar-power",  50, 100), cond("pressure", 1000, 2000)}, -- Nauvis, Gleba
        ["yumako-tree"] = {cond("solar-power",  50,  50), cond("pressure", 2000, 2000)}, -- Gleba
        ["jellystem"]   = {cond("solar-power",  50,  50), cond("pressure", 2000, 2000)}, -- Gleba
        ["slipstack"]   = {cond("solar-power",  50,  50), cond("pressure", 2000, 2000)}, -- Gleba
        ["sunnycomb"]   = {cond("solar-power",  50,  50), cond("pressure", 2000, 2000)}, -- Gleba
    }
    -- MAIN TABLE --
    local output = {
        type = "assembling-machine",
        name = PREFIX.."greenhouse-for-"..Variant,
        icon = ASSETS_ICON.."greenhouse-"..Variant.."-icon.png",
        icon_size = 64,
        icon_draw_specification = {scale = 2, shift = {0, -0.2}},
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        minable = {mining_time = 0.3, result = PREFIX.."greenhouse-for-"..Variant},
        fast_replaceable_group = "k2-greenhouse",
        max_health = 500,
        corpse = PREFIX.."greenhouse-remnants",
        dying_explosion = PREFIX.."greenhouse-explosion",
        impact_category = "metal-large",
        damaged_trigger_effect = hit_effects.entity(),
        collision_box = {{-3.1, -3.1},{ 3.1, 3.1}},
        selection_box = {{-3.5, -3.5},{ 3.5, 3.5}},
        energy_source = {
            type = "electric",
            usage_priority = "secondary-input",
            emissions_per_minute = Emissions[Variant],
            drain = "0kW"
        },
        energy_usage = "25kW",
        crafting_speed = 1,
        crafting_categories = {PREFIX.."greenhouse-"..Variant.."-recipes"},
        module_slots = SETTING.MODULE_SLOTS,                 -- Beacons only work when there
        allowed_module_categories = {"speed", "efficiency"}, -- is at least one module slot.
        allowed_effects = {"consumption", "speed"},
        fixed_recipe = PREFIX.."greenhouse-"..Variant.."-growth",
        fluid_boxes_off_when_no_fluid_recipe = false,
        fluid_boxes = {{
            production_type = "input",
            pipe_covers = pipecoverspictures(),
            volume = 200,
            pipe_connections = {
                dir("north",{ 0,-3}), dir("east", { 3, 0}),
                dir("south",{ 0, 3}), dir("west", {-3, 0})
            }
        }},
        circuit_connector = circuit_connector_definitions["k2gp-greenhouse"],
        circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
        graphics_set = {
            animation = {layers = {GraphicsGreenhouse, GraphicsGreenhouseShadow}},
            working_visualisations = {
                {animation = GraphicsGreenhouseWorking},
                {animation = GraphicsGreenhouseLight},
            }
        },
        open_sound = sounds.metal_large_open,
        close_sound = sounds.metal_large_close
    }
    if SPACE_AGE then
        output.surface_conditions = Conditions[Variant]
        table.insert(output.allowed_module_categories, "quality")
        table.insert(output.allowed_effects, "quality")
    end
    return output
end
---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
if SETTING.TREE_GREENHOUSE then
    data:extend({
        createGreenhouse("tree")
    })
end
if SPACE_AGE and SETTING.GLEBA_GREENHOUSES_1 ~= "disabled" then
    data:extend({
        createGreenhouse("yumako-tree"),
        createGreenhouse("jellystem")
    })
end
if SPACE_AGE and SETTING.GLEBA_GREENHOUSES_2 then
    data:extend({
        createGreenhouse("slipstack"),
        createGreenhouse("sunnycomb")
    })
end
---------------------------------------------------------------------------------------------------
