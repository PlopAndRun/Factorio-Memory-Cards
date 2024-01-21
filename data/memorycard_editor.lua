local names = require('utils').names
local graphics = require 'graphics.definitions'

local shortcut = {
    type = 'shortcut',
    action = 'lua',
    name = names.memorycard_editor.SHORTCUT,
    localised_name = { 'memorycards-editor.name', },
    icon = graphics.editor_shortcut.normal,
    small_icon = graphics.editor_shortcut.small,
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
