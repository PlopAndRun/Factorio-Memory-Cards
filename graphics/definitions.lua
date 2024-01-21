local function graphics(filename)
    return '__memory-cards__/graphics/' .. filename
end

return {
    transparent = {
        filename = graphics('transparent.png'),
        width = 1,
        height = 1,
    },
    reader_entity = {
        idle = {
            filename = graphics('reader-entity.png'),
            width = 52,
            height = 52,
            x = 0,
            y = 0,
        },
        active = {
            filename = graphics('reader-entity.png'),
            width = 52,
            height = 52,
            x = 52,
            y = 0,
        },
    },
    writer_entity = {
        idle_animation = {
            filename = graphics('writer-entity.png'),
            size = { 42, 69, },
            position = { 0, 0, },
            hr_version = {
                filename = graphics('writer-entity-hr.png'),
                size = { 84, 138, },
                position = { 0, 0, },
                scale = 0.5,
            },
        },
        crafting_animation = {
            filename = graphics('writer-entity.png'),
            size = { 42, 69, },
            position = { 42, 0, },
            run_mode = 'forward',
            frame_count = 2,
            line_length = 2,
            animation_speed = 0.125,
            max_advance = 1,
            hr_version = {
                filename = graphics('writer-entity-hr.png'),
                size = { 84, 138, },
                position = { 84, 0, },
                run_mode = 'forward',
                scale = 0.5,
                frame_count = 2,
                line_length = 2,
                animation_speed = 0.125,
                max_advance = 1,
            },
        },
        ready_animation = {
            filenmae = graphics('writer-entity.png'),
            size = { 42, 69, },
            position = { 126, 0, },
            hr_version = {
                filename = graphics('writer-entity-hr.png'),
                size = { 84, 138, },
                position = { 252, 0, },
                scale = 0.5,
            },
        },
    },
    writer_item = {
        icon = graphics('writer-item.png'),
        icon_size = 64,
    },
    reader_item = {
        icon = graphics('reader-item.png'),
        icon_size = 64,
    },
    memorycard_item = {
        icon = graphics('memorycard-item.png'),
        icon_size = 64,
    },
    inserted_signal = {
        icon = graphics('inserted-signal.png'),
        icon_size = 64,
    },
    editor_shortcut = {
        normal = {
            filename = graphics('editor-shortcut.png'),
            size = 16,
            flags = { 'icon', },
        },
        small = {
            filename = graphics('editor-shortcut.png'),
            size = 12,
            x = 16,
            flags = { 'icon', },
        },
        disabled_small = {
            filename = graphics('editor-shortcut.png'),
            size = 12,
            x = 28,
            flags = { 'icon', },
        },
    },
    editor_card_placeholder = {
        filename = graphics('editor-card-placeholder.png'),
        size = 32,
        flags = { 'icon', },

    },
}
