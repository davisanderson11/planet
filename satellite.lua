local Satellite = {}
Satellite.__index = Satellite

function Satellite.new(centerX, centerY, xVel, yVel)
    local self = setmetatable({}, Satellite)
    self.x = centerX
    self.y = centerY
    self.vx = xVel
    self.vy = yVel
    self.displaySize = 5
    self.color = {1, 1, 1}
    return self
end

function Satellite.fromTo(fromPlanet, toPlanet)
    local startX, startY = fromPlanet.x, fromPlanet.y
    local dx = toPlanet.x - fromPlanet.x
    local dy = toPlanet.y - fromPlanet.y
    local distance = math.sqrt(dx^2 + dy^2)

    local speed = 5000 -- Adjust this as needed
    local vx = (dx / distance) * speed
    local vy = (dy / distance) * speed

    local newSatellite = Satellite.new(startX, startY, vx, vy)
    table.insert(satellites, newSatellite)
end

function Satellite:update(dt, planets)
    local totalAx, totalAy = 0, 0

    for _, planet in ipairs(planets) do
        local dx = planet.x - self.x
        local dy = planet.y - self.y
        local distance = math.sqrt(dx^2 + dy^2)

        if distance > 0 then
            local gravitationalForce = planet.mass / (distance^2)
            local ax = gravitationalForce * (dx / distance)
            local ay = gravitationalForce * (dy / distance)

            totalAx = totalAx + ax
            totalAy = totalAy + ay
        end
    end

    self.vx = self.vx + totalAx * dt
    self.vy = self.vy + totalAy * dt

    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
end

function Satellite:draw(camera)
    local adjustedSize = self.displaySize / camera.scale
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, adjustedSize, 3)
end

return Satellite
    