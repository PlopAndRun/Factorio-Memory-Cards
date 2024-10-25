local utils = require 'utils'
local graphics = require 'graphics.definitions'
local names = utils.names
local other_mods = utils.other_mods

local writing_recipe_category = {
    type = 'recipe-category',
    name = names.writer.RECIPE_CATEGORY,
}

local writing_recipe = {
    type = 'recipe',
    category = writing_recipe_category.name,
    name = names.writer.WRITE_RECIPE,
    localised_name = { 'item-name.memorycard-write-recipe', },
    ingredients = {
        { type = 'item', name = names.memorycard.ITEM, amount = 1, },
    },
    results = { { type = 'item', name = names.memorycard.ITEM, amount = 1, }, },
    energy_required = 1,
    hidden = false,
    hidden_in_factoriopedia = true,
    hide_from_stats = false,
    hide_from_player_crafting = true,
    allow_as_intermediate = false,
    allow_intermediates = false,
}

local connection_point = {
    red = { 0.08, 0.8, },
    green = { -0.12, 0.8, },
}

local building = {
    -- entity
    type = 'assembling-machine',
    name = names.writer.BUILDING,
    localised_name = { 'item-name.memorycard-writer', },
    localised_description = { 'description.memorycard-writer', },
    flags = { 'player-creation', },
    subgroup = 'circuit-network',

    -- crafting
    energy_usage = '50W',
    energy_source = { type = 'electric', usage_priority = 'secondary-input', },
    crafting_speed = 1.0,
    crafting_categories = { writing_recipe_category.name, },
    fixed_recipe = writing_recipe.name,
    show_recipe_icon = false,
    allowed_effects = { 'speed', 'consumption', 'pollution', },
    show_recipe_icon_on_map = false,

    -- graphics and sound
    icons = { graphics.writer_item, },
    graphics_set = {
        animation = graphics.writer_entity.idle_animation,
        reset_animation_when_frozen = true,
        working_visualisations = { {
            animation = graphics.writer_entity.crafting_animation,
        },
        },
    },
    match_animation_speed_to_activity = false,
    open_sound = data.raw['assembling-machine']['assembling-machine-1'].open_sound,
    close_sound = data.raw['assembling-machine']['assembling-machine-1'].close_sound,

    -- circuit network
    circuit_connector = {
        {
            points = {
                wire = connection_point,
                shadow = connection_point,
            },
        },
        {
            points = {
                wire = connection_point,
                shadow = connection_point,
            },
        },
        {
            points = {
                wire = connection_point,
                shadow = connection_point,
            },
        },
        {
            points = {
                wire = connection_point,
                shadow = connection_point,
            },
        },
    },
    circuit_wire_max_distance = 9,
    draw_circuit_wires = true,
    enable_logistic_control_behavior = true,

    -- building
    minable = {
        mining_time = 0.5,
        result = names.writer.ITEM,
    },
    collision_box = { { -0.4, -0.9, }, { 0.4, 0.9, }, },
    collision_mask = { layers = { item = true, object = true, player = true, water_tile = true, }, },
    selection_box = { { -0.5, -1, }, { 0.5, 1, }, },
    allow_copy_paste = true,
    selectable_in_game = true,
    source_inventory_size = 1,
    result_inventory_size = 1,
    placeable_by = { item = names.writer.ITEM, count = 1, },

    -- misc
    se_allow_in_space = true,
}

local legacy_building = {
    type = 'furnace',
    name = names.writer.LEGACY_BUILDING,
    energy_usage = '50W',
    crafting_speed = 1.0,
    crafting_categories = { writing_recipe_category.name, },
    circuit_wire_connection_point = {
        wire = connection_point,
        shadow = connection_point,
    },
    show_recipe_icon = false,
    energy_source = { type = 'electric', usage_priority = 'secondary-input', },
    allowed_effects = { 'speed', 'consumption', 'pollution', },
    always_draw_idle_animation = true,
    idle_animation = graphics.writer_entity.idle_animation,
    working_visualisations = { {
        render_layer = 'object',
        animation = graphics.writer_entity.crafting_animation,
        always_draw = false,
    }, },
    minable = { mining_time = 0.5, },
    match_animation_speed_to_activity = false,
    show_recipe_icon_on_map = false,
    icons = { graphics.writer_item, },
    collision_box = { { -0.4, -0.9, }, { 0.4, 0.9, }, },
    collision_mask = { layers = { item = true, object = true, player = true, water_tile = true, }, },
    selection_box = { { -0.5, -1, }, { 0.5, 1, }, },
    subgroup = 'circuit-network',
    allow_copy_paste = true,
    selectable_in_game = true,
    selection_priority = 0,
    source_inventory_size = 1,
    result_inventory_size = 1,
    se_allow_in_space = true,
    hidden_in_factoriopedia = true,
}

local item = {
    type = 'item',
    name = names.writer.ITEM,
    localised_name = building.localised_name,
    localised_description = building.localised_description,
    stack_size = 50,
    icons = { graphics.writer_item, },
    place_result = names.writer.BUILDING,
    subgroup = 'circuit-network',
}

local recipe = {
    type = 'recipe',
    name = names.writer.RECIPE,
    icon = item.icon,
    icon_size = item.icon_size,
    ingredients = {
        { type = 'item', name = 'constant-combinator', amount = 1, },
        { type = 'item', name = 'electronic-circuit',  amount = 2, },
    },
    results = { { type = 'item', name = item.name, amount = 1, }, },
    energy_required = 1,
    enabled = false,
    order = 'c[combinators]-m[memorycard-writer]',
}

local legacy_signal_receiver = {
    type = 'lamp',
    flags = { 'player-creation', },
    is_military_target = false,
    name = names.writer.SIGNAL_RECEIVER,
    localised_name = building.localised_name,
    localised_description = building.localised_description,
    energy_usage_per_tick = '1W',
    energy_source = { type = 'void', },
    circuit_wire_connection_point = {
        wire = connection_point,
        shadow = connection_point,
    },
    minable = {
        mining_time = data.raw['constant-combinator']['constant-combinator'].minable.mining_time,
        result = names.writer.ITEM,
    },
    circuit_wire_max_distance = 9,
    draw_circuit_wires = true,
    always_on = true,
    selectable_in_game = true,
    selection_box = { { -0.5, -1, }, { 0.5, 1, }, },
    placeable_by = { item = names.writer.ITEM, count = 1, },
    se_allow_in_space = true,
    hidden_in_factoriopedia = true,
}

local animation = table.deepcopy(graphics.writer_entity.ready_animation)
animation.type = 'animation'
animation.name = names.writer.READY_ANIMATION

if other_mods.ULTRACUBE then
    table.insert(recipe.ingredients, 1, { type = 'item', name = 'cube-basic-matter-unit', amount = 1, })
    recipe.order = 'cube-' .. recipe.order
    recipe.category = 'cube-fabricator-handcraft'
    writing_recipe.order = 'cube-' .. writing_recipe.name
    item.subgroup = 'cube-combinator-extra'
end

return {
    register = function ()
        data:extend({
            writing_recipe_category,
            item,
            building,
            recipe,
            writing_recipe,
            animation,

            legacy_building,
            legacy_signal_receiver,
        });
        utils.add_recipe_to_unlocks(recipe)
    end,
}
