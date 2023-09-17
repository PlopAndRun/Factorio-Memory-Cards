local _M = {}

function _M.writers()
    return global.writers or {}
end

function _M.register_writer(writer, receiver)
    global.writers = _M.writers()
    global.writers[writer.unit_number] = {
        entity = writer,
        receiver = receiver
    };
end

function _M.delete_writer(writer)
    global.writers[writer.unit_number] = nil
end

function _M.readers()
    return global.readers or {}
end

function _M.register_reader(reader, sender)
    global.readers = _M.readers()
    global.readers[reader.unit_number] = {
        entity = reader,
        sender = sender
    }
end

function _M.delete_reader(reader)
    global.readers[reader.unit_number] = nil
end

return _M
