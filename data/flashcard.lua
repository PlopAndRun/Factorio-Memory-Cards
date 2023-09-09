local names = require 'data.names'

local item = {
    type = 'item-with-tags',
    name = names.flashcard.ITEM,
    icon = '__base__/graphics/icons/water-wube.png',
    icon_size = 32,
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
