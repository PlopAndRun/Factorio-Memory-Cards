local _M = {}

function _M.spill_items(surface, position, force, inventory)
    for _, index in pairs(inventory.get_contents()) do
        local item = inventory[index]
        local spilled = surface.spill_item_stack(position, item, false, force, false)
        for _, entity in pairs(spilled) do
            entity.order_deconstruction(force)
        end
    end
end

function _M.fast_insert(player, entity)
    if not player.cursor_stack then return end
    if not entity then return end
    if entity.insert(player.cursor_stack) > 0 then
        player.play_sound({ path = 'utility/inventory_move' })
        player.cursor_stack.clear()
    end
end

return _M