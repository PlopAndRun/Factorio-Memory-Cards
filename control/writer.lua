local names = require 'data.names'
local persistence = require 'persistence'
local flashcard = require 'control.flashcard'
local _M = {}

function _M.on_built(writer)
    local surface = writer.surface
    local position = writer.position
    local receiver = surface.create_entity {
        name = names.writer.SIGNAL_RECEIVER,
        position = position,
        force = writer.force,
        create_build_effect_smoke = false
    }
    persistence.register_writer(writer, receiver)
end

function _M.on_destroyed(entity, player_index)
    local writer = entity.surface.find_entity(names.writer.BUILDING, entity.position)
    local holder = persistence.writers()[writer.unit_number]
    if holder then
        persistence.delete_writer(holder)
        local player = game.players[player_index]
        player.mine_entity(holder.writer)
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
