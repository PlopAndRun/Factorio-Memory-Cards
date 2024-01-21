local names = require('utils').names
local writer = require 'control.writer'
local reader = require 'control.reader'
local memorycard_editor = require 'control.memorycard_editor'
local persistence = require 'persistence'

local function on_built(event)
    local entity = event.created_entity or event.entity
    if entity.name == names.writer.BUILDING or entity.name == names.writer.SIGNAL_RECEIVER then
        writer.on_built(entity)
    elseif entity.name == names.reader.SIGNAL_SENDER then
        reader.on_built(entity)
    end
end

local function on_cloned(event)
    local source = event.source
    if source.name == names.writer.BUILDING or source.name == names.writer.SIGNAL_RECEIVER then
        writer.on_cloned(source, event.destination)
    elseif source.name == names.reader.SIGNAL_SENDER or source.name == names.reader.CONTAINER or source.name == names.reader.SIGNAL_SENDER_CELL then
        reader.on_cloned(source, event.destination)
    end
end

local function on_destroyed(event)
    local entity = event.entity
    if entity.name == names.writer.BUILDING or entity.name == names.writer.SIGNAL_RECEIVER then
        writer.on_destroyed(entity, event.player_index)
    elseif entity.name == names.reader.SIGNAL_SENDER or entity.name == names.reader.CONTAINER then
        reader.on_destroyed(entity, event.player_index)
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
    if entity.name == names.reader.SIGNAL_SENDER then
        reader.on_gui_opened(entity, event.player_index)
    elseif entity.name == names.writer.SIGNAL_RECEIVER then
        writer.on_gui_opened(entity, event.player_index)
    end
end

local function on_player_fast_transferred(event)
    local entity = event.entity
    if not entity then return end
    if not event.from_player then return end -- an attempt to transfer from a lamp does not trigger an event
    if entity.name == names.reader.SIGNAL_SENDER then
        reader.on_player_fast_inserted(entity, game.get_player(event.player_index))
    elseif entity.name == names.writer.SIGNAL_RECEIVER then
        writer.on_player_fast_inserted(entity, game.get_player(event.player_index))
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
    end
end

local function on_gui_elem_changed(event)
    if event.element.name:find(names.memorycard_editor.gui.PATTERN) == 1 then
        memorycard_editor.on_gui_elem_changed(event.player_index, event.element)
    end
end

local function on_player_changed_force(event)
    memorycard_editor.on_player_changed_force(game.get_player(event.player_index))
end

local function on_player_removed(event)
    persistence.on_player_removed(event.player_index)
end

script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.on_entity_cloned, on_cloned)
script.on_event(defines.events.on_pre_surface_cleared, on_surface_erased)
script.on_event(defines.events.on_pre_surface_deleted, on_surface_erased)

script.on_event(defines.events.on_pre_player_mined_item, on_destroyed)
script.on_event(defines.events.on_robot_pre_mined, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)

script.on_event(defines.events.on_tick, on_tick)

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_player_fast_transferred, on_player_fast_transferred)
script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)
script.on_event(defines.events.on_player_changed_force, on_player_changed_force)
script.on_event(defines.events.on_player_removed, on_player_removed)
