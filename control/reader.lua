local names = require 'data.names'
local persistence = require 'persistence'
local flashcard = require 'control.flashcard'
local utils = require 'utils'

local _M = {}

local function find_chest(entity)
    return entity.surface.find_entity(names.reader.CONTAINER, entity.position)
end

function _M.on_built(sender)
    local control_behavior = sender.get_or_create_control_behavior()
    control_behavior.parameters = {}

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
        if player_index ~= nil then
            game.players[player_index].mine_entity(holder.reader, true)
        else
            local inventory = holder.reader.get_inventory(defines.inventory.chest)
            utils.spill_items(entity.surface, entity.position, entity.force, inventory)
            holder.reader.destroy()
        end
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
    local chest = find_chest(entity)
    if chest then
        game.get_player(player_index).opened = chest
    end
end

function _M.on_player_fast_inserted(entity, player)
    utils.fast_insert(player, find_chest(entity))
end

return _M
