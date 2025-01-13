local Planet = {}
Planet.__index = Planet

    -- Indicies for table
    local MASS = 1
    local DENSITYFACTOR = 2
    local RADIUSMAXIMUM = 3 -- For display on screen only
    local RESOURCES = 4

    -- Table of important planetary values
    local planetData = {
        star = {333, 1.572, 1.5, {Hydrogen = 70, Helium = 30}},
        superJovia = {120, 1.64, 2, {Hydrogen = 89, Deuterium = 1, Helium = 10}},
        jovia = {40, 1.64, 2, {Hydrogen = 90, Helium = 10}},
        subJovia = {8, 1.64, 2, {Hydrogen = 90, Helium = 9, Carbon = 1}},
        superNeptunia = {5, 1.5, 5, {Hydrogen = 89, Helium = 9, Carbon = 1, Nitrogen = 1}},
        neptunia = {2, 1.5, 5, {Hydrogen = 89, Helium = 10, Nitrogen = 1}},
        subNeptunia = {0.6, 1.5, 5, {Hydrogen = 89, Nitrogen = 10, CarbonDioxide = 1}},
        superTerra = {0.5, 1, 12, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2}},
        terra = {0.1, 1, 12, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2}},
        subTerra = {0.04, 1.15, 12, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2}},
        superFerria = {0.05, 1, 12, {Iron = 30, Silicon = 68, RareMetals = 2}},
        ferria = {0.01, 1, 12, {Iron = 30, Silicon = 68, RareMetals = 2}},
        subFerria = {0.0005, 1, 12, {Iron = 30, Silicon = 68, RareMetals = 2}}, 
        superPlutonia = {0.01, 1.43, 25, {Carbon = 70, Nitrogen = 10, Water = 20}},
        plutonia =  {0.0005, 1.43, 25, {Carbon = 70, Nitrogen = 10, Water = 20}},
        subPlutonia = {0.0001, 1.43, 50, {Carbon = 70, Nitrogen = 10, Water = 20}},

        sol = {333, 1.572, 1.5, {Hydrogen = 70, Helium = 30}},
        mercury = {0.0055, 1, 20, {Iron = 30, Silicon = 68, RareMetals = 2}},
        venus = {0.0815, 1, 12, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, CarbonDioxide = 2}},
        earth = {0.1, 1, 12, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2}},
        mars = {0.00107, 1.5, 25, {Iron = 20, Carbon = 10, Silicon = 42, Oxygen = 20, Nitrogen = 6, RareMetals = 2}},
        ceres = {0.000016, 1, 90, {Carbon = 70, Nitrogen = 10, Water = 20}},
        jupiter = {31.7906, 1, 2, {Hydrogen = 89, Deuterium = 1, Helium = 10}},
        saturn = {9.516, 1.15, 2, {Hydrogen = 90, Helium = 10}},
        uranus = {1.454, 1, 5, {Hydrogen = 89, Helium = 10, Nitrogen = 1}},
        neptune = {1.715, 1, 5, {Hydrogen = 89, Helium = 10, Nitrogen = 1}},
        pluto = {0.00022, 1.43, 30, {Carbon = 70, Nitrogen = 10, Water = 20}}, 
        eris = {0.00027, 1.43, 30, {Carbon = 70, Nitrogen = 10, Water = 20}},
    }

-- Constructor for a new planet
function Planet.new(centerX, centerY, smaj, ecc, t, parentBody)
    local self = setmetatable({}, Planet)

    self.angle = math.random(0, 360)
    self.semiMajorAxis = smaj 
    self.semiMinorAxis = smaj * math.sqrt(1 - ecc^2) -- Initially circular

    self.type = t

    self.mass = planetData[self.type][MASS]
    self.radius = self.mass^(1/3) * planetData[self.type][DENSITYFACTOR]
    self.speed = 1 / self.semiMajorAxis
    self.temperature = (((255 / ((self.semiMajorAxis / 235)/110000^0.5))^0.5) * 1 * 1) - 273.15 -- Multiplied by albedo factor and greenhouse factor (TODO)

    local c = math.sqrt(self.semiMajorAxis^2 - self.semiMinorAxis^2)
    self.originX = centerX + c -- Adjust to place the center at one focus
    self.originY = centerY

    self.color = {1,1,1,1} -- TODO: Planet texture generation
    if t == "star" or t == "sol" then self.color = {100,100,0,1} end
    self.atmosphereColor = self.color -- TODO: Atmosphere generation
    if t == "star" or t == "sol" then self.atmosphereColor = {120,100,0,1} end

    -- Init pos
    self.x = self.originX
    self.y = self.originY

    self.composition = self:generateComposition()

    self.parentBody = parentBody -- TODO: Reintegrate moons

    return self
end


function Planet:generateComposition()
    -- Get the resource weights for the planet type
    local resourceWeights = planetData[self.type][RESOURCES]
    if not resourceWeights then
        error("Resources not defined for planet type: " .. tostring(self.type))
    end

    local compositions = {}

    -- Calculate total weight
    local totalWeight = 0
    for _, weight in pairs(resourceWeights) do
        totalWeight = totalWeight + weight
    end

    -- Normalize weights to percentages
    for resource, weight in pairs(resourceWeights) do
        local percentage = (weight / totalWeight) * 100
        compositions[resource] = percentage
    end

    return compositions
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

    self.angle = self.angle + self.speed * dt
    self.x = self.originX + self.semiMajorAxis * math.cos(math.rad(self.angle))
    self.y = self.originY + self.semiMinorAxis * math.sin(math.rad(self.angle))
end


function Planet:isClicked(mouseX, mouseY)
    local distance = math.sqrt((mouseX - self.x)^2 + (mouseY - self.y)^2)
    return distance <= self.radius -- Check if within the planet's radius
end

function Planet:getCompositionText()
    local text = {"Composition:"}
    for element, percentage in pairs(self.composition) do
        table.insert(text, element .. ": " .. percentage .. "%")
    end
    return text
end

-- Draw the planet and its elliptical orbit
function Planet:draw(camera)
    local scaledRadius = self.radius / camera.scale
    local adjustedRadius = self.type and math.max(self.radius, scaledRadius * planetData[self.type][RADIUSMAXIMUM]) or self.radius

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
