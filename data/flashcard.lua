local names = require 'data.names'
local graphics = require 'graphics.definitions'

local item = {
    type = 'item-with-tags',
    name = names.flashcard.ITEM,
    icons = { graphics.flash_card_item },
    subgroup = 'circuit-network',
    stack_size = 1,
    localised_name = 'Flash card',
    flags = { 'not-stackable' }
}

local recipe = {
    type = 'recipe',
    name = names.flashcard.RECIPE,
    result = item.name,
    ingredients = {
        { 'electronic-circuit', 1 }
    }
}

return {
    register = function()
        data:extend({ item, recipe })
    end
}
