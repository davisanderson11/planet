local PlanetMenu = {}

local windowWidth, windowHeight = love.graphics.getDimensions()

-- Variable to track the currently selected planet
local selectedPlanet = nil

syFont = love.graphics.newFont("fonts/NotoSansSymbols.ttf", 15)
txFont = love.graphics.newFont("fonts/NotoSansSymbols.ttf", 15)

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
    local width, height = 300, 300
    local yOffset = 40

    -- Background box
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x, y, width, height)

    -- Border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)

    -- Title
    love.graphics.printf(selectedPlanet.name:upper() .. " INFO", x + 10, y + 10, width - 20, "center")

    font = love.graphics.setFont(syFont, 15)
    if selectedPlanet.mass <= 0.012 then
        love.graphics.printf("Mass: " .. string.format("%.2f", selectedPlanet.mass * 833.33333333) .. " M☾", x + 10, y + yOffset, width - 20, "left") end
    if selectedPlanet.mass > 0.012 and selectedPlanet.mass <= 1 then
        love.graphics.printf("Mass: " .. string.format("%.2f", selectedPlanet.mass * 10) .. " M🜨", x + 10, y + yOffset, width - 20, "left") end
    if selectedPlanet.mass > 1 then
        love.graphics.printf("Mass: " .. string.format("%.2f", selectedPlanet.mass * 0.03145583914) .. " M♃", x + 10, y + yOffset, width - 20, "left") end
    yOffset = yOffset + 20

    font = love.graphics.setFont(txFont, 15)
    love.graphics.printf("Temperature: " .. string.format("%.2f", selectedPlanet.temperature) .. " °C", x + 10, y + yOffset, width - 20, "left")
    yOffset = yOffset + 20

    if selectedPlanet.semiMajorAxis / 235 < 0.1 then
        love.graphics.printf("Semi Major Axis: " .. string.format("%.0f", ((selectedPlanet.semiMajorAxis) *14960000)/235) .. " km", x + 10, y + yOffset, width - 20, "left")
    else
        love.graphics.printf("Semi Major Axis: " .. string.format("%.2f", (selectedPlanet.semiMajorAxis)/235) .. " AU", x + 10, y + yOffset, width - 20, "left")
    end
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
