local utils = require 'utils'
local graphics = require 'graphics.definitions'
local names = utils.names
local other_mods = utils.other_mods

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

if other_mods.ULTRACUBE then
    recipe.ingredients[2] = { 'cube-basic-matter-unit', 1 }
    recipe.order = 'cube-' .. recipe.order
    recipe.category = 'cube-fabricator-handcraft'
    item.subgroup = 'cube-combinator-extra'
end

return {
    register = function()
        data:extend({ item, recipe })
        utils.add_recipe_to_unlocks(recipe)
    end
}
