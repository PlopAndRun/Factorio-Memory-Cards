local _M = {}
local styles = require('utils').names.styles
local persistence = require 'persistence'

local GUI_PREFIX = require('utils').names.writer.gui.NAME
local WINDOW = GUI_PREFIX .. '.window'
local USE_CHANNELS = GUI_PREFIX .. '.use-channels'

local function create_titlebar(parent)
    local titlebar = parent.add {
        type = 'flow',
        direction = 'horizontal',
    }

    titlebar.add {
        type = 'label',
        style = 'frame_title',
        caption = { 'memorycards-writer-options.title', },
        ignored_by_interaction = true,
    }
end

function _M.open_options_gui(player, holder)
    local gui = player.gui.relative

    local anchor = {
        gui = defines.relative_gui_type.furnace_gui,
        position = defines.relative_gui_position.right,
    }

    local window = gui.add {
        type = 'frame',
        direction = 'vertical',
        name = WINDOW,
        anchor = anchor,
    }
    window.style.vertically_stretchable = 'stretch_and_expand'

    create_titlebar(window)
    local frame = window.add {
        type = 'frame',
        style = styles.MACHINE_OPTIONS_FRAME,
    }

    local root = frame.add {
        type = 'flow',
        direction = 'vertical',
    }

    root.add {
        type = 'checkbox',
        name = USE_CHANNELS,
        caption = { 'memorycards-writer-options.use-channels', },
        tooltip = { 'memorycards-writer-options.use-channels-tooltip', },
        state = holder.options.use_channels,
    }
end

function _M.on_gui_checked_state_changed(player_index, element)
    local player = game.get_player(player_index)
    if not player then return end

    local writer = player.opened
    if not writer then 
        game.print('Failed to find the opened writer')
        return
    end

    local holder = persistence.writers()[writer.unit_number]
    if not holder then
        game.print("Failed to find the writer's data")
        return
    end

    if element.name == USE_CHANNELS then
        holder.options.use_channels = element.state
    end
end

function _M.close_options_gui(player)
    local gui = player.gui.relative
    local window = gui[WINDOW]
    if window then
        window.destroy()
    end
end

return _M
