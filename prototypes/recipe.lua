---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┏┓┳┏┓┏┓
--  ┣┫┣ ┃ ┃┃┃┣
--  ┛┗┗┛┗┛┻┣┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------------------------------------------
-- Checks for presence of item, returns error in log if missing.
local function item_exists(ModName, Item)
    if data.raw.item[Item] ~= nil then
        return true
    else
        log("item with ID \""..Item.."\" from the mod \""..ModName.."\" does not exist!")
        return false
    end
end
---------------------------------------------------------------------------------------------------
-- GREENHOUSE: RECIPE CATEGORIES
---------------------------------------------------------------------------------------------------
local function createRecipeCategory(Variant)
    return {type = "recipe-category", name = PREFIX.."greenhouse-"..Variant.."-recipes" }
end
---------------------------------------------------------------------------------------------------
-- ASSEMBLING MACHINE: GREENHOUSE ENTITIES
---------------------------------------------------------------------------------------------------
-- Recipes for greenhouse variants. Mods may replace iron plates with some variant of glass. The
-- amounts required will reflect the cost of producing that glass.
local function createGreenhouseRecipe(Variant, Order)
    -- Chooses only one glass item name and amount to be used, from among various mods. Ordered so
    -- that smaller mods and mods that modify other mods go first. Special care must be taken with
    -- AAI Industry and Krastorio 2, since the former chooses the glass name of the latter, if both
    -- are present.

    local TreeSeed = SPACE_AGE and "tree-seed" or "wood" -- assumes 1 wood to 1 seed

    local Set  = SETTING.GLEBA_GREENHOUSES_1

    local Soil = {
        ["disabled"]             = "overgrowth", -- value doesn't matter, greenhouse is disabled
        ["with-overgrowth-soil"] = "overgrowth",
        ["with-artificial-soil"] = "artificial"
    }

    local Crop = {
        ["tree"]        = { seed = {TreeSeed,       10}, soil = {"landfill",                  1} },
        ["yumako-tree"] = { seed = {"yumako-seed",   5}, soil = {Soil[Set].."-yumako-soil",   8} },
        ["jellystem"]   = { seed = {"jellynut-seed", 5}, soil = {Soil[Set].."-jellynut-soil", 8} },
        ["slipstack"]   = { seed = {"spoilage",     50}, soil = {"landfill",                  1} },
        ["sunnycomb"]   = { seed = {"spoilage",     50}, soil = {"landfill",                  1} }
    }

    local output = {
        type     = "recipe",
        name     = PREFIX.."greenhouse-for-"..Variant,
        categories = {"crafting"},
        subgroup = SPACE_AGE and "agriculture" or "production-machine",
        order    = (SPACE_AGE and "a" or "g").."[greenhouse]-"..Order.."["..Variant.."]",
        enabled  = false,
        energy_required = nil, -- defined below
        ingredients = {
            { type = "item", name = Crop[Variant].seed[1], amount = Crop[Variant].seed[2] },
            { type = "item", name = Crop[Variant].soil[1], amount = Crop[Variant].soil[2] }
            -- More to be added below
        },
        results = {
            { type = "item", name = PREFIX.."greenhouse-for-"..Variant, amount = 1 }
        }
    }

    local function add_ingr(Name, Amount)
        table.insert(output.ingredients, { type = "item", name = Name ,amount = Amount })
    end

    -- Adds various ingredients and changes energy need depending on mods installed.
    if KRASTORIO2 then
        output.energy_required = 10
        add_ingr("kr-iron-beam",       10)
        add_ingr("kr-automation-core", 10)

    else
        output.energy_required = 5
        add_ingr("steel-plate",         8)
        add_ingr("electronic-circuit",  6)
    end

    -- Adds glass, perhaps from other mods, in a particular order:
    if SETTING.GLASS then
        add_ingr(PREFIX.."glass", 24) -- 100% glass : stone
    -- Glass:
    elseif mods["Glass"] and item_exists("Glass", "glass-plate") then
        add_ingr("glass-plate",   24) -- 100% glass : stone
    -- QuirkyCat Glass, Sand and Clay (and minerals) :
    elseif mods["quirkycat_glass"] and item_exists("quirkycat_glass", "glass") then
        add_ingr("glass",         32) -- 150% glass : stone
    -- Crushing Industry:
    elseif mods["crushing-industry"] and settings.startup["crushing-industry-glass"].value
    and item_exists("crushing-industry", "glass") then
        add_ingr("glass",         20) --  80% glass : stone
    -- Factorio+:
    elseif mods["factorioplus"] and item_exists("factorioplus", "glass-plate") then
        add_ingr("glass-plate",   24) -- 100% glass : stone
    -- AAI Industry (but not Krastorio 2):
    elseif mods["aai-industry"] and not KRASTORIO2 and item_exists("aai-industry", "glass") then
        add_ingr("glass",         12) -- 50% glass : stone
    -- Krastorio 2:
    elseif KRASTORIO2 and item_exists("Krastorio2", "kr-glass") then
        add_ingr("kr-glass",      20) -- 125% glass : stone, but kr-greenhouse uses 20 plates
    -- No glass provided by any recognized source:
    else
        add_ingr("iron-plate",  24)
    end

    return output
end
---------------------------------------------------------------------------------------------------
-- GREENHOUSE: CROP GROWTH RECIPES
---------------------------------------------------------------------------------------------------
-- Recipes for the crops grown by each greenhouse variant.
local function createCropGrowthRecipe(Variant, Order)
    local Icons = {
        ["tree"] =        {{ icon = "__base__/graphics/icons/wood.png"              }},
        ["yumako-tree"] = {{ icon = "__space-age__/graphics/icons/yumako.png"       }},
        ["jellystem"]   = {{ icon = "__space-age__/graphics/icons/jellynut.png"     }},
        ["slipstack"]   = {{ icon = "__base__/graphics/icons/stone.png",
                             scale = 0.300, shift = { 8, 0}, draw_background = true },
                           { icon = "__space-age__/graphics/icons/spoilage.png",
                             scale = 0.300, shift = {-8, 0}, draw_background = true }},
        ["sunnycomb"]   = {{ icon = "__space-age__/graphics/icons/spoilage.png"     }},
    }

    local Subgroup      = SPACE_AGE and "agriculture-processes" or "raw-resource"

    local Results = {
        ["tree"]        = {{ type = "item",  name = "wood",     amount =  5 }},
        ["yumako-tree"] = {{ type = "item",  name = "yumako",   amount =  5 }},
        ["jellystem"]   = {{ type = "item",  name = "jellynut", amount =  5 }},
        ["slipstack"]   = {{ type = "item",  name = "spoilage", amount =  3 },
                           { type = "item",  name = "stone",    amount =  2 }},
        ["sunnycomb"]   = {{ type = "item",  name = "spoilage", amount =  5 }},
    }

    local output = {
        type     = "recipe",
        name     = PREFIX.."greenhouse-"..Variant.."-growth",
        icons    = Icons[Variant],
        categories = {PREFIX.."greenhouse-"..Variant.."-recipes"},
        subgroup = Subgroup,
        order    = "a[greenhouse]-"..Order.."["..Variant.."]",
        enabled  = false,
        energy_required = 5 / SETTING.OUTPUT_RATE[Variant],
        ingredients = {
            { type = "fluid", name = "water", amount = 50 },
        },
        results = Results[Variant],
        always_show_made_in = true
    }
    return output
end
---------------------------------------------------------------------------------------------------
-- FURNACE: BASIC WOOD PYROLYSIS RECIPE
---------------------------------------------------------------------------------------------------
local BasicWoodPyrolysisRecipe = {
    type = "recipe",
    name = PREFIX.."basic-wood-pyrolysis",
    icons = {
        { icon = "__base__/graphics/icons/coal.png",
          scale = 0.500, shift = { 4,  4}, draw_background = true },
        { icon = "__base__/graphics/icons/wood.png",
          scale = 0.275, shift = {-3, -3}, draw_background = true }
    },
    categories = {"smelting"},
    subgroup = "raw-material",
    order    = "a[burning]-a[charcoal]",
    enabled = true, -- Unlocked right from the start.
    energy_required = 6.4, -- 3.2 at double speed (electric furnace)
    ingredients = {
        { type = "item", name = "wood", amount = 8 }
    },
    results = {
        { type = "item", name = "coal", amount = 4 }
    },
    allow_productivity = true
}

---------------------------------------------------------------------------------------------------
-- CHEMICAL PLANT: ADVANCED WOOD PYROLYSIS RECIPE
---------------------------------------------------------------------------------------------------
local AdvancedWoodPyrolysisRecipe = {
    type = "recipe",
    name = PREFIX.."advanced-wood-pyrolysis",
    icons = {
        { icon = "__base__/graphics/icons/fluid/crude-oil.png",
          scale = 0.500, shift = { 4,  4}, draw_background = true },
        { icon = "__base__/graphics/icons/wood.png",
          scale = 0.275, shift = {-3, -3}, draw_background = true }
    },
    categories = {"chemistry", SPACE_AGE and "organic"},
    subgroup = "fluid-recipes",
    order    = "a[fluid]-b[oil]-b[petroleum-gas]",
    enabled = false,
    energy_required = 4.0, -- 2.0 at double speed (biochamber)
    ingredients = {
        { type = "item",  name = "wood",          amount = 15 }
    },
    results = {
        { type = "fluid", name = "crude-oil",     amount = 20, fluidbox_index = 2 },
        { type = "fluid", name = "petroleum-gas", amount = 10, fluidbox_index = 1 },
        { type = "item",  name = "coal",          amount = 4 }
    },
    crafting_machine_tint = {
        primary    = {r = 0.250, g = 0.200, b = 0.250, a = 1.000}, -- Liquid.     1st output color?
        secondary  = {r = 0.100, g = 0.080, b = 0.100, a = 1.000}, -- Foam.       2nd output color?
        tertiary   = {r = 0.875, g = 0.716, b = 0.586, a = 1.000}, -- Outer smoke. 1st input color?
        quaternary = {r = 1.000, g = 0.614, b = 0.280, a = 1.000}  -- Inner smoke. 2nd input color?
    },
    allow_productivity = true,
    maximum_productivity = 1.0 -- max in vanilla: 1.5 (biochamber: 50%, lv5 prod 3: 4x25% )
}

---------------------------------------------------------------------------------------------------
-- SPACE AGE: BIOCHAMBER: ORGANIC WOOD DISTILLATION RECIPE
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
-- ASSEMBLING MACHINE: SAND RECIPE
---------------------------------------------------------------------------------------------------
local sandRecipe = {
    type = "recipe",
    name = PREFIX .. "sand",
    auto_recycle = false,
    energy_required = 0.8,
    ingredients = {
        { type = "item", name = "stone",          amount = 1 }
    },
    results = {
        { type = "item", name = PREFIX .. "sand", amount = 1 }
    },
    allow_productivity = true
}

---------------------------------------------------------------------------------------------------
-- FURNACE: GLASS RECIPE
---------------------------------------------------------------------------------------------------
local glassRecipe =  {
   type = "recipe",
   name = PREFIX .. "glass",
   categories = {"smelting"},
   auto_recycle = false,
   energy_required = 3.2,
   ingredients = {
       { type = "item", name = PREFIX .. "sand",        amount = 1 }
   },
   results = {
       { type = "item", name = PREFIX .. "glass", amount = 1 }
   },
   allow_productivity = true
 }

---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE --
---------------------------------------------------------------------------------------------------
if SETTING.PYROLYSIS == "both-recipes" then
    data:extend({
        BasicWoodPyrolysisRecipe,
        AdvancedWoodPyrolysisRecipe
    })
elseif SETTING.PYROLYSIS == "basic-recipe" then
    data:extend({
        BasicWoodPyrolysisRecipe
    })
elseif SETTING.PYROLYSIS == "advanced-recipe" then
    data:extend({
        AdvancedWoodPyrolysisRecipe
    })
end
if SETTING.GLASS then
    data:extend({
        sandRecipe,
        glassRecipe
    })
end
if SETTING.TREE_GREENHOUSE then
    data:extend({
        createRecipeCategory  ("tree"            ),
        createGreenhouseRecipe("tree",        "a"),
        createCropGrowthRecipe("tree",        "a"),
    })
end
if SPACE_AGE and SETTING.GLEBA_GREENHOUSES_1 ~= "disabled" then
    data:extend({
        createRecipeCategory  ("yumako-tree"     ),
        createGreenhouseRecipe("yumako-tree", "b"),
        createCropGrowthRecipe("yumako-tree", "b"),
        createRecipeCategory  ("jellystem"       ),
        createGreenhouseRecipe("jellystem",   "c"),
        createCropGrowthRecipe("jellystem",   "c"),
    })
end
if SPACE_AGE and SETTING.GLEBA_GREENHOUSES_2 then
    data:extend({
        createRecipeCategory("slipstack"),
        createGreenhouseRecipe("slipstack", "d"),
        createCropGrowthRecipe("slipstack", "d"),
        createRecipeCategory("sunnycomb"),
        createGreenhouseRecipe("sunnycomb", "e"),
        createCropGrowthRecipe("sunnycomb", "e"),
    })
end

---------------------------------------------------------------------------------------------------
-- SPACE AGE: TREE PROCESSING
---------------------------------------------------------------------------------------------------
if SPACE_AGE then
    local seed_rec = data.raw.recipe["tree-seed"]
    -- Reduces cost of wood for the extraction of tree seeds from 2 to 1.
    seed_rec.ingredients = {{type = "item", name = "wood", amount = 1}}
    -- Reduces processing time from 2 to 1, to match similar recipes.
    seed_rec.energy_required = 1
    -- Removes surface condition requirement so tree seeds can be produced anywhere.
    seed_rec.surface_conditions = nil
end
---------------------------------------------------------------------------------------------------
-- END NOTES
---------------------------------------------------------------------------------------------------

-- ENERGY MEASUREMENTS (BEFORE V1.4.0) --

-- Basic pyrolysis:
-- ~3.7% net energy loss.

-- Basic pyrolysis + coal liquefaction + solid fuel making:
-- ~56.5% net energy gain.

-- Advanced pyrolysis + (advanced oil processing & coal liquefaction) + solid fuel making:
-- ~56% net energy gain

-- Coal liquefaction + solid fuel making:
-- ~72.5% net energy gain

-- The advanced setup produces 25.5% more plastic and 22.4% more sulfur than the basic one,
-- if coal is burned in the Boiler to produce steam for coal liquefaction.

-- ENERGY MEASUREMENTS (V1.4.4) --

-- If an electric boiler from a mod provides the steam for coal liquefaction, then the advanced
-- setup produces about 24.5% more petroleum gas, 24.8% more plastic and 25.1% more sulfur than
-- the basic one. Saving on coal favors the basic setup, except when productivity gets very high,
-- then it's the opposite.

---------------------------------------------------------------------------------------------------
