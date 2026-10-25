--[[
script.on_configuration_changed(function(data)
    -- Iterate through all surfaces in the save file

    if not script.active_mods["SimpleSeablock"] then return end

    for _, surface in pairs(game.surfaces) do
        -- Find all "tree-plant" entities
        local plants = surface.find_entities_filtered{name = "tree-plant"}

        for _, plant in pairs(plants) do
            if plant.valid then
                -- Save current position and quality (if applicable in Space Age)
                local pos = plant.position
                local grown = plant.tick_grown
                -- Destroy the stuck plant and instantly recreate it
                -- This forces the engine to recalculate the new growth_ticks
                plant.destroy()
                surface.create_entity{
                    name = "tree-plant",
                    position = pos,
                    tick_grown = grown,
                    raise_built = false -- Avoid triggering other mods' build events
                }
            end
        end
    end
end)
]]
