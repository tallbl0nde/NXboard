require "keyboard"

function love.load()
    KB = Keyboard
    KB:new()
end

function love.update(dt)
	KB:update(dt)
end

text = ""
text2 = ""
function love.draw()
    love.graphics.setBackgroundColor(0.3,0.3,1,1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(love.timer.getFPS(),500,50)
    love.graphics.rectangle("fill", 200, 200, 200, 30)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line", 200, 200, 200, 30)
    love.graphics.print(text,210,203)
    if (not KB.active and text == "") then
        text = KB.buffer or ""
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("fill", 880, 200, 200, 30)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line", 880, 200, 200, 30)
    love.graphics.print(text2,890,203)
    if (not KB.active and text2 == "") then
        text2 = KB.buffer or ""
    end
    --Draw the keyboard
    KB:draw()
end

function love.gamepadpressed(joystick, button)
    if (button == "plus") then
        love.event.quit()
    end
end

function love.touchpressed(id,x,y)
    KB:touchPressed(id,x,y)
    --If the keyboard is not on the screen then check touches
    if (not KB.active) then
        if (x > 200 and x < 400 and y > 200 and y < 230) then
            KB:init("","dark","keyboard",{"return",'4'},20,"Enter a username...")
            text = ""
        end

        if (x > 880 and x < 1080 and y > 200 and y < 230) then
            KB:init("","dark","numpad",{'0','1','2','3',"space"},8,"Enter your ID...")
            text2 = ""
        end
    end
end

function love.touchmoved(id,x,y)
    KB:touchMoved(id,x,y)
end

function love.touchreleased(id,x,y)
    KB:touchReleased(id,x,y)
end
