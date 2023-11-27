local names = require 'data.names'
local persistence = require 'persistence'
local flashcard = require 'control.flashcard'
local _M = {}

function _M.on_built(entity)
    local surface = entity.surface
    local position = entity.position
    local writer, receiver
    if entity.name == names.writer.BUILDING then
        writer = entity
        receiver = surface.create_entity {
            name = names.writer.SIGNAL_RECEIVER,
            position = position,
            force = entity.force,
            create_build_effect_smoke = false
        }
    else
        receiver = entity
        writer = surface.create_entity {
            name = names.writer.BUILDING,
            position = position,
            force = entity.force,
            create_build_effect_smoke = false
        }
    end
    persistence.register_writer(writer, receiver)
end

local function spill_items(surface, position, force, inventory)
    for _, index in pairs(inventory.get_contents()) do
        local item = inventory[index]
        local spilled = surface.spill_item_stack(position, item, false, force, false)
        for _, entity in pairs(spilled) do
            entity.order_deconstruction(force)
        end
    end
end

function _M.on_destroyed(entity, player_index)
    local surface = entity.surface
    local writer = surface.find_entity(names.writer.BUILDING, entity.position)
    local holder = persistence.writers()[writer.unit_number]
    if holder then
        persistence.delete_writer(holder)
        if player_index ~= nil then
            local player = game.players[player_index]
            -- TODO: overflow
            player.mine_entity(holder.writer, true)
        else
            spill_items(surface, entity.position, entity.force,
                holder.writer.get_inventory(defines.inventory.furnace_source))
            spill_items(surface, entity.position, entity.force,
                holder.writer.get_inventory(defines.inventory.furnace_result))
            if holder.writer.is_crafting() then
                local temp_inventory = game.create_inventory(1)
                temp_inventory.insert{name=names.flashcard.ITEM, count=1}
                spill_items(surface, entity.position, entity.force, temp_inventory)
                temp_inventory.destroy()
            end
            holder.writer.destroy()
        end
    end
end

function _M.on_gui_opened(entity, player_index)
    local writer = entity.surface.find_entity(names.writer.BUILDING, entity.position)
    if entity then
        game.get_player(player_index).opened = writer
    end
end

function _M.on_tick()
    for _, holder in pairs(persistence.writers()) do
        local inventory = holder.writer.get_output_inventory()
        if not inventory.is_empty()
            and inventory[1].name == names.flashcard.ITEM
            and not flashcard.is_initialized(inventory[1])
        then
            local signals = holder.receiver.get_merged_signals();
            flashcard.save_data(inventory[1], signals)
        end
    end
end

return _M
