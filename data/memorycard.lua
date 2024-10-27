local utils = require 'utils'
local graphics = require 'graphics.definitions'
local names = utils.names
local other_mods = utils.other_mods

local item = {
    type = 'item-with-tags',
    name = names.memorycard.ITEM,
    icons = { graphics.memorycard_item, },
    subgroup = 'circuit-network',
    stack_size = 1,
    localised_name = { 'item-name.memorycard', },
    localised_description = { 'description.memorycard-empty', },
    flags = { 'not-stackable', },
    weight = 2000,
}

local recipe = {
    type = 'recipe',
    name = names.memorycard.RECIPE,
    localised_description = { 'description.memorycard', },
    results = { { type = 'item', name = item.name, amount = 1, }, },
    ingredients = {
        { type = 'item', name = 'electronic-circuit', amount = 1, },
        { type = 'item', name = 'plastic-bar',        amount = 1, },
    },
    allow_quality = false,
    enabled = false,
    order = 'c[combinators]-m[memorycard]',
}

if other_mods.ULTRACUBE then
    recipe.ingredients[2] = { type = 'item', name = 'cube-basic-matter-unit', amount = 1, }
    recipe.order = 'cube-' .. recipe.order
    recipe.category = 'cube-fabricator-handcraft'
    item.subgroup = 'cube-combinator-extra'
end

return {
    register = function ()
        data:extend({ item, recipe, })
        utils.add_recipe_to_unlocks(recipe)
    end,
}
