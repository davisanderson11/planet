local Planet = require("main/planet")
local Camera = require("main/camera")
local Satellite = require("main/satellite")
local PlanetMenu = require("menu/planet_menu")
local MainMenu = require("menu/main_menu")
local SatelliteMenu = require("menu/satellite_menu")
local TimeController = require("main/time_controller")

local gameState = "main_menu" -- Default game state

local windowWidth, windowHeight = love.graphics.getDimensions()
planets = {}
local camera = Camera.new()
local satellites = {}
local timeController = TimeController.new()

local selectedSatellite = nil
local inputActive = false
local inputText = ""

function love.load()
    -- Set up window
    window = {translateX = 40, translateY = 40, scale = 1, windowWidth = 1920, windowHeight = 1080}
    love.window.setMode(windowWidth, windowHeight, {resizable = true, borderless = false})
    math.randomseed(os.time())
    local middleX, middleY = windowWidth/2, windowHeight/2
    local au = 235

    -- Add planets
    table.insert(planets, Planet.new(middleX, middleY, 333, 0.000001 * au, 0, 0, "reg", "sol", nil, "Sol"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0055, 0.387 * au, 0.206, 7, "reg", "mercury", nil, "Mercury"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0815, 0.723 * au, 0.006, 3.4, "reg", "venus", nil, "Venus"))
    table.insert(planets, Planet.new(middleX, middleY, 0.1, 1 * au, 0.017, 0, "reg", "earth", nil, "Earth"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0107, 1.523 * au, 0.093, 1.8, "reg", "mars", nil, "Mars"))
    table.insert(planets, Planet.new(middleX, middleY, 0.000016, 2.77 * au, 0.079, 10.4, "reg", "ceres", nil, "Ceres"))
    table.insert(planets, Planet.new(middleX, middleY, 31.7906, 5.203 * au, 0.049, 1.3, "reg", "jupiter", nil, "Jupiter"))
    table.insert(planets, Planet.new(middleX, middleY, 9.516, 9.583 * au, 0.057, 2.5, "reg", "saturn", nil, "Saturn"))
    table.insert(planets, Planet.new(middleX, middleY, 1.454, 19.191 * au, 0.047, 0.8, "reg", "uranus", nil, "Uranus"))
    table.insert(planets, Planet.new(middleX, middleY, 1.715, 30.07 * au, 0.009, 1.8, "reg", "neptune", nil, "Neptune"))
    table.insert(planets, Planet.new(middleX, middleY, 0.00022, 39.482 * au, 0.249, 17.2, "reg", "pluto", nil, "Pluto"))

    table.insert(planets, Planet.new(middleX, middleY, 0.0012, 0.02 * au, 0.05, 0, "sub", "ferria", planets[4], "Moon"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0015, 0.028 * au, 0, 0, "reg", "ferria", planets[7], "Io"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0008, 0.045 * au, 0.01, 0, "sub", "ferria", planets[7], "Europa"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0025, 0.072 * au, 0, 0, "reg", "ferria", planets[7], "Ganymede"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0018, 0.13 * au, 0.01, 0, "reg", "ferria", planets[7], "Callisto"))
    table.insert(planets, Planet.new(middleX, middleY, 0.00000063, 0.012 * au, 0.02, 0, "mini", "plutonia", planets[8], "Mimas"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0000018, 0.016 * au, 0, 0, "mini", "plutonia", planets[8], "Enceladus"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0000103, 0.02 * au, 0, 0, "sub", "plutonia", planets[8], "Tethys"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0000183, 0.025 * au, 0, 0, "reg", "plutonia", planets[8], "Dione"))
    table.insert(planets, Planet.new(middleX, middleY, 0.000039, 0.035 * au, 0, 0, "reg", "plutonia", planets[8], "Rhea"))
    table.insert(planets, Planet.new(middleX, middleY, 0.00225, 0.08 * au, 0.03, 0, "super", "plutonia", planets[8], "Titan"))
    table.insert(planets, Planet.new(middleX, middleY, 0.00003, 0.23 * au, 0.03, 0, "reg", "plutonia", planets[8], "Iapetus"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0000011, 0.009 * au, 0, 0, "mini", "plutonia", planets[9], "Miranda"))
    table.insert(planets, Planet.new(middleX, middleY, 0.000019, 0.013 * au, 0, 0, "sub", "plutonia", planets[9], "Ariel"))
    table.insert(planets, Planet.new(middleX, middleY, 0.000019, 0.018 * au, 0, 0, "sub", "plutonia", planets[9], "Umbriel"))
    table.insert(planets, Planet.new(middleX, middleY, 0.000056, 0.029 * au, 0, 0, "reg", "plutonia", planets[9], "Titania"))
    table.insert(planets, Planet.new(middleX, middleY, 0.000051, 0.039 * au, 0, 0, "reg", "plutonia", planets[9], "Oberon"))
    table.insert(planets, Planet.new(middleX, middleY, 0.0004, 0.024 * au, 0, 0, "super", "plutonia", planets[10], "Triton"))
    table.insert(planets, Planet.new(middleX, middleY, 0.000027, 0.005 * au, 0, 0, "sub", "plutonia", planets[11], "Charon"))
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

        -- Update all satellites
        for _, satellite in ipairs(satellites) do
            satellite:update(adjustedDt)
        end

        -- Update mouse position for zoom functionality
        camera:updateMousePosition()
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

        if button == 1 then -- Left-click for planet menu or satellite selection
            for _, planet in ipairs(planets) do
                if planet:isClicked(worldX, worldY) then
                    PlanetMenu.open(planet)
                    return
                end
            end

            -- Check if a satellite is clicked
            for _, satellite in ipairs(satellites) do
                if satellite:isClicked(worldX, worldY, camera) then
                    selectedSatellite = satellite
                    SatelliteMenu.open(selectedSatellite)
                    inputActive = true
                    inputText = ""
                    return
                end
            end

            camera:startDragging(x, y)

        elseif button == 2 then -- Right-click to add a satellite
            for _, planet in ipairs(planets) do
                if planet:isClicked(worldX, worldY) then
                    table.insert(satellites, Satellite.new(planet))
                    return
                end
            end
        end
    end
end

function love.keypressed(key)
    if inputActive then
        if key == "return" then
            -- Find the planet with the entered name
            for _, planet in ipairs(planets) do
                if planet.name:lower() == inputText:lower() then
                    selectedSatellite:setTargetPlanet(planet)
                    break
                end
            end
            inputActive = false
        elseif key == "backspace" then
            inputText = inputText:sub(1, -2)
        elseif key == "escape" then
            inputActive = false
        end
    else
        if key == "=" then -- Increase speed
            timeController:increaseSpeed()
        elseif key == "-" then -- Decrease speed
            timeController:decreaseSpeed()
        elseif key == "0" then -- Reset speed
            timeController:resetSpeed()
        end
    end
end

function love.textinput(text)
    if inputActive then
        inputText = inputText .. text
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

        -- Draw all satellites
        for _, satellite in ipairs(satellites) do
            satellite:draw(camera)
        end

        camera:reset()

        -- Draw the planet info screen if open
        PlanetMenu.draw()

        -- Draw input box if satellite renaming is active
        if inputActive then
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.rectangle("fill", 200, 300, 400, 50)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 200, 300, 400, 50)
            love.graphics.print("Enter planet name: " .. inputText, 210, 320)
        end
    end
end
