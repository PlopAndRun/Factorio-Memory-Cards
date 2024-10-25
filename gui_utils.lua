local styles = require('utils').names.styles

local _M = {}

local function create_titlebar(parent, title)
    local titlebar = parent.add {
        type = 'flow',
        direction = 'horizontal',
    }

    titlebar.add {
        type = 'label',
        style = 'frame_title',
        caption = title,
        ignored_by_interaction = true,
    }
end

function _M.create_machine_options_window(options)
    local gui = options.player.gui.relative
    local anchor = {
        gui = options.anchor_gui,
        position = defines.relative_gui_position.right,
    }
    local window = gui.add {
        type = 'frame',
        direction = 'vertical',
        name = options.window_name,
        anchor = anchor,
    }
    window.style.vertically_stretchable = true
    create_titlebar(window, options.title)
    local frame = window.add {
        type = 'frame',
        style = styles.MACHINE_OPTIONS_FRAME,
    }

    local root = frame.add {
        type = 'flow',
        direction = 'vertical',
    }

    return root
end

function _M.close_machine_options_window(player, window_name)
    local gui = player.gui.relative
    local window = gui[window_name]
    if window then
        window.destroy()
    end
end

return _M
