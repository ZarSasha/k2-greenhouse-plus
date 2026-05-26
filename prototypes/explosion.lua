---------------------------------------------------------------------------------------------------
--  ┏┓┏┓┏┓┏┓┓ ┏┓┏┓┳┏┓┳┓
--  ┣  ┃┃ ┃┃┃ ┃┃┗┓┃┃┃┃┃
--  ┗┛┗┛┗┛┣┛┗┛┗┛┗┛┻┗┛┛┗
---------------------------------------------------------------------------------------------------
local sounds = require "__base__.prototypes.entity.sounds"
local explosion_animations = require "__base__.prototypes.entity.explosion-animations"
---------------------------------------------------------------------------------------------------
-- GREENHOUSE ENTITY
---------------------------------------------------------------------------------------------------
local function create_debris(particle, amount, height, area, speed)
    return {
        type = "create-particle",
        repeat_count = amount,
        particle_name = particle,
        --offsets = {}
        offset_deviation = {{-(area), -(area)}, {(area), (area)}},
        initial_height = height,
        initial_height_deviation = height,
        initial_vertical_speed = speed,
        initial_vertical_speed_deviation = speed,
        speed_from_center = speed * 0.45,
        speed_from_center_deviation = speed * 0.45
    }
end
local targetEffects = {
    create_debris("oil-refinery-long-metal-particle-medium", 120, 0.25, 2.00, 0.10),
    create_debris("oil-refinery-long-metal-particle-medium",  24, 0.00, 0.75, 0.05),
    create_debris("chemical-plant-metal-particle-big",        16, 0.25, 1.75, 0.10),
    create_debris("splitter-metal-particle-big",              16, 0.10, 1.75, 0.10),
    create_debris("solar-panel-glass-particle-small",         96, 0.25, 1.75, 0.10),
    create_debris("branch-particle",                         120, 0.10, 1.75, 0.08),
    create_debris("branch-particle",                          24, 0.00, 0.50, 0.04),
    create_debris("leaf-particle",                            96, 0.10, 1.75, 0.08)
}
local GreenhouseExplosion = {
    type = "explosion",
    name = PREFIX.."greenhouse-explosion",
    icon = ASSETS_ICON.."greenhouse-icon.png",
    flags = {"not-on-map"},
    hidden = true,
    subgroup = "production-machine-explosions",
    order = "d-c-b", -- after Assembler Mk3.
    height = 0,
    animations = explosion_animations.big_explosion(),
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1,
    sound = sounds.large_explosion(0.4, 0.5),
    created_effect = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = targetEffects
        }
    }
}
---------------------------------------------------------------------------------------------------
-- FINAL DATA WRITE
---------------------------------------------------------------------------------------------------
data:extend({
    GreenhouseExplosion
})
---------------------------------------------------------------------------------------------------