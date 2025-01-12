local Planet = {}
Planet.__index = Planet

local Satellite = require("satellite")

-- Constructor for a new planet
function Planet.new(centerX, centerY, smaj, ecc, t, parentBody)
    assert(type(ecc) == "number", "Eccentricity (ecc) must be a number")
    local self = setmetatable({}, Planet)

    self.angle = math.random(0, 360)
    self.semiMajorAxis = smaj -- Between 50 and 1000
    self.semiMinorAxis = smaj * math.sqrt(1 - ecc^2) -- Initially circular

    self.type = t

    local masses = {
        star = 333000,
        superJupiter = 1200,
        jupiter = 400,
        subJupiter = 80,
        superNeptune = 50,
        neptune = 20,
        subNeptune = 6,
        superEarth = 5,
        earth = 1,
        subEarth = 0.4,
        superMercury = 0.5,
        mercury = 0.1,
        subMercury = 0.005, 
        superPluto = 0.1,
        pluto =  0.005,
        subPluto = 0.001,
    }

    local densityFactors = {
        star = 1.572,
        superJupiter = 1.64,
        jupiter = 1.64,
        subJupiter = 1.64,
        superNeptune = 1.5,
        neptune = 1.5,
        subNeptune = 1.5,
        superEarth = 1,
        earth = 1,
        subEarth = 1.15,
        superMercury = 1,
        mercury = 1,
        subMercury = 1, 
        superPluto = 1.43,
        pluto =  1.43,
        subPluto = 1.43,
    }

    self.mass = masses[self.type]
    self.radius = self.mass^(1/3) * densityFactors[self.type]
    self.speed = 1 / self.semiMajorAxis
    self.temperature = nil

    local c = math.sqrt(self.semiMajorAxis^2 - self.semiMinorAxis^2)
    self.originX = centerX + c -- Adjust to place the center at one focus
    self.originY = centerY

    local colors = {
        star = {1,1,0,1},
        superJupiter = {0.8,0.6,0,1},
        jupiter = {0.8,0.6,0,1},
        subJupiter = {0.8,0.6,0,1},
        superNeptune = {0.05,0.2,0.8,1},
        neptune = {0.05,0.2,0.8,1},
        subNeptune = {0.05,0.2,0.8,1},
        superEarth = {0.05,0.5,0.8,1},
        earth = {0.05,0.5,0.8,1},
        subEarth = {0.05,0.5,0.8,1},
        superMercury = {1,1,1,0.8},
        mercury = {1,1,1,0.8},
        subMercury = {1,1,1,0.8}, 
        superPluto = {0.4,0.6,0.1,1},
        pluto = {0.4,0.6,0.1,1},
        subPluto = {0.4,0.6,0.1,1},
    }

    self.color = colors[self.type]
    if t == "star" then self.color = {100,100,0,1} end
    self.atmosphereColor = self.color
    if t == "star" then self.atmosphereColor = {120,100,0,1} end

    self.x = self.originX -- Initialize position
    self.y = self.originY -- Initialize position

    self.composition = Planet.generateComposition()

    self.parentBody = parentBody -- New field for parent planet/moon relationship

    return self
end


function Planet:generateComposition()
    local compositions = {}
    local iron = math.random(10,40)
    local silicon = math.random(20,50)
    local carbon = math.random(5,15)
    local water = math.random(0,20)
    local total = iron + silicon + carbon + water

    local composition = {
        iron = (iron / total) * 100,
        silicon = (silicon / total) * 100,
        carbon = (carbon / total) * 100,
        water = (water / total) * 100,
    }
    return composition
end

-- Update the planet's position along its elliptical orbit
function Planet:update(dt)
    -- Update position for moons
    if self.parentBody then
        local parent = planets[self.parentBody]
        if parent then
            self.originX = parent.x
            self.originY = parent.y
        end
    end

    -- Update the planet's position along its elliptical orbit
    self.angle = self.angle + self.speed * dt
    self.x = self.originX + self.semiMajorAxis * math.cos(math.rad(self.angle))
    self.y = self.originY + self.semiMinorAxis * math.sin(math.rad(self.angle))
end


function Planet:isClicked(mouseX, mouseY)
    local distance = math.sqrt((mouseX - self.x)^2 + (mouseY - self.y)^2)
    return distance <= self.radius -- Check if within the planet's radius
end

function Planet:onRightClick()
    -- Place a satellite in a stable orbit at 4 times the planet's radius
    local orbitRadius = self.radius * 2
    local angle = math.random(0, 2 * math.pi) -- Random angle around the planet
    local satelliteX = self.x + orbitRadius * math.cos(angle)
    local satelliteY = self.y + orbitRadius * math.sin(angle)

    -- Calculate the required orbital velocity for a stable circular orbit
    local orbitalVelocity = math.sqrt(self.mass / orbitRadius)
    local tangentialAngle = angle + math.pi / 2 -- Perpendicular to the radial direction
    local velocityX = orbitalVelocity * math.cos(tangentialAngle)
    local velocityY = orbitalVelocity * math.sin(tangentialAngle)

    -- Create and add the satellite
    local newSatellite = Satellite.new(satelliteX, satelliteY, velocityX, velocityY)
    table.insert(satellites, newSatellite)
end

function Planet:getCompositionText()
    local text = {"Surface Composition:"}
    for element, percentage in pairs(self.composition) do
        table.insert(text, element .. ": " .. percentage .. "%")
    end
    return text
end

-- Draw the planet and its elliptical orbit
function Planet:draw(camera)
    local radiusMaximums = {
        star = 0.2,
        superJupiter = 0.8,
        jupiter = 0.8,
        subJupiter = 0.8,
        superNeptune = 1.5,
        neptune = 1.5,
        subNeptune = 1.5,
        superEarth = 4,
        earth = 5,
        subEarth = 5,
        superMercury = 7,
        mercury = 7,
        subMercury = 10, 
        superPluto = 7,
        pluto =  10,
        subPluto = 15,
    }
    local scaledRadius = self.radius / camera.scale
    local adjustedRadius = self.type and math.max(self.radius, scaledRadius * radiusMaximums[self.type]) or self.radius

    love.graphics.setColor(self.atmosphereColor)
    love.graphics.circle("fill", self.x, self.y, (adjustedRadius) * 1.2)
    love.graphics.setColor(1, 1, 1, 0.5) -- Semi-transparent orbit
    love.graphics.setLineWidth(1 / camera.scale)
    love.graphics.ellipse(
        "line",
        self.originX, -- Center X of the ellipse
        self.originY, -- Center Y of the ellipse
        self.semiMajorAxis, -- Horizontal radius
        self.semiMinorAxis -- Vertical radius
    )
    love.graphics.setLineWidth(1)
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, adjustedRadius)
    love.graphics.setColor(1,1,1,1)
end

return Planet
