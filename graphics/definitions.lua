local function graphics(filename)
    return '__flash-cards__/graphics/' .. filename
end

return {
    transparent = {
        filename = graphics('transparent.png'),
        width = 1,
        height = 1
    },
    reader_entity = {
        idle = {
            filename = graphics('reader-entity.png'),
            width = 52,
            height = 52,
            x = 0,
            y = 0
        },
        active = {
            filename = graphics('reader-entity.png'),
            width = 52,
            height = 52,
            x = 52,
            y = 0
        }
    },
    writer_entity = {
        idle_animation = {
            filename = graphics('writer-entity.png'),
            size = { 42, 69 },
            position = { 0, 0 },
            hr_version = {
                filename = graphics('writer-entity-hr.png'),
                size = { 84, 138 },
                position = { 0, 0 },
                scale = 0.5,
            },
        },
        crafting_animation = {
            filename = graphics('writer-entity.png'),
            size = { 42, 69 },
            position = { 42, 0 },
            run_mode = 'forward',
            frame_count = 2,
            line_length = 2,
            animation_speed = 0.125,
            max_advance = 1,
            hr_version = {
                filename = graphics('writer-entity-hr.png'),
                size = { 84, 138 },
                position = { 84, 0 },
                run_mode = 'forward',
                scale = 0.5,
                frame_count = 2,
                line_length = 2,
                animation_speed = 0.125,
                max_advance = 1,
            },
        }
    },
    writer_item = {
        icon = graphics('writer-item.png'),
        icon_size = 64
    },
    flash_card_item = {
        icon = graphics('flash-card-item.png'),
        icon_size = 64
    }
}
