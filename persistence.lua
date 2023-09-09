local _M = {}

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

function _M.writers()
    return global.writers or {}
end

return _M
