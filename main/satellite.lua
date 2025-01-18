local Satellite = {}
Satellite.__index = Satellite

-- Constructor for a new satellite
function Satellite.new(planet)
    local self = setmetatable({}, Satellite)

    -- Set initial position at 4 * planet radius away
    self.center = planet
    self.radius = 4 * planet.radius
    self.angle = math.random(0, 2 * math.pi)
    self.speed = 1/self.radius -- Match the planet's velocity

    -- Calculate initial position
    self.x = planet.x + self.radius * math.cos(self.angle)
    self.y = planet.y + self.radius * math.sin(self.angle)

    return self
end

-- Update satellite position to maintain circular orbit
function Satellite:update(dt)
    if self.center then
        -- Keep the satellite in a circular orbit
        self.angle = self.angle + self.speed * dt
        self.x = self.center.x + self.radius * math.cos(self.angle)
        self.y = self.center.y + self.radius * math.sin(self.angle)
    end
end

-- Function to check if the user right-clicked a planet
function Satellite.spawnIfClicked(planets, mouseX, mouseY)
    for _, planet in ipairs(planets) do
        local distance = math.sqrt((mouseX - planet.x)^2 + (mouseY - planet.y)^2)
        if distance <= planet.radius then
            -- Spawn a satellite in orbit around this planet
            return Satellite.new(planet)
        end
    end
    return nil
end

-- Draw the satellite
function Satellite:draw(camera)
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("fill", self.x, self.y, 5/camera.scale, 3) -- Small satellite dot
    love.graphics.setColor(1, 1, 1, 1)
end

return Satellite
