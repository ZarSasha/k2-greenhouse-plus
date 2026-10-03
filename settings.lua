---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┏┳┓┏┳┓┳┳┓┏┓┏┓
--  ┗┓┣  ┃  ┃ ┃┃┃┃┓┗┓
--  ┗┛┗┛ ┻  ┻ ┻┛┗┗┛┗┛
---------------------------------------------------------------------------------------------------
local space_age = false; if mods["space-age"] then space_age = true end
local quality   = false; if mods["quality"]   then quality   = true end
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
            "distillation", -- Includes a variant exclusive to the biochamber from Space Age.
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
        setting_type = "startup",
        default_value = 0,     -- Set to 0 by default, to match the
        minimum_value = 0,     -- agricultural tower from Space Age.
        maximum_value = 20,
        order = "c1"
    },
    {-- Quality: Allows the output rate for greenhouses to scale normally with quality.
     -- Disabled by default, because it breaks game balance.
        type = "bool-setting",
        name = "k2gp-allow-greenhouse-quality-scaling",
        setting_type = "startup",
        default_value = false,
        hidden = not quality,
        --forced_value = false, -- loaded when |hidden = true|
        order = "c2"
    },
    {-- Greenhouse wood production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-tree-output-pr-sec",
        setting_type = "startup",
        default_value = 0.5,   -- The equivalent of 75 planted trees when growth time is
        minimum_value = 0.01,  -- 10 min. and each harvest yields 4 wood (this many could
        maximum_value = 10,    -- technically be planted with a 7x7 area).
        order = "e1"
    },
    {-- Space Age: Greenhouse yumako production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-yumako-tree-output-pr-sec",
        setting_type = "startup",
        default_value = 1,     -- Balanced to produce ~70% pr. area of what
        minimum_value = 0.01,  -- an agricultural tower is capable of.
        maximum_value = 10,
        hidden = not space_age,
        order = "e2"
    },
    {-- Space Age: Greenhouse jellynut production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-jellystem-output-pr-sec",
        setting_type = "startup",
        default_value = 1,     -- Same as above ^
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "e3"
    },
    {-- Space Age: Greenhouse slipstack production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-slipstack-output-pr-sec",
        setting_type = "startup",
        default_value = 1,     -- 60% spoilage, 40% stone
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "e4"
    },
    {-- Space Age: Greenhouse sunnycomb production rate (items/s.)
        type = "double-setting",
        name = "k2gp-greenhouse-sunnycomb-output-pr-sec",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 0.01,
        maximum_value = 10,
        hidden = not space_age,
        order = "e5"
    },

}

---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
data:extend(startup_settings)
---------------------------------------------------------------------------------------------------
