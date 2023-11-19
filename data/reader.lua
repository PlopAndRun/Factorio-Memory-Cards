local names = require 'data.names'
local graphics = require 'graphics.definitions'

local inventory = table.deepcopy(data.raw['container']['wooden-chest'])
inventory.name = names.reader.CONTAINER
inventory.localised_name = 'Flash card reader'
inventory.inventory_size = 1
inventory.enable_inventory_bar = false
inventory.picture = graphics.transparent

local inventory = {
    type = 'container',
    name = names.reader.CONTAINER,
    inventory_size = 1,
    picture = graphics.transparent,
    enable_inventory_bar = false,
    flags = { 'placeable-off-grid' },
    selection_box = { { 0.5, 0.5 }, { 0.5, 0.5 } }
}

local connection_point = {
    wire = {
        red = { 0, 1 },
        green = { 0.1, 1 }
    },
    shadow = {
        red = { 0, 1 },
        green = { 0.1, 1 }
    }
}

local signal_sender = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])

signal_sender.type = 'constant-combinator'
signal_sender.name = names.reader.SIGNAL_SENDER
signal_sender.sprites = graphics.reader_entity.idle
signal_sender.activity_led_sprites = graphics.reader_entity.active
signal_sender.activity_led_light_offsets = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } }
signal_sender.selection_priority = 40
signal_sender.items_to_place_this = { names.reader.ITEM }
signal_sender.minable = {
    mining_time = 1,
    result = names.reader.ITEM
}

local item = {
    type = 'item',
    name = names.reader.ITEM,
    localised_name = inventory.localised_name,
    stack_size = 50,
    icon = '__base__/graphics/icons/constant-combinator.png',
    icon_size = 64,
    place_result = signal_sender.name,
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
