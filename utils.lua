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

function _M.add_recipe_to_unlocks(recipe)
    table.insert(data.raw["technology"]["circuit-network"].effects, {
        type = 'unlock-recipe',
        recipe = recipe.name,
    })
end

_M.constants = {
    READER_SLOTS = 20,
    HIDDEN_ENTITY_FLAGS = { 'placeable-off-grid',
        'not-on-map',
        'not-deconstructable',
        'not-blueprintable',
        'hidden',
        'hide-alt-info',
        'not-flammable',
        'no-copy-paste',
        'not-selectable-in-game',
        'not-in-kill-statistics',
    },
}

_M.names = {}
_M.names.MOD_PREFIX = 'memorycards-'

_M.names.memorycard = {}
_M.names.memorycard.ITEM = _M.names.MOD_PREFIX .. 'memorycard'
_M.names.memorycard.WRITE_RESULT_ITEM = _M.names.MOD_PREFIX .. 'memorycard-written'
_M.names.memorycard.RECIPE = _M.names.memorycard.ITEM

_M.names.writer = {}
_M.names.writer.WRITE_RECIPE = _M.names.MOD_PREFIX .. 'write-recipe'
_M.names.writer.BUILDING = _M.names.MOD_PREFIX .. 'writer'
_M.names.writer.ITEM = _M.names.writer.BUILDING
_M.names.writer.RECIPE = _M.names.writer.ITEM
_M.names.writer.RECIPE_CATEGORY = _M.names.MOD_PREFIX .. 'write-recipe-category'
_M.names.writer.SIGNAL_RECEIVER = _M.names.MOD_PREFIX .. 'writer-signal-receiver'
_M.names.writer.READY_ANIMATION = _M.names.MOD_PREFIX .. 'writer-ready-animation'

_M.names.reader = {}
_M.names.reader.CONTAINER = _M.names.MOD_PREFIX .. 'reader'
_M.names.reader.ITEM = _M.names.reader.CONTAINER
_M.names.reader.RECIPE = _M.names.reader.CONTAINER
_M.names.reader.SIGNAL_SENDER = _M.names.MOD_PREFIX .. 'reader-signal-sender'
_M.names.reader.SIGNAL_SENDER_CELL = _M.names.MOD_PREFIX .. 'reader-signal-sender-cell'

_M.names.signal = {}
_M.names.signal.INSERTED = _M.names.MOD_PREFIX .. 'signal-inserted'

return _M
