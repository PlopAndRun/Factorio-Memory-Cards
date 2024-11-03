local _M = {}
local gui_utils = require 'gui_utils'
local utils = require 'utils'
local styles = require('utils').names.styles
local persistence = require 'persistence'

local GUI_PREFIX = require('utils').names.writer.gui.NAME
local tag_names = require('utils').tags.writer
local APPLY = GUI_PREFIX .. '.apply'
local CANCEL = GUI_PREFIX .. '.cancel'
local EDIT_LABEL_BUTTON = GUI_PREFIX .. '.edit-label'
local LIST_CONTENTS_IN_DESCRIPTION = GUI_PREFIX .. '.list-contents'
local USE_CHANNELS = GUI_PREFIX .. '.use-channels'
local WINDOW = GUI_PREFIX .. '.window'

local function get_use_channels(gui_info)
    if gui_info.holder then
        return gui_info.holder.options.use_channels
    elseif gui_info.ghost then
        return utils.get(
            gui_info.ghost.tags,
            tag_names.USE_CHANNELS_TAG,
            persistence.DEFAULT_WRITER_OPTIONS.use_channels)
    end
end

local function set_use_channels(gui_info, value)
    if gui_info.holder then
        gui_info.holder.options.use_channels = value
    elseif gui_info.ghost then
        utils.set_tag(gui_info.ghost, tag_names.USE_CHANNELS_TAG, value)
    end
end

local function get_list_contents(gui_info)
    if gui_info.holder then
        return gui_info.holder.options.list_contents
    elseif gui_info.ghost then
        return utils.get(
            gui_info.ghost.tags,
            tag_names.LIST_CONTENTS_TAG,
            persistence.DEFAULT_WRITER_OPTIONS.list_contents)
    end
end

local function set_list_contents(gui_info, value)
    if gui_info.holder then
        gui_info.holder.options.list_contents = value
    elseif gui_info.ghost then
        utils.set_tag(gui_info.ghost, tag_names.LIST_CONTENTS_TAG, value)
    end
end

local function get_label(gui_info)
    if gui_info.holder then
        return gui_info.holder.options.label
    elseif gui_info.ghost then
        return utils.get(
            gui_info.ghost.tags,
            tag_names.LABEL_TAG,
            persistence.DEFAULT_WRITER_OPTIONS.label)
    end
end

local function set_label(gui_info, value)
    if gui_info.holder then
        gui_info.holder.options.label = value
    elseif gui_info.ghost then
        utils.set_tag(gui_info.ghost, tag_names.LABEL_TAG, value)
    end
end

local function create_label_viewer(parent, index, gui_info)
    local layout = parent.add {
        type = 'flow',
        orientation = 'horizontal',
        index = index,
    }

    local label = get_label(gui_info)
    if label then
        layout.add {
            type = 'label',
            style = 'caption_label',
            caption = { 'memorycards-writer-options.custom-label', },
            tooltip = { 'memorycards-writer-options.custom-label-tooltip', },
        }

        layout.add {
            type = 'label',
            caption = label,
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
        sprite = 'utility/rename_icon',
        tooltip = { 'memorycards-writer-options.custom-label-edit-button-tooltip', },
    }
end

local function create_label_editor(parent, index, gui_info)
    local layout = parent.add {
        type = 'flow',
        orientation = 'horizontal',
        index = index,
    }

    local textfield = layout.add {
        type = 'textfield',
        text = get_label(gui_info) or '',
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
        sprite = 'utility/close',
    }
end

function _M.open_options_gui(player, info)
    local gui_info = persistence.machine_ui(player.index)
    gui_info.holder = info.holder
    gui_info.ghost = info.ghost

    local root = gui_utils.create_machine_options_window {
        player = player,
        window_name = WINDOW,
        title = { 'memorycards-writer-options.title', },
        anchor_gui = defines.relative_gui_type.assembling_machine_gui,
    }

    root.add {
        type = 'checkbox',
        name = USE_CHANNELS,
        caption = { 'memorycards-writer-options.use-channels', },
        tooltip = { 'memorycards-writer-options.use-channels-tooltip', },
        state = get_use_channels(gui_info),
    }

    create_label_viewer(root, 1, gui_info)

    root.add {
        type = 'checkbox',
        name = LIST_CONTENTS_IN_DESCRIPTION,
        caption = { 'memorycards-writer-options.list-contents', },
        tooltip = { 'memorycards-writer-options.list-contents-tooltip', },
        state = get_list_contents(gui_info),
    }
end

function _M.on_gui_click(player_index, element)
    local gui_info = gui_utils.get_machine_gui_info(player_index)
    if gui_info == nil then return end

    if element.name == EDIT_LABEL_BUTTON then
        local flow = element.parent
        local root = flow.parent
        local index = flow.get_index_in_parent()
        flow.destroy()
        create_label_editor(root, index, gui_info)
    elseif element.name == APPLY or element.name == CANCEL then
        local flow = element.parent
        local root = flow.parent
        local index = flow.get_index_in_parent()
        if element.name == APPLY then
            set_label(gui_info, utils.trim_nilable_string(flow.children[1].text))
        end
        flow.destroy()
        create_label_viewer(root, index, gui_info)
    end
end

function _M.on_gui_checked_state_changed(player_index, element)
    local gui_info = gui_utils.get_machine_gui_info(player_index)
    if gui_info == nil then return end

    if element.name == USE_CHANNELS then
        set_use_channels(gui_info, element.state)
    elseif element.name == LIST_CONTENTS_IN_DESCRIPTION then
        set_list_contents(gui_info, element.state)
    end
end

function _M.on_opened_entity_built(player_index, holder)
    local player = game.get_player(player_index)
    if player == nil then return end
    local gui_info = persistence.machine_ui(player_index)
    if gui_info == nil then return end
    gui_info.ghost = nil
    gui_info.holder = holder
end

function _M.close_options_gui(player)
    gui_utils.close_machine_options_window(player, WINDOW)
end

return _M
