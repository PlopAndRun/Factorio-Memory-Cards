local names = require 'data.names'
local persistence = require 'persistence'
local _M = {}

local INIT_FLAG = 'initialized'

local function save_data_on_flash_card(flashcard)
    if flashcard.name == names.flashcard.ITEM then
        if flashcard.get_tag(INIT_FLAG) ~= true then
            flashcard.set_tag(INIT_FLAG, true)
            flashcard.custom_description = "Initialized"
        end
    end
end

function _M.on_built(writer)
    local surface = writer.surface
    local position = writer.position
    position.x = position.x;
    local receiver = surface.create_entity {
        name = names.writer.SIGNAL_RECEIVER,
        position = position,
        force = writer.force,
        create_build_effect_smoke = false
    }
        persistence.register_writer(writer, receiver)
end

function _M.on_destroyed(writer)
    local holder = persistence.writers()[writer.unit_number]
    if holder then
        persistence.delete_writer(writer)
        holder.receiver.destroy()
    end
end

function _M.on_tick()
    for _, writer in pairs(persistence.writers()) do
        local inventory = writer.entity.get_output_inventory()
        if not inventory.is_empty() then
            save_data_on_flash_card(inventory[1])
        end
    end
end

return _M
