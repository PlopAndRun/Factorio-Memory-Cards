local utils = require 'utils'
local graphics = require 'graphics.definitions'
local names = utils.names

local item = {
    type = 'item-with-tags',
    name = names.memorycard.ITEM,
    icons = { graphics.memorycard_item },
    subgroup = 'circuit-network',
    stack_size = 1,
    localised_name = { 'item-name.memorycard' },
    localised_description = { 'description.memorycard-empty' },
    flags = { 'not-stackable' },
}

local recipe = {
    type = 'recipe',
    name = names.memorycard.RECIPE,
    localised_description = { 'description.memorycard' },
    result = item.name,
    ingredients = {
        { 'electronic-circuit', 1 },
        { 'plastic-bar',        1 },
    },
    enabled = false,
    order = 'c[combinators]-m[memorycard]',
}

return {
    register = function()
        data:extend({ item, recipe })
        utils.add_recipe_to_unlocks(recipe)
    end
}
