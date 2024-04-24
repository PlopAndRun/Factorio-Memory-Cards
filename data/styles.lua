local styles = require('utils').names.styles
local gui_style = data.raw['gui-style'].default

local function signal_button(size, parent_style)
    return {
        type = 'button_style',
        parent = parent_style,
        size = size,
    }
end

return {
    register = function ()
        gui_style[styles.DRAGGABLE_HEADER] = {
            type = 'empty_widget_style',
            parent = 'draggable_space',
            height = 24,
            horizontally_stretchable = 'on',
        }

        gui_style[styles.SPACER] = {
            type = 'empty_widget_style',
            horizontally_stretchable = 'on',
        }

        gui_style[styles.CARD_SLOT_ROW] = {
            type = 'horizontal_flow_style',
            vertical_align = 'center',
        }

        gui_style[styles.CARD_CONTROLS_FLOW] = {
            type = 'vertical_flow_style',
            margin = 12,
        }

        gui_style[styles.COPY_BUTTON] = {
            type = 'button_style',
            parent = 'forward_button',
            horizontally_stretchable = 'on',
            horizontal_align = 'right',
        }

        gui_style[styles.PASTE_BUTTON] = {
            type = 'button_style',
            parent = 'green_button',
            horizontally_stretchable = 'on',
            horizontal_align = 'right',
            height = 32,
            font = 'default-dialog-button',
        }

        gui_style[styles.CARD_MEMORY_SCROLLBAR] = {
            type = 'scroll_pane_style',
            parent = 'scroll_pane_in_shallow_frame',
            vertically_stretchable = 'on',
        }

        gui_style[styles.CARD_SIGNALS_FRAME] = {
            type = 'frame_style',
            parent = 'slot_button_deep_frame',
            margin = 4,
            vertically_stretchable = 'on',
            horizontally_stretchable = 'on',
        }

        gui_style[styles.CARD_SIGNALS_TABLE_STYLE] = {
            type = 'table_style',
            padding = 3,
        }

        gui_style[styles.CARD_SIGNAL_BUTTON] = signal_button(36, 'slot')
        gui_style[styles.CARD_SIGNAL_BUTTON_RED] = signal_button(36, 'flib_slot_button_red')
        gui_style[styles.CARD_SIGNAL_BUTTON_GREEN] = signal_button(36, 'flib_slot_button_green')

        gui_style[styles.EDITOR_SIGNAL_BUTTON] = signal_button(40, 'slot')
        gui_style[styles.EDITOR_SIGNAL_BUTTON_RED] = signal_button(40, 'flib_slot_button_red')
        gui_style[styles.EDITOR_SIGNAL_BUTTON_GREEN] = signal_button(40, 'flib_slot_button_green')

        gui_style[styles.RESET_BUTTON] = {
            type = 'button_style',
            parent = 'tool_button_red',
            right_margin = 4,
        }

        gui_style[styles.RED_BUTTON] = {
            type = 'button_style',
            parent = 'tool_button_red',
        }

        gui_style[styles.GREEN_BUTTON] = {
            type = 'button_style',
            parent = 'item_and_count_select_confirm',
        }

        gui_style[styles.INLINE_BUTTON] = {
            type = 'button_style',
            parent = 'mini_button_aligned_to_text_vertically',
        }

        gui_style[styles.EDITOR_SIGNALS_SCROLLBAR] = {
            type = 'scroll_pane_style',
            margin = 12,
            vertically_stretchable = 'on',
            horizontally_stretchable = 'on',
        }

        gui_style[styles.EDITOR_SIGNALS_CONTAINER] = {
            type = 'horizontal_flow_style',
            horizontal_spacing = 60,
        }

        gui_style[styles.EDITOR_SINGLE_SIGNAL_CONTAINER] = {
            type = 'horizontal_flow_style',
            vertical_align = 'center',
        }

        gui_style[styles.EDITOR_SIGNAL_COUNT] = {
            type = 'textbox_style',
            width = 100,
        }

        gui_style[styles.MACHINE_OPTIONS_FRAME] = {
            type = 'frame_style',
            parent = 'inside_shallow_frame',
            vertically_stretchable = 'on',
            padding = 12,
        }
    end,
}
