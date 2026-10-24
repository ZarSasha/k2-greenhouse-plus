---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┏┳┓┏┓  ┳┳┏┓┳┓┏┓┏┳┓┏┓┏┓
--  ┃┃┣┫ ┃ ┣┫━━┃┃┃┃┃┃┣┫ ┃ ┣ ┗┓
--  ┻┛┛┗ ┻ ┛┗  ┗┛┣┛┻┛┛┗ ┻ ┗┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------------------------------------------
local function unlock(Recipe) return {type = "unlock-recipe", recipe = Recipe} end

---------------------------------------------------------------------------------------------------
-- COMPATIBILITY FOR ARIG + ANY PLANET START
---------------------------------------------------------------------------------------------------
-- Re-adds missing recipe.

if ENABLED.DISTILLATION and mods["planetaris-arig"] and mods["any-planet-start"]
and settings.startup["aps-planet"].value == "arig" then
    table.insert(
        data.raw.technology["oil-processing"].effects, 3, unlock(PREFIX.."wood-distillation")
    )
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

    -- Allows virtually unlimited productivity bonuses for distillation recipes.
    local distillation_1 = data.raw.recipe[PREFIX.."wood-distillation"]
    distillation_1.maximum_productivity = 9999
    local distillation_2 = data.raw.recipe[PREFIX.."wood-distillation-enhanced"]
    distillation_2.maximum_productivity = 9999

    -- Makes distillation recipes benefit from mining productivity.
    AddMiningProductivity(PREFIX.."wood-distillation")
    AddMiningProductivity(PREFIX.."wood-distillation-enhanced")

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
                independent_probability = diamonds
            })
            table.insert(distillation_2.results, {
                type = "item", name = "bob-diamond-ore", amount = 1,
                independent_probability = diamonds
            })
        elseif diamonds > 1 then
            local diamonds_integer = math.floor(diamonds)
            local diamonds_fraction = diamonds - diamonds_integer
            table.insert(distillation_1.results, {
                type = "item", name = "bob-diamond-ore", amount = diamonds_integer,
                extra_count_fraction = diamonds_fraction
            })
            table.insert(distillation_2.results, {
                type = "item", name = "bob-diamond-ore", amount = diamonds_integer,
                extra_count_fraction = diamonds_fraction
            })
        end
    end
end

---------------------------------------------------------------------------------------------------
