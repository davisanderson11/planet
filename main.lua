local Planet = require("planet")
local Satellite = require("satellite")
local Camera = require("camera")

local windowWidth, windowHeight = love.graphics.getDimensions()
planets = {}
satellites = {}
local camera = Camera.new()

function love.load()
    window = {translateX = 40, translateY = 40, scale = 1, windowWidth = 1920, windowHeight = 1080}
    love.window.setMode(windowWidth, windowHeight, {resizable = true, borderless = false})

    -- Add the central star
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 0.000001, 0, "star", {1, 1, 0, 1}, {1,0.8,0,1}))

    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 0.387 * 23455, 0.206, "mercury"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 0.723 * 23455, 0.006, "earth"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 1 * 23455, 0.017, "earth"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 1.523 * 23455, 0.093, "subEarth"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 2.77 * 23455, 0.079, "subEarth"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 5.203 * 23455, 0.049, "jupiter"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 9.583 * 23455, 0.057, "subJupiter"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 19.191 * 23455, 0.047, "neptune"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 30.07 * 23455, 0.009, "neptune"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 39.482 * 23455, 0.249, "pluto"))


    -- Add moons to specific planets
    local function addMoons(parentIndex, numMoons)
        local parentPlanet = planets[parentIndex]
        for i = 1, numMoons do
            local semiMajorAxis = math.random(50, 200) -- Smaller orbit for a moon
            table.insert(planets, Planet.new(parentPlanet.x, parentPlanet.y, semiMajorAxis, 0, "subMercury", parentIndex))
        end
    end

    addMoons(4, 1)  -- Planet 3 gets 2 moons
    addMoons(5, 2)  -- Planet 5 gets 1 moon
    addMoons(7, 5)  -- Planet 7 gets 5 moons
    addMoons(8, 6)  -- Planet 8 gets 6 moons
    addMoons(9, 2)  -- Planet 9 gets 2 moons
    addMoons(10, 4) -- Planet 10 gets 4 moons
end

function love.update(dt)
    local adjustedDt = math.min(dt, 0.01)
    -- Update camera
    camera:update(adjustedDt)

    -- Handle camera dragging
    if camera.isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        camera:drag(mouseX, mouseY)
    end

    -- Update all planets
    for _, planet in ipairs(planets) do 
        planet:update(adjustedDt)
    end

    -- Update all satellites
    for _, satellite in ipairs(satellites) do
        satellite:update(adjustedDt, planets) -- Pass all planets to the satellite update
    end

    -- Update mouse position for zoom functionality
    camera:updateMousePosition()
end

local currentComposition = nil

function love.mousepressed(x, y, button)
    -- Convert screen coordinates to world coordinates
    local worldX, worldY = camera:screenToWorld(x, y)

    if button == 1 then -- Left mouse button
        -- Check for left-click on a planet
        for _, planet in ipairs(planets) do
            if planet:isClicked(worldX, worldY) then
                currentComposition = planet:getCompositionText()
                return -- Only handle the first clicked planet
            end
        end

        -- If no planet is clicked, enable camera dragging
        camera:startDragging(x, y)
    elseif button == 2 then -- Right mouse button
        -- Handle right-click for adding satellites
        for _, planet in ipairs(planets) do
            if planet:isClicked(worldX, worldY) then
                planet:onRightClick()
                break -- Only handle the first clicked planet
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then -- Left mouse button
        camera:stopDragging()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        -- Create a moon with parentBody = 2
        local parentPlanet = planets[2] -- The parent is planet 2
        local semiMajorAxis = math.random(50, 200) -- Smaller orbit for a moon
        local mass = math.random(0.01, 0.1) -- Small mass for a moon
        local color = {0.8, 0.8, 0.8, 1} -- Gray color for moons
        local atmosphereColor = {0.6, 0.6, 0.6, 1} -- Light gray atmosphere
        table.insert(planets, Planet.new(parentPlanet.x, parentPlanet.y, semiMajorAxis, mass, "rocky", color, atmosphereColor, 2))
    end
end


function love.wheelmoved(x, y)
    -- Delegate zoom control to the camera
    camera:wheelmoved(x, y)
end

function love.draw()
    -- Apply camera transformations
    camera:apply()

    -- Draw all planets
    for _, planet in ipairs(planets) do
        planet:draw(camera)
    end
    for _, satellite in ipairs(satellites) do
        satellite:draw(camera)
    end

    -- Reset camera transformations
    camera:reset()

    -- Draw the composition text in the top-left corner
    if currentComposition then
        love.graphics.setColor(1, 1, 1, 1) -- White text color
        local y = 10
        for _, line in ipairs(currentComposition) do
            love.graphics.print(line, 10, y)
            y = y + 20
        end
    end
end

