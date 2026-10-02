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
    {-- Space Age: Allow Gleba trees to be grown in their own greenhouses.
        type = "string-setting",
        name = "k2gp-enable-gleba-greenhouses",
        setting_type = "startup",
        default_value = "all",
        allowed_values = {
            "all",
            "main",    -- Yumako and Jellynut
            "other",   -- Slipstack and Sunnycomb
            "disabled"
        },
        hidden = not space_age,
        order = "a2"
    },
    {-- Lets the mod provide its own source of glass for the greenhouses.
        type = "bool-setting",
        name = "k2gp-provide-glass-for-greenhouses",
        setting_type = "startup",
        default_value = true,
        order = "a4"
    },
    {-- Enable the pyrolysis recipes. Option useful in relation to mod compatibility.
        type = "string-setting",
        name = "k2gp-enable-pyrolysis-recipes",
        setting_type = "startup",
        default_value = "both-recipes",
        allowed_values = {
            "both-recipes",
            "carbonization",
            "distillation", -- includes a recipe variant exclusive to the biochamber
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
        default_value = 0.5,   -- The equivalent of 75 planted trees when growth time is 10 min.
        minimum_value = 0.01,  -- and each harvest yields 4 wood. (It is an amount that could
        maximum_value = 10,    -- technically be planted within a 7x7 area, the size of the
        order = "e1"           -- greenhouse's collision box.
    },
    {-- Space Age: Greenhouse yumako production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-yumako-tree-output-pr-sec",
        setting_type = "startup",
        default_value = 1.0,  -- Balanced to produce a bit less (~93.5%) pr. area of
        minimum_value = 0.01, -- what an agricultural tower setup is capable of.
        maximum_value = 10,
        hidden = not space_age,
        order = "e2"
    },
    {-- Space Age: Greenhouse jellynut production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-jellystem-output-pr-sec",
        setting_type = "startup",
        default_value = 1.0,  -- Same as above ^
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "e3"
    },
    {-- Space Age: Greenhouse slipstack production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-slipstack-output-pr-sec",
        setting_type = "startup",
        default_value = 1.0,  -- 60% spoilage, 40% stone
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "e4"
    },
    {-- Space Age: Greenhouse sunnycomb production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-sunnycomb-output-pr-sec",
        setting_type = "startup",
        default_value = 1.0,
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "e5"
    }
}
---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
data:extend(startup_settings)
---------------------------------------------------------------------------------------------------
