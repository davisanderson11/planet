-- time_controller.lua
local TimeController = {}
TimeController.__index = TimeController

function TimeController.new()
    local self = setmetatable({}, TimeController)
    self.timeScale = 1 -- Default time scale (1 = normal speed)
    return self
end

-- Increase the time scale
function TimeController:increaseSpeed()
    self.timeScale = self.timeScale * 2
end

-- Decrease the time scale
function TimeController:decreaseSpeed()
    self.timeScale = self.timeScale / 2
    if self.timeScale < 0.1 then
        self.timeScale = 0.1 -- Prevent time scale from becoming too slow
    end
end

-- Reset the time scale to normal
function TimeController:resetSpeed()
    self.timeScale = 1
end

return TimeController
