local names = require 'data.names'
local writer = require 'control.writer'
local reader = require 'control.reader'

local function on_built(event)
    local entity = event.created_entity or event.entity
    if entity.name == names.writer.BUILDING then
        writer.on_built(entity)
    elseif entity.name == names.reader.CONTAINER then
        reader.on_built(entity)
    end
end

local function on_destroyed(event)
    local entity = event.entity
    if entity.name == names.writer.BUILDING then
        writer.on_destroyed(entity)
    elseif entity.name == names.reader.CONTAINER then
        reader.on_destroyed(reader)
    end
end

local function on_tick()
    writer.on_tick()
    reader.on_tick()
end

script.on_event(defines.events.on_built_entity, on_built)

script.on_event(defines.events.on_pre_player_mined_item, on_destroyed)
script.on_event(defines.events.on_robot_pre_mined, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)

script.on_event(defines.events.on_tick, on_tick)
