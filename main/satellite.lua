local Satellite = {}
Satellite.__index = Satellite

-- Constructor for a new satellite
function Satellite.new(planet)
    local self = setmetatable({}, Satellite)

    -- Set initial position at 4 * planet radius away
    self.orbit_center = planet
    self.orbit_radius = 4 * planet.radius
    self.orbit_angle = math.random(0, 2 * math.pi)
    self.orbit_speed = 1/self.orbit_radius -- Match the planet's velocity

    -- Calculate initial position
    self.x = planet.x + self.orbit_radius * math.cos(self.orbit_angle)
    self.y = planet.y + self.orbit_radius * math.sin(self.orbit_angle)

    return self
end

-- Update satellite position to maintain circular orbit
function Satellite:update(dt)
    if self.orbit_center then
        -- Keep the satellite in a circular orbit
        self.orbit_angle = self.orbit_angle + self.orbit_speed * dt
        self.x = self.orbit_center.x + self.orbit_radius * math.cos(self.orbit_angle)
        self.y = self.orbit_center.y + self.orbit_radius * math.sin(self.orbit_angle)
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
