local persistence = require 'persistence'
local names = require('utils').names
local _M = {}

function _M.healthcheck(command)
    local readers = persistence.readers()
    local units = {}
    for _, holder in pairs(readers) do
        units[holder.sender.unit_number] = true
        units[holder.reader.unit_number] = true
        units[holder.diagnostics_cell.unit_number] = true
        if holder.cells then
            for _, cell in pairs(holder.cells) do
                units[cell.unit_number] = true
            end
        end
    end

    local writers = persistence.writers()
    for _, holder in pairs(writers) do
        units[holder.writer.unit_number] = true
        units[holder.receiver.unit_number] = true
    end

    local surfaces = game.surfaces

    game.print { 'memorycards-commands.healthcheck-total-holders',
        table_size(readers),
        table_size(writers),
        table_size(units),
    }

    local checked = 0

    local function check_orphans(surface, name)
        local entities = surface.find_entities_filtered { name = name, }
        local orphans = 0
        for _, entity in pairs(entities) do
            checked = checked + 1
            if not units[entity.unit_number] then
                orphans = orphans + 1
                entity.destroy()
            end
        end

        if orphans > 0 then
            game.print { 'memorycards-commands.healthcheck-found-orphans', #entities, name, surface.name, }
        end
    end

    for _, surface in pairs(surfaces) do
        check_orphans(surface, names.reader.CONTAINER)
        check_orphans(surface, names.reader.SIGNAL_SENDER)
        check_orphans(surface, names.reader.SIGNAL_SENDER_CELL)
        check_orphans(surface, names.reader.SIGNAL_DIAGNOSTICS_CELL)
        check_orphans(surface, names.writer.BUILDING)
        check_orphans(surface, names.writer.SIGNAL_RECEIVER)
    end

    game.print { 'memorycards-commands.healthcheck-checked', checked, }
end

return _M
