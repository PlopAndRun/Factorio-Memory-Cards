local names = require('utils').names
local writer = require 'control.writer'
local writer_gui = require 'control.writer_gui'
local reader = require 'control.reader'
local reader_gui = require 'control.reader_gui'
local memorycard_editor = require 'control.memorycard_editor'
local persistence = require 'persistence'
local cmds = require 'commands'

local function on_built(event)
    local entity = event.created_entity or event.entity
    if entity.name == names.writer.BUILDING then
        writer.on_built(entity, event.tags)
    elseif entity.name == names.reader.SIGNAL_SENDER then
        reader.on_built(entity, event.tags)
    end
end

local function on_cloned(event)
    local source = event.source
    if source.name == names.writer.BUILDING or source.name == names.writer.SIGNAL_RECEIVER then
        writer.on_cloned(source, event.destination)
    elseif source.name == names.reader.SIGNAL_SENDER
        or source.name == names.reader.CONTAINER
        or source.name == names.reader.SIGNAL_SENDER_CELL
        or source.name == names.reader.SIGNAL_DIAGNOSTICS_CELL
    then
        reader.on_cloned(source, event.destination)
    end
end

local function real_or_ghost_name(entity)
    if entity.name == 'entity-ghost' then
        return entity.ghost_name
    else
        return entity.name
    end
end

local function on_entity_settings_pasted(event)
    local source = event.source
    local destination = event.destination
    local source_name = real_or_ghost_name(source)
    local destination_name = real_or_ghost_name(destination)
    if source_name == names.writer.BUILDING and destination_name == names.writer.BUILDING then
        writer.copy_settings(source, destination, event.player_index)
    elseif (source_name == names.reader.SIGNAL_SENDER or source_name == names.reader.CONTAINER)
        and (destination_name == names.reader.SIGNAL_SENDER or destination_name == names.reader.CONTAINER)
    then
        reader.copy_settings(source, destination, event.player_index)
    end
end

local function on_destroyed(event)
    local entity = event.entity
    if not entity then return end
    if entity.name == names.writer.BUILDING or entity.name == names.writer.SIGNAL_RECEIVER then
        writer.on_destroyed(entity)
    elseif entity.name == names.reader.SIGNAL_SENDER or entity.name == names.reader.CONTAINER then
        reader.on_destroyed(entity, event.player_index, true)
    end
end

local function on_destroyed_from_script(event)
    -- Don't spill inventory when destroyed by another mod to avoid duplicating items when the destruction is a part of a clone operation
    local entity = event.entity
    if entity.name == names.writer.BUILDING or entity.name == names.writer.SIGNAL_RECEIVER then
        writer.on_destroyed(entity)
    elseif entity.name == names.reader.SIGNAL_SENDER or entity.name == names.reader.CONTAINER then
        reader.on_destroyed(entity, event.player_index, false)
    end
end

local function on_surface_erased(event)
    writer.on_surface_erased(event.surface_index)
    reader.on_surface_erased(event.surface_index)
end

local function on_tick()
    writer.on_tick()
    reader.on_tick()
end

local function on_gui_opened(event)
    local entity = event.entity
    if not entity then return end

    if entity.name == 'entity-ghost' then
        if entity.ghost_name == names.writer.BUILDING then
            writer.on_ghost_gui_opened(entity, event.player_index)
        elseif entity.ghost_name == names.reader.SIGNAL_SENDER then
            local player = game.players[event.player_index]
            if player ~= nil then
                player.opened = nil
                game.print('Cannot edit reader settings in a ghost form')
            end
        end
    elseif entity.name == names.reader.SIGNAL_SENDER then
        reader.on_gui_opened(entity, event.player_index)
    elseif entity.name == names.writer.BUILDING then
        writer.on_gui_opened(entity, event.player_index)
    end
end

local function on_gui_closed(event)
    local entity = event.entity
    if not entity then return end
    local name = real_or_ghost_name(entity)
    if name == names.writer.BUILDING then
        writer.on_gui_closed(entity, event.player_index)
    elseif entity.name == names.reader.CONTAINER or entity.name == names.reader.SIGNAL_SENDER then
        reader.on_gui_closed(entity, event.player_index)
    end
end

local function on_player_fast_transferred(event)
    local entity = event.entity
    if not entity then return end
    if not event.from_player then return end -- an attempt to transfer from a lamp does not trigger an event
    if entity.name == names.reader.SIGNAL_SENDER then
        reader.on_player_fast_inserted(entity, game.get_player(event.player_index))
    end
end
local function on_lua_shortcut(event)
    if event.prototype_name == names.memorycard_editor.SHORTCUT then
        memorycard_editor.on_lua_shortcut(event.player_index)
    end
end

local function on_gui_click(event)
    if event.element.name:find(names.memorycard_editor.gui.PATTERN) == 1 then
        memorycard_editor.on_gui_click(event.player_index, event.element)
    elseif event.element.name:find(names.writer.gui.PATTERN) == 1 then
        writer_gui.on_gui_click(event.player_index, event.element)
    end
end

local function on_gui_checked_state_changed(event)
    if event.element.name:find(names.memorycard_editor.gui.PATTERN) == 1 then
        memorycard_editor.on_gui_checked_state_changed(event.player_index, event.element)
    elseif event.element.name:find(names.writer.gui.PATTERN) == 1 then
        writer_gui.on_gui_checked_state_changed(event.player_index, event.element)
    end
end

local function on_gui_switch_state_changed(event)
    if event.element.name:find(names.memorycard_editor.gui.PATTERN) == 1 then
        memorycard_editor.on_gui_switch_state_changed(event.player_index, event.element)
    end
end

local function on_gui_elem_changed(event)
    if event.element.name:find(names.memorycard_editor.gui.PATTERN) == 1 then
        memorycard_editor.on_gui_elem_changed(event.player_index, event.element)
    end
end

local function on_gui_selection_state_changed(event)
    if event.element.name:find(names.reader.gui.PATTERN) == 1 then
        local holder = reader_gui.on_gui_selection_state_changed(event.player_index, event.element)
        if holder then
            reader.apply_options(holder)
        end
    end
end

local function on_player_changed_force(event)
    memorycard_editor.on_player_changed_force(game.get_player(event.player_index))
end

local function on_player_removed(event)
    persistence.on_player_removed(event.player_index)
end


local function on_player_setup_blueprint(event)
    local blueprint = event.stack

    if not blueprint or not blueprint.valid_for_read then
        return
    end

    local mapping = event.mapping.get()
    for i, entity in pairs(mapping) do
        if entity.valid then
            if entity.name == names.writer.BUILDING or entity.name == names.writer.SIGNAL_RECEIVER then
                writer.save_blueprint_data(entity, blueprint, i)
            elseif entity.name == names.reader.CONTAINER or entity.name == names.reader.SIGNAL_SENDER then
                reader.save_blueprint_data(entity, blueprint, i)
            end
        end
    end
end

script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_space_platform_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_entity_cloned, on_cloned)
script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)
script.on_event(defines.events.on_pre_surface_cleared, on_surface_erased)
script.on_event(defines.events.on_pre_surface_deleted, on_surface_erased)

script.on_event(defines.events.on_pre_player_mined_item, on_destroyed)
script.on_event(defines.events.on_robot_pre_mined, on_destroyed)
script.on_event(defines.events.on_space_platform_mined_entity, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed_from_script)

script.on_event(defines.events.on_tick, on_tick)

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_player_fast_transferred, on_player_fast_transferred)
script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_checked_state_changed, on_gui_checked_state_changed)
script.on_event(defines.events.on_gui_switch_state_changed, on_gui_switch_state_changed)
script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)
script.on_event(defines.events.on_player_changed_force, on_player_changed_force)
script.on_event(defines.events.on_player_removed, on_player_removed)

script.on_event(defines.events.on_player_setup_blueprint, on_player_setup_blueprint)

commands.add_command('memorycards-healthcheck', { 'memorycards-commands.healthcheck-description', }, cmds.healthcheck)
