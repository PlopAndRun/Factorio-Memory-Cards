local utils = require('utils')

local item = {
    type = 'item',
    name = utils.mod_prefix .. 'flashcard',
    icon = '__base__/graphics/icons/water-wube.png',
    icon_size = 32,
    subgroup = 'circuit-network',
    stack_size = 1,
    localised_name = 'Flash card',
    flags = { 'not-stackable' }
}

local recipe = {
    type = 'recipe',
    name = item.name,
    result = item.name,
    ingredients = {
        { 'electronic-circuit', 1 }
    }
}

local function register()
    data:extend({ item, recipe })
end

return { register = register, item = item, recipe = recipe }