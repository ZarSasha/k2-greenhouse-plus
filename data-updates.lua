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
-- COMPATIBILITY FOR SIMPLE SEABLOCK: HIDE CHARCOAL RECIPE WITH 20x BONUS MULTIPLIER
---------------------------------------------------------------------------------------------------
-- The mod applies a 20x energy bonus multiplier to its charcoal recipe to compensate for low yield
-- from trees grown with an agricultural tower (net output of 9.2 wood/min from a 21x21 area, with
-- 46 active "fields" and half of the output diverted to seed extraction). The greenhouse (net
-- output of 30 wood/min * (441 tiles / 61.25 tiles) = 216 wood/min from the same area is already
-- ~23.5x as efficient (no less than ~22.3x when accounting for power consumption), so it's better
-- to just disable that recipe. Then the pyrolysis recipes won't have to be adapted or disabled
-- depending on settings. Making charcoal will require more machines and more energy, but there is
-- really no issue with that.

if mods["SimpleSeablock"] then
    local wood_to_coal = data.raw.recipe["wood-to-coal"]
    table.insert(wood_to_coal.flags, "hidden[overridden]")
    wood_to_coal.hidden = true
    wood_to_coal.enabled = false
end

-- Note: Other greenhouse mods must account for seed extraction, but not this one.

---------------------------------------------------------------------------------------------------
