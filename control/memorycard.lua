local names = (require 'utils').names

local _M = {}

local SIGNALS = names.MOD_PREFIX .. 'signals'
local RED_SIGNALS = names.MOD_PREFIX .. 'red-signals'
local GREEN_SIGNALS = names.MOD_PREFIX .. 'green-signals'
local CHANNEL_INDENT = '        '

local function build_description(signals)
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
        table.insert(builder, build_description(signals.combined))
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
        table.insert(builder, build_description(signals.red))
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
        table.insert(builder, build_description(signals.green))
        added_text = true
    end

    if not added_text then
        return { 'description.memorycard-empty', }
    end

    return builder
end

local function convert_signals(signals)
    if not signals then return {} end
    local result = {}
    for i = 1, #signals do
        table.insert(result, {
            index = i,
            signal = signals[i].signal,
            count = signals[i].count,
        })
    end
    return result
end

function _M.unwritten(memorycard)
    return memorycard.get_tag(SIGNALS) == nil
end

function _M.save_data(memorycard, signals)
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

    memorycard.custom_description = build_channeled_description(signals)
end

function _M.read_data(memorycard)
    return {
        combined = memorycard.get_tag(SIGNALS) or {},
        red = memorycard.get_tag(RED_SIGNALS) or {},
        green = memorycard.get_tag(GREEN_SIGNALS) or {},
    }
end

return _M
