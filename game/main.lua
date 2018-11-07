require "keyboard"

function love.load()
    KB = Keyboard
    KB:new()
    KB:init("text: ","dark","keyboard",{'a','#','!',"space","return"})
end

function love.update(dt)
	KB:update()
end

function love.draw()
    KB:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(KB.buffer,50,50)
    love.graphics.print(love.timer.getFPS(),500,150)
end

function love.touchpressed(id,x,y)
    KB:touchPressed(id,x,y)
end

function love.touchmoved(id,x,y)
    KB:touchMoved(id,x,y)
end

function love.touchreleased(id,x,y)
    KB:touchReleased(id,x,y)
end
