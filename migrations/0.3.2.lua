local function add_options_to_writers()
    local writers = global.writers
    if writers == nil then return end
    for _, writer in pairs(writers) do
        writer.options.list_contents = true
    end
end


local function close_memorycards_gui()
    local players = global.players
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
close_memorycards_gui()
