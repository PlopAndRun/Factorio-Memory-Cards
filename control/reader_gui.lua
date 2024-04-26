local gui_utils = require 'gui_utils'
local persistence = require 'persistence'

local _M = {}

local GUI_PREFIX = require('utils').names.reader.gui.NAME
local WINDOW = GUI_PREFIX .. '.window'
local DIAGNOSTICS_CHANNEL = GUI_PREFIX .. '.diagnostics-channel'

local function create_signal_selector(parent, holder)
    parent.add {
        type = 'label',
        caption = { 'memorycards-reader-options.diagnostics-channel', },
        tooltip = { 'memorycards-reader-options.diagnostics-channel-tooltip', },
    }

    parent.add {
        type = 'drop-down',
        caption = 'asdf',
        items = {
            { 'memorycards-reader-options.diagnostics-channel-none', },
            { 'memorycards-reader-options.diagnostics-channel-red', },
            { 'memorycards-reader-options.diagnostics-channel-green', },
            { 'memorycards-reader-options.diagnostics-channel-both', },
        },
        selected_index = holder.options.diagnostics_channel,
        name = DIAGNOSTICS_CHANNEL
    }
end

function _M.open_options_gui(player, holder)
    local root = gui_utils.create_machine_options_window {
        player = player,
        window_name = WINDOW,
        title = { 'memorycards-reader-options.title', },
        anchor_gui = defines.relative_gui_type.container_gui,
    }
    create_signal_selector(root, holder)
end

function _M.on_gui_selection_state_changed(player_index, element)
    local player = game.get_player(player_index)
    if not player then return end

    local machine = player.opened
    if not machine then
        game.print('Failed to find the opened reader')
        return
    end

    local holder = persistence.readers()[machine.unit_number]
    if not holder then
        game.print("Failed to find the reader's data")
        return
    end

    if element.name == DIAGNOSTICS_CHANNEL then
        holder.options.diagnostics_channel = element.selected_index
        return holder
    end
end

function _M.close_options_gui(player)
    gui_utils.close_machine_options_window(player, WINDOW)
end

return _M
