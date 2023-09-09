local function graphics(filename)
    return '__flash-cards__/graphics/' .. filename
end

return {
    transparent = {
        filename = graphics('transparent.png'),
        width = 1,
        height = 1
    }
}