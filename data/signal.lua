local names = require('utils').names;

local card_inserted = {
    type = 'virtual-signal',
    name = names.signal.INSERTED,
    localised_name = { 'virtual-signal.memorycards-signal-inserted' },
    localised_description = { 'description.memorycards-signal-inserted' },
    icons = {
        {
            icon = '__base__/graphics/icons/water-wube.png',
            icon_size = 64,
            icon_mipmaps = 4,
        }
    },
}

return {
    register = function()
        data:extend({ card_inserted })
    end
}
