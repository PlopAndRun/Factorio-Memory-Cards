local names = require 'data.names'
local graphics = require 'graphics.definitions'

local writing_recipe = {
    type = 'recipe',
    name = names.writer.WRITE_RECIPE,
    ingredients = {
        { names.flashcard.ITEM, 1 }
    },
    result = names.flashcard.ITEM,
    energy_required = 1,
    hidden = true,
    hide_from_stats = true,
    hide_from_player_crafting = true,
    allow_as_intermediate = false,
    allow_intermediates = false,
}

local building = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
building.name = names.writer.BUILDING
building.localised_name = 'Flash card writer'
building.fixed_recipe = writing_recipe.name
building.ingredient_count = 1
building.energy_usage = '1W'
building.crafting_speed = 1
building.crafting_categories = { 'crafting' }
building.show_recipe_icon = false
building.fast_replaceable_group = nil
building.next_upgrade = nil
building.additional_pastable_entities = nil

local item = {
    type = 'item',
    name = names.writer.ITEM,
    localised_name = building.localised_name,
    stack_size = 50,
    icon = '__base__/graphics/icons/assembling-machine-1.png',
    icon_size = 64,
    place_result = building.name,
    subgroup = 'circuit-network',
}

local recipe = {
    type = 'recipe',
    name = names.writer.RECIPE,
    icon = item.icon,
    icon_size = item.icon_size,
    ingredients = {
        { 'constant-combinator',  1 },
        { 'assembling-machine-1', 1 }
    },
    result = item.name,
    energy_required = 1,
}

local connection_point = {
    wire = {
        red = { 0, 0 },
        green = { 0, 0 }
    },
    shadow = {
        red = { 0, 0 },
        green = { 0, 0 }
    }
}

local signal_receiver = table.deepcopy(data.raw['lamp']['small-lamp'])
signal_receiver.name = names.writer.SIGNAL_RECEIVER;
signal_receiver.flags = { 'placeable-off-grid' };
signal_receiver.collision_mask = {};
signal_receiver.circuit_wire_max_distance = 3;
signal_receiver.circuit_wire_connection_points = { connection_point, connection_point, connection_point, connection_point };
signal_receiver.sticker_box = { { -0.5, -0.5 }, { 0.5, 0.5 } };
signal_receiver.selection_priority = 60;

-- signal_receiver.picture_on = graphics.transparent;
-- signal_receiver.picture_off = graphics.transparent;
signal_receiver.energy_usage_per_tick = '1W';
signal_receiver.energy_source = { type = 'void' };

return {
    register = function()
        data:extend({
            item,
            building,
            recipe,
            writing_recipe,
            signal_receiver,
        });
    end
}
