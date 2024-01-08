local persistence = require 'persistence'
local memorycard = require 'control.memorycard'
local utils = require 'utils'
local names = utils.names
local constants = utils.constants
local _M = {}

local function find_chest(entity)
    return entity.surface.find_entity(names.reader.CONTAINER, entity.position)
end

local function create_cells(holder, card)
    local surface = holder.reader.surface
    local data = memorycard.read_data(card)
    local cells = {}
    local cell = nil
    local cell_control_behavior = nil
    local index = constants.READER_SLOTS
    for _, v in pairs(data) do
        if index == constants.READER_SLOTS then
            index = 0
            cell = surface.create_entity {
                name = names.reader.SIGNAL_SENDER_CELL,
                position = {
                    x = holder.sender.position.x,
                    y = holder.sender.position.y,
                },
                force = holder.sender.force,
                create_build_effect_smoke = false,

            }
            cell.destructible = false;
            table.insert(cells, cell)
            holder.sender.connect_neighbour {
                wire = defines.wire_type.red,
                target_entity = cell,
            }
            holder.sender.connect_neighbour {
                wire = defines.wire_type.green,
                target_entity = cell,
            }
            cell_control_behavior = cell.get_or_create_control_behavior()
        end
        index = index + 1
        assert(cell_control_behavior)
        cell_control_behavior.set_signal(index, v)
    end
    holder.cells = cells
end

local function destroy_cells(holder)
    for _, cell in pairs(holder.cells) do
        cell.destroy()
    end
    holder.cells = nil
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
        if holder.cells ~= nil then
            destroy_cells(holder)
        end
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
            and inventory[1].name == names.memorycard.ITEM
        then
            if holder.cells == nil then
                create_cells(holder, inventory[1])
                local cb = holder.sender.get_or_create_control_behavior()
                cb.set_signal(1, { signal = { type = 'virtual', name = names.signal.INSERTED }, count = 1 })
            end
        else
            if holder.cells ~= nil then
                destroy_cells(holder)
                local cb = holder.sender.get_or_create_control_behavior()
                cb.set_signal(1, nil)
            end
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
