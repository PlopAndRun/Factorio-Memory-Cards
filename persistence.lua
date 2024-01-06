local _M = {}

function _M.writers()
    return global.writers or {}
end

function _M.readers()
    return global.readers or {}
end

function _M.register_writer(writer, receiver)
    local holder = {
        writer = writer,
        receiver = receiver
    }
    if not global.writers then global.writers = {} end
    global.writers[writer.unit_number] = holder
end

function _M.delete_writer(holder)
    global.writers[holder.writer.unit_number] = nil
end

function _M.register_reader(sender, reader)
    local holder = {
        sender = sender,
        reader = reader,
    }
    if not global.readers then global.readers = {} end
    global.readers[reader.unit_number] = holder
end

function _M.delete_reader(holder)
    global.readers[holder.reader.unit_number] = nil
end

return _M
