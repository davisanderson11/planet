local Planet = {}
Planet.__index = Planet

-- Indicies for table
local MASS, DENSITYFACTOR, RADIUSMAXIMUM, INCLINATION, RESOURCES = 1, 2, 3, 4, 5

local commonResources = {
    rocky = {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2},
    icy = {Carbon = 70, Nitrogen = 10, Water = 20},
    metallic = {Iron = 30, Silicon = 68, RareMetals = 2},
    gas = {Hydrogen = 90, Helium = 10},
}

-- Table of important planetary values
local planetData = {
    star = {333, 1.572, 1.5, 0, {Hydrogen = 70, Helium = 30}},
    jovia = {40, 1.64, 2, 0, commonResources.gas},
    neptunia = {2, 1.5, 5, 0, commonResources.gas},
    terra = {0.1, 1, 12, 0, commonResources.rocky},
    ferria = {0.01, 1, 12, 0, commonResources.metallic},
    plutonia =  {0.0005, 1.43, 25, 0, commonResources.icy},

    chthonia = {5, 1.2, 5, 0, {Unknown = 100}},
    carbonia = {1, 1.2, 5, 0, {Unknown = 100}},
    hyceanPlanet = {1, 1.2, 5, 0, {Unknown = 100}},
    heliumPlanet = {1, 1.2, 5, 0, {Unknown = 100}},
    ammoniaPlanet = {1, 1.2, 5, 0, {Unknown = 100}},

    sol = {333, 1.572, 1.5, 0, {Hydrogen = 70, Helium = 30}},
    mercury = {0.0055, 1, 20, 7, {Iron = 30, Silicon = 68, RareMetals = 2}},
    venus = {0.0815, 1, 12, 3.4, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, CarbonDioxide = 2}},
    earth = {0.1, 1, 12, 0, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2}},
    mars = {0.00107, 1.5, 25, 1.8, {Iron = 20, Carbon = 10, Silicon = 42, Oxygen = 20, Nitrogen = 6, RareMetals = 2}},
    ceres = {0.000016, 1, 90, 10.4, {Carbon = 70, Nitrogen = 10, Water = 20}},
    jupiter = {31.7906, 1, 2, 1.3, {Hydrogen = 89, Deuterium = 1, Helium = 10}},
    saturn = {9.516, 1.15, 2, 2.5, {Hydrogen = 90, Helium = 10}},
    uranus = {1.454, 1, 5, 0.8, {Hydrogen = 89, Helium = 10, Nitrogen = 1}},
    neptune = {1.715, 1, 5, 1.8, {Hydrogen = 89, Helium = 10, Nitrogen = 1}},
    pluto = {0.00022, 1.43, 30, 17.2, {Carbon = 70, Nitrogen = 10, Water = 20}}, 
    eris = {0.00027, 1.43, 30, 44, {Carbon = 70, Nitrogen = 10, Water = 20}},
}

local function rotatePoint(x, y, px, py, theta)
    theta = math.rad(theta)
    local cosTheta = math.cos(theta)
    local sinTheta = math.sin(theta)
    local dx = x - px
    local dy = y - py

    local rotatedX = px + dx * cosTheta - dy * sinTheta
    local rotatedY = py + dx * sinTheta + dy * cosTheta
    return rotatedX, rotatedY
end

-- Constructor for a new planet
function Planet.new(centerX, centerY, smaj, ecc, t, parentBody, name)
    local self = setmetatable({}, Planet)

    self.angle = math.random(0, 360)
    self.semiMajorAxis = smaj
    self.semiMinorAxis = smaj * math.sqrt(1 - ecc^2) -- Initially circular

    self.type = t
    self.name = name

    self.mass = planetData[self.type][MASS]
    self.radius = self.mass^(1/3) * planetData[self.type][DENSITYFACTOR]
    self.temperature = (((255 / ((self.semiMajorAxis / 235)/110000^0.5))^0.5) * 1 * 1) - 273.15 -- Multiplied by albedo factor and greenhouse factor (TODO)

    local c = math.sqrt(self.semiMajorAxis^2 - self.semiMinorAxis^2)
    self.originX = centerX + c -- Adjust to place the center at one focus
    self.originY = centerY
    self.rotatedOriginX, self.rotatedOriginY = rotatePoint(self.originX, self.originY, centerX, centerY, planetData[self.type][INCLINATION])

    local viewAngle = 45
    self.visibleSemiMajorAxis = self.semiMajorAxis * (90/viewAngle) -- Adjust view angle (TODO - Fix)
    self.visibleSemiMinorAxis = self.semiMinorAxis * math.cos(math.rad(INCLINATION))

    self.speed = 1 / self.visibleSemiMajorAxis

    self.color = {1,1,1,1} -- TODO: Planet texture generation
    if t == "star" or t == "sol" then self.color = {100,100,0,1} end

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
    -- Update position for moons (if this is a moon)
    if self.parentBody then
        local parent = self.parentBody
        self.originX = parent.x
        self.originY = parent.y
        self.rotatedOriginX, self.rotatedOriginY = rotatePoint(self.originX, self.originY, parent.originX, parent.originY, planetData[self.type][INCLINATION])
    end

    -- Update the orbital angle
    self.angle = self.angle + self.speed * dt

    -- Calculate position along the ellipse
    local x = self.visibleSemiMajorAxis * math.cos(math.rad(self.angle))
    local y = self.visibleSemiMinorAxis * math.sin(math.rad(self.angle))

    -- Apply rotation for inclination
    local rotatedX, rotatedY = rotatePoint(x, y, 0, 0, planetData[self.type][INCLINATION])

    -- Adjust for the rotated origin
    self.x = self.rotatedOriginX + rotatedX
    self.y = self.rotatedOriginY + rotatedY
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

    love.graphics.setColor(1, 1, 1, 0.5) -- Semi-transparent orbit
    love.graphics.setLineWidth(1 / camera.scale)
    love.graphics.push() -- Save the current transformation state
    love.graphics.translate(self.rotatedOriginX, self.rotatedOriginY) -- Move to the rotated origin
    love.graphics.rotate(math.rad(planetData[self.type][INCLINATION])) -- Rotate the drawing context

    -- Draw the ellipse
    love.graphics.ellipse(
        "line",
        0, -- The ellipse is now drawn relative to the rotated origin
        0,
        self.visibleSemiMajorAxis, -- Horizontal radius
        self.visibleSemiMinorAxis -- Vertical radius
    )

    love.graphics.pop()
    love.graphics.setLineWidth(1)
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, adjustedRadius)
    love.graphics.setColor(1,1,1,1)
end

return Planet
