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

function Satellite:draw(camera)
    local adjustedSize = self.displaySize / camera.scale
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, adjustedSize, 3)
end

return Satellite
    