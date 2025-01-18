local Satellite = {}
Satellite.__index = Satellite

function Satellite.new(planet)
    local self = setmetatable({}, Satellite)

    self.center = planet
    self.radius = 4 * planet.radius
    self.angle = math.random(0, 2 * math.pi)
    self.speed = 1 / self.radius

    self.x = planet.x + self.radius * math.cos(self.angle)
    self.y = planet.y + self.radius * math.sin(self.angle)

    self.selected = false
    self.targetPlanet = nil
    self.moving = false -- Track movement

    return self
end

function Satellite:update(dt)
    if self.targetPlanet then
        self:moveToPlanet(dt)
    elseif self.center then
        self.angle = self.angle + self.speed * dt
        self.x = self.center.x + self.radius * math.cos(self.angle)
        self.y = self.center.y + self.radius * math.sin(self.angle)
    end
end

-- Moves satellite toward the new planet
function Satellite:moveToPlanet(dt)
    local dx = self.targetPlanet.x - self.x
    local dy = self.targetPlanet.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 4 * self.targetPlanet.radius then
        local moveSpeed = 50 * dt
        self.x = self.x + (dx / distance) * moveSpeed
        self.y = self.y + (dy / distance) * moveSpeed
    else
        -- Arrived at new planet, switch to orbit
        self.center = self.targetPlanet
        self.radius = 4 * self.targetPlanet.radius
        self.angle = math.random(0, 2 * math.pi)
        self.targetPlanet = nil
        self.moving = false
    end
end

-- Detect click on the satellite
function Satellite:isClicked(mouseX, mouseY, camera)
    local scaledX = self.x
    local scaledY = self.y
    local distance = math.sqrt((mouseX - scaledX)^2 + (mouseY - scaledY)^2)
    return distance <= 5
end

function Satellite:setTargetPlanet(planet)
    self.targetPlanet = planet
    self.moving = true
end

function Satellite:draw(camera)
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", self.x, self.y, 1, 3)
    if self.selected then
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("line", self.x, self.y, 1, 3)
    end
    love.graphics.setColor(1, 1, 1)
end

return Satellite
