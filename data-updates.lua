---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┏┳┓┏┓  ┳┳┏┓┳┓┏┓┏┳┓┏┓┏┓
--  ┃┃┣┫ ┃ ┣┫━━┃┃┃┃┃┃┣┫ ┃ ┣ ┗┓
--  ┻┛┛┗ ┻ ┛┗  ┗┛┣┛┻┛┛┗ ┻ ┗┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- COMPATIBILITY FOR ARIG + ANY PLANET START
---------------------------------------------------------------------------------------------------
-- Re-adds missing recipe.

if ENABLED.DISTILLATION and mods["planetaris-arig"] and mods["any-planet-start"]
and settings.startup["aps-planet"].value == "arig" then
    table.insert(data.raw.technology["oil-processing"].effects, 3, {
        type = "unlock-recipe", recipe = PREFIX.."wood-distillation"
    })
end

---------------------------------------------------------------------------------------------------
-- COMPATIBILITY FOR SIMPLE SEABLOCK & BOB'S ORES
---------------------------------------------------------------------------------------------------
if mods["SimpleSeablock"] then
    -- The mod applies a 20x energy bonus multiplier to its charcoal recipe to compensate for low
    -- yield from trees grown with an agricultural tower (net output of 9.2 wood/min from a 21x21
    -- area, with 46 active "fields" and half of the output diverted to seed extraction). The
    -- greenhouse (net output of 30 wood/min * (441 tiles / 61.25 tiles) = 216 wood/min from the
    -- same area is already ~23.5x as efficient (no less than ~22.3x when accounting for power
    -- consumption), so it's better to just disable that recipe. Then the pyrolysis recipes won't
    -- have to be adapted or disabled depending on settings. Making charcoal will require more
    -- machines and more energy, but there is really no issue with that.

    -- The greenhouse is plenty powerful, so this nerfs the charcoal recipe and increases its
    -- crafting time to match the carbonization recipe from this mod.
    local wood_to_coal = data.raw.recipe["wood-to-coal"]
    wood_to_coal.energy_required = 6.4 * (20/8)
    wood_to_coal.ingredients = {{type = "item", name = "wood", amount = 20}}

    -- Hides and disables own recipe.
    local carbonization = data.raw.recipe[PREFIX.."wood-carbonization"]
    if carbonization ~= nil then
        carbonization.enabled = false
        carbonization.hidden = true
    end

    -- Reduces cost of researching greenhouse tech.
    local greenhouse_tech = data.raw.technology[PREFIX.."greenhouse-tech"]
    greenhouse_tech.unit.count = 30
    greenhouse_tech.unit.time  =  5

    -- Increases growth speed and wood yield of the growable Nauvis tree by a factor of 15x.
    -- (This mod also halves cost of seed extraction, so this is enough to make up for the
    -- 20x charcoal bonus multiplier that was nerfed. The default output for the greenouse is
    -- also nearly perfectly balanced already.)
    local tree_plant = data.raw.plant["tree-plant"]
    tree_plant.growth_ticks = 60 * 60 * 5 -- default: 10 minutes.
    for _, result in pairs(tree_plant.minable.results) do
        if result.name == "wood" then
            result.amount = 30 -- default: 4
        end
    end

    -- Allows virtually unlimited productivity bonuses for distillation recipes.
    local distillation_1 = data.raw.recipe[PREFIX.."wood-distillation"]
    distillation_1.maximum_productivity = 9999
    local distillation_2 = data.raw.recipe[PREFIX.."wood-distillation-enhanced"]
    distillation_2.maximum_productivity = 9999

    -- Applies up to 10 levels of 10% mining productivity bonus to a recipe.
    local function addMiningProductivity(recipe, pos)
        for i = 1, 10 do
            local miningProductivity = data.raw.technology["mining-productivity-" .. tostring(i)]
            if miningProductivity == nil then break end -- no more to go through
            table.insert(miningProductivity.effects, pos, {
                type = "change-recipe-productivity", recipe = recipe, change = 0.1
            })
        end
    end

    -- Makes distillation recipes benefit from mining productivity, up to 100% from 10 levels.
    addMiningProductivity(PREFIX.."wood-distillation", 2)
    addMiningProductivity(PREFIX.."wood-distillation-enhanced", 3)

    --- ADDITIONAL COMPATIBILITY FOR BOB'S ORES ---

    -- Allows distillation recipes to also yield diamonds if Bob Ores is configured to yield gems
    -- from non-gem ores.
    if mods["bobores"] and settings.startup["bobmods-ores-gemsfromotherores"].value then
        local diamonds =
            settings.startup["bobmods-ores-gemprobability"].value * -- default: 0.05
            settings.startup["bobmods-gems-diamondratio"].value *   -- default: 0.2
            (15/2) -- recipe takes 15 wood, the equivalent of 7.5 coal
        if diamonds > 0 and diamonds <= 1 then
            table.insert(distillation_1.results, {
                type = "item", name = "bob-diamond-ore", amount = 1,
                independent_probability = RoundNumber(diamonds, 5)
            })
            table.insert(distillation_2.results, {
                type = "item", name = "bob-diamond-ore", amount = 1,
                independent_probability = RoundNumber(diamonds, 5)
            })
        elseif diamonds > 1 then
            local diamonds_integer = math.floor(diamonds)
            local diamonds_fraction = diamonds - diamonds_integer
            table.insert(distillation_1.results, {
                type = "item", name = "bob-diamond-ore", amount = diamonds_integer,
                extra_count_fraction = RoundNumber(diamonds_fraction, 5)
            })
            table.insert(distillation_2.results, {
                type = "item", name = "bob-diamond-ore", amount = diamonds_integer,
                extra_count_fraction = RoundNumber(diamonds_fraction, 5)
            })
        end
    end
end

---------------------------------------------------------------------------------------------------
