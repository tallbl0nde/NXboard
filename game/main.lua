require "keyboard"

function love.load()
    KB = Keyboard
    KB:new()
end

function love.update(dt)
	KB:update()
end

thm = "dark"
function love.draw()
    KB:draw(thm)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(KB.buffer,50,50)
    love.graphics.print(love.timer.getFPS(),500,150)
end

function love.touchpressed(id,x,y)
    KB:touchPressed(id,x,y)
    if (x > 700 and y < 200) then
        if (thm == "light") then
            thm = "dark"
        else
            thm = "light"
        end
    end
    if (x < 200 and y < 200) then
        KB:init()
    end
end

function love.touchmoved(id,x,y)
    KB:touchMoved(id,x,y)
end

function love.touchreleased(id,x,y)
    KB:touchReleased(id,x,y)
end
