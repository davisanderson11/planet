local Planet = require("main/planet")
local Camera = require("main/camera")
local PlanetMenu = require("menu/planet_menu")
local MainMenu = require("menu/main_menu")
local TimeController = require("main/time_controller")

local gameState = "main_menu" -- Default game state

local windowWidth, windowHeight = love.graphics.getDimensions()
planets = {}
local camera = Camera.new()
local timeController = TimeController.new()

function love.load()
    -- Set up window
    window = {translateX = 40, translateY = 40, scale = 1, windowWidth = 1920, windowHeight = 1080}
    love.window.setMode(windowWidth, windowHeight, {resizable = true, borderless = false})
    math.randomseed(os.time())

    -- Add planets
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

    table.insert(planets, Planet.new(windowWidth / 2, windowHeight / 2, 0.02 * 235, 0.05, "ferria", planets[4])) -- Moon orbiting Earth
end

function love.update(dt)
    if gameState == "game" then
        -- Apply the time scale to the delta time
        local adjustedDt = math.min(dt, 0.01) * timeController.timeScale

        -- Update the camera
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
        
        -- Update mouse position for zoom functionality
        camera:updateMousePosition()
    end
end

function love.keypressed(key)
    if key == "=" then -- Increase speed
        timeController:increaseSpeed()
    elseif key == "-" then -- Decrease speed
        timeController:decreaseSpeed()
    elseif key == "0" then -- Reset speed
        timeController:resetSpeed()
    end
end


function love.mousepressed(x, y, button)
    if gameState == "main_menu" then
        local action = MainMenu.mousepressed(x, y, button)
        if action == "game" then
            gameState = "game" -- Start the game
        end
        return
    end

    if gameState == "game" then
        if PlanetMenu.isOpen() then
            PlanetMenu.close()
            return
        end

        local worldX, worldY = camera:screenToWorld(x, y)

        if button == 1 then
            for _, planet in ipairs(planets) do
                if planet:isClicked(worldX, worldY) then
                    PlanetMenu.open(planet)
                    return
                end
            end

            camera:startDragging(x, y)
        end
    end
end

function love.mousereleased(x, y, button)
    if gameState == "game" and button == 1 then
        camera:stopDragging()
    end
end

function love.mousemoved(x, y, dx, dy)
    if gameState == "main_menu" then
        MainMenu.mousemoved(x, y)
    end
end

function love.wheelmoved(x, y)
    if gameState == "game" then
        camera:wheelmoved(x, y) -- Only handle zooming when in the game state
    end
end


function love.draw()
    if gameState == "main_menu" then
        MainMenu.draw()
    elseif gameState == "game" then
        camera:apply()

        -- Draw all planets
        for _, planet in ipairs(planets) do
            planet:draw(camera)
        end

        camera:reset()

        -- Draw the planet info screen if open
        PlanetMenu.draw()
    end
end

