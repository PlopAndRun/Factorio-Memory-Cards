local names = (require 'utils').names

local _M = {}

local WRITTEN = names.MOD_PREFIX .. 'written'
local SIGNALS = names.MOD_PREFIX .. 'signals'
local RED_SIGNALS = names.MOD_PREFIX .. 'red-signals'
local GREEN_SIGNALS = names.MOD_PREFIX .. 'green-signals'
local CHANNEL_INDENT = '        '
local LABEL = names.MOD_PREFIX .. 'label'
local LIST_CONTENTS = names.MOD_PREFIX .. 'list_contents'

local function build_signals_description(signals)
    if not signals then
        return { 'description.memorycard-empty', }
    end
    local builder = { '', }
    table.sort(signals, function (signal1, signal2) return signal2.count < signal1.count end)
    local limit = #signals <= 19 and 20 or 19
    if signals ~= nil then
        for _, signal in pairs(signals) do
            local name = signal.signal.name
            local count = signal.count
            local newline = #builder > 1 and '\n' or ''
            local localization = { '?',
                { 'item-name.' .. name, },
                { 'entity-name.' .. name, },
                { 'virtual-signal-name.' .. name, },
                name,
            }
            table.insert(builder, { '', newline, CHANNEL_INDENT, localization, ': ', count, })
            if #builder >= limit then
                break
            end
        end
    end
    if #signals >= 20 then
        table.insert(builder, { '', '\n', CHANNEL_INDENT, { 'memorycards.has-more-signals', #signals - 18, }, });
    end
    return builder
end

local function build_channeled_description(signals)
    local builder = { '', }
    local added_text = false

    if signals.combined and #signals.combined > 0 then
        table.insert(builder, { '',
            { 'memorycards.combined-channel-description', },
            '\n',
        })
        table.insert(builder, build_signals_description(signals.combined))
        added_text = true
    end

    if #signals.red > 0 then
        if added_text then
            table.insert(builder, { '', '\n\n', })
        end
        table.insert(builder, { '',
            { 'memorycards.red-channel-description', },
            '\n',
        })
        table.insert(builder, build_signals_description(signals.red))
        added_text = true
    end

    if #signals.green > 0 then
        if added_text then
            table.insert(builder, { '', '\n\n', })
        end
        table.insert(builder, { '',
            { 'memorycards.green-channel-description', },
            '\n',
        });
        table.insert(builder, build_signals_description(signals.green))
        added_text = true
    end

    return builder
end

local function convert_signals(signals)
    if not signals then return {} end
    local result = {}
    for i = 1, #signals do
        table.insert(result, {
            signal = signals[i].signal,
            count = signals[i].count,
        })
    end
    return result
end

function _M.unwritten(memorycard)
    return memorycard.get_tag(WRITTEN) ~= true
end

function _M.generate_description(memorycard, signals, options)
    memorycard.set_tag(LABEL, options.label)
    memorycard.set_tag(LIST_CONTENTS, options.list_contents)

    if signals == nil then
        signals = _M.read_data(memorycard)
    end

    local description = { '', }
    if options.label then
        local label_line = {
            '[color=255,230,192]',
            options.label,
            '[/color]',
            '\n',
        }
        table.insert(description, table.concat(label_line))
    end

    local total_signals = #signals.combined + #signals.red + #signals.green
    if total_signals == 0 then
        table.insert(description, { 'description.memorycard-empty', })
    elseif options.list_contents then
        table.insert(description, build_channeled_description(signals))
    else
        table.insert(description, { 'memorycards.total-signals', total_signals, })
    end
    memorycard.custom_description = description
end

function _M.save_data(memorycard, signals, options)
    memorycard.set_tag(WRITTEN, true)
    if signals.combined and #signals.combined > 0 then
        memorycard.set_tag(SIGNALS, convert_signals(signals.combined))
    else
        memorycard.remove_tag(SIGNALS)
    end

    if signals.red and #signals.red > 0 then
        memorycard.set_tag(RED_SIGNALS, convert_signals(signals.red))
    else
        memorycard.remove_tag(RED_SIGNALS)
    end

    if signals.green and #signals.green > 0 then
        memorycard.set_tag(GREEN_SIGNALS, convert_signals(signals.green))
    else
        memorycard.remove_tag(GREEN_SIGNALS)
    end

    signals.combined = signals.combined or {}
    signals.red = signals.red or {}
    signals.green = signals.green or {}
    _M.generate_description(memorycard, signals, options)
end

function _M.read_data(memorycard)
    return {
        combined = memorycard.get_tag(SIGNALS) or {},
        red = memorycard.get_tag(RED_SIGNALS) or {},
        green = memorycard.get_tag(GREEN_SIGNALS) or {},
    }
end

function _M.read_options(memorycard)
    local options = {
        label = memorycard.get_tag(LABEL),
        list_contents = memorycard.get_tag(LIST_CONTENTS),
    }
    if options.list_contents == nil then
        options.list_contents = true
    end
    return options
end

return _M
