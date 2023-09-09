local names = require 'data.names'

local building = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
building.name = names.reader.BUILDING
building.localised_name = 'Flash card reader'
building.item_slot_count = 1

local item = {
    type = 'item',
    name = names.reader.ITEM,
    localised_name = building.localised_name,
    stack_size = 50,
    icon = '__base__/graphics/icons/constant-combinator.png',
    icon_size = 64,
    place_result = building.name,
    subgroup = 'circuit-network',
}

local recipe = {
    type = 'recipe',
    name = names.reader.RECIPE,
    icon = item.icon,
    icon_size = item.icon_size,
    ingredients = {
        { 'decider-combinator',    1 },
        { 'arithmetic-combinator', 1 }
    },
    result = item.name,
    energy_required = 1
}

return {
    register = function()
        data:extend({ item, recipe, building })
    end
}
