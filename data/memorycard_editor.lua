local names = require('utils').names
local graphics = require 'graphics.definitions'

local shortcut = {
    type = 'shortcut',
    action = 'lua',
    name = names.memorycard_editor.SHORTCUT,
    localised_name = { 'memorycards-editor.name', },
    icon = graphics.editor_shortcut.normal.filename,
    icon_size = graphics.editor_shortcut.normal.size,
    small_icon = graphics.editor_shortcut.small.filename,
    small_icon_size = graphics.editor_shortcut.small.size,
    disabled_small_icon = graphics.editor_shortcut.disabled_small,
}

local placeholder_sprite = {
    type = 'sprite',
    name = names.memorycard_editor.PLACEHOLDER_SPRITE,
    layers = {
        graphics.editor_card_placeholder,
    },
}

return {
    register = function ()
        data:extend({ shortcut, placeholder_sprite, })
    end,
};
