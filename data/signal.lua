local names = require('utils').names;
local graphics = require 'graphics.definitions'

local card_inserted = {
    type = 'virtual-signal',
    name = names.signal.INSERTED,
    localised_name = { 'virtual-signal-name.memorycards-signal-inserted' },
    localised_description = { 'description.memorycards-signal-inserted' },
    icons = { graphics.inserted_signal },
}

return {
    register = function()
        data:extend({ card_inserted })
    end
}
