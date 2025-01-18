local SatelliteMenu = {}

local windowWidth, windowHeight = love.graphics.getDimensions()

-- Variable to track the currently selected planet
local selectedSatellite = nil

syFont = love.graphics.newFont("fonts/NotoSansSymbols.ttf", 15)
txFont = love.graphics.newFont("fonts/NotoSansSymbols.ttf", 15)

-- Function to open the planet info menu
function SatelliteMenu.open(satellite)
    selectedSatellite = satellite
end

-- Function to close the planet info menu
function SatelliteMenu.close()
    selectedSatellite = nil
end

-- Check if the planet menu is open
function SatelliteMenu.isOpen()
    return selectedSatellite ~= nil
end

-- Draw the planet info screen
function SatelliteMenu.draw()
    if not selectedSatellite then return end

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
    love.graphics.printf(selectedSatellite.type:upper() .. " INFO", x + 10, y + 10, width - 20, "center")

    font = love.graphics.setFont(txFont, 15)
    love.graphics.printf("Target: " .. selectedSatellite.targetPlanet, x + 10, y + yOffset, width - 20, "left")
end

return SatelliteMenu
