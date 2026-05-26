---------------------------------------------------------------------------------------------------
--  ┏┓┓┏┏┓┳┓┏┓┳┓
--  ┗┓┣┫┣┫┣┫┣ ┃┃
--  ┗┛┛┗┛┗┛┗┗┛┻┛
---------------------------------------------------------------------------------------------------
-- Used in prototype stage.
---------------------------------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------------------------------
MODNAME       = "k2-greenhouse-plus"
PREFIX        = "k2gp-"
ASSETS        = "__"..MODNAME.."__/assets/"
ASSETS_ENTITY = ASSETS.."entity/"
ASSETS_ICON   = ASSETS.."icon/"
ASSETS_SOUND  = ASSETS.."sound/"
ASSETS_TECH   = ASSETS.."technology/"

SPACE_AGE     = false; if mods["space-age"] then SPACE_AGE = true end
---------------------------------------------------------------------------------------------------
-- STARTUP SETTINGS
---------------------------------------------------------------------------------------------------
local function conf(Name) return settings.startup[Name].value end
SETTING = {
    TREE_GREENHOUSE     = conf "k2gp-enable-tree-greenhouse",
    GLEBA_GREENHOUSES_1 = conf "k2gp-enable-main-gleba-greenhouses",
    GLEBA_GREENHOUSES_2 = conf "k2gp-enable-other-gleba-greenhouses",
    PYROLYSIS           = conf "k2gp-enable-pyrolysis-recipes",
    EARLY_LIQUEFACTION  = conf "k2gp-unlock-coal-liquefaction-early",
    MODULE_SLOTS        = conf "k2gp-greenhouse-module-slot-amount",
    OUTPUT_RATE = {
        ["tree"       ] = conf "k2gp-greenhouse-tree-output-pr-sec",
        ["yumako-tree"] = conf "k2gp-greenhouse-yumako-tree-output-pr-sec",
        ["jellystem"  ] = conf "k2gp-greenhouse-jellystem-output-pr-sec",
        ["slipstack"  ] = conf "k2gp-greenhouse-slipstack-output-pr-sec",
        ["sunnycomb"  ] = conf "k2gp-greenhouse-sunnycomb-output-pr-sec"
    }
}
---------------------------------------------------------------------------------------------------