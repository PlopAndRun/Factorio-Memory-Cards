local names = (require 'utils').names

local _M = {}

local SIGNALS = names.MOD_PREFIX .. 'signals'

local function build_description(signals)
    if not signals then
        return { 'description.memorycard-empty' }
    end
    local builder = { '' }
    table.sort(signals, function(signal1, signal2) return signal2.count < signal1.count end)
    local limit = #signals <= 19 and 20 or 19
    if signals ~= nil then
        for _, signal in pairs(signals) do
            local name = signal.signal.name
            local count = signal.count
            local newline = #builder > 1 and '\n' or ''
            local localization = { '?',
                { 'item-name.' .. name },
                { 'entity-name.' .. name },
                { 'virtual-signal-name.' .. name },
                name
            }
            table.insert(builder, { '', newline, localization, ': ', count })
            if #builder >= limit then
                break
            end
        end
    end
    if #signals >= 20 then
        table.insert(builder, { '', '\n', { 'memorycards.has-more-signals', #signals - 18 } });
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
            count = signals[i].count
        })
    end
    return result
end

function _M.save_data(memorycard, signals)
    memorycard.set_tag(SIGNALS, convert_signals(signals))
    memorycard.custom_description = build_description(signals)
end

function _M.read_data(memorycard)
    return memorycard.get_tag(SIGNALS) or {}
end

return _M
