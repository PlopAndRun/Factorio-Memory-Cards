for _, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes
    if technologies['circuit-network'].researched then
        recipes['memorycards-writer'].enabled = true
        recipes['memorycards-reader'].enabled = true
        recipes['memorycards-memorycard'].enabled = true
    end
end