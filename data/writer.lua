local utils = require('utils')
local flashcard = require('data.flashcard')

local writing_recipe = {
    type = 'recipe',
    name = utils.mod_prefix .. 'write-recipe',
    ingredients = {
        { flashcard.item.name, 1 }
    },
    result = flashcard.item.name,
    energy_required = 1,
    hidden = true,
    hide_from_stats = true,
    hide_from_player_crafting = true,
    allow_as_intermediate = false,
    allow_intermediates = false,
}

local building = table.deepcopy(data.raw['assembling-machine']['assembling-machine-1'])
building.name = utils.mod_prefix .. 'writer'
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
    name = building.name,
    localised_name = building.localised_name,
    stack_size = 50,
    icon = '__base__/graphics/icons/assembling-machine-1.png',
    icon_size = 64,
    place_result = building.name,
    subgroup = 'circuit-network',
}

local recipe = {
    type = 'recipe',
    name = item.name,
    icon = item.icon,
    icon_size = item.icon_size,
    ingredients = {
        { 'constant-combinator',  1 },
        { 'assembling-machine-1', 1 }
    },
    result = item.name,
    energy_required = 1,
}

local function register()
    data:extend({ item, building, recipe, writing_recipe });
end

return {
    register = register,
    item = item,
    recipe = recipe,
    writing_recipe = writing_recipe,
    building = building
}
