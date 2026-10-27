---------------------------------------------------------------------------------------------------
--  ┳┳┓┏┓┳┓  ┏┓┏┓┳┳┓┏┓┏┓┏┳┓┳┳┓┳┓ ┳┏┳┓┓┏
--  ┃┃┃┃┃┃┃  ┃ ┃┃┃┃┃┃┃┣┫ ┃ ┃┣┫┃┃ ┃ ┃ ┗┫
--  ┛ ┗┗┛┻┛  ┗┛┗┛┛ ┗┣┛┛┗ ┻ ┻┻┛┻┗┛┻ ┻ ┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- COMPATIBILITY FOR SIMPLE SEABLOCK & BOB'S ORES
---------------------------------------------------------------------------------------------------
-- The Simple Seablock mod applies a 20x bonus multiplier to the yield of charcoal burning to
-- compensate for low yields from trees grown with the agricultural tower (they deliver an output
-- of 9.2 wood/min from 46 active "fields" and recycling of seeds). This code just applies that
-- bonus to trees instead and adjusts recipes accordingly. The default output of the greenhouse
-- (0.5 wood/s) doesn't really need to change, because they output 30 wood/min * (441 tiles / 61.25
-- tiles) = 216 wood/min from the same 21x21 area, which is ~23.5x as efficient (no less than
-- ~22.3x when accounting for power consumption). Making charcoal will require more machines and
-- more energy, but there is really no issue with that.

if not mods["SimpleSeablock"] then return end

--- HELPER FUNCTIONS ---

-- Adds recipe to be unlocked with tech.
local function unlock(Recipe) return {type = "unlock-recipe", recipe = Recipe} end

-- Applies up to 10 levels of 10% mining productivity bonus to a recipe.
local function addMiningProductivity(recipe, pos)
    for i = 1, 10 do
        local miningProductivity = data.raw.technology["mining-productivity-"..tostring(i)]
        if miningProductivity == nil then break end -- no more to go through
        table.insert(miningProductivity.effects, pos, {
            type = "change-recipe-productivity", recipe = recipe, change = 0.1
        })
    end
end

--- TREE AND TREE SEED EXTRACTION YIELD ---

local tree_plant = data.raw.plant["tree-plant"] -- nil check likely unneeded
for _, result in pairs(tree_plant.minable.results) do
    if result.name == "wood" then result.amount = 40+2 end
end

-- Note: This increases the output of the tree farms by 20x (9.2 -> 184 wood/min -> 92 coal/min),
-- thus eliminating the need for the charcoal bonus multiplier.

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

--- CHARCOAL/CARBONIZATION RECIPE ---

if ENABLED.CARBONIZATION then
    local carbonization = data.raw.recipe[PREFIX.."wood-carbonization"]
    carbonization.enabled = false
    carbonization.hidden = true
end

-- Doubles crafting time, removes 20x bonus multiplier.
local wood_to_coal  = data.raw.recipe["wood-to-coal"]
wood_to_coal.energy_required = 6.4 -- was 3.2
wood_to_coal.ingredients = {{type = "item", name = "wood", amount = 8}}
for _, result in pairs(wood_to_coal.results) do
    if result.name == "coal" then result.amount = 4 end
end

--- DISTILLATION RECIPES ---

if ENABLED.DISTILLATION then

    -- Adjusts distillation recipe to potentially gain higher productivity.
    local distillation_1 = data.raw.recipe[PREFIX.."wood-distillation"]
    distillation_1.maximum_productivity = 9999
    addMiningProductivity(PREFIX.."wood-distillation", 2)

    -- Adjusts enhanced distillation recipe to potentially gain higher productivity.
    local distillation_2 = data.raw.recipe[PREFIX.."wood-distillation-enhanced"]
    distillation_2.maximum_productivity = 9999
    addMiningProductivity(PREFIX.."wood-distillation-enhanced", 3)

    --- ADDITIONAL COMPATIBILITY FOR BOB'S ORES ---

    -- Allows distillation recipes to also yield diamonds (a maximum of 1 pr. wood, regardless
    -- of output of coal) if Bob Ores is configured to yield gems from non-gem ores.
    if mods["bobores"] and settings.startup["bobmods-ores-gemsfromotherores"].value then
        local diamonds =
            settings.startup["bobmods-ores-gemprobability"].value * -- default: 0.05
            settings.startup["bobmods-gems-diamondratio"].value *   -- default: 0.2
            7.5 -- Recipes require 15 wood, which corresponds to 7.5 coal
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
