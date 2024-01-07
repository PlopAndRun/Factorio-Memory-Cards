local names = (require 'utils').names

local _M = {}

local SIGNALS = names.MOD_PREFIX .. 'signals'

local function build_description(signals)
    local builder = {}
    if signals ~= nil then
        for _, signal in pairs(signals) do
            local name = signal.signal.name
            local count = tostring(signal.count)
            table.insert(builder, name .. ": " .. count)
        end
    end
    return table.concat(builder, '\n')
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

function _M.save_data(flashcard, signals)
    flashcard.set_tag(SIGNALS, convert_signals(signals))
    flashcard.custom_description = build_description(signals)
end

function _M.read_data(flashcard)
    return flashcard.get_tag(SIGNALS) or {}
end

return _M
