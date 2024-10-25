local utils = require 'utils'
local graphics = require 'graphics.definitions'
local names = utils.names
local constants = utils.constants
local other_mods = utils.other_mods

local inventory = {
    type = 'container',
    name = names.reader.CONTAINER,
    localised_name = { 'item-name.memorycard-reader', },
    localised_description = { 'description.memorycard-reader', },
    inventory_size = 1,
    picture = graphics.reader_entity.idle,
    enable_inventory_bar = false,
    flags = constants.HIDDEN_ENTITY_FLAGS,
    destructible = false,
    selection_box = { { -0.5, -0.5, }, { 0.5, 0.5, }, },
    selectable_in_game = false,
    minable = { mining_time = data.raw['constant-combinator']['constant-combinator'].minable.mining_time, },
    inventory_type = 'with_filters_and_bar',
    se_allow_in_space = true,
    collision_mask = { layers = {}, },
}

local signal_sender = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])

signal_sender.type = 'constant-combinator'
signal_sender.name = names.reader.SIGNAL_SENDER
signal_sender.flags = { 'player-creation', 'not-rotatable', }
signal_sender.is_military_target = false
signal_sender.localised_name = inventory.localised_name
signal_sender.localised_description = inventory.localised_description
signal_sender.sprites = graphics.reader_entity.idle
signal_sender.selection_priority = 40
signal_sender.minable.result = names.reader.ITEM
signal_sender.se_allow_in_space = true

local combinator_cell = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
combinator_cell.name = names.reader.SIGNAL_SENDER_CELL
combinator_cell.flags = constants.HIDDEN_ENTITY_FLAGS
combinator_cell.sprites = nil
combinator_cell.activity_led_sprites = nil
combinator_cell.draw_circuit_wires = false
combinator_cell.selectable_in_game = false
combinator_cell.se_allow_in_space = true
combinator_cell.collision_mask = { layers = {}, }

local diagnostics_cell = table.deepcopy(combinator_cell)
diagnostics_cell.name = names.reader.SIGNAL_DIAGNOSTICS_CELL
diagnostics_cell.activity_led_sprites = graphics.reader_entity.active
diagnostics_cell.activity_led_light_offsets = { { 0, 0, }, { 0, 0, }, { 0, 0, }, { 0, 0, }, }
diagnostics_cell.se_allow_in_space = true

local item = {
    type = 'item',
    name = names.reader.ITEM,
    localised_name = inventory.localised_name,
    localised_description = inventory.localised_description,
    stack_size = 50,
    icons = { graphics.reader_item, },
    place_result = signal_sender.name,
    subgroup = 'circuit-network',
}

local recipe = {
    type = 'recipe',
    name = names.reader.RECIPE,
    icon = item.icon,
    icon_size = item.icon_size,
    ingredients = {
        { type = 'item', name = 'decider-combinator',    amount = 1, },
        { type = 'item', name = 'arithmetic-combinator', amount = 1, },
    },
    results = { { type = 'item', name = item.name, amount = 1, }, },
    energy_required = 1,
    enabled = false,
    order = 'c[combinators]-m[memorycard-reader]',
}

if other_mods.ULTRACUBE then
    table.insert(recipe.ingredients, 1, { type = 'item', name = 'cube-basic-matter-unit', amount = 1, })
    recipe.order = 'cube-' .. recipe.order
    recipe.category = 'cube-fabricator-handcraft'
    item.subgroup = 'cube-combinator-extra'
end

return {
    register = function ()
        data:extend({ item, recipe, inventory, signal_sender, combinator_cell, diagnostics_cell, })
        utils.add_recipe_to_unlocks(recipe)
    end,
}
