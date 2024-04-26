local persistence = require 'persistence'
local memorycard = require 'control.memorycard'
local utils = require 'utils'
local gui = require 'control.writer_gui'
local names = utils.names
local _M = {}

local USE_CHANNELS_TAG = names.MOD_PREFIX .. 'use-channels'

local function find_writer(entity)
    return entity.surface.find_entity(names.writer.BUILDING, entity.position)
end

local function get_signals(holder)
    if holder.options.use_channels then
        local red_network = holder.receiver.get_circuit_network(defines.wire_type.red)
        local green_network = holder.receiver.get_circuit_network(defines.wire_type.green)
        return {
            combined = {},
            red = red_network and red_network.signals or {},
            green = green_network and green_network.signals or {},
        }
    else
        return {
            combined = holder.receiver.get_merged_signals(),
            red = {},
            green = {},
        }
    end
end

function _M.on_built(entity, tags)
    local surface = entity.surface
    local position = entity.position
    local writer, receiver
    if entity.name == names.writer.BUILDING then
        writer = entity
        receiver = surface.create_entity {
            name = names.writer.SIGNAL_RECEIVER,
            position = position,
            force = entity.force,
            create_build_effect_smoke = false,
        }
    else
        receiver = entity
        writer = surface.create_entity {
            name = names.writer.BUILDING,
            position = position,
            force = entity.force,
            create_build_effect_smoke = false,
        }
    end
    local holder = persistence.register_writer(writer, receiver)
    holder.options.use_channels = tags and tags[USE_CHANNELS_TAG] or false
end

function _M.on_cloned(source, destination)
    local writer = find_writer(source)
    if writer == nil then return end;
    local holder = persistence.writers()[writer.unit_number]
    if holder.clones == nil then
        holder.clones = { total = 0, }
    end

    holder.clones[destination.name] = destination
    holder.clones.total = holder.clones.total + 1
    if holder.clones.total == 2 then
        local cloned_holder = persistence.register_writer(holder.clones[names.writer.BUILDING],
            holder.clones[names.writer.SIGNAL_RECEIVER])
        persistence.copy_writer_options(holder, cloned_holder)
        holder.clones = nil
    end
end

function _M.on_destroyed(entity, player_index, spill_inventory)
    local surface = entity.surface
    local writer = find_writer(entity)
    if writer == nil then return end
    local holder = persistence.writers()[writer.unit_number]
    if holder then
        persistence.delete_writer(holder)
        if player_index ~= nil then
            game.players[player_index].mine_entity(holder.writer, true)
        elseif spill_inventory then
            utils.spill_items(surface, entity.position, entity.force,
                holder.writer.get_inventory(defines.inventory.furnace_source))
            utils.spill_items(surface, entity.position, entity.force,
                holder.writer.get_inventory(defines.inventory.furnace_result))
            if holder.writer.is_crafting() then
                local temp_inventory = game.create_inventory(1)
                temp_inventory.insert { name = names.memorycard.ITEM, count = 1, }
                utils.spill_items(surface, entity.position, entity.force, temp_inventory)
                temp_inventory.destroy()
            end
            holder.writer.destroy()
        end
    end
end

function _M.on_gui_opened(entity, player_index)
    local writer = find_writer(entity)
    local player = game.get_player(player_index)
    if writer and player then
        player.opened = writer
        gui.open_options_gui(player, persistence.writers()[writer.unit_number])
    end
end

function _M.on_gui_closed(_, player_index)
    local player = game.get_player(player_index)
    if not player then return end
    gui.close_options_gui(player)
end

function _M.on_tick()
    for _, holder in pairs(persistence.writers()) do
        local inventory = holder.writer.get_output_inventory()
        if not inventory.is_empty() then
            local item = inventory[1]

            if item.name == names.memorycard.ITEM and memorycard.unwritten(item) then
                local signals = get_signals(holder)
                memorycard.save_data(item, signals, holder.options)
            end

            if holder.animation == nil then
                holder.animation = rendering.draw_animation({
                    animation = names.writer.READY_ANIMATION,
                    target = holder.writer,
                    surface = holder.writer.surface,
                })
                holder.writer.active = false
            end
        elseif holder.animation ~= nil then
            rendering.destroy(holder.animation)
            holder.animation = nil
            holder.writer.active = true
        end
    end
end

function _M.on_player_fast_inserted(entity, player)
    utils.fast_insert(player, find_writer(entity))
end

function _M.on_surface_erased(surface_index)
    local writers = persistence.writers()
    for key, holder in pairs(writers) do
        if holder.writer.surface_index == surface_index then
            writers[key] = nil
        end
    end
end

function _M.save_blueprint_data(entity, blueprint, index)
    local writer = find_writer(entity)
    if writer == nil then return end
    local holder = persistence.writers()[writer.unit_number]
    if holder == nil then return end
    blueprint.set_blueprint_entity_tag(index, USE_CHANNELS_TAG, holder.options.use_channels)
end

function _M.copy_settings(source, destination)
    local source_writer = find_writer(source)
    local destination_writer = find_writer(destination)
    local source_holder = persistence.writers()[source_writer.unit_number]
    local destination_holder = persistence.writers()[destination_writer.unit_number]
    if source_holder and destination_holder then
        persistence.copy_writer_options(source_holder, destination_holder)
    end
end

return _M
