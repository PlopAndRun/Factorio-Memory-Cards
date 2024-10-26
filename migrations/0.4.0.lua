local function connect(entity, wire, target)
    local connector = entity.get_wire_connector(wire, true)
    connector.connect_to(target.get_wire_connector(wire, true), false)
end

local function disconnect(entity, wire, target)
    local connector = entity.get_wire_connector(wire, true)
    connector.disconnect_from(target.get_wire_connector(wire, true))
end

local function apply_reader_options(holder)
    local channel = holder.options.diagnostics_channel
    local red = channel == 2 or channel == 4
    local green = channel == 3 or channel == 4
    if red then
        connect(holder.sender, defines.wire_connector_id.circuit_red, holder.diagnostics_cell)
    else
        disconnect(holder.sender, defines.wire_connector_id.circuit_red, holder.diagnostics_cell)
    end

    if green then
        connect(holder.sender, defines.wire_connector_id.circuit_green, holder.diagnostics_cell)
    else
        disconnect(holder.sender, defines.wire_connector_id.circuit_green, holder.diagnostics_cell)
    end
end

local function destroy_cells(holder)
    if holder.cells == nil then return end
    for _, cell in pairs(holder.cells) do
        cell.destroy()
    end
    holder.cells = nil
end

local function reattach_wires(from, to)
    for _, connector in pairs(from.get_wire_connectors()) do
        local my_connector = to.get_wire_connector(connector.wire_connector_id, true)
        for i = 1, connector.connection_count do
            local connection = connector.connections[i]
            my_connector.connect_to(connection.target)
        end
    end
end

local function update_readers()
    if storage.readers == nil then return end
    for _, holder in pairs(storage.readers) do
        local cell = holder.diagnostics_cell
        local cb = cell.get_or_create_control_behavior()
        cb.enabled = false;
        local section = cb.get_section(1)
        section.filters = { {
            value = {
                type = 'virtual',
                name = 'memorycards-signal-inserted',
                quality = 'normal',
                comparator = '=',
            },
            min = 1,
        }, }
        apply_reader_options(holder)
        destroy_cells(holder)
    end
end

local function transfer_inventory(old_writer, new_writer, inventory)
    local old = old_writer.get_inventory(inventory)
    if not old.is_empty() then
        local new = new_writer.get_inventory(inventory)
        new[1].transfer_stack(old[1])
    end
end

local function transfer_inventories(old_writer, new_writer)
    transfer_inventory(old_writer, new_writer, defines.inventory.furnace_source)
    transfer_inventory(old_writer, new_writer, defines.inventory.furnace_result)
    if old_writer.is_crafting() then
        new_writer.crafting_progress = old_writer.crafting_progress
    end
end

local function update_writers()
    if storage.writers == nil then return end
    local writers = {}
    for _, holder in pairs(storage.writers) do
        local old_writer = holder.writer
        local surface = old_writer.surface
        local writer = surface.create_entity {
            name = 'memorycards-writer-machine',
            position = old_writer.position,
            force = old_writer.force,
            create_build_effect_smoke = false,
        }

        transfer_inventories(old_writer, writer)
        old_writer.destroy()

        local old_receiver = holder.receiver
        if old_receiver then
            reattach_wires(old_receiver, writer)
            old_receiver.destroy()
        end

        writers[writer.unit_number] = {
            writer = writer,
            options = holder.options,
        }
    end
    storage.writers = writers
end

update_readers()
update_writers()
