-- NXBoard 1.0
-- Created by: tallbl0nde
-- A replacement for the on-screen keyboard on
-- the switch for LovePotion projects :D
-- For usage see: ...

-- Change this directory to the location of the
-- resources if necessary:
local path = "resources/keyboard/"

-- The rest of this shouldn't need to be touched
Keyboard = {}

function Keyboard:new()
    self.newTheme = "light"
    self:update()
    --Keyboard stuff
    --keys1: ABC: no shift
    --keys2: ABC: shift
    --keys3: Symbols
    self.keys1={'1','2','3','4','5','6','7','8','9','0','-',
                'q','w','e','r','t','y','u','i','o','p','/',
                'a','s','d','f','g','h','j','k','l',':','\'',
                'z','x','c','v','b','n','m',',','.','?','!'}
    self.keys2={'#','£','€','$','%','^','&','*','(',')','_',
                'Q','W','E','R','T','Y','U','I','O','P','@',
                'A','S','D','F','G','H','J','K','L',';','\"',
                'Z','X','C','V','B','N','M','<','>','+','='}
    self.keys3={'1','2','3','4','5','6','7','8','9','0','-',
                '!','@','#','$','%','^','&','*','(',')','_',
                '~','`','=','\\','+','{','}','|','[',']','',
                '<','>',';',':','\"','\'',',','.','?','/',''}
    self:init()
    self.ellipse = love.graphics.newImage(path.."ellipse.png")
end

--Called to 'reinitalise' the keyboard
function Keyboard:init(buffer)
    self.isShift = 0
    self.isSymbols = false
    self.buffer = buffer or ""
    self.keyTouch = {}
    for x=1,11 do
        self.keyTouch[x]={}
    end
end

function Keyboard:update()
    --Change dimensions if screen size changes (not needed?)
    if (love.graphics.getWidth() ~= self.width) then
        self.width = love.graphics.getWidth()
        self.scaleX = self.width/1920
        self.font = love.graphics.newFont(math.ceil(self.width*0.025))
        self.fontSmall = love.graphics.newFont(math.ceil(self.width*0.018))
    end
    if (love.graphics.getHeight() ~= self.height) then
        self.height = love.graphics.getHeight()
        self.scaleY = self.height/1080
    end
    --Change theme variables if theme is changed
    if (self.theme ~= self.newTheme) then
        self.theme = self.newTheme
        if (self.theme == "light") then
            self.backgroundColor = {0.94,0.94,0.94}
            self.keyColor = {0.91,0.91,0.91}
            self.key2Color = {0.85,0.85,0.85}
            self.keyPressedColor = {0.59,0.94,0.94,0.5}
            self.returnKeyColor = {0.197,0.313,0.941}
            self.backspaceColor ={0.18,0.18,0.18}
            self.fontColor = self.backspaceColor
            self.font2Color = self.backgroundColor
        elseif (self.theme == "dark") then
            self.backgroundColor = {0.27,0.27,0.27}
            self.keyColor = {0.3,0.3,0.3}
            self.key2Color = {0.36,0.36,0.36}
            self.keyPressedColor = {0.22,0.53,0.61,0.5}
            self.returnKeyColor = {0,1,0.8}
            self.backspaceColor = {1,1,1}
            self.fontColor = self.backspaceColor
            self.font2Color = self.fontColor
        end
        self.shiftIcon = love.graphics.newImage(path.."shift_"..self.theme..".png")
        self.shiftIconOn = love.graphics.newImage(path.."shift_"..self.theme.."_active.png")
        self.backspaceIcon = love.graphics.newImage(path.."backspace_"..self.theme..".png")
        self.buttonY = love.graphics.newImage(path.."y_"..self.theme..".png")
        self.buttonB = love.graphics.newImage(path.."b_"..self.theme..".png")
        self.buttonPlus = love.graphics.newImage(path.."+_"..self.theme..".png")
    end
    --Change key grid based on current state
    if (self.isSymbols) then
        self.keys = self.keys3
    elseif (self.isShift == 0) then
        self.keys = self.keys1
    elseif (self.isShift == 1 or self.isShift == 2) then
        self.keys = self.keys2
    end
end

--Main draw function called (theme, 'type', keys that can't be pressed)
function Keyboard:draw(theme,type,noKeys)
    self.newTheme = theme or "light"
    self.type = type or "keyboard"
    self.noKeys = noKeys or {}

    --Draw the appropriate type
    if (self.type == "numpad") then
        self:drawNumpad()
    elseif (self.type == "keyboard") then
        self:drawKeyboard(noKeys)
    end

    --Draw keyboard buffer part
    love.graphics.print(self.buffer,50,50)
end

function Keyboard:drawKeyboard(noKeys)
    --Background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill",0,self.height*0.4,self.width,self.height*0.6)
    --Key 'grid'
    love.graphics.setFont(self.font)
    for y=1,4 do
        for x=1,11 do
            if (self.keyTouch[x][y] ~= nil) then
                self:drawKey(x,y,1,1,self.keys1[x+((y-1)*11)],true)
            else
                self:drawKey(x,y,1,1,self.keys1[x+((y-1)*11)],false)
            end
        end
    end
    --Keys (bottom row)
    for x=1,3 do
        love.graphics.setColor(unpack(self.key2Color))
        love.graphics.rectangle("fill",self.width*0.042+(x-1)*self.width*0.075,self.height*0.816,self.width*0.072,self.height*0.083)
    end
    --Shift key
    if (self.isShift == 0) then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.shiftIcon,math.ceil(self.width*0.1535-(self.scaleX*self.shiftIcon:getWidth()/2)),math.ceil(self.height*0.858-(self.scaleY*self.shiftIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
        love.graphics.setColor(0.7,0.7,0.7)
        love.graphics.draw(self.ellipse,math.ceil(self.width*0.126),math.ceil(self.height*0.831),0,self.scaleX,self.scaleY)
    end
    if (self.isShift == 1) then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.shiftIconOn,math.ceil(self.width*0.1535-(self.scaleX*self.shiftIcon:getWidth()/2)),math.ceil(self.height*0.858-(self.scaleY*self.shiftIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
        love.graphics.setColor(0.7,0.7,0.7)
        love.graphics.draw(self.ellipse,math.ceil(self.width*0.126),math.ceil(self.height*0.831),0,self.scaleX,self.scaleY)
    end
    if (self.isShift == 2) then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.shiftIconOn,math.ceil(self.width*0.1535-(self.scaleX*self.shiftIcon:getWidth()/2)),math.ceil(self.height*0.858-(self.scaleY*self.shiftIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
        love.graphics.setColor(unpack(self.returnKeyColor))
        love.graphics.draw(self.ellipse,math.ceil(self.width*0.126),math.ceil(self.height*0.831),0,self.scaleX,self.scaleY)
    end
    --Symbol key
    love.graphics.setFont(self.fontSmall)
    love.graphics.setColor(unpack(self.fontColor))
    if (self.isSymbols) then
        self:printC("ABC",self.width*0.227,self.height*0.84,self.fontSmall)
    else
        self:printC("#+=",self.width*0.227,self.height*0.84,self.fontSmall)
    end
    --Highlight if pressed
    for x=1,3 do
        if (self.keyTouch[x][5] ~= nil) then
            love.graphics.setColor(unpack(self.keyPressedColor))
            love.graphics.rectangle("fill",self.width*0.042+(x-1)*self.width*0.075,self.height*0.816,self.width*0.072,self.height*0.083)
        end
    end
    --Space key
    love.graphics.setColor(unpack(self.key2Color))
    love.graphics.rectangle("fill",self.width*0.267,self.height*0.816,self.width*0.597,self.height*0.083)
    love.graphics.setColor(unpack(self.fontColor))
    self:printC("Space",self.width*0.566,self.height*0.84,self.fontSmall)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.buttonY,math.ceil(self.width*0.839),math.ceil(self.height*0.819),0,self.scaleX,self.scaleY)
    --Highlight if pressed
    if (self.spacePressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.267,self.height*0.816,self.width*0.597,self.height*0.083)
    end
    --Keys (side column)
    --Backspace key
    love.graphics.setColor(unpack(self.backspaceColor))
    love.graphics.rectangle("fill",self.width*0.867,self.height*0.46,self.width*0.091,self.height*0.083)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.backspaceIcon,math.ceil(self.width*0.912-(self.scaleX*self.backspaceIcon:getWidth()/2)),math.ceil(self.height*0.5-(self.scaleY*self.backspaceIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
    love.graphics.draw(self.buttonB,math.ceil(self.width*0.935),math.ceil(self.height*0.46),0,self.scaleX,self.scaleY)
    --Highlight if selected
    if (self.backspacePressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.867,self.height*0.46,self.width*0.091,self.height*0.083)
    end
    --Return key
    love.graphics.setColor(unpack(self.key2Color))
    love.graphics.rectangle("fill",self.width*0.867,self.height*0.549,self.width*0.091,self.height*0.172)
    love.graphics.setColor(unpack(self.fontColor))
    self:printC("Return",self.width*0.912,self.height*0.615,self.fontSmall)
    --Highlight if pressed
    if (self.returnPressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.867,self.height*0.549,self.width*0.091,self.height*0.172)
    end
    --OK/Enter/Finish key
    love.graphics.setColor(unpack(self.returnKeyColor))
    love.graphics.rectangle("fill",self.width*0.867,self.height*0.727,self.width*0.091,self.height*0.172)
    if (self.theme == "light") then
        love.graphics.setColor(1,1,1,1)
    else
        love.graphics.setColor(unpack(self.backgroundColor))
    end
    self:printC("OK",self.width*0.912,self.height*0.795,self.fontSmall)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.buttonPlus,math.ceil(self.width*0.935),math.ceil(self.height*0.727),0,self.scaleX,self.scaleY)
    --Highlight if pressed
    if (self.okPressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.867,self.height*0.727,self.width*0.091,self.height*0.172)
    end
end

--Mainly used to draw the 'grid' of keys
function Keyboard:drawKey(x,y,w,h,char,isPressed)
    love.graphics.setColor(unpack(self.keyColor))
    love.graphics.rectangle("fill",self.width*0.042+(x-1)*self.width*0.075,self.height*0.46+(y-1)*self.height*0.089,self.width*0.072*w+((w-1)*self.width*0.045),self.height*0.083*h)
    love.graphics.setColor(unpack(self.fontColor))
    self:printC(char,self.width*0.078+(x-1)*self.width*0.075,self.height*0.48+(y-1)*self.height*0.089,self.font)
    if (isPressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.042+(x-1)*self.width*0.075,self.height*0.46+(y-1)*self.height*0.089,self.width*0.072*w+((w-1)*self.width*0.045),self.height*0.083*h)
    end
end

--Used for key text
function Keyboard:printC(txt,x,y,font)
    love.graphics.print(txt,math.ceil(x - font:getWidth(txt)/2),math.ceil(y - font:getHeight(txt)/2))
end

function Keyboard:touchPressed(id,x,y)
    --Determine x key
    for a=1,11 do
        if (x > self.width*0.042+(a-1)*self.width*0.075 and x < self.width*0.042+(a-1)*self.width*0.075+self.width*0.072) then
            --Determine y key
            for b=1,5 do
                if (y > self.height*0.46+(b-1)*self.height*0.089 and y < self.height*0.46+(b-1)*self.height*0.089+self.height*0.083) then
                    self.keyTouch[a][b] = id
                    break
                end
            end
        end
    end

    --Spacebar
    if (x > self.width*0.267 and x < self.width*0.864 and y > self.height*0.816 and y < self.height*0.899) then
        self.spacePressed = true
        return
    end
    --Backspace
    if (x > self.width*0.867 and x < self.width*0.958 and y > self.height*0.46 and y < self.height*0.543) then
        self.backspacePressed = true
    end
    --Return
    if (x > self.width*0.867 and x < self.width*0.958 and y > self.height*0.549 and y < self.height*0.721) then
        self.returnPressed = true
    end
    --OK/Finished
    if (x > self.width*0.867 and x < self.width*0.958 and y > self.height*0.727 and y < self.height*0.899) then
        self.okPressed = true
    end
end

function Keyboard:touchMoved(id,x,y)
    --Deselect certain keys if moved off
    --Shift
    -- if (x > self.width*0.189 or x < self.width*0.117 or y > self.height*0.899 or y < self.height*0.816) and self.keyTouchX[id] == 2 and self.keyTouchY[id] == 5 then
    --     --self.keyTouchX[id] = nil
    --     --self.keyTouchY[id] = nil
    --     return
    -- end
    -- --Symbols
    -- if (x > self.width*0.264 or x < self.width*0.192 or y > self.height*0.899 or y < self.height*0.816) and self.keyTouchX[id] == 3 and self.keyTouchY[id] == 5 then
    --     --self.keyTouchX[id] = nil
    --     --self.keyTouchY[id] = nil
    --     return
    -- end
    --Spacebar
    if (x < self.width*0.267 or x > self.width*0.864 or y < self.height*0.816 or y > self.height*0.899) and self.spacePressed then
        self.spacePressed = nil
        return
    end
    --Backspace
    if (x < self.width*0.867 or x > self.width*0.958 or y < self.height*0.46 or y > self.height*0.543) and self.backspacePressed then
        self.backspacePressed = false
        return
    end
    --Return
    if (x < self.width*0.867 or x > self.width*0.958 or y < self.height*0.549 or y > self.height*0.721) and self.returnPressed then
        self.returnPressed = false
    end
    --OK/Finish
    if (x < self.width*0.867 or x > self.width*0.958 or y < self.height*0.727 or y > self.height*0.899) and self.okPressed then
        self.okPressed = false
    end
end

function Keyboard:touchReleased(id,x,y)
    --Key grid
    for a=1,11 do
        for b=1,5 do
            if (self.keyTouch[a][b] == id) then
                --Shift key
                -- if (self.keyTouchX[id] == 2 and self.keyTouchY[id] == 5 and not self.isSymbols) then
                --     if (self.isShift == 2) then
                --         self.isShift = 0
                --     else
                --         self.isShift = self.isShift + 1
                --     end
                -- --Symbol/ABC key
                -- elseif (self.keyTouchX[id] == 3 and self.keyTouchY[id] == 5) then
                --     self.isSymbols = not self.isSymbols
                --     self.isShift = 0
                -- --Else insert a character
                -- elseif (self.keyTouchX[id] < 12 and self.keyTouchY[id] < 5) then
                --     self.buffer = self.buffer..self.keys[self.keyTouchX[id]+((self.keyTouchY[id]-1)*11)]
                --     if (self.isShift ~= 2) then
                --         self.isShift = 0
                --     end
                -- end
                --Insert a character
                if (a < 12 and b < 5) then
                    self.buffer = self.buffer..self.keys[a+((b-1)*11)]
                    if (self.isShift ~= 2) then
                        self.isShift = 0
                    end
                end
                --Delete touch coords
                self.keyTouch[a][b] = nil
                self.keyTouch[a][b] = nil
            end
            --Spacebar (delete later?)
            if (self.spacePressed) then
                self.spacePressed = nil
                self.buffer = self.buffer.." "
            end
            --backspaceebar (delete later?)
            if (self.backspacePressed) then
                self.backspacePressed = nil
                self.buffer = string.sub(self.buffer,1,-2)
            end
            --return
            if (self.returnPressed) then
                self.returnPressed = nil
                self.buffer = self.buffer.."\n"
            end
            if (self.okPressed) then
                self.okPressed = false
            end
        end
    end
end