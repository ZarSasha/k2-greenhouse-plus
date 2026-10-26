---------------------------------------------------------------------------------------------------
--  ┳┳┓┏┓┳┓  ┏┓┏┓┳┳┓┏┓┏┓┏┳┓┳┳┓┳┓ ┳┏┳┓┓┏
--  ┃┃┃┃┃┃┃  ┃ ┃┃┃┃┃┃┃┣┫ ┃ ┃┣┫┃┃ ┃ ┃ ┗┫
--  ┛ ┗┗┛┻┛  ┗┛┗┛┛ ┗┣┛┛┗ ┻ ┻┻┛┻┗┛┻ ┻ ┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- COMPATIBILITY FOR SIMPLE SEABLOCK & BOB'S ORES
---------------------------------------------------------------------------------------------------
-- The mod applies a 20x energy bonus multiplier to its charcoal recipe to compensate for low yield
-- from trees grown with an agricultural tower (net output of 9.2 wood/min from a 21x21 area, with
-- 46 active "fields" and half of the output diverted to seed extraction). The greenhouse (net
-- output of 30 wood/min * (441 tiles / 61.25 tiles) = 216 wood/min from the same area is already
-- ~23.5x as efficient (no less than ~22.3x when accounting for power consumption), so it's better
-- to just disable that recipe. Then the pyrolysis recipes won't have to be adapted or disabled
-- depending on settings. Making charcoal will require more machines and more energy, but there is
-- really no issue with that.

if not mods["SimpleSeablock"] then return end

local function unlock(Recipe) return {type = "unlock-recipe", recipe = Recipe} end

--- GREENHOUSE TECH ---

-- Reduces cost of researching greenhouse tech to match of the agricultural tower.
local greenhouse_tech = data.raw.technology[PREFIX.."greenhouse-tech"]
if greenhouse_tech ~= nil then
    greenhouse_tech.unit.count = 30
    greenhouse_tech.unit.time  =  5
end

--- UNLOCKING OF OTHER GLEBA GREENHOUSES ---

if ENABLED.OTHER_GLEBA_GREENHOUSES then
    local agri_tech = data.raw.technology["agriculture"]
    if agri_tech ~= nil then
        RemoveRecipeUnlockFromTech(agri_tech, PREFIX.."greenhouse-for-slipstack"   )
        RemoveRecipeUnlockFromTech(agri_tech, PREFIX.."greenhouse-slipstack-growth")
        RemoveRecipeUnlockFromTech(agri_tech, PREFIX.."greenhouse-for-sunnycomb"   )
        RemoveRecipeUnlockFromTech(agri_tech, PREFIX.."greenhouse-sunnycomb-growth")
    end
    local gleba_discovery = data.raw.technology["planet-discovery-gleba"]
    if gleba_discovery ~= nil then
        table.insert(gleba_discovery.effects, unlock(PREFIX.."greenhouse-for-slipstack"   ))
        table.insert(gleba_discovery.effects, unlock(PREFIX.."greenhouse-slipstack-growth"))
        table.insert(gleba_discovery.effects, unlock(PREFIX.."greenhouse-for-sunnycomb"   ))
        table.insert(gleba_discovery.effects, unlock(PREFIX.."greenhouse-sunnycomb-growth"))
    end
end

--- CHARCOAL RECIPE ---

-- Increases smelting time for the charcoal recipe a bit.
local wood_to_coal = data.raw.recipe["wood-to-coal"]
wood_to_coal.energy_required = 4.0 -- was 3.2

-- Hides and disables the carbonization recipe of this mod.
if ENABLED.CARBONIZATION then
    local carbonization = data.raw.recipe[PREFIX.."wood-carbonization"]
    carbonization.enabled = false
    carbonization.hidden = true
end

--- DISTILLATION RECIPES ---

if ENABLED.DISTILLATION then

    -- Helper function: Applies up to 10 levels of 10% mining productivity bonus to a recipe.
    local function addMiningProductivity(recipe, pos)
        for i = 1, 10 do
            local miningProductivity = data.raw.technology["mining-productivity-"..tostring(i)]
            if miningProductivity == nil then break end -- no more to go through
            table.insert(miningProductivity.effects, pos, {
                type = "change-recipe-productivity", recipe = recipe, change = 0.1
            })
        end
    end

    -- Adjusts distillation recipe so it takes longer and gets a 20x bonus.
    local distillation_1 = data.raw.recipe[PREFIX.."wood-distillation"]
    distillation_1.energy_required = 8
    distillation_1.ingredients = {
        { type = "item",  name = "wood",          amount = 15 / 5 }
    }
    distillation_1.results = {
        { type = "fluid", name = "crude-oil",     amount = 20 * 4, fluidbox_index = 2 },
        { type = "fluid", name = "petroleum-gas", amount = 10 * 4, fluidbox_index = 1 },
        { type = "item",  name = "coal",          amount =  4 * 4 }
    }
    distillation_1.maximum_productivity = 9999
    addMiningProductivity(distillation_1, 2)

    -- Adjusts enhanced distillation recipe so it takes longer and gets a 20x bonus.
    local distillation_2 = data.raw.recipe[PREFIX.."wood-distillation-enhanced"]
    distillation_2.energy_required = 8
    distillation_2.ingredients = {
        { type = "item",  name = "wood",          amount = 15 / 5 }
    }
    distillation_2.results = {
        { type = "fluid", name = "crude-oil",     amount = 20 * 4, fluidbox_index = 2 },
        { type = "fluid", name = "petroleum-gas", amount =  5 * 4, fluidbox_index = 1 },
        { type = "item",  name = "coal",          amount =  3 * 4}
    }
    distillation_2.maximum_productivity = 9999
    addMiningProductivity(distillation_2, 3)

    --- ADDITIONAL COMPATIBILITY FOR BOB'S ORES ---

    -- Allows distillation recipes to also yield diamonds (a maximum of 1 pr. wood) if Bob Ores is
    -- configured to yield gems from non-gem ores.
    if mods["bobores"] and settings.startup["bobmods-ores-gemsfromotherores"].value then
        local diamonds =
            settings.startup["bobmods-ores-gemprobability"].value * -- default: 0.05
            settings.startup["bobmods-gems-diamondratio"].value *   -- default: 0.2
            3 -- Recipes require 3 wood
        table.insert(distillation_1.results, {
            type = "item", name = "bob-diamond-ore", amount = 1,
            independent_probability = math.min(RoundNumber(diamonds, 5),1)
        })
        table.insert(distillation_2.results, {
            type = "item", name = "bob-diamond-ore", amount = 1,
            independent_probability = math.min(RoundNumber(diamonds, 5),1)
        })
    end
end

---------------------------------------------------------------------------------------------------
