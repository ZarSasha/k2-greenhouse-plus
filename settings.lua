---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┏┳┓┏┳┓┳┳┓┏┓┏┓
--  ┗┓┣  ┃  ┃ ┃┃┃┃┓┗┓
--  ┗┛┗┛ ┻  ┻ ┻┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
local space_age = false; if mods["space-age"] then space_age = true end
---------------------------------------------------------------------------------------------------
-- STARTUP SETTINGS
---------------------------------------------------------------------------------------------------
local startup_settings = {

    {-- Enable the tree greenhouse. Option useful in relation to mod compatibility.
        type = "bool-setting",
        name = "k2gp-enable-tree-greenhouse",
        localised_description = (not space_age and {
            "mod-setting-description.k2gp-enable-tree-greenhouse-base-game"
        }) or {
            "mod-setting-description.k2gp-enable-tree-greenhouse-space-age"
        },
        setting_type = "startup",
        default_value = true,
        order = "a1"
    },
    {-- Space Age: Allow Yumako and Jellynut trees to be grown in their own greenhouses.
        type = "string-setting",
        name = "k2gp-enable-main-gleba-greenhouses",
        setting_type = "startup",
        default_value = "with-overgrowth-soil",
        allowed_values = {
            "with-overgrowth-soil",
            "with-artificial-soil",
            "disabled"
        },
        hidden = not space_age,
        order = "a2"
    },
    {-- Space Age: Allow Slipstack and Sunnycomb to be grown in their own greenhouses.
        type = "bool-setting",
        name = "k2gp-enable-other-gleba-greenhouses",
        setting_type = "startup",
        default_value = true,
        hidden = not space_age,
        order = "a3"
    },
    {-- Enable the pyrolysis recipes. Option useful in relation to mod compatibility.
        type = "string-setting",
        name = "k2gp-enable-pyrolysis-recipes",
        setting_type = "startup",
        default_value = "both-recipes",
        allowed_values = {
            "both-recipes",
            "basic-recipe",
            "advanced-recipe",
            "disabled"
        },
        order = "b1"
    },
    {-- Unlock Coal Liquefaction tech right after Advanced Oil Processing, at lower cost.
        type = "bool-setting",
        name = "k2gp-unlock-coal-liquefaction-early",
        setting_type = "startup",
        default_value = true,
        order = "b2"
    },
    {-- Greenhouse module slot amount.
        type = "int-setting",
        name = "k2gp-greenhouse-module-slot-amount",
        localised_description = (not space_age and {
            "mod-setting-description.k2gp-greenhouse-module-slot-amount-base-game"
        }) or {
            "mod-setting-description.k2gp-greenhouse-module-slot-amount-space-age"
        },
        setting_type = "startup",
        default_value = 0,    -- Set to 0 by default, since the growth of planted trees
        minimum_value = 0,    -- cannot be accelerated in any way.
        maximum_value = 20,
        order = "c"
    },
    {-- Greenhouse wood production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-tree-output-pr-sec",
        setting_type = "startup",
        default_value = 0.25,  -- The equivalent of 37.5 planted trees (10 min growth time).
        minimum_value = 0.01,  -- Energy output may be twice that of solar + accu in practice,
        maximum_value = 10,    -- but burning the wood for energy also pollutes a lot. And I
        order = "d1"           -- don't really want the output to be any lower than this.
    },
    {-- Space Age: Greenhouse yumako production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-yumako-tree-output-pr-sec",
        setting_type = "startup",
        default_value = 0.375, -- Balanced so a legendary tier greenhouse produces slightly
        minimum_value = 0.01,  -- more pr. area than an agricultural tower setup does.
        maximum_value = 10,
        hidden = not space_age,
        order = "d2"
    },
    {-- Space Age: Greenhouse jellynut production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-jellystem-output-pr-sec",
        setting_type = "startup",
        default_value = 0.375, -- Same as above ^
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "d3"
    },
    {-- Space Age: Greenhouse slipstack production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-slipstack-output-pr-sec",
        setting_type = "startup",
        default_value = 0.375, -- 0.225 spoilage, 0.15 stone pr. sec.
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "d4"
    },
    {-- Space Age: Greenhouse sunnycomb production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-sunnycomb-output-pr-sec",
        setting_type = "startup",
        default_value = 0.375,
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "d5"
    }
}
---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
data:extend(startup_settings)
---------------------------------------------------------------------------------------------------