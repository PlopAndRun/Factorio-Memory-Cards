local utils = require 'utils'
local graphics = require 'graphics.definitions'
local names = utils.names
local constants = utils.constants

local writing_recipe_category = {
    type = 'recipe-category',
    name = names.writer.RECIPE_CATEGORY
}

local freshly_written_flashcard = {
    type = 'item',
    name = names.flashcard.WRITE_RESULT_ITEM,
    icons = { graphics.flash_card_item },
    localised_name = 'asdf',
    subgroup = 'circuit-network',
    stack_size = 1,
    flags = { 'not-stackable' },
}

local writing_recipe = {
    type = 'recipe',
    category = writing_recipe_category.name,
    name = names.writer.WRITE_RECIPE,
    ingredients = {
        { names.flashcard.ITEM, 1 }
    },
    result = names.flashcard.WRITE_RESULT_ITEM,
    energy_required = 1,
    hidden = false,
    hide_from_stats = false,
    hide_from_player_crafting = true,
    allow_as_intermediate = false,
    allow_intermediates = false,
}

local building = {
    type = 'furnace',
    name = names.writer.BUILDING,
    localised_name = 'Flash card writer',
    flags = constants.HIDDEN_ENTITY_FLAGS,
    energy_usage = '50W',
    crafting_speed = 1.0,
    crafting_categories = { writing_recipe_category.name },
    show_recipe_icon = false,
    energy_source = { type = 'electric', usage_priority = 'secondary-input' },
    allowed_effects = 'speed',
    always_draw_idle_animation = true,
    idle_animation = graphics.writer_entity.idle_animation,
    working_visualisations = { {
        render_layer = 'object',
        animation = graphics.writer_entity.crafting_animation,
        always_draw = false
    } },
    minable = { mining_time = 0.5 },
    match_animation_speed_to_activity = false,
    show_recipe_icon_on_map = false,
    module_specifications = { module_slots = 1 },
    icons = { graphics.writer_item },
    collision_box = { { -0.4, -0.9 }, { 0.4, 0.9 } },
    collision_mask = { 'item-layer', 'object-layer', 'player-layer', 'water-tile' },
    selection_box = { { 0, 0 }, { 0, 0 } },
    subgroup = 'circuit-network',
    allow_copy_paste = true,
    selectable_in_game = true,
    selection_priority = 0,
    source_inventory_size = 1,
    result_inventory_size = 1,
}

local item = {
    type = 'item',
    name = names.writer.ITEM,
    localised_name = building.localised_name,
    stack_size = 50,
    icons = { graphics.writer_item },
    place_result = names.writer.SIGNAL_RECEIVER,
    subgroup = 'circuit-network',
}

local recipe = {
    type = 'recipe',
    name = names.writer.RECIPE,
    icon = item.icon,
    icon_size = item.icon_size,
    ingredients = {
        { 'constant-combinator', 1 },
        { 'electronic-circuit',  2 }
    },
    result = item.name,
    energy_required = 1,
    enabled = false,
    order = 'c[combinators]-f[flashcard-writer]',
}

local connection_point = {
    red = { 0.08, 0.8 },
    green = { -0.12, 0.8 }
}

local signal_receiver = {
    type = 'lamp',
    flags = { 'player-creation' },
    is_military_target = false,
    name = names.writer.SIGNAL_RECEIVER,
    localised_name = building.localised_name,
    localised_description = building.localised_description,
    picture_on = building.idle_animation,
    picture_off = building.idle_animation,
    energy_usage_per_tick = '1W',
    energy_source = { type = 'void' },
    circuit_wire_connection_point = {
        wire = connection_point,
        shadow = connection_point
    },
    collision_box = { { -0.4, -0.9 }, { 0.4, 0.9 } },
    collision_mask = { 'item-layer', 'object-layer', 'player-layer', 'water-tile' },
    minable = { mining_time = 0.5, result = names.writer.ITEM },
    circuit_wire_max_distance = 9,
    draw_circuit_wires = true,
    always_on = true,
    selectable_in_game = true,
    selection_box = { { -0.5, -1 }, { 0.5, 1 } },
    placeable_by = { item = names.writer.ITEM, count = 1 },
}

local animation = table.deepcopy(graphics.writer_entity.ready_animation)
animation.type = 'animation'
animation.name = names.writer.READY_ANIMATION

return {
    register = function()
        data:extend({
            writing_recipe_category,
            item,
            freshly_written_flashcard,
            building,
            recipe,
            writing_recipe,
            signal_receiver,
            animation,
        });
        utils.add_recipe_to_unlocks(recipe)
    end
}
