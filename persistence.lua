local _M = {}

_M.CHANNEL_OPTION = {
    NONE = 1,
    RED = 2,
    GREEN = 3,
    BOTH = 4,
}

_M.DEFAULT_WRITER_OPTIONS = {
    use_channels = false,
    label = nil,
    list_contents = true,
}

function _M.writers()
    return storage.writers or {}
end

function _M.readers()
    return storage.readers or {}
end

function _M.players()
    if storage.players == nil then
        storage.players = {}
    end
    return storage.players
end

function _M.editor_ui(player_index)
    local players = _M.players()
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

function _M.machine_ui(player_index)
    local players = _M.players()
    local player = players[player_index]
    if player == nil then
        player                = {}
        players[player_index] = player
    end
    local machine_ui = player.machine_ui
    if machine_ui == nil then
        machine_ui = {}
        player.machine_ui = machine_ui
    end
    return machine_ui
end

function _M.on_player_removed(player_index)
    _M.players()[player_index] = nil
end

function _M.register_writer(writer)
    local holder = {
        writer = writer,
        options = {},
    }
    _M.copy_writer_options({ options = _M.DEFAULT_WRITER_OPTIONS, }, holder)
    if not storage.writers then storage.writers = {} end
    storage.writers[writer.unit_number] = holder
    return holder
end

function _M.delete_writer(holder)
    storage.writers[holder.writer.unit_number] = nil
end

function _M.copy_writer_options(source, destination)
    destination.options.use_channels = source.options.use_channels
    destination.options.label = source.options.label
    destination.options.list_contents = source.options.list_contents
end

function _M.register_reader(sender, reader, diagnostics_cell)
    local holder = {
        sender = sender,
        reader = reader,
        diagnostics_cell = diagnostics_cell,
        options = {
            diagnostics_channel = _M.CHANNEL_OPTION.BOTH,
        },
    }
    if not storage.readers then storage.readers = {} end
    storage.readers[reader.unit_number] = holder
    return holder
end

function _M.copy_reader_options(source, destination)
    destination.options.diagnostics_channel = source.options.diagnostics_channel
end

function _M.delete_reader(holder)
    storage.readers[holder.reader.unit_number] = nil
end

return _M
