local names = require 'data.names'

local inventory = table.deepcopy(data.raw['container']['wooden-chest'])
inventory.name = names.reader.CONTAINER
inventory.localised_name = 'Flash card reader'
inventory.inventory_size = 1
inventory.enable_inventory_bar = false

local signal_sender = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
signal_sender.name = names.reader.SIGNAL_SENDER
signal_sender.flags = { 'placeable-off-grid' }
signal_sender.collision_mask = {}
signal_sender.selection_priority = 60

local item = {
    type = 'item',
    name = names.reader.ITEM,
    localised_name = inventory.localised_name,
    stack_size = 50,
    icon = '__base__/graphics/icons/constant-combinator.png',
    icon_size = 64,
    place_result = inventory.name,
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
        data:extend({ item, recipe, inventory, signal_sender })
    end
}
