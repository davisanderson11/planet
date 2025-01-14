local PlanetMenu = {}

local windowWidth, windowHeight = love.graphics.getDimensions()

-- Variable to track the currently selected planet
local selectedPlanet = nil

-- Function to open the planet info menu
function PlanetMenu.open(planet)
    selectedPlanet = planet
end

-- Function to close the planet info menu
function PlanetMenu.close()
    selectedPlanet = nil
end

-- Check if the planet menu is open
function PlanetMenu.isOpen()
    return selectedPlanet ~= nil
end

-- Draw the planet info screen
function PlanetMenu.draw()
    if not selectedPlanet then return end

    -- Screen dimensions
    local x, y = 10, 10
    local width, height = 300, 200
    local yOffset = 40

    -- Background box
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x, y, width, height)

    -- Border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Title
    love.graphics.printf(selectedPlanet.type:upper() .. " INFO", x + 10, y + 10, width - 20, "center")

    -- Display temperature
    love.graphics.printf("Temperature: " .. string.format("%.2f", selectedPlanet.temperature) .. " °C", x + 10, y + yOffset, width - 20, "left")
    yOffset = yOffset + 20

    love.graphics.printf("Semi Major Axis: " .. string.format("%.2f", (selectedPlanet.semiMajorAxis / 2)/235) .. " AU", x + 10, y + yOffset, width - 20, "left")
    yOffset = yOffset + 20

    -- Display composition
    love.graphics.printf("Composition:", x + 10, y + yOffset, width - 20, "left")
    yOffset = yOffset + 20

    for element, percentage in pairs(selectedPlanet.composition) do
        love.graphics.printf(element .. ": " .. string.format("%.2f", percentage) .. "%", x + 10, y + yOffset, width - 20, "left")
        yOffset = yOffset + 15
    end
end

return PlanetMenu
