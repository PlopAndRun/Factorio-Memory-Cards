local _M = {}

function _M.writers()
    return global.writers or {}
end

function _M.readers()
    return global.readers or {}
end

function _M.editor_ui(player_index)
    local players = global.players
    if players == nil then
        players = {}
        global.players = players
    end
    local player = players[player_index]
    if player == nil then
        player = {}
        players[player_index] = player
    end
    local editor_ui = player.editor_ui
    if editor_ui == nil then
        editor_ui = {}
        player.editor_ui = editor_ui
    end
    return editor_ui
end

function _M.on_player_removed(player_index)
    if global.players == {} then return end
    global.players[player_index] = nil
end

function _M.register_writer(writer, receiver)
    local holder = {
        writer = writer,
        receiver = receiver,
        options = {
            use_channels = false,
            label = nil,
            list_contents = true,
        },
    }
    if not global.writers then global.writers = {} end
    global.writers[writer.unit_number] = holder
    return holder
end

function _M.delete_writer(holder)
    global.writers[holder.writer.unit_number] = nil
end

function _M.copy_writer_options(source, destination)
    destination.options.use_channels = source.options.use_channels
    destination.options.label = source.options.label
    destination.options.list_contents = source.options.list_contents
end

function _M.register_reader(sender, reader)
    local holder = {
        sender = sender,
        reader = reader,
        options = {
        },
    }
    if not global.readers then global.readers = {} end
    global.readers[reader.unit_number] = holder
    return holder
end

function _M.delete_reader(holder)
    global.readers[holder.reader.unit_number] = nil
end

return _M
