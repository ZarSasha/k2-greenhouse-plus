---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┏┓┳┏┓┏┓
--  ┣┫┣ ┃ ┃┃┃┣
--  ┛┗┗┛┗┛┻┣┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- GREENHOUSE: RECIPE CATEGORIES
---------------------------------------------------------------------------------------------------
local function createRecipeCategory(Variant)
    return {type = "recipe-category", name = PREFIX.."greenhouse-"..Variant.."-recipes" }
end

---------------------------------------------------------------------------------------------------
-- ASSEMBLING MACHINE: GREENHOUSE ENTITIES
---------------------------------------------------------------------------------------------------
-- Creates recipes for greenhouse variants.
local function createGreenhouseRecipe(Variant, Order)
    local ModOrder = (KRASTORIO2 and "d-g3") or (SPACE_AGE and "a") or "g"
    -- Main prototype table:
    local output = {
        type     = "recipe",
        name     = PREFIX.."greenhouse-for-"..Variant,
        categories = {"crafting"},
        subgroup = SPACE_AGE and "agriculture" or "production-machine",
        order    = ModOrder.."[greenhouse]-"..Order.."["..Variant.."]",
        enabled  = false,
        energy_required = nil, -- defined below
        ingredients = {}, -- filled below
        results = {
            { type = "item", name = PREFIX.."greenhouse-for-"..Variant, amount = 1 }
        },
        sort_item_ingredients = false
    }

    -- Helper function to add ingredients to recipe:
    local function add_ingr(Position, Name, Amount)
        table.insert(output.ingredients, Position, { type = "item", name = Name ,amount = Amount })
    end

    -- Adds various ingredients and changes energy need depending on mods installed.
    if KRASTORIO2 then
        output.energy_required = 10
        add_ingr(1, "kr-iron-beam",       10)
        add_ingr(3, "kr-automation-core", 10)
    else
        output.energy_required = 5
        add_ingr(1, "steel-plate",         8)
        add_ingr(3, "electronic-circuit",  6)
    end

    -- Chooses only one glass item name and amount to be used, from among various mods. Ordered so
    -- that smaller mods and mods that modify other mods go first. Special care must be taken with
    -- AAI Industry and Krastorio 2, since the former chooses the glass name of the latter, if both
    -- are present.
    if ENABLED.GLASS then
        add_ingr(2, PREFIX.."glass", 24) -- 100% glass : stone
    -- Glass:
    elseif mods["Glass"] and ItemExists("Glass", "glass-plate") then
        add_ingr(2, "glass-plate",   24) -- 100% glass : stone
    -- QuirkyCat Glass, Sand and Clay (and minerals) :
    elseif mods["quirkycat_glass"] and ItemExists("quirkycat_glass", "glass") then
        add_ingr(2, "glass",         32) -- 150% glass : stone
    -- Crushing Industry:
    elseif mods["crushing-industry"] and settings.startup["crushing-industry-glass"].value
    and ItemExists("crushing-industry", "glass") then
        add_ingr(2, "glass",         20) --  80% glass : stone
    -- Factorio+:
    elseif mods["factorioplus"] and ItemExists("factorioplus", "glass-plate") then
        add_ingr(2, "glass-plate",   24) -- 100% glass : stone
    -- Bob's Metals, Chemicals and Intermediates:
    elseif mods["bobplates"] and ItemExists("bobplates", "bob-glass") then
        add_ingr(2, "bob-glass",     24) -- made from quartz resource
    -- AAI Industry (but not Krastorio 2):
    elseif mods["aai-industry"] and not KRASTORIO2 and ItemExists("aai-industry", "glass") then
        add_ingr(2, "glass",         12) -- 50% glass : stone
    -- Krastorio 2:
    elseif KRASTORIO2 and ItemExists("Krastorio2", "kr-glass") then
        add_ingr(2, "kr-glass",      20) -- 125% glass : stone, but kr-greenhouse uses 20 plates
    -- No glass provided by any recognized source:
    else
        add_ingr(2, "iron-plate",    24)
    end

    -- Adds seeds and bed to recipe:
    local TreeSeed = SPACE_AGE and {"tree-seed", 10} or {"wood", 10}
    local Landfill = KRASTORIO2 and {"stone", 25} or {"landfill", 1}
    local Seed = {
        ["tree"]        = TreeSeed,
        ["yumako-tree"] = {"yumako-seed",    5},
        ["jellystem"]   = {"jellynut-seed",  5},
        ["slipstack"]   = {"spoilage",      25},
        ["sunnycomb"]   = {"spoilage",      25}
    }
    local Bed = {
        ["tree"]        = Landfill,
        ["yumako-tree"] = {"artificial-yumako-soil",   1},
        ["jellystem"]   = {"artificial-jellynut-soil", 1},
        ["slipstack"]   = Landfill,
        ["sunnycomb"]   = Landfill
    }
    add_ingr(4, Seed[Variant][1], Seed[Variant][2])
    add_ingr(5, Bed[Variant][1],  Bed[Variant][2] )

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
-- FURNACE: WOOD CARBONIZATION RECIPE
---------------------------------------------------------------------------------------------------
local WoodCarbonizationRecipe = {
    type = "recipe",
    name = PREFIX.."wood-carbonization",
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
-- CHEMICAL PLANT: WOOD DISTILLATION RECIPE
---------------------------------------------------------------------------------------------------
local WoodDistillationRecipe = {
    type = "recipe",
    name = PREFIX.."wood-distillation",
    icons = {
        { icon = "__base__/graphics/icons/fluid/crude-oil.png",
          scale = 0.500, shift = { 4,  4}, draw_background = true },
        { icon = "__base__/graphics/icons/wood.png",
          scale = 0.275, shift = {-3, -3}, draw_background = true }
    },
    categories = {"chemistry"},
    subgroup = "fluid-recipes",
    order    = "a[distillation-of-wood]",
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
    allow_productivity = true
}

---------------------------------------------------------------------------------------------------
-- BIOCHAMBER: ENHANCED WOOD DISTILLATION RECIPE
---------------------------------------------------------------------------------------------------
local EnhancedWoodDistillationRecipe = {
    type = "recipe",
    name = PREFIX.."wood-distillation-enhanced",
    icons = {
        { icon = "__base__/graphics/icons/fluid/crude-oil.png",
          scale = 0.500, shift = { 4,  4}, draw_background = true },
        { icon = "__base__/graphics/icons/wood.png",
          scale = 0.275, shift = {-3, -3}, draw_background = true }
    },
    categories = {"organic"},
    subgroup = "agriculture-products",
    order    = "a[distillation-of-wood]",
    enabled = false,
    energy_required = 4.0, -- 2.0 at double speed (biochamber)
    ingredients = {
        { type = "item",  name = "wood",          amount = 15 }
    },
    results = {
        { type = "fluid", name = "crude-oil",     amount = 20, fluidbox_index = 2 },
        { type = "fluid", name = "petroleum-gas", amount =  5, fluidbox_index = 1 },
        { type = "item",  name = "coal",          amount =  3 }
    },
    crafting_machine_tint = {
        primary    = {r = 0.250, g = 0.200, b = 0.250, a = 1.000}, -- Liquid.     1st output color?
        secondary  = {r = 0.100, g = 0.080, b = 0.100, a = 1.000}  -- Foam.       2nd output color?
    },
    allow_productivity = true
}

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
       { type = "item", name = PREFIX .. "sand",  amount = 1 }
   },
   results = {
       { type = "item", name = PREFIX .. "glass", amount = 1 }
   },
   allow_productivity = true
 }

---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE --
---------------------------------------------------------------------------------------------------
if ENABLED.GLASS then data:extend({
    sandRecipe,
    glassRecipe
}) end
if ENABLED.TREE_GREENHOUSE then data:extend({
    createRecipeCategory  ("tree"            ),
    createGreenhouseRecipe("tree",        "a"),
    createCropGrowthRecipe("tree",        "a"),
}) end
if SPACE_AGE and ENABLED.MAIN_GLEBA_GREENHOUSES then data:extend({
    createRecipeCategory  ("yumako-tree"     ),
    createGreenhouseRecipe("yumako-tree", "b"),
    createCropGrowthRecipe("yumako-tree", "b"),
    createRecipeCategory  ("jellystem"       ),
    createGreenhouseRecipe("jellystem",   "c"),
    createCropGrowthRecipe("jellystem",   "c"),
}) end
if SPACE_AGE and ENABLED.OTHER_GLEBA_GREENHOUSES then data:extend({
    createRecipeCategory("slipstack"),
    createGreenhouseRecipe("slipstack", "d"),
    createCropGrowthRecipe("slipstack", "d"),
    createRecipeCategory("sunnycomb"),
    createGreenhouseRecipe("sunnycomb", "e"),
    createCropGrowthRecipe("sunnycomb", "e"),
}) end
if ENABLED.CARBONIZATION then data:extend({
    WoodCarbonizationRecipe
}) end
if ENABLED.DISTILLATION then data:extend({
    WoodDistillationRecipe
}) end
if SPACE_AGE and ENABLED.ENHANCED_DISTILLATION then data:extend({
    EnhancedWoodDistillationRecipe
}) end

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

-- ENERGY MEASUREMENTS (v1.5.0) --

-- Measurement: Does not account for idle consumption, which is very minor.

-- Machines: An electric boiler is used for the production of steam.

-- Recipes: Carbonization turns 2 wood into 1 coal. Distillation turns 15 wood into 20 crude oil,
-- 10 petgas amd 4 coal. Enhanced distillation turns 15 wood into 20 crude oil, 5 petgas and 3
-- coal (technically inferior, but gets to benefit from 50% prod. bonus).

-- Total energy gained, accounting for normal machine consumption:
--   Coal production:
--     Carbonization:         ~3.7% energy loss
--   Solid fuel production:
--     Carbonization chain:  ~56.8% energy gain
--     Distillation chain:   ~69.5% energy gain
--     - With biochamber:   ~105.8% energy gain (roughly accounting for nutrients)

-- Conclusion: At the first stage of merely converting all products into solid fuel that can be
-- consumed for energy, distillation normally has just a small advantage, but the new biochamber
-- recipe still increases it quite a lot. I will just accept this, because it is a less important
-- balance issue.

-- Distillation/carbonization output yield ratios with chemical plants:
--                  --Normal--      --Lv5-Tier3 prod.--
--   Solid fuel:     ~104.2%         ~116.1%
--   Petroleum:      ~123.8%         ~103.1%
--   Plastic:        ~124.0%         ~103.1%

-- Conclusion: With higher levels of productivity, the advantage that distillation holds in regards
-- to solid fuel slowly compounds. But the much greater advantage in relation to petgas and plastic
-- is fairly quickly lost, due to less cracking. An outright reversal has only been prevented with
-- the recent balance change in v1.4.6.

-- In Space Age, the tendencies above are exacerbated by the 50% productivity bonus from the
-- biochamber, because it can be applied to cracking, and this even flips things on their head.
-- To prevent it, a distillation recipe was created for the biochamber, carefully balanced to not
-- increase the solid fuel advantage too much, but still keep the advantage in regards to petgas
-- and plastic within a reasonable range.

-- Distillation/carbonization output ratios with biochambers:
--                  --Normal--      --Lv5-Tier3 prod.--
--   Solid fuel:     ~127.9%         ~137.9%
--   Petroleum:      ~119.5%	     ~106.5%
--   Plastic:        ~119.6%	     ~105.6%

-- Conclusion: The solid fuel advantage continues to compound slowly, but the distillation chain
-- gets a boost that won't be lost even as the productivity bonuses reach their maximum level.

-- NB: Infrastructure, space and energy cost for distillation is generally lower as well.

---------------------------------------------------------------------------------------------------
