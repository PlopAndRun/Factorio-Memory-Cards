local persistence = require 'persistence'
local memorycard = require 'control.memorycard'
local utils = require 'utils'
local names = utils.names
local constants = utils.constants
local gui = require 'control.reader_gui'
local _M = {}

local DIAGNOSTICS = names.MOD_PREFIX .. 'diagnostics-channel'

local function find_chest(entity)
    return entity.surface.find_entity(names.reader.CONTAINER, entity.position)
end

local function create_cells_for_channel(cells, holder, data, connect_red, connect_green)
    local surface = holder.reader.surface
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
            if connect_red then
                holder.sender.connect_neighbour {
                    wire = defines.wire_type.red,
                    target_entity = cell,
                }
            end
            if connect_green then
                holder.sender.connect_neighbour {
                    wire = defines.wire_type.green,
                    target_entity = cell,
                }
            end
            cell_control_behavior = cell.get_or_create_control_behavior()
        end
        index = index + 1
        assert(cell_control_behavior)
        cell_control_behavior.set_signal(index, v)
    end
    return cells
end

local function create_cells(holder, card)
    local data = memorycard.read_data(card)
    local cells = {}
    if #data.combined > 0 then
        create_cells_for_channel(cells, holder, data.combined, true, true)
    end
    if #data.red > 0 then
        create_cells_for_channel(cells, holder, data.red, true, false)
    end
    if #data.green > 0 then
        create_cells_for_channel(cells, holder, data.green, false, true)
    end
    holder.cells = cells
end

local function destroy_cells(holder)
    for _, cell in pairs(holder.cells) do
        cell.destroy()
    end
    holder.cells = nil
end

function _M.apply_options(holder)
    local channel = holder.options.diagnostics_channel
    local red = channel == persistence.CHANNEL_OPTION.RED or channel == persistence.CHANNEL_OPTION.BOTH
    local green = channel == persistence.CHANNEL_OPTION.GREEN or channel == persistence.CHANNEL_OPTION.BOTH
    if red then
        holder.sender.connect_neighbour {
            wire = defines.wire_type.red,
            target_entity = holder.diagnostics_cell,
        }
    else
        holder.sender.disconnect_neighbour {
            wire = defines.wire_type.red,
            target_entity = holder.diagnostics_cell,
        }
    end

    if green then
        holder.sender.connect_neighbour {
            wire = defines.wire_type.green,
            target_entity = holder.diagnostics_cell,
        }
    else
        holder.sender.disconnect_neighbour {
            wire = defines.wire_type.green,
            target_entity = holder.diagnostics_cell,
        }
    end
end

function _M.on_built(sender, tags)
    local control_behavior = sender.get_or_create_control_behavior()
    control_behavior.parameters = {}

    local surface = sender.surface
    local position = sender.position
    local reader = surface.create_entity {
        name = names.reader.CONTAINER,
        position = position,
        force = sender.force,
        create_build_effect_smoke = false,
    }
    local diagnostics = surface.create_entity {
        name = names.reader.SIGNAL_DIAGNOSTICS_CELL,
        position = position,
        force = sender.force,
        create_build_effect_smoke = false,
    }
    local inventory = reader.get_inventory(defines.inventory.chest)
    inventory.set_filter(1, names.memorycard.ITEM)
    local holder = persistence.register_reader(sender, reader, diagnostics)
    holder.options.diagnostics_channel = tags and tags[DIAGNOSTICS] or persistence.CHANNEL_OPTION.BOTH
    _M.apply_options(holder)
end

function _M.on_cloned(source, destination)
    local reader = find_chest(source)
    if reader == nil then return end;
    local holder = persistence.readers()[reader.unit_number]
    if holder.clones == nil then
        holder.clones = {
            total = 0,
            required = 3,
            cells = {},
        }
        if holder.cells ~= nil then
            holder.clones.required = holder.clones.required + #holder.cells
        end
    end

    if destination.name == names.reader.SIGNAL_SENDER_CELL then
        table.insert(holder.clones.cells, destination)
    else
        holder.clones[destination.name] = destination
    end
    holder.clones.total = holder.clones.total + 1
    if holder.clones.total == holder.clones.required then
        local new_holder = persistence.register_reader(
            holder.clones[names.reader.SIGNAL_SENDER],
            holder.clones[names.reader.CONTAINER],
            holder.clones[names.reader.SIGNAL_DIAGNOSTICS_CELL])
        if holder.cells ~= nil then
            new_holder.cells = holder.clones.cells
        end
        persistence.copy_reader_options(holder, new_holder)
        holder.clones = nil
    end
end

function _M.on_destroyed(entity, player_index, spill_inventory)
    local reader = entity.surface.find_entity(names.reader.CONTAINER, entity.position)
    if reader == nil then return end
    local holder = persistence.readers()[reader.unit_number]
    if holder then
        if holder.cells ~= nil then
            destroy_cells(holder)
        end
        persistence.delete_reader(holder)
        holder.diagnostics_cell.destroy()
        if player_index ~= nil then
            game.players[player_index].mine_entity(holder.reader, true)
        elseif spill_inventory then
            local inventory = holder.reader.get_inventory(defines.inventory.chest)
            utils.spill_items(entity.surface, entity.position, entity.force, inventory)
            holder.reader.destroy()
        end
    end
end

function _M.on_tick()
    for _, holder in pairs(persistence.readers()) do
        local inventory = holder.reader.get_inventory(defines.inventory.chest)
        if not inventory.is_empty() and inventory[1].name == names.memorycard.ITEM
        then
            if holder.cells == nil then
                create_cells(holder, inventory[1])
                local cb = holder.diagnostics_cell.get_or_create_control_behavior()
                cb.set_signal(1, { signal = { type = 'virtual', name = names.signal.INSERTED, }, count = 1, })
            end
        else
            if holder.cells ~= nil then
                destroy_cells(holder)
                local cb = holder.diagnostics_cell.get_or_create_control_behavior()
                cb.set_signal(1, nil)
            end
        end
    end
end

function _M.on_gui_opened(entity, player_index)
    local chest = find_chest(entity)
    local player = game.get_player(player_index)
    if chest and player then
        game.get_player(player_index).opened = chest
        gui.open_options_gui(player, persistence.readers()[chest.unit_number])
    end
end

function _M.on_gui_closed(_, player_index)
    local player = game.get_player(player_index)
    if not player then return end
    gui.close_options_gui(player)
end

function _M.on_player_fast_inserted(entity, player)
    utils.fast_insert(player, find_chest(entity))
end

function _M.on_surface_erased(surface_index)
    local readers = persistence.readers()
    for key, holder in pairs(readers) do
        if holder.reader.surface_index == surface_index then
            readers[key] = nil
        end
    end
end

function _M.save_blueprint_data(entity, blueprint, index)
    local chest = find_chest(entity)
    if chest == nil then return end
    local holder = persistence.readers()[chest.unit_number]
    if holder == nil then return end
    blueprint.set_blueprint_entity_tag(index, DIAGNOSTICS, holder.options.diagnostics_channel)
end

function _M.copy_settings(source, destination)
    local source_reader = find_chest(source)
    local destination_reader = find_chest(destination)
    local source_holder = persistence.readers()[source_reader.unit_number]
    local destination_holder = persistence.readers()[destination_reader.unit_number]
    if source_holder and destination_holder then
        persistence.copy_reader_options(source_holder, destination_holder)
        _M.apply_options(destination_holder)
    end
end

return _M
