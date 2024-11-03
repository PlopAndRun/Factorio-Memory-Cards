local persistence = require 'persistence'
local memorycard = require 'control.memorycard'
local utils = require 'utils'
local gui = require 'control.writer_gui'
local names = utils.names
local tag_names = utils.tags.writer;
local _M = {}

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
        if tags[tag_names.USE_CHANNELS_TAG] ~= nil then
            holder.options.use_channels = tags[tag_names.USE_CHANNELS_TAG]
        end
        if tags[tag_names.LABEL_TAG] ~= nil then
            holder.options.label = tags[tag_names.LABEL_TAG]
        end
        if tags[tag_names.LIST_CONTENTS_TAG] ~= nil then
            holder.options.list_contents = tags[tag_names.LIST_CONTENTS_TAG]
        end
        local opened_by = tags[utils.tags.opened_by] or {}
        for player, _ in pairs(opened_by) do
            gui.on_opened_entity_built(tonumber(player), holder)
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
    local holder = persistence.writers()[writer.unit_number]

    if writer and player then
        gui.open_options_gui(player, { holder = holder, })
    end
end

function _M.on_ghost_gui_opened(writer, player_index)
    local player = game.get_player(player_index)
    if writer and player then
        local tags = writer.tags or {}
        if tags[utils.tags.opened_by] == nil then
            tags[utils.tags.opened_by] = {}
        end
        tags[utils.tags.opened_by][tostring(player_index)] = true
        writer.tags = tags
        gui.open_options_gui(player, { ghost = writer, })
    end
end

function _M.on_gui_closed(entity, player_index)
    local player = game.get_player(player_index)
    if not player then return end
    if entity.name == 'entity-ghost' then
        local tags = entity.tags or {}
        tags[utils.tags.opened_by][tostring(player_index)] = nil
        entity.tags = tags
    end
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
    blueprint.set_blueprint_entity_tag(index, tag_names.USE_CHANNELS_TAG, holder.options.use_channels)
    blueprint.set_blueprint_entity_tag(index, tag_names.LABEL_TAG, holder.options.label)
    blueprint.set_blueprint_entity_tag(index, tag_names.LIST_CONTENTS_TAG, holder.options.list_contents)
end

local function read_options(machine)
    if machine.tags ~= nil then
        return {
            use_channels = machine.tags[tag_names.USE_CHANNELS_TAG],
            label = machine.tags[tag_names.LABEL_TAG],
            list_contents = machine.tags[tag_names.LIST_CONTENTS_TAG],
        }
    end
    local holder = persistence.writers()[machine.unit_number]
    return holder and holder.options or {}
end

local function write_options(machine, options)
    if machine.name == 'entity-ghost' then
        local tags = machine.tags or {}
        tags[tag_names.USE_CHANNELS_TAG] = options.use_channels
        tags[tag_names.LABEL_TAG] = options.label
        tags[tag_names.LIST_CONTENTS_TAG] = options.list_contents
        machine.tags = tags
        return true
    end
    local holder = persistence.writers()[machine.unit_number]
    if holder ~= nil then
        persistence.copy_writer_options({ options = options, }, holder)
        return true
    end
    return false
end

function _M.copy_settings(source, destination, player_index)
    local options = read_options(source)
    if not options then return end
    if write_options(destination, options) then
        local player = game.players[player_index]
        player.play_sound { path = 'utility/entity_settings_pasted', }
    end
end

return _M
