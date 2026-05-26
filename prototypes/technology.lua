---------------------------------------------------------------------------------------------------
--  ┏┳┓┏┓┏┓┓┏┳┓┏┓┓ ┏┓┏┓┓┏
--   ┃ ┣ ┃ ┣┫┃┃┃┃┃ ┃┃┃┓┗┫
--   ┻ ┗┛┗┛┛┗┛┗┗┛┗┛┗┛┗┛┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------------------------------------------
local function unlock(Recipe) return {type = "unlock-recipe", recipe = Recipe} end
---------------------------------------------------------------------------------------------------
-- GREENHOUSE TECH: WOOD
---------------------------------------------------------------------------------------------------
-- Unlocks the greenhouse for wood. Also unlocks the wood processing recipe with it.
local function createGreenhouseTech()
    local desc = SPACE_AGE and {"technology-description.k2gp-greenhouse-tech-space-age"}
                            or {"technology-description.k2gp-greenhouse-tech-base-game"}
    local output = {
        type = "technology",
        name = PREFIX.."greenhouse-tech",
        localised_description = desc,
        icon = ASSETS_TECH.."greenhouse-tech.png",
        icon_size = 256,
        prerequisites = {
            "steel-processing",
            "landfill"
        },
        effects = {
            unlock(PREFIX.."greenhouse-for-tree"),
            unlock(PREFIX.."greenhouse-tree-growth"),
        },
        unit = {
            count = 50,
            time = 15,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack",   1}
            }
        }
    }
    if SPACE_AGE then            -- Space Age: Unlock wood processing recipe much earlier
        table.insert(output.effects, 1, unlock("wood-processing"))
    end
    if mods["aai-industry"]      -- AAI Industry
    or mods["factorioplus"] then -- Factorio+
        table.insert(output.prerequisites, "glass-processing")
    end
    return output
end
---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
if SETTING.TREE_GREENHOUSE then
    data:extend({
        createGreenhouseTech()
    })
end
---------------------------------------------------------------------------------------------------
-- OIL PROCESSING TECH: ADVANCED WOOD PYROLYSIS + BASIC COAL LIQUEFACTION + COAL LIQUEFACTION
---------------------------------------------------------------------------------------------------
-- Unlock advanced wood pyrolysis with Oil Processing, removing the need to find oil or research
-- Oil Gathering. Adds research cost instead.
if SETTING.PYROLYSIS == "both-recipes" or SETTING.PYROLYSIS == "advanced-recipe" then
    local oil_tech = data.raw.technology["oil-processing"]
    oil_tech.prerequisites = {"fluid-handling"}
    table.insert(oil_tech.effects, unlock(PREFIX.."advanced-wood-pyrolysis"))
    oil_tech.research_trigger = nil
    oil_tech.unit = {
        count = 25, time = 15,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack",   1}
        }
    }
end

if SETTING.EARLY_LIQUEFACTION then
    -- Moves Coal Liquefaction tech to right after Advanced Oil Processing, lowering its cost as well.
    -- Non-essential branch tech with no dependents, so it seems fine.
    local coal_tech = data.raw.technology["coal-liquefaction"]
    coal_tech.prerequisites = {"advanced-oil-processing"}
    coal_tech.unit = {
        count = 150, time = 30,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack",   1},
            {"chemical-science-pack",   1}
        }
    }
end
---------------------------------------------------------------------------------------------------
-- SPACE AGE: TREE SEEDING AND SOIL TECH UNLOCKS
---------------------------------------------------------------------------------------------------
if SPACE_AGE then
    if SETTING.TREE_GREENHOUSE then
        -- Minimizes research cost of the Tree Seeding tech, since it unlocks nothing new:
        local seed_tech  = data.raw.technology["tree-seeding"]
        seed_tech.unit.count = 1
    end
    if SETTING.GLEBA_GREENHOUSES_1 == "with-overgrowth-soil" then
        -- Unlocks yumako/jellynut greenhouses with Artificial Soil tech:
        local soil1_tech = data.raw.technology["overgrowth-soil"]
        table.insert(soil1_tech.effects, unlock(PREFIX.."greenhouse-for-yumako-tree"   ))
        table.insert(soil1_tech.effects, unlock(PREFIX.."greenhouse-for-jellystem"     ))
        table.insert(soil1_tech.effects, unlock(PREFIX.."greenhouse-yumako-tree-growth"))
        table.insert(soil1_tech.effects, unlock(PREFIX.."greenhouse-jellystem-growth"  ))
    elseif SETTING.GLEBA_GREENHOUSES_1 == "with-artificial-soil" then
        -- Unlocks yumako/jellynut greenhouses with Overgrowth Soil tech:
        local soil2_tech = data.raw.technology["artificial-soil"]
        table.insert(soil2_tech.effects, unlock(PREFIX.."greenhouse-for-yumako-tree"   ))
        table.insert(soil2_tech.effects, unlock(PREFIX.."greenhouse-for-jellystem"     ))
        table.insert(soil2_tech.effects, unlock(PREFIX.."greenhouse-yumako-tree-growth"))
        table.insert(soil2_tech.effects, unlock(PREFIX.."greenhouse-jellystem-growth"  ))
    end
    if SETTING.GLEBA_GREENHOUSES_2 then
        -- Unlocks slipstack and sunnycomb greenhouses with Agriculture tech:
        local agri_tech  = data.raw.technology["agriculture"]
        table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-for-slipstack"     ))
        table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-for-sunnycomb"     ))
        table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-slipstack-growth"  ))
        table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-sunnycomb-growth"  ))
    end
end
---------------------------------------------------------------------------------------------------