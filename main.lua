local Planet = require("planet")
local Camera = require("camera")

local windowWidth, windowHeight = love.graphics.getDimensions()
planets = {}
local camera = Camera.new()

function love.load()
    window = {translateX = 40, translateY = 40, scale = 1, windowWidth = 1920, windowHeight = 1080}
    love.window.setMode(windowWidth, windowHeight, {resizable = true, borderless = false})
    math.randomseed(os.time())

    -- Add the central star and planets
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 0.000001, 0, "sol"))

    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 0.387 * 235, 0.206, "mercury"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 0.723 * 235, 0.006, "venus"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 1 * 235, 0.017, "earth"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 1.523 * 235, 0.093, "mars"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 2.77 * 235, 0.079, "ceres"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 5.203 * 235, 0.049, "jupiter"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 9.583 * 235, 0.057, "saturn"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 19.191 * 235, 0.047, "uranus"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 30.07 * 235, 0.009, "neptune"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 39.482 * 235, 0.249, "pluto"))
    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 67.864 * 235, 0.436, "eris"))

    local function addMoons(parentIndex, numMoons)
        local parentPlanet = planets[parentIndex]
        for i = 1, numMoons do
            local semiMajorAxis = math.random(0.5, 2)
            table.insert(planets, Planet.new(parentPlanet.x, parentPlanet.y, semiMajorAxis, 0, "subMercury", parentIndex))
        end
    end
end

function love.update(dt)
    local adjustedDt = math.min(dt, 0.01)
    camera:update(adjustedDt)

    if camera.isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        camera:drag(mouseX, mouseY)
    end

    for _, planet in ipairs(planets) do 
        planet:update(adjustedDt)
    end

    camera:updateMousePosition()
end

local currentComposition = nil

function love.mousepressed(x, y, button)
    -- Convert screen coordinates to world coordinates
    local worldX, worldY = camera:screenToWorld(x, y)

    if button == 1 then
        for _, planet in ipairs(planets) do
            if planet:isClicked(worldX, worldY) then
                currentComposition = planet:getCompositionText()
                return -- Only handle the first clicked planet
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        camera:stopDragging()
    end
end


function love.wheelmoved(x, y)
    camera:wheelmoved(x, y)
end

function love.draw()
    camera:apply()

    -- Draw all planets
    for _, planet in ipairs(planets) do
        planet:draw(camera)
    end

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

