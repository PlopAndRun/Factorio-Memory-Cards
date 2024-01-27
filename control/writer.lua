local persistence = require 'persistence'
local memorycard = require 'control.memorycard'
local utils = require 'utils'
local _M = {}
local names = utils.names

local function find_writer(entity)
    return entity.surface.find_entity(names.writer.BUILDING, entity.position)
end

function _M.on_built(entity)
    local surface = entity.surface
    local position = entity.position
    local writer, receiver
    if entity.name == names.writer.BUILDING then
        writer = entity
        receiver = surface.create_entity {
            name = names.writer.SIGNAL_RECEIVER,
            position = position,
            force = entity.force,
            create_build_effect_smoke = false
        }
    else
        receiver = entity
        writer = surface.create_entity {
            name = names.writer.BUILDING,
            position = position,
            force = entity.force,
            create_build_effect_smoke = false
        }
    end
    persistence.register_writer(writer, receiver)
end

function _M.on_cloned(source, destination)
    local writer = find_writer(source)
    if writer == nil then return end;
    local holder = persistence.writers()[writer.unit_number]
    if holder.clones == nil then
        holder.clones = { total = 0 }
    end

    holder.clones[destination.name] = destination
    holder.clones.total = holder.clones.total + 1
    if holder.clones.total == 2 then
        persistence.register_writer(holder.clones[names.writer.BUILDING], holder.clones[names.writer.SIGNAL_RECEIVER])
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
                temp_inventory.insert { name = names.memorycard.ITEM, count = 1 }
                utils.spill_items(surface, entity.position, entity.force, temp_inventory)
                temp_inventory.destroy()
            end
            holder.writer.destroy()
        end
    end
end

function _M.on_gui_opened(entity, player_index)
    local writer = find_writer(entity)
    if writer then
        game.get_player(player_index).opened = writer
    end
end

function _M.on_tick()
    for _, holder in pairs(persistence.writers()) do
        local inventory = holder.writer.get_output_inventory()
        if not inventory.is_empty() then
            local item = inventory[1]
            if item.name == names.memorycard.ITEM and memorycard.unwritten(item) then
                local signals = holder.receiver.get_merged_signals();
                memorycard.save_data(item, signals)
            end
            if holder.animation == nil then
                holder.animation = rendering.draw_animation({
                    animation = names.writer.READY_ANIMATION,
                    target = holder.writer,
                    surface = holder.writer.surface
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

return _M
