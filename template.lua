--Include NXboard
require "NXboard"

function love.load()
    --Initialise the keyboard into memory (I've given it the name KB)
    KB = NXboard
    KB:new()
end

function love.update(dt)
    --Update needs to be passed delta time
	KB:update(dt)
end

function love.draw()
    --You code goes here ^ (above the KB:draw())
    KB:draw()
end

function love.gamepadpressed(joystick, button)
    if (not KB.active) then
        --Your events go here
    end
    --Call keyboard last!
    KB:gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    if (not KB.active) then
        --Your events go here
    end
    --Call keyboard last!
    KB:gamepadreleased(joystick, button)
end

function love.touchpressed(id,x,y)
    KB:touchpressed(id,x,y)
    if (not KB.active) then
        --Any of your touch events go in here
    end
end

function love.touchmoved(id,x,y)
    KB:touchmoved(id,x,y)
    if (not KB.active) then
        --Any of your touch events go in here
    end
end

function love.touchreleased(id,x,y)
    KB:touchreleased(id,x,y)
    if (not KB.active) then
        --Any of your touch events go in here
    end
end
