local Planet = {}
Planet.__index = Planet

-- Indicies for table
local DENSITYFACTOR, RADIUSMAXIMUM, RESOURCES = 1, 2, 3

local commonResources = {
    rocky = {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2},
    icy = {Carbon = 70, Nitrogen = 10, Water = 20},
    metallic = {Iron = 30, Silicon = 68, RareMetals = 2},
    gas = {Hydrogen = 90, Helium = 10},
}

-- Table of important planetary values
local planetData = {
    star = {1.572, 1.5, {Hydrogen = 70, Helium = 30}},
    jovia = {1.64, 2, commonResources.gas},
    neptunia = {1.5, 5, commonResources.gas},
    terra = {1, 12, commonResources.rocky},
    ferria = {1, 25, commonResources.metallic},
    plutonia =  {1.43, 40, commonResources.icy},

    chthonia = {1.2, 5, {Unknown = 100}},
    carbonia = {1.2, 5, {Unknown = 100}},
    hyceanPlanet = {1.2, 5, {Unknown = 100}},
    heliumPlanet = {1.2, 5, {Unknown = 100}},
    ammoniaPlanet = {1.2, 5, {Unknown = 100}},

    sol = {1.572, 1.5, {Hydrogen = 70, Helium = 30}},
    mercury = {1, 25, {Iron = 30, Silicon = 68, RareMetals = 2}},
    venus = {1, 12, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, CarbonDioxide = 2}},
    earth = {1, 12, {Iron = 20, Carbon = 10, Silicon = 40, Oxygen = 20, Nitrogen = 6, RareMetals = 2, Water = 2}},
    mars = {1.5, 30, {Iron = 20, Carbon = 10, Silicon = 42, Oxygen = 20, Nitrogen = 6, RareMetals = 2}},
    ceres = {1, 90, {Carbon = 70, Nitrogen = 10, Water = 20}},
    jupiter = {1, 2, {Hydrogen = 89, Deuterium = 1, Helium = 10}},
    saturn = {1.15, 2, {Hydrogen = 90, Helium = 10}},
    uranus = {1, 5, {Hydrogen = 89, Helium = 10, Nitrogen = 1}},
    neptune = {1, 5, {Hydrogen = 89, Helium = 10, Nitrogen = 1}},
    pluto = {1.43, 40, {Carbon = 70, Nitrogen = 10, Water = 20}}, 
}

local subtypeMultipliers = {
    mega = 0.1,
    super = 0.25,
    reg = 1,
    sub = 2,
    mini = 4,
    micro = 10,
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
function Planet.new(centerX, centerY, mass, smaj, ecc, inc, st, t, parentBody, name)
    local self = setmetatable({}, Planet)

    self.angle = math.random(0, 360)
    self.semiMajorAxis = smaj
    self.semiMinorAxis = smaj * math.sqrt(1 - ecc^2)

    self.subtype = st
    self.type = t
    self.name = name

    self.mass = mass
    self.radius = self.mass^(1/3) * planetData[self.type][DENSITYFACTOR] *  subtypeMultipliers[self.subtype]

    self.temperature = (((255 / ((self.semiMajorAxis / 235)/110000^0.5))^0.5) * 1 * 1) - 273.15 -- Multiplied by albedo factor and greenhouse factor (TODO)
    self.inclination = inc

    local c = math.sqrt(self.semiMajorAxis^2 - self.semiMinorAxis^2)
    self.originX = centerX + c -- Adjust to place the center at one focus
    self.originY = centerY
    self.rotatedOriginX, self.rotatedOriginY = rotatePoint(self.originX, self.originY, centerX, centerY, self.inclination)

    local viewAngle = 45
    self.visibleSemiMajorAxis = self.semiMajorAxis * (90/viewAngle) -- Adjust view angle (TODO - Fix)
    self.visibleSemiMinorAxis = self.semiMinorAxis * math.cos(math.rad(self.inclination))

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
        self.rotatedOriginX, self.rotatedOriginY = rotatePoint(self.originX, self.originY, parent.originX, parent.originY, self.inclination)
    end

    -- Update the orbital angle
    self.angle = self.angle + self.speed * dt

    -- Calculate position along the ellipse
    local x = self.visibleSemiMajorAxis * math.cos(math.rad(self.angle))
    local y = self.visibleSemiMinorAxis * math.sin(math.rad(self.angle))

    -- Apply rotation for inclination
    local rotatedX, rotatedY = rotatePoint(x, y, 0, 0, self.inclination)

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
    love.graphics.rotate(math.rad(self.inclination)) -- Rotate the drawing context

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
