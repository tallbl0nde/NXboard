-- This contains examples on how to use
-- NXboard with your LovePotion project
require "keyboard"

function love.load()
    font20 = love.graphics.newFont(20)
    --Initialise (load) the keyboard into memory
    --(Think of it like a background task)
    KB = Keyboard
    KB:new()
    --Render drawings (many calls of love.graphics.print causes FPS drops)
    canvas = love.graphics.newCanvas(1280,720)
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(0.1,0.1,0.4,1)
    love.graphics.rectangle("fill",0,0,1280,720)
    love.graphics.setFont(font20)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Tap a box to open the keyboard, press + to exit",400,5)
    love.graphics.print("Or use up/down and A to select!",475,30)
    --Example 1: Username
    love.graphics.print("Ex 1: Username",100,70)
    love.graphics.rectangle("fill",100,100,250,50)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("KB:init(\"uname\",\"\",\"dark\",\"keyboard\",{\"return\",\"space\"},20,\"Enter a username...\")",400,115)
    --Example 2: Seed for generation
    love.graphics.print("Ex 2: Seed (for random)",100,170)
    love.graphics.rectangle("fill",100,200,250,50)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("KB:init(\"seed\",\"\",\"light\",\"numpad\",\"only_numbers\",10,\"Enter a seed...\")",400,215)
    --Example 3: Description
    love.graphics.print("Ex 3: Short description",100,270)
    love.graphics.rectangle("fill",100,300,1080,200)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("KB:init(\"desc\",desc,\"dark\",\"keyboard\",{\'{\',\'}\',\'@\',\'%\'},300,\"Type something...\")",100,515)
    love.graphics.setCanvas()
    --Initialise selection stuff (don't worry about this)
    selectedBox = 1
    isTouch = false
    sinNum = 0
end

function love.update(dt)
    --Update needs to be passed delta time
	KB:update(dt)
    --Animated selection box (ignore this too)
    sinNum = sinNum + math.pi*dt
    if (sinNum >= 2*math.pi) then sinNum = sinNum - 2*math.pi end
    colorG = 0.8 + 0.2*math.sin(sinNum)
end

--initalise empty vars
uname = ""
seed = ""
desc = "Hello World!"
function love.draw()
    --Draw the canvas from earlier
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(canvas,0,0)
    --Plus dynamic stuff (don't need to worry about this)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("FPS: "..love.timer.getFPS(),5,5)
    love.graphics.setColor(0,0,0,1)
    love.graphics.print(uname,105,115)
    love.graphics.print(seed,105,215)
    love.graphics.printf(desc,105,315,1080,"left")
    love.graphics.setColor(0,colorG,1,1)
    if (not isTouch) then
        if (selectedBox == 1) then
            KB:drawRectangle(100,100,250,50,5)
        elseif (selectedBox == 2) then
            KB:drawRectangle(100,200,250,50,5)
        elseif (selectedBox == 3) then
            KB:drawRectangle(100,300,1080,200,5)
        end
    end
    --Draw the keyboard (make sure it's last so it is drawn on top!)
    --Will not draw anything until Keyboard.active is true
    KB:draw()
end

function love.gamepadpressed(joystick, button)
    if (not KB.active) then
        if (isTouch) then
            isTouch = false
            return
        end
        --Allows you to exit
        if (button == "plus") then
            love.event.quit()
        end
        --Move selection
        if (button == "dpdown" and selectedBox < 3) then
            selectedBox = selectedBox + 1
        end
        if (button == "dpup" and selectedBox > 1) then
            selectedBox = selectedBox - 1
        end
        if (button == "a") then
            --Called as follows: Keyboard.init(variable name (string) to return to, buffer text, theme, keyboard/numpad, keys to omit, max characters, display message)
            --Ex 1
            if (selectedBox == 1) then
                KB:init("uname","","dark","keyboard",{"return","space"},20,"Enter a username...")
            end
            --Ex 2
            if (selectedBox == 2) then
                KB:init("seed","","light","numpad","only_numbers",10,"Enter a seed...")
            end
            --Ex 3
            if (selectedBox == 3) then
                KB:init("desc",desc,"dark","keyboard",{'{','}','@','%'},300,"Type something...")
            end
        end
    end
    KB:gamepadPressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    KB:gamepadReleased(joystick, button)
end

--For all the touch events, you can simply pass (id, x, y)
--and these functions will only check for keyboard touches
--if Keyboard.active is true (managed internally) Hence, to
--avoid overlap any other touches need to only be checked
--when Keyboard.active is false as seen below
function love.touchpressed(id,x,y)
    KB:touchPressed(id,x,y)
    --If the keyboard is not on the screen (active) then check touches
    if (not KB.active) then
        --Any of your touch events go in here
        isTouch = true
        --Called as follows: Keyboard.init(variable name (string) to return to, buffer text, theme, keyboard/numpad, keys to omit, max characters, display message)
        --Ex 1
        if (x > 100 and x < 350 and y > 100 and y < 150) then
            KB:init("uname","","dark","keyboard",{"return","space"},20,"Enter a username...")
            selectedBox = 1
        end
        --Ex 2
        if (x > 100 and x < 350 and y > 200 and y < 250) then
            KB:init("seed","","light","numpad","only_numbers",10,"Enter a seed...")
            selectedBox = 2
        end
        --Ex 3
        if (x > 100 and x < 1080 and y > 300 and y < 500) then
            KB:init("desc",desc,"dark","keyboard",{'{','}','@','%'},300,"Type something...")
            selectedBox = 3
        end
    end
end

function love.touchmoved(id,x,y)
    KB:touchMoved(id,x,y)
    --If the keyboard is not on the screen then check touches
    if (not KB.active) then
        --Any of your touch events go in here
    end
end

function love.touchreleased(id,x,y)
    KB:touchReleased(id,x,y)
    --If the keyboard is not on the screen then check touches
    if (not KB.active) then
        --Any of your touch events go in here
    end
end
