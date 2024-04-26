local _M = {}
local gui_utils = require 'gui_utils'
local utils = require 'utils'
local styles = require('utils').names.styles
local persistence = require 'persistence'

local GUI_PREFIX = require('utils').names.writer.gui.NAME
local APPLY = GUI_PREFIX .. '.apply'
local CANCEL = GUI_PREFIX .. '.cancel'
local EDIT_LABEL_BUTTON = GUI_PREFIX .. '.edit-label'
local LIST_CONTENTS_IN_DESCRIPTION = GUI_PREFIX .. '.list-contents'
local USE_CHANNELS = GUI_PREFIX .. '.use-channels'
local WINDOW = GUI_PREFIX .. '.window'

local function create_label_viewer(parent, index, holder)
    local layout = parent.add {
        type = 'flow',
        orientation = 'horizontal',
        index = index,
    }

    if holder.options.label then
        layout.add {
            type = 'label',
            style = 'caption_label',
            caption = { 'memorycards-writer-options.custom-label', },
            tooltip = { 'memorycards-writer-options.custom-label-tooltip', },
        }

        layout.add {
            type = 'label',
            caption = holder.options.label,
        }
    else
        layout.add {
            type = 'label',
            style = 'caption_label',
            caption = { 'memorycards-writer-options.custom-label-empty', },
            tooltip = { 'memorycards-writer-options.custom-label-tooltip', },
        }
    end


    layout.add {
        name = EDIT_LABEL_BUTTON,
        type = 'sprite-button',
        style = styles.INLINE_BUTTON,
        sprite = 'utility/rename_icon_small_black',
        tooltip = { 'memorycards-writer-options.custom-label-edit-button-tooltip', },
    }
end

local function create_label_editor(parent, index, holder)
    local layout = parent.add {
        type = 'flow',
        orientation = 'horizontal',
        index = index,
    }

    local textfield = layout.add {
        type = 'textfield',
        text = holder.options.label or '',
    }

    textfield.select_all()
    textfield.focus()

    layout.add {
        name = APPLY,
        type = 'sprite-button',
        style = styles.GREEN_BUTTON,
        sprite = 'utility/enter',
    }

    layout.add {
        name = CANCEL,
        type = 'sprite-button',
        style = styles.RED_BUTTON,
        sprite = 'utility/close_white',
    }
end

function _M.open_options_gui(player, holder)
    local root = gui_utils.create_machine_options_window {
        player = player,
        window_name = WINDOW,
        title = { 'memorycards-writer-options.title', },
        anchor_gui = defines.relative_gui_type.furnace_gui,
    }

    root.add {
        type = 'checkbox',
        name = USE_CHANNELS,
        caption = { 'memorycards-writer-options.use-channels', },
        tooltip = { 'memorycards-writer-options.use-channels-tooltip', },
        state = holder.options.use_channels,
    }

    create_label_viewer(root, 1, holder)

    root.add {
        type = 'checkbox',
        name = LIST_CONTENTS_IN_DESCRIPTION,
        caption = { 'memorycards-writer-options.list-contents', },
        tooltip = { 'memorycards-writer-options.list-contents-tooltip', },
        state = holder.options.list_contents,
    }
end

function _M.on_gui_click(player_index, element)
    local player = game.get_player(player_index)
    if player == nil then return end

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

    if element.name == EDIT_LABEL_BUTTON then
        local flow = element.parent
        local root = flow.parent
        local index = flow.get_index_in_parent()
        flow.destroy()
        create_label_editor(root, index, holder)
    elseif element.name == APPLY or element.name == CANCEL then
        local flow = element.parent
        local root = flow.parent
        local index = flow.get_index_in_parent()
        if element.name == APPLY then
            holder.options.label = utils.trim_nilable_string(flow.children[1].text)
        end
        flow.destroy()
        create_label_viewer(root, index, holder)
    end
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
    elseif element.name == LIST_CONTENTS_IN_DESCRIPTION then
        holder.options.list_contents = element.state
    end
end

function _M.close_options_gui(player)
    gui_utils.close_machine_options_window(player, WINDOW)
end

return _M
