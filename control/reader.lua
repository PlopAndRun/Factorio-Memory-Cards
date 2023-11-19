local names = require 'data.names'
local persistence = require 'persistence'
local flashcard = require 'control.flashcard'

local _M = {}

function _M.on_built(sender)
    local surface = sender.surface
    local position = sender.position
    local reader = surface.create_entity {
        name = names.reader.CONTAINER,
        position = position,
        force = sender.force,
        create_build_effect_smoke = false
    }
    persistence.register_reader(sender, reader)
end

function _M.on_destroyed(entity, player_index)
    local reader = entity.surface.find_entity(names.reader.CONTAINER, entity.position)
    local holder = persistence.readers()[reader.unit_number]
    if holder then
        persistence.delete_reader(holder)
        game.players[player_index].mine_entity(holder.reader, true)
    end
end

function _M.on_tick()
    for _, holder in pairs(persistence.readers()) do
        local inventory = holder.reader.get_inventory(defines.inventory.chest)
        if not inventory.is_empty()
            and inventory[1].name == names.flashcard.ITEM
        then
            local control_behavior = holder.sender.get_or_create_control_behavior()
            local data = flashcard.read_data(inventory[1]);
            control_behavior.parameters = data
        else
            local control_behavior = holder.sender.get_or_create_control_behavior()
            control_behavior.parameters = {}
        end
    end
end

function _M.on_gui_opened(entity, player_index)
    local chest = entity.surface.find_entity(names.reader.CONTAINER, entity.position)
    if chest then 
        game.get_player(player_index).opened = chest
    end
end

return _M
