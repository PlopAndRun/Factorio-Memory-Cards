local names = require 'data.names'
local persistence = require 'persistence'
local flashcard = require 'control.flashcard'

local _M = {}

function _M.on_built(reader)
    local surface = reader.surface
    local position = reader.position
    position.x = position.x + 1
    local sender = surface.create_entity {
        name = names.reader.SIGNAL_SENDER,
        position = position,
        force = reader.force,
        create_build_effect_smoke = false,
    }
    persistence.register_reader(reader, sender)
end

function _M.on_destroyed(reader)
    local holder = persistence.readers()[reader.unit_number]
    if holder then
        persistence.delete_reader(reader)
        holder.sender.destroy()
    end
end

function _M.on_tick()
    for _, reader in pairs(persistence.readers()) do
        local inventory = reader.entity.get_inventory(defines.inventory.chest)
        if not inventory.is_empty()
            and inventory[1].name == names.flashcard.ITEM
        then
            local control_behavior = reader.sender.get_or_create_control_behavior()
            local data = flashcard.read_data(inventory[1]);
            control_behavior.parameters = data
        else
            local control_behavior = reader.sender.get_or_create_control_behavior()
            control_behavior.parameters = {}
        end
    end
end

return _M
