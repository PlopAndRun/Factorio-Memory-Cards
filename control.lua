local names = require('utils').names
local writer = require 'control.writer'
local reader = require 'control.reader'

local function on_built(event)
    local entity = event.created_entity or event.entity
    if entity.name == names.writer.BUILDING or entity.name == names.writer.SIGNAL_RECEIVER then
        writer.on_built(entity)
    elseif entity.name == names.reader.SIGNAL_SENDER then
        reader.on_built(entity)
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

script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)

script.on_event(defines.events.on_pre_player_mined_item, on_destroyed)
script.on_event(defines.events.on_robot_pre_mined, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)

script.on_event(defines.events.on_tick, on_tick)

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_player_fast_transferred, on_player_fast_transferred)
