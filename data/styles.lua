local styles = require('utils').names.styles
local gui_style = data.raw['gui-style'].default

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
            left_margin = 12,
            right_margin = 12,
            bottom_margin = 12,
            top_margin = -12,
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

        gui_style[styles.CARD_SIGNAL_BUTTON] = {
            type = 'button_style',
            parent = 'slot',
            width = 36,
            height = 36,
            font = 'default-semibold',
        }

        gui_style[styles.RESET_BUTTON] = {
            type = 'button_style',
            parent = 'tool_button_red',
            right_margin = 4,
        }

        gui_style[styles.EDITOR_SIGNALS_SCROLLBAR] = {
            type = 'scroll_pane_style',
            margin = 12,
            vertically_stretchable = 'on',
            horizontally_stretchable = 'on',
        }

        gui_style[styles.EDITOR_SIGNALS_CONTAINER] = {
            type = 'horizontal_flow_style',
            horizontal_spacing = 40,
        }

        gui_style[styles.EDITOR_SINGLE_SIGNAL_CONTAINER] = {
            type = 'horizontal_flow_style',
            vertical_align = 'center',
        }

        gui_style[styles.EDITOR_SIGNAL_COUNT] = {
            type = 'textbox_style',
            width = 100,
        }
    end,
}
