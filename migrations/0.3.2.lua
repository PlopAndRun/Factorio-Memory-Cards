local function add_options_to_writers()
    local writers = storage.writers
    if writers == nil then return end
    for _, writer in pairs(writers) do
        writer.options.list_contents = true
    end
end

local function update_readers()
    local holders = storage.readers
    if holders == nil then return end
    for _, holder in pairs(holders) do
        holder.options = {
            diagnostics_channel = 4, -- both channels
        }
        local surface = holder.sender.surface
        local cell = surface.create_entity {
            name = 'memorycards-reader-signal-diagnostics-cell',
            position = {
                x = holder.sender.position.x,
                y = holder.sender.position.y,
            },
            force = holder.sender.force,
            create_build_effect_smoke = false,
        }
        holder.diagnostics_cell = cell

        holder.sender.connect_neighbour {
            wire = defines.wire_type.green,
            target_entity = cell,
        }
        holder.sender.connect_neighbour {
            wire = defines.wire_type.red,
            target_entity = cell,
        }

        local inventory = holder.reader.get_inventory(defines.inventory.chest)
        if not inventory.is_empty() and inventory[1].name == 'memorycards-memorycard' then
            local behavior = cell.get_or_create_control_behavior()
            behavior.set_signal(1, {
                signal = {
                    type = 'virtual',
                    name = 'memorycards-signal-inserted',
                },
                count = 1,
            })
        end
    end
end

local function close_memorycards_gui()
    local players = storage.players
    if players == nil then return end
    for _, player in pairs(players) do
        local gui_info = player.editor_ui
        if gui_info and gui_info.root then
            gui_info.root.destroy()
            gui_info.root = nil
            gui_info.signals_pane = nil
            gui_info.card_ui = nil
        end
    end
end

add_options_to_writers()
update_readers()
close_memorycards_gui()
