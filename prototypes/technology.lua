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
-- KRASTORIO 2 COMPATIBILITY
---------------------------------------------------------------------------------------------------
-- Unlocks greenhouse for trees alongside the existing greenhouse. Note: Recipe also adapted.
if KRASTORIO2 then
    local green_tech = data.raw.technology["kr-greenhouse"]
    if green_tech == nil then goto skip end
    table.insert(green_tech.effects, 3, unlock(PREFIX.."greenhouse-for-tree"))
    table.insert(green_tech.effects, 4, unlock(PREFIX.."greenhouse-tree-growth"))
    if ENABLED.GLASS then
        table.insert(green_tech.effects, 5, unlock(PREFIX.."sand"))
        table.insert(green_tech.effects, 6, unlock(PREFIX.."glass"))
    end
    if SPACE_AGE then -- Krastorio 2 isn't actually adapted for Space Age
        table.insert(green_tech.effects, 5, unlock("tree-seed"))
    end
    ::skip::
end

---------------------------------------------------------------------------------------------------
-- GREENHOUSE TECH: WOOD
---------------------------------------------------------------------------------------------------
-- Unlocks the greenhouse for wood through its own tech. Also unlocks the wood processing recipe.
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

    -- Space Age: Unlocks tree seed recipe much earlier, with the greenhouse tech:
   if SPACE_AGE then
       table.insert(output.effects, 1, unlock("tree-seed"))
   end

    -- Unlocks sand and glass recipes if the setting for it is enabled. Otherwise, a glass item
    -- will be chosen from another mod, and any relevant glass tech will be made a prerequisite.
    if ENABLED.GLASS then
        table.insert(output.effects, unlock(PREFIX.."glass"))
        table.insert(output.effects, unlock(PREFIX.."sand"))
    else
        -- Factorio+:
        if mods["factorioplus"] then
            table.insert(output.prerequisites, "glass-processing")
        -- Angel's Smelting (uses glass from Bob's Metals, Chemicals and Intermediates):
        elseif mods["angelssmelting"] then
            table.insert(output.prerequisites, "angels-glass-smelting-1")
        -- AAI Industry:
        elseif mods["aai-industry"] then
            table.insert(output.prerequisites, "glass-processing")
        end
    end

    return output
end
---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
if ENABLED.TREE_GREENHOUSE and not KRASTORIO2 then data:extend({
    createGreenhouseTech()
}) end

---------------------------------------------------------------------------------------------------
-- OIL PROCESSING TECH: ADVANCED WOOD PYROLYSIS + BASIC COAL LIQUEFACTION + COAL LIQUEFACTION
---------------------------------------------------------------------------------------------------
if ENABLED.DISTILLATION then
    -- Unlocks advanced wood pyrolysis with Oil Processing, removing the need to find oil or
    -- research Oil Gathering. Adds research cost instead.
    local oil_tech = data.raw.technology["oil-processing"]
    oil_tech.prerequisites = {"fluid-handling"}
    table.insert(oil_tech.effects, unlock(PREFIX.."wood-distillation"))
    oil_tech.research_trigger = nil
    oil_tech.unit = {
        count = 25, time = 15,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack",   1}
        }
    }
end

if SPACE_AGE and ENABLED.ENHANCED_DISTILLATION then
    -- Unlocks enhanced wood distillation with the biochamber.
    local bio_tech = data.raw.technology["biochamber"]
    table.insert(bio_tech.effects, unlock(PREFIX.."wood-distillation-enhanced"))
end

if ENABLED.EARLY_LIQUEFACTION then
    -- Moves Coal Liquefaction tech to right after Advanced Oil Processing, grealy lowering its
    -- research cost as well. Non-essential branch tech with no dependents, so it seems fine.
    local coal_tech = data.raw.technology["coal-liquefaction"]
    coal_tech.prerequisites = {"advanced-oil-processing"}
    coal_tech.unit = {
        count = 50, time = 30,
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
if SPACE_AGE and ENABLED.TREE_GREENHOUSE then
    -- Minimizes research cost of the Tree Seeding tech, since it unlocks nothing new:
    local seed_tech  = data.raw.technology["tree-seeding"]
    seed_tech.unit.count = 1
end
if SPACE_AGE and ENABLED.MAIN_GLEBA_GREENHOUSES then
    local soil_tech  = data.raw.technology["artificial-soil"]
    table.insert(soil_tech.effects, unlock(PREFIX.."greenhouse-for-yumako-tree"   ))
    table.insert(soil_tech.effects, unlock(PREFIX.."greenhouse-yumako-tree-growth"))
    table.insert(soil_tech.effects, unlock(PREFIX.."greenhouse-for-jellystem"     ))
    table.insert(soil_tech.effects, unlock(PREFIX.."greenhouse-jellystem-growth"  ))
end
if SPACE_AGE and ENABLED.OTHER_GLEBA_GREENHOUSES then
    -- Unlocks other Gleba greenhouses with Agriculture tech:
    local agri_tech  = data.raw.technology["agriculture"]
    table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-for-slipstack"     ))
    table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-slipstack-growth"  ))
    table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-for-sunnycomb"     ))
    table.insert(agri_tech.effects,  unlock(PREFIX.."greenhouse-sunnycomb-growth"  ))
end

---------------------------------------------------------------------------------------------------
