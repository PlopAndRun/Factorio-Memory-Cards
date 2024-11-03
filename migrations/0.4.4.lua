for _, player in pairs(game.players) do
    if player.opened ~= nil and player.opened.name == 'memorycards-writer-machine' then
        player.opened = nil
    end
end