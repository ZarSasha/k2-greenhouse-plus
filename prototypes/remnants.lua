---------------------------------------------------------------------------------------------------
--  ┳┓┏┓┳┳┓┳┓┏┓┳┓┏┳┓┏┓
--  ┣┫┣ ┃┃┃┃┃┣┫┃┃ ┃ ┗┓
--  ┛┗┗┛┛ ┗┛┗┛┗┛┗ ┻ ┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- GREENHOUSE ENTITY
---------------------------------------------------------------------------------------------------
local GreenhouseRemnantsPic = {
    filename = ASSETS_ENTITY.."greenhouse-remnants.png",
    width  = 512, height = 512, shift  = util.by_pixel(0, 0), scale  = 0.5
}
local r, s = 3.5, 0.85
local GreenhouseRemnants = {
    type = "corpse",
    name = PREFIX.."greenhouse-remnants",
    icon = ASSETS_ICON.."greenhouse-icon.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "production-machine-remnants",
    order = "a-a-a",
    selection_box = {{-r, -r}, {r, r}},
    tile_width = r*2,
    tile_height = r*2,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    animation = { GreenhouseRemnantsPic }
}
---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
data:extend({
    GreenhouseRemnants
})
---------------------------------------------------------------------------------------------------