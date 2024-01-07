local utils = require 'utils'
local graphics = require 'graphics.definitions'
local names = utils.names

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
        { 'electronic-circuit', 1 },
        { 'plastic-bar',        1 },
    },
    enabled = false,
    order = 'c[combinators]-f[flashcard]',
}

return {
    register = function()
        data:extend({ item, recipe })
        utils.add_recipe_to_unlocks(recipe)
    end
}
