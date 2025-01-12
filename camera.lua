local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)
    self.scale = 1 -- Current zoom level
    self.offsetX = 0 -- Camera offset in X
    self.offsetY = 0 -- Camera offset in Y
    self.moveSpeed = 300 -- Base movement speed
    self.isDragging = false -- Track if the user is dragging the camera
    self.lastMouseX = 0 -- Last mouse X position
    self.lastMouseY = 0 -- Last mouse Y position
    return self
end

function Camera:update(dt)
    -- Adjust movement speed based on zoom level
    local adjustedMoveSpeed = self.moveSpeed * (1)

    -- Handle keyboard movement
    if love.keyboard.isDown("w") then
        self.offsetY = self.offsetY + adjustedMoveSpeed * dt
    end
    if love.keyboard.isDown("s") then
        self.offsetY = self.offsetY - adjustedMoveSpeed * dt
    end
    if love.keyboard.isDown("a") then
        self.offsetX = self.offsetX + adjustedMoveSpeed * dt
    end
    if love.keyboard.isDown("d") then
        self.offsetX = self.offsetX - adjustedMoveSpeed * dt
    end
end

function Camera:updateMousePosition()
    -- Track mouse position globally
    self.mouseX, self.mouseY = love.mouse.getPosition()
end

function Camera:wheelmoved(x, y)
    -- Calculate world coordinates under the mouse
    local worldX = (self.mouseX - self.offsetX) / self.scale
    local worldY = (self.mouseY - self.offsetY) / self.scale

    -- Adjust zoom level
    if y > 0 then
        self.scale = self.scale / 1.1
    elseif y < 0 then
        self.scale = self.scale * 1.1
    end

    -- Adjust offsets to maintain focus on the mouse
    self.offsetX = self.mouseX - worldX * self.scale
    self.offsetY = self.mouseY - worldY * self.scale
end

function Camera:apply()
    -- Apply camera transformations
    love.graphics.push()
    love.graphics.translate(self.offsetX, self.offsetY)
    love.graphics.scale(self.scale)
end

function Camera:reset()
    -- Reset transformations
    love.graphics.pop()
end

function Camera:screenToWorld(screenX, screenY)
    -- Convert screen coordinates to world coordinates
    local worldX = (screenX - self.offsetX) / self.scale
    local worldY = (screenY - self.offsetY) / self.scale
    return worldX, worldY
end

-- Start dragging the camera
function Camera:startDragging(x, y)
    self.isDragging = true
    self.lastMouseX = x
    self.lastMouseY = y
end

-- Stop dragging the camera
function Camera:stopDragging()
    self.isDragging = false
end

-- Drag the camera
function Camera:drag(x, y)
    if self.isDragging then
        local dx = x - self.lastMouseX
        local dy = y - self.lastMouseY
        self.offsetX = self.offsetX + dx
        self.offsetY = self.offsetY + dy
        self.lastMouseX = x
        self.lastMouseY = y
    end
end

return Camera
