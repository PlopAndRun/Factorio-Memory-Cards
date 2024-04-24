local GUI_PREFIX = require('utils').names.memorycard_editor.gui.NAME
local utils = require 'utils'
local names = require('utils').names
local styles = require('utils').names.styles
local memorycard = require 'control.memorycard'
local persistence = require 'persistence'

local _M = {}
local CLOSE_BUTTON = GUI_PREFIX .. '.close'
local MEMORYCARD_SLOT = GUI_PREFIX .. '.memorycard-slot'
local READ_BUTTON = GUI_PREFIX .. '.read'
local RESET_BUTTON = GUI_PREFIX .. '.reset-button'
local SIGNAL_CHOOSE_BUTTON = GUI_PREFIX .. '.signal-choose-button'
local SIGNAL_COLOR_SWITCH = GUI_PREFIX .. '.signal-color-switch'
local WINDOW = GUI_PREFIX .. '.window'
local WRITE_BUTTON = GUI_PREFIX .. '.write'
local LABEL_APPLY = GUI_PREFIX .. '.apply-label'
local LABEL_CANCEL = GUI_PREFIX .. '.cancel-label'
local LABEL_EDIT = GUI_PREFIX .. '.edit-label'
local LIST_CONTENTS = GUI_PREFIX .. '.list-label'

local DEFAULT_PADDING = 12
local ROW_SPACING = 4
local ROW_ELEMENT_HEIGHT = 40
local ROW_HEIGHT = ROW_ELEMENT_HEIGHT + ROW_SPACING

local function create_main_window(player)
    local frame = player.gui.screen.add {
        type = 'frame',
        direction = 'vertical',
        name = WINDOW,
    }

    local resolution = player.display_resolution
    local scale = player.display_scale
    local width = resolution.width * 0.6 / scale
    local height = resolution.height * 0.6 / scale

    frame.style.width = width
    frame.style.height = height
    frame.location = { (resolution.width - width * scale) / 2, (resolution.height - height * scale) / 2, }

    return {
        window = frame,
        size = {
            width = width - 24,
            height = height - 24,
            scale = scale,
        },
    }
end

local function create_label_viewer(parent, index, label)
    local layout = parent.add {
        type = 'flow',
        orientation = 'horizontal',
        index = index,
    }

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
        name = LABEL_EDIT,
        type = 'sprite-button',
        style = styles.INLINE_BUTTON,
        sprite = 'utility/rename_icon_small_black',
        tooltip = { 'memorycards-writer-options.custom-label-edit-button-tooltip', },
    }

    return layout
end

local function recreate_label_viewer(gui_info, label)
    local parent = gui_info.card_ui.label_layout.parent
    local index = gui_info.card_ui.label_layout.get_index_in_parent()
    gui_info.card_ui.label_layout.destroy()
    gui_info.card_ui.label_layout = create_label_viewer(parent, index, label)
end

local function create_label_editor(parent, index, label)
    local layout = parent.add {
        type = 'flow',
        orientation = 'horizontal',
        index = index,
    }

    local textfield = layout.add {
        type = 'textfield',
        text = label or '',
    }

    textfield.select_all()
    textfield.focus()

    layout.add {
        name = LABEL_APPLY,
        type = 'sprite-button',
        style = styles.GREEN_BUTTON,
        sprite = 'utility/enter',
    }

    layout.add {
        name = LABEL_CANCEL,
        type = 'sprite-button',
        style = styles.RED_BUTTON,
        sprite = 'utility/close_white',
    }

    return layout
end

local function create_titlebar(parent, available_size)
    local titlebar = parent.add {
        type = 'flow',
        direction = 'horizontal',
    }
    titlebar.drag_target = parent

    titlebar.add {
        type = 'label',
        style = 'frame_title',
        caption = { 'memorycards-editor.name', },
        ignored_by_interaction = true,
    }

    titlebar.add {
        type = 'empty-widget',
        style = styles.DRAGGABLE_HEADER,
        ignored_by_interaction = true,
    }

    titlebar.add {
        type = 'sprite-button',
        style = 'close_button',
        name = CLOSE_BUTTON,
        sprite = 'utility/close_white',
        hovered_sprite = 'utility/close_black',
        clicked_sprite = 'utility/close_black',
        tooltip = { 'memorycards-editor.close', },
    }

    available_size.height = available_size.height - 24
end

local function create_card_ui(parent, available_size)
    local section_flow = parent.add {
        type = 'flow',
        direction = 'vertical',
    }
    local section_frame = section_flow.add {
        type = 'frame',
        style = 'inside_shallow_frame',
    }

    local width = 270
    section_flow.style.width = width

    local root = section_frame.add {
        type = 'flow',
        direction = 'vertical',
    }

    local title_frame = root.add {
        type = 'frame',
        style = 'subheader_frame',
    }
    local title_layout = title_frame.add {
        type = 'flow',
        direction = 'horizontal',
    }
    title_layout.add {
        type = 'label',
        caption = { 'memorycards.info-label', { 'memorycards-editor.memory-card-section-title', }, },
        style = 'subheader_caption_label',
        tooltip = { 'memorycards-editor.memory-card-section-help', },
    }
    title_layout.add {
        type = 'empty-widget',
        style = styles.SPACER,
    }

    local controls_flow = root.add {
        type = 'flow',
        direction = 'vertical',
        style = styles.CARD_CONTROLS_FLOW,
    }

    local label = create_label_viewer(controls_flow, #controls_flow.children + 1, nil)

    local slot_row = controls_flow.add {
        type = 'flow',
        direction = 'horizontal',
        style = styles.CARD_SLOT_ROW,
    }

    local slot = slot_row.add {
        type = 'sprite-button',
        name = MEMORYCARD_SLOT,
        style = 'slot',
    }

    local buttons_flow = slot_row.add {
        type = 'flow',
        direction = 'vertical',
    }

    local copy_button = buttons_flow.add {
        type = 'button',
        name = READ_BUTTON,
        caption = { 'memorycards-editor.memory-card-section-copy-caption', },
        style = styles.COPY_BUTTON,
        tooltip = { 'memorycards-editor.memory-card-section-copy-tooltip', },
    }

    local hint = buttons_flow.add {
        type = 'label',
        caption = { 'memorycards-editor.memory-card-section-no-card-hint', },
        style = 'bold_label',
    }

    local paste_button = controls_flow.add {
        type = 'button',
        name = WRITE_BUTTON,
        caption = { 'memorycards-editor.memory-card-section-paste-caption', },
        tooltip = { 'memorycards-editor.memory-card-section-paste-tooltip', },
        style = styles.PASTE_BUTTON,
    }

    local list_contents = controls_flow.add {
        type = 'checkbox',
        name = LIST_CONTENTS,
        caption = { 'memorycards-writer-options.list-contents', },
        tooltip = { 'memorycards-writer-options.list-contents-tooltip', },
        state = false,
    }

    local scrollbar = root.add {
        type = 'scroll-pane',
        style = styles.CARD_MEMORY_SCROLLBAR,
        visible = false,
    }

    local signals_frame = scrollbar.add {
        type = 'frame',
        style = styles.CARD_SIGNALS_FRAME,
    }

    local signals_table = signals_frame.add {
        type = 'table',
        column_count = 6,
        style = styles.CARD_SIGNALS_TABLE_STYLE,
    }

    available_size.width = available_size.width - width - DEFAULT_PADDING

    return {
        slot = slot,
        container = scrollbar,
        signals = signals_table,
        copy_button = copy_button,
        paste_button = paste_button,
        hint = hint,
        label_layout = label,
        list_contents_checkbox = list_contents,
    }
end

local function draw_signals(gui_info, signals, style)
    if not signals then return end
    for _, signal in pairs(signals) do
        local sprite = ''
        local tooltip = nil
        if signal.signal.type == 'virtual' then
            sprite = 'virtual-signal/' .. signal.signal.name
            tooltip = {
                type = 'signal',
                name = signal.signal.name,
            }
        elseif signal.signal.type == 'item' then
            sprite = 'item/' .. signal.signal.name
            tooltip = {
                type = 'item',
                name = signal.signal.name,
            }
        elseif signal.signal.type == 'fluid' then
            sprite = 'fluid/' .. signal.signal.name
            tooltip = {
                type = 'fluid',
                name = signal.signal.name,
            }
        end

        if not game.is_valid_sprite_path(sprite) then
            sprite = 'utility/questionmark'
        end

        local parameters = {
            type = 'sprite-button',
            style = style,
            sprite = sprite,
            number = signal.count,
            elem_tooltip = tooltip,
        }

        local success, button = pcall(gui_info.card_ui.signals.add, parameters)

        if not success then
            parameters.elem_tooltip = nil
            parameters.tooltip = signal.signal.name
        end
    end
end

local function update_card_ui(gui_info, player)
    local inventory = gui_info.inserted_cards[player.force.index]
    gui_info.card_ui.signals.clear()
    if inventory == nil then
        gui_info.card_ui.slot.sprite = names.memorycard_editor.PLACEHOLDER_SPRITE
        gui_info.card_ui.container.visible = false
        gui_info.card_ui.copy_button.visible = false
        gui_info.card_ui.paste_button.visible = false
        gui_info.card_ui.hint.visible = true
        gui_info.card_ui.label_layout.visible = false
        gui_info.card_ui.list_contents_checkbox.visible = false
    else
        local card = inventory[1]
        gui_info.card_ui.slot.sprite = 'item/' .. card.name
        gui_info.card_ui.container.visible = true
        gui_info.card_ui.hint.visible = false
        gui_info.card_ui.copy_button.visible = true
        gui_info.card_ui.paste_button.visible = true
        gui_info.card_ui.label_layout.visible = true
        gui_info.card_ui.list_contents_checkbox.visible = true

        local options = memorycard.read_options(card)
        recreate_label_viewer(gui_info, options.label)
        gui_info.card_ui.list_contents_checkbox.state = options.list_contents

        local data = memorycard.read_data(card)
        draw_signals(gui_info, data.combined, styles.CARD_SIGNAL_BUTTON)
        draw_signals(gui_info, data.red, styles.CARD_SIGNAL_BUTTON_RED)
        draw_signals(gui_info, data.green, styles.CARD_SIGNAL_BUTTON_GREEN)
    end
end

local function create_signals_ui(root, available_size)
    local signals_frame = root.add {
        type = 'frame',
        style = 'inside_shallow_frame',
    }
    signals_frame.style.width = available_size.width
    signals_frame.style.height = available_size.height

    local layout = signals_frame.add {
        type = 'flow',
        direction = 'vertical',
    }

    local title_frame = layout.add {
        type = 'frame',
        style = 'subheader_frame',
    }
    local title_layout = title_frame.add {
        type = 'flow',
        direction = 'horizontal',
    }
    title_layout.add {
        type = 'label',
        caption = { 'memorycards.info-label', { 'memorycards-editor.editor-section-title', }, },
        tooltip = { 'memorycards-editor.editor-section-help', },
        style = 'subheader_caption_label',
    }
    title_layout.add {
        type = 'empty-widget',
        style = styles.SPACER,
    }
    title_layout.add {
        name = RESET_BUTTON,
        type = 'sprite-button',
        style = styles.RESET_BUTTON,
        sprite = 'utility/reset',
        tooltip = { 'memorycards-editor.editor-section-reset-help', },
    }
    available_size.height = available_size.height - 36 - 4

    local scrollbar = layout.add {
        type = 'scroll-pane',
        style = styles.EDITOR_SIGNALS_SCROLLBAR,
    }

    local signals = scrollbar.add {
        type = 'flow',
        direction = 'horizontal',
        style = styles.EDITOR_SIGNALS_CONTAINER,
    }
    available_size.height = available_size.height - 24 - 12

    return {
        signals = signals,
        signals_per_column = math.floor((available_size.height) / ROW_HEIGHT),
    }
end

local function create_signal_ui(gui_info, signal, network)
    local pane = gui_info.signals_pane

    local vertical_layout = pane.children[#pane.children]
    if vertical_layout == nil or #vertical_layout.children == gui_info.signals_per_column then
        vertical_layout = pane.add {
            type = 'flow',
            direction = 'vertical',
        }
    end

    local signal_container = vertical_layout.add {
        type = 'flow',
        direction = 'horizontal',
        style = styles.EDITOR_SINGLE_SIGNAL_CONTAINER,
    }

    signal_container.add {
        type = 'choose-elem-button',
        name = SIGNAL_CHOOSE_BUTTON .. '-' .. tostring(#vertical_layout.children + 1),
        style = network == 'red' and styles.CARD_SIGNAL_BUTTON_RED or network == 'green' and styles.CARD_SIGNAL_BUTTON_GREEN or nil,
        elem_type = 'signal',
        signal = signal.signal,
    }

    signal_container.add {
        type = 'textfield',
        numeric = true,
        allow_decimal = false,
        allow_negative = true,
        text = signal.count or '',
        style = styles.EDITOR_SIGNAL_COUNT,
    }

    signal_container.add {
        type = 'switch',
        name = SIGNAL_COLOR_SWITCH .. '-' .. tostring(#vertical_layout.children + 1),
        tooltip = { 'memorycards-editor.editor-section-channel-switch-help', },
        allow_none_state = true,
        switch_state = network == 'red' and 'left' or network == 'green' and 'right' or 'none',
        left_label_caption = { '', '[item=red-wire]', },
        right_label_caption = { '', '[item=green-wire]', },
    }
end

local function create_empty_signal_ui(gui_info)
    create_signal_ui(gui_info, { signal = nil, count = nil, }, 'both')
end

local function create_signals(signals_pane)
    local signals = {
        combined = {},
        red = {},
        green = {},
    }
    for _, column in pairs(signals_pane.children) do
        for _, signal_layout in pairs(column.children) do
            local signal = signal_layout.children[1].elem_value
            local count = tonumber(signal_layout.children[2].text)
            local switch = signal_layout.children[3].switch_state
            if signal ~= nil and count ~= nil and count ~= 0 then
                local channel
                if switch == 'left' then
                    channel = signals.red
                elseif switch == 'right' then
                    channel = signals.green
                else
                    channel = signals.combined
                end
                table.insert(channel, {
                    signal = signal,
                    count = count,
                })
            end
        end
    end
    return signals
end

local function has_ui_state(gui_info)
    for _, column in pairs(gui_info.signals_pane.children) do
        for _, signal_layout in pairs(column.children) do
            local signal = signal_layout.children[1].elem_value
            local count = tonumber(signal_layout.children[2].text)
            if signal ~= nil or (count ~= nil and count ~= 0) then
                return true
            end
        end
    end
    return false
end

local function close_window(gui_info)
    if not has_ui_state(gui_info) then
        gui_info.root.destroy()
        gui_info.root = nil
        gui_info.signals_pane = nil
        gui_info.card_ui = nil
    else
        gui_info.root.visible = false
    end
end

local function insert_memorycard(gui_info, player)
    local editor_inventory = game.create_inventory(1)
    gui_info.inserted_cards[player.force.index] = editor_inventory
    editor_inventory[1].transfer_stack(player.cursor_stack)
    update_card_ui(gui_info, player)
end

local function eject_memorycard(gui_info, player)
    local editor_inventory = gui_info.inserted_cards[player.force.index]
    if player.cursor_stack.transfer_stack(editor_inventory[1]) then
        gui_info.inserted_cards[player.force.index] = nil
        editor_inventory.destroy()
    end
    update_card_ui(gui_info, player)
end

local function exchange_memorycard(gui_info, player)
    local editor_inventory = gui_info.inserted_cards[player.force.index]
    player.cursor_stack.swap_stack(editor_inventory[1])
    update_card_ui(gui_info, player)
end

function _M.on_lua_shortcut(player_index)
    local player = game.get_player(player_index)
    if player == nil then
        return
    end
    local gui_info = persistence.editor_ui(player_index)

    if gui_info.root ~= nil then
        if gui_info.root.visible then
            close_window(gui_info)
        else
            gui_info.root.visible = true
        end
        return
    end

    local window_info = create_main_window(player)
    local window = window_info.window
    local available_size = window_info.size
    create_titlebar(window, available_size)
    available_size.height = available_size.height - 4

    local root = window.add {
        type = 'flow',
        direction = 'horizontal',
        style = 'inset_frame_container_horizontal_flow',
    }

    local card_ui = create_card_ui(root, available_size)
    local signals_info = create_signals_ui(root, available_size)

    gui_info.root = window
    gui_info.signals_pane = signals_info.signals
    gui_info.card_ui = card_ui
    gui_info.signals_per_column = signals_info.signals_per_column
    if gui_info.inserted_cards == nil then
        gui_info.inserted_cards = {}
    end

    update_card_ui(gui_info, player)
    create_empty_signal_ui(gui_info)
end

function _M.on_gui_elem_changed(player_index, button)
    local player = game.get_player(player_index)
    if player == nil then
        return
    end

    local gui_info = persistence.editor_ui(player_index)
    if gui_info == nil or gui_info.root == nil then
        return
    end

    local button_flow = button.parent
    local column = button_flow.parent
    local all_columns = column.parent
    local textfield = button_flow.children[2]

    local is_last_button = all_columns.children[#all_columns.children] == column and
        column.children[#column.children] == button_flow

    if button.elem_value ~= nil then
        if is_last_button then
            create_empty_signal_ui(gui_info)
        end
        textfield.focus()
        textfield.select_all()
    else
        textfield.text = ''
    end
end

function _M.on_gui_switch_state_changed(player_index, element)
    local player = game.get_player(player_index)
    if player == nil then return end

    local gui_info = persistence.editor_ui(player_index)
    if gui_info == nil or gui_info.root == nil then
        return
    end

    local button_flow = element.parent
    local choose_elem_button = button_flow.children[1]
    choose_elem_button.style =
        element.switch_state == 'left' and styles.EDITOR_SIGNAL_BUTTON_RED or
        element.switch_state == 'right' and styles.EDITOR_SIGNAL_BUTTON_GREEN or
        styles.EDITOR_SIGNAL_BUTTON
end

function _M.on_gui_click(player_index, element)
    local player = game.get_player(player_index)
    if player == nil then
        return
    end

    local gui_info = persistence.editor_ui(player_index)
    if gui_info == nil or gui_info.root == nil then
        return
    end

    local stack = player.cursor_stack
    local holding_memorycard = stack.valid_for_read and stack.name == names.memorycard.ITEM
    local editor_inventory = gui_info.inserted_cards[player.force.index]
    local inserted_card = editor_inventory ~= nil and editor_inventory[1] or nil

    if element.name == CLOSE_BUTTON then
        close_window(gui_info)
    elseif element.name == READ_BUTTON then
        if inserted_card ~= nil then
            gui_info.signals_pane.clear()
            data = memorycard.read_data(inserted_card)
            for _, signal in pairs(data.combined) do
                create_signal_ui(gui_info, signal, 'both')
            end
            for _, signal in pairs(data.red) do
                create_signal_ui(gui_info, signal, 'red')
            end
            for _, signal in pairs(data.green) do
                create_signal_ui(gui_info, signal, 'green')
            end
            create_empty_signal_ui(gui_info)
        end
    elseif element.name == WRITE_BUTTON then
        if inserted_card ~= nil then
            memorycard.save_data(inserted_card, create_signals(gui_info.signals_pane), {})
            update_card_ui(gui_info, player)
        end
    elseif element.name == MEMORYCARD_SLOT then
        if holding_memorycard and inserted_card == nil then
            insert_memorycard(gui_info, player)
        elseif not holding_memorycard and inserted_card ~= nil then
            eject_memorycard(gui_info, player)
        elseif holding_memorycard and inserted_card ~= nil then
            exchange_memorycard(gui_info, player)
        end
    elseif element.name == RESET_BUTTON then
        gui_info.signals_pane.clear()
        create_empty_signal_ui(gui_info)
    elseif element.name == LABEL_EDIT then
        local flow = element.parent
        local root = flow.parent
        local index = flow.get_index_in_parent()
        local options = memorycard.read_options(inserted_card)
        local text = inserted_card ~= nil and options.label or ''
        flow.destroy()
        gui_info.card_ui.label_layout = create_label_editor(root, index, text)
    elseif element.name == LABEL_CANCEL then
        local options = memorycard.read_options(inserted_card)
        local text = inserted_card ~= nil and options.label or ''
        recreate_label_viewer(gui_info, text)
    elseif element.name == LABEL_APPLY then
        local flow = element.parent
        local options = memorycard.read_options(inserted_card)
        options.label = utils.trim_nilable_string(flow.children[1].text)
        memorycard.generate_description(inserted_card, nil, options)
        recreate_label_viewer(gui_info, options.label)
    end
end

function _M.on_gui_checked_state_changed(player_index, element)
    local player = game.get_player(player_index)
    if player == nil then return end

    local gui_info = persistence.editor_ui(player_index)
    if gui_info == nil or gui_info.root == nil then return end

    local editor_inventory = gui_info.inserted_cards[player.force.index]
    local inserted_card = editor_inventory ~= nil and editor_inventory[1] or nil
    if inserted_card == nil then return end

    if element.name == LIST_CONTENTS then
        local options = memorycard.read_options(inserted_card)
        options.list_contents = element.state
        memorycard.generate_description(inserted_card, nil, options)
    end
end

function _M.on_player_changed_force(player)
    local gui_info = persistence.editor_ui(player.index)
    if gui_info.root == nil then
        return
    end
    update_card_ui(gui_info, player)
end

return _M;
