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

_M.names.styles = {}
_M.names.styles.STYLE_PREFIX = _M.names.MOD_PREFIX .. 'style-'
_M.names.styles.DRAGGABLE_HEADER = _M.names.styles.STYLE_PREFIX .. 'draggable-header'
_M.names.styles.SPACER = _M.names.styles.STYLE_PREFIX .. 'spacer'
_M.names.styles.CARD_SLOT_ROW = _M.names.styles.STYLE_PREFIX .. 'card-slot-row'
_M.names.styles.COPY_BUTTON = _M.names.styles.STYLE_PREFIX .. 'copy-button'
_M.names.styles.PASTE_BUTTON = _M.names.styles.STYLE_PREFIX .. 'paste-button'
_M.names.styles.CARD_MEMORY_SCROLLBAR = _M.names.styles.STYLE_PREFIX .. 'card-memory-scrollbar'
_M.names.styles.CARD_SIGNALS_FRAME = _M.names.styles.STYLE_PREFIX .. 'card-signals-frame'
_M.names.styles.CARD_SIGNALS_TABLE_STYLE = _M.names.styles.STYLE_PREFIX .. 'card-signals-table-style'
_M.names.styles.CARD_SIGNAL_BUTTON = _M.names.styles.STYLE_PREFIX .. 'card-signal-button'
_M.names.styles.RESET_BUTTON = _M.names.styles.STYLE_PREFIX .. 'reset-button'
_M.names.styles.EDITOR_SIGNALS_SCROLLBAR = _M.names.styles.STYLE_PREFIX .. 'editor-signals-scrollbar'
_M.names.styles.EDITOR_SIGNALS_CONTAINER = _M.names.styles.STYLE_PREFIX .. 'editor-signals-container'
_M.names.styles.EDITOR_SINGLE_SIGNAL_CONTAINER = _M.names.styles.STYLE_PREFIX .. 'editor-single-signal-container'
_M.names.styles.EDITOR_SIGNAL_COUNT = _M.names.styles.STYLE_PREFIX .. 'editor-signal-count'

_M.names.memorycard = {}
_M.names.memorycard.ITEM = _M.names.MOD_PREFIX .. 'memorycard'
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

_M.names.memorycard_editor = {}
_M.names.memorycard_editor.SHORTCUT = _M.names.MOD_PREFIX .. 'memorycard-editor-shortcut'
_M.names.memorycard_editor.PLACEHOLDER_SPRITE = _M.names.MOD_PREFIX .. 'memorycard-editor-placeholder'
_M.names.memorycard_editor.gui = {}
_M.names.memorycard_editor.gui.NAME = _M.names.MOD_PREFIX .. 'memorycard-editor-gui'
_M.names.memorycard_editor.gui.PATTERN = '^' .. _M.names.memorycard_editor.gui.NAME
    :gsub('%-', '%%-')
    :gsub('%.', '%%.')


return _M
