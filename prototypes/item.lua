---------------------------------------------------------------------------------------------------
--  ┳┏┳┓┏┓┳┳┓
--  ┃ ┃ ┣ ┃┃┃
--  ┻ ┻ ┗┛┛ ┗
---------------------------------------------------------------------------------------------------
local item_sounds = require("__base__.prototypes.item_sounds")
---------------------------------------------------------------------------------------------------
-- GREENHOUSE ENTITIES (BASE & SPACE AGE DLC)
---------------------------------------------------------------------------------------------------
local function createGreenhouseItem(Variant, Order)
    local Subgroup = SPACE_AGE and "agriculture" or "production-machine"
    local output   = {
        type = "item",
        name = PREFIX .. "greenhouse-for-" .. Variant,
        icon = ASSETS_ICON .. "greenhouse-" .. Variant .. "-icon.png",
        icon_size = 64,
        subgroup = Subgroup,
        order = "a[greenhouse]-" .. Order .. "[" .. Variant .. "]",
        inventory_move_sound = item_sounds.mechanical_inventory_move,
        pick_sound = item_sounds.mechanical_inventory_pickup,
        drop_sound = item_sounds.mechanical_inventory_move,
        stack_size = 10,
        place_result = PREFIX .. "greenhouse-for-" .. Variant,
        weight = 100 * kg
    }
    return output
end

---------------------------------------------------------------------------------------------------
-- SAND ITEM
---------------------------------------------------------------------------------------------------
local sandItem = {
    type = "item",
    name = PREFIX .. "sand",
    icon = ASSETS_ICON .. "sand-icon.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "a[smelting]-d[glass-1]",
    inventory_move_sound = item_sounds.sulfur_inventory_move,
    pick_sound = item_sounds.landfill_inventory_pickup,
    drop_sound = item_sounds.sulfur_inventory_move,
    stack_size = 100,
    weight = 1 * kg
}

---------------------------------------------------------------------------------------------------
-- GLASS ITEM
---------------------------------------------------------------------------------------------------
local glassItem = {
    type = "item",
    name = PREFIX .. "glass",
    icon = ASSETS_ICON .. "glass-icon.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "a[smelting]-d[glass-2]",
    inventory_move_sound = item_sounds.grenade_inventory_move,
    pick_sound = item_sounds.grenade_inventory_pickup,
    drop_sound = item_sounds.grenade_inventory_move,
    stack_size = 100,
    weight = 1 * kg
}

---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
if SETTING.TREE_GREENHOUSE then
    data:extend({
        createGreenhouseItem("tree",        "a")
    })
end
if SPACE_AGE and SETTING.GLEBA_GREENHOUSES_1 ~= "disabled" then
    data:extend({
        createGreenhouseItem("yumako-tree", "b"),
        createGreenhouseItem("jellystem",   "c")
    })
end
if SPACE_AGE and SETTING.GLEBA_GREENHOUSES_2 then
    data:extend({
        createGreenhouseItem("slipstack", "d"),
        createGreenhouseItem("sunnycomb", "e")
    })
end
if SETTING.GLASS then
    data:extend({
        sandItem,
        glassItem
    })
end
---------------------------------------------------------------------------------------------------
