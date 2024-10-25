local persistence = require 'persistence'
local memorycard = require 'control.memorycard'
local utils = require 'utils'
local gui = require 'control.writer_gui'
local names = utils.names
local _M = {}

local USE_CHANNELS_TAG = names.MOD_PREFIX .. 'use-channels'
local LABEL_TAG = names.MOD_PREFIX .. 'label'
local LIST_CONTENTS_TAG = names.MOD_PREFIX .. 'list-contents'

local function get_signals(holder)
    if holder.options.use_channels then
        return {
            combined = {},
            red = holder.writer.get_signals(defines.wire_connector_id.circuit_red),
            green = holder.writer.get_signals(defines.wire_connector_id.circuit_green),
        }
    else
        return {
            combined = holder.writer.get_signals(
                defines.wire_connector_id.circuit_red,
                defines.wire_connector_id.circuit_green),
            red = {},
            green = {},
        }
    end
end

function _M.on_built(writer, tags)
    local holder = persistence.register_writer(writer)
    if tags then
        if tags[USE_CHANNELS_TAG] ~= nil then
            holder.options.use_channels = tags[USE_CHANNELS_TAG]
        end
        if tags[LABEL_TAG] ~= nil then
            holder.options.label = tags[LABEL_TAG]
        end
        if tags[LIST_CONTENTS_TAG] ~= nil then
            holder.options.list_contents = tags[LIST_CONTENTS_TAG]
        end
    end
end

function _M.on_cloned(writer, destination)
    if writer == nil then return end;
    local holder = persistence.writers()[writer.unit_number]
    local cloned_holder = persistence.register_writer(destination)
    persistence.copy_writer_options(holder, cloned_holder)
end

function _M.on_destroyed(writer)
    if writer == nil then return end
    local holder = persistence.writers()[writer.unit_number]
    if holder ~= nil then
        persistence.delete_writer(holder)
    end
end

function _M.on_gui_opened(writer, player_index)
    local player = game.get_player(player_index)
    if writer and player then
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
            holder.animation.destroy()
            holder.animation = nil
            holder.writer.active = true
        end
    end
end

function _M.on_surface_erased(surface_index)
    local writers = persistence.writers()
    for key, holder in pairs(writers) do
        if holder.writer.surface_index == surface_index then
            writers[key] = nil
        end
    end
end

function _M.save_blueprint_data(writer, blueprint, index)
    if writer == nil then return end
    local holder = persistence.writers()[writer.unit_number]
    if holder == nil then return end
    blueprint.set_blueprint_entity_tag(index, USE_CHANNELS_TAG, holder.options.use_channels)
    blueprint.set_blueprint_entity_tag(index, LABEL_TAG, holder.options.label)
    blueprint.set_blueprint_entity_tag(index, LIST_CONTENTS_TAG, holder.options.list_contents)
end

function _M.copy_settings(source, destination)
    local source_holder = persistence.writers()[source.unit_number]
    local destination_holder = persistence.writers()[destination.unit_number]
    if source_holder and destination_holder then
        persistence.copy_writer_options(source_holder, destination_holder)
    end
end

return _M
