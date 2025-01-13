local MainMenu = {}

-- Button configuration
local buttons = {
    {text = "Start", action = function() return "game" end},
    {text = "Exit", action = function() love.event.quit() end},
}

-- Track the hovered button
local hoveredButton = nil

-- Draw the main menu
function MainMenu.draw()
    love.graphics.setBackgroundColor(0, 0, 0 )
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local buttonWidth, buttonHeight = 200, 50
    local buttonSpacing = 20
    local startY = (windowHeight - (#buttons * (buttonHeight + buttonSpacing - buttonSpacing))) / 2

    for i, button in ipairs(buttons) do
        local x = (windowWidth - buttonWidth) / 2
        local y = startY + (i - 1) * (buttonHeight + buttonSpacing)

        -- Highlight hovered button
        if hoveredButton == i then
            love.graphics.setColor(0.4, 0.4, 0.4)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", x, y, buttonWidth, buttonHeight)

        -- Draw button text
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(button.text, x, y + buttonHeight / 4, buttonWidth, "center")
    end
end

-- Handle mouse movement
function MainMenu.mousemoved(x, y)
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local buttonWidth, buttonHeight = 200, 50
    local buttonSpacing = 20
    local startY = (windowHeight - (#buttons * (buttonHeight + buttonSpacing))) / 2

    hoveredButton = nil
    for i, button in ipairs(buttons) do
        local bx = (windowWidth - buttonWidth) / 2
        local by = startY + (i - 1) * (buttonHeight + buttonSpacing)
        if x > bx and x < bx + buttonWidth and y > by and y < by + buttonHeight then
            hoveredButton = i
            return
        end
    end
end

-- Handle mouse presses
function MainMenu.mousepressed(x, y, button)
    if button == 1 and hoveredButton then
        local action = buttons[hoveredButton].action
        return action()
    end
end

return MainMenu
