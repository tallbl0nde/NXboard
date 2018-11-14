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

--[[ Reference:
Backspace = 100
Return = 101
OK = 102
Toggle = 50
Shift = 51
Symbol = 52
Space = 53
Other keys = Grid ID
]]

function Keyboard:new()
    --Load resources and values
    --keys1: ABC: no shift
    --keys2: ABC: shift
    --keys3: Symbols
    self.keys1={'1','2','3','4','5','6','7','8','9','0','-',
                'q','w','e','r','t','y','u','i','o','p','/',
                'a','s','d','f','g','h','j','k','l',':','\'',
                'z','x','c','v','b','n','m',',','.','?','!'}
    self.keys1T = {}
    self.keys2={'#','','','$','%','^','&','*','(',')','_',
                'Q','W','E','R','T','Y','U','I','O','P','@',
                'A','S','D','F','G','H','J','K','L',';','\"',
                'Z','X','C','V','B','N','M','<','>','+','='}
    self.keys2T = {}
    self.keys3={'1','2','3','4','5','6','7','8','9','0','-',
                '!','@','#','$','%','^','&','*','(',')','_',
                '~','`','=','\\','+','{','}','|','[',']','',
                '<','>',';',':','\"','\'',',','.','?','/',''}
    self.keys3T = {}
    self.num={'1','2','3','4','5','6','7','8','9'}
    self.numsT = {}
    self.buffer = "€"
    self.ellipse = love.graphics.newImage(path.."ellipse.png")
end

--Called to 'reinitalise' the keyboard (variable to return to (string), buffer text, theme, 'type', keys that can't be pressed, char limit, message to display when no text)
function Keyboard:init(varName,buffer,theme,type,noKeys,lim,msg)
    --Set up keyboard based on arguments passed
    self.var = varName
    self.buffer = buffer or ""
    self.newTheme = theme or "light"
    self.type = type or "keyboard"
    --Set which keys can't be pressed
    if (noKeys == "only_numbers") then
        self.noKeys = {'-',
                    'q','w','e','r','t','y','u','i','o','p','/',
                    'a','s','d','f','g','h','j','k','l',':','\'',
                    'z','x','c','v','b','n','m',',','.','?','!',
                    '#','$','%','^','&','*','(',')','_','Q','W',
                    'E','R','T','Y','U','I','O','P','@','A','S',
                    'D','F','G','H','J','K','L',';','\"','Z','X',
                    'C','V','B','N','M','<','>','+','=','~','`',
                    '\\','{','}','|','[',']',"space","return"}
    else
        self.noKeys = noKeys or {}
    end
    self.limit = lim or 300
    self.message = msg or ""
    self.active = true
    --Reinitalise certain variables
    self.isTouch = false
    self.nums = self:copyTable(self.num)
    self.keyState = 5
    self.newState = 0
    self.keyTouch = {}
    for x=1,11 do
        self.keyTouch[x]={}
    end
    --Animation stuff
    self.sinVal = 0
    self.selectedKey = 1
    self:update(0)
end

--Called to render keys once instead of every frame (improves FPS)
function Keyboard:createTextures()
    --self.keys1
    for i=1,#self.keys1,1 do
        local canvas = love.graphics.newCanvas(math.ceil(self.width*0.072),math.ceil(self.height*0.083))
        love.graphics.setCanvas(canvas)
        love.graphics.setColor(unpack(self.keyColor))
        love.graphics.rectangle("fill",0,0,canvas:getWidth(),canvas:getHeight())
        love.graphics.setColor(unpack(self.fontColor))
        self:printC(self.keys1[i],canvas:getWidth()/2,canvas:getHeight()/2-(canvas:getHeight()*0.25),self.font)
        love.graphics.setCanvas()
        self.keys1T[i] = canvas
    end
    --self.keys2
    for i=1,#self.keys2,1 do
        local canvas = love.graphics.newCanvas(math.ceil(self.width*0.072),math.ceil(self.height*0.083))
        love.graphics.setCanvas(canvas)
        love.graphics.setColor(unpack(self.keyColor))
        love.graphics.rectangle("fill",0,0,canvas:getWidth(),canvas:getHeight())
        love.graphics.setColor(unpack(self.fontColor))
        self:printC(self.keys2[i],canvas:getWidth()/2,canvas:getHeight()/2-(canvas:getHeight()*0.25),self.font)
        love.graphics.setCanvas()
        self.keys2T[i] = canvas
    end
    --self.keys3
    for i=1,#self.keys3,1 do
        local canvas = love.graphics.newCanvas(math.ceil(self.width*0.072),math.ceil(self.height*0.083))
        love.graphics.setCanvas(canvas)
        love.graphics.setColor(unpack(self.keyColor))
        love.graphics.rectangle("fill",0,0,canvas:getWidth(),canvas:getHeight())
        love.graphics.setColor(unpack(self.fontColor))
        self:printC(self.keys3[i],canvas:getWidth()/2,canvas:getHeight()/2-(canvas:getHeight()*0.25),self.font)
        love.graphics.setCanvas()
        self.keys3T[i] = canvas
    end
    --self.nums
    for i=0,#self.nums do
        local canvas = love.graphics.newCanvas(math.ceil(self.width*0.143),math.ceil(self.height*0.083))
        love.graphics.setCanvas(canvas)
        love.graphics.setColor(unpack(self.keyColor))
        love.graphics.rectangle("fill",0,0,canvas:getWidth(),canvas:getHeight())
        love.graphics.setColor(unpack(self.fontColor))
        self:printC(i,canvas:getWidth()/2,canvas:getHeight()/2-(canvas:getHeight()*0.25),self.font)
        love.graphics.setCanvas()
        if (i == 0) then
            self.nums0 = canvas
        else
            self.numsT[i] = canvas
        end
    end
end

--Called to match noKeys (ie disable certain keys)
function Keyboard:checkKeys()
    self.noZero = false
    self.noSpace = false
    self.noReturn = false
    for b=1,#self.noKeys do
        for a=1,#self.keys do
            if (self.keys[a] == self.noKeys[b]) then
                self.keys[a] = ''
                break
            end
        end
        for a=1,#self.nums do
            if (self.nums[a] == self.noKeys[b]) then
                self.nums[a] = ''
                break
            end
        end
        if (self.noKeys[b] == '0') then
            self.noZero = true
        end
        if (self.noKeys[b] == "space") then
            self.noSpace = true
        end
        if (self.noKeys[b] == "return") then
            self.noReturn = true
        end
    end
end

--Called to update the state of the keyboard
function Keyboard:update(dt)
    if (not self.active) then
        --Update return variable if necessary (euro used as a placeholder xD)
        if (self.buffer ~= "€") then
            _G[self.var] = self.buffer
            self.buffer = "€"
        end
        return
    end
    --Flashing box animation
    if (not self.isTouch) then
        self.sinVal = self.sinVal + math.pi*dt
        if (self.sinVal > 2*math.pi) then
            self.sinVal = self.sinVal - 2*math.pi
        end
        self.boxColor = 0.85 + 0.15*math.sin(self.sinVal)
    end
    --Backspace if held down
    if (self.backspacePressed) then
        self.backTime = self.backTime + dt
        if (self.backTime > 0.5 and self.backHeld == false) then
            self.backHeld = true
            self.backTime = 0
        end
        if (self.backTime > 0.08 and self.backHeld) then
            self.buffer = string.sub(self.buffer,1,-2)
            self.backTime = 0
        end
    end
    --Change dimensions if screen size changes (not needed?)
    if (love.graphics.getWidth() ~= self.width) then
        self.width = love.graphics.getWidth()
        self.scaleX = self.width/1920
        self.font = love.graphics.newFont(math.ceil(self.width*0.025))
        self.fontSmall = love.graphics.newFont(math.ceil(self.width*0.018))
        self.fontSmaller = love.graphics.newFont(math.ceil(self.width*0.011))
    end
    if (love.graphics.getHeight() ~= self.height) then
        self.height = love.graphics.getHeight()
        self.scaleY = self.height/1080
    end
    --Change theme variables if theme is changed
    if (self.theme ~= self.newTheme) then
        self.theme = self.newTheme
        if (self.theme == "light") then
            self.backgroundColor = {0.94,0.94,0.94,1}
            self.keyColor = {0.91,0.91,0.91,1}
            self.key2Color = {0.85,0.85,0.85,1}
            self.key2ColorNo = {0.85,0.85,0.85,0.6}
            self.keyPressedColor = {0.59,0.94,0.94,0.5}
            self.returnKeyColor = {0.197,0.313,0.941,1}
            self.backspaceColor ={0.18,0.18,0.18,1}
            self.fontColor = self.backspaceColor
            self.fontColorNo = {0.18,0.18,0.18,0.3}
            self.font2Color = self.backgroundColor
        elseif (self.theme == "dark") then
            self.backgroundColor = {0.27,0.27,0.27,1}
            self.keyColor = {0.3,0.3,0.3,1}
            self.key2Color = {0.36,0.36,0.36,1}
            self.key2ColorNo = {0.36,0.36,0.36,0.8}
            self.keyPressedColor = {0.22,0.53,0.61,0.5}
            self.returnKeyColor = {0,1,0.8,1}
            self.backspaceColor = {1,1,1,1}
            self.fontColor = self.backspaceColor
            self.fontColorNo = {1,1,1,0.3}
            self.font2Color = self.fontColor
        end
        self.shiftIcon = love.graphics.newImage(path.."shift_"..self.theme..".png")
        self.shiftIconOn = love.graphics.newImage(path.."shift_"..self.theme.."_active.png")
        self.backspaceIcon = love.graphics.newImage(path.."backspace_"..self.theme..".png")
        self.keyboardIcon = love.graphics.newImage(path.."keyboard_"..self.theme..".png")
        self.numpadIcon = love.graphics.newImage(path.."numpad_"..self.theme..".png")
        self.buttonY = love.graphics.newImage(path.."y_"..self.theme..".png")
        self.buttonB = love.graphics.newImage(path.."b_"..self.theme..".png")
        self.buttonPlus = love.graphics.newImage(path.."+_"..self.theme..".png")
        --Regen key textures:
        self:createTextures()
    end
    --Change key grid based on current state
    if (self.keyState ~= self.newState) then
        if (self.newState == 4) then
            self.keys = self:copyTable(self.keys3)
            self.keysT = self.keys3T
        elseif (self.newState == 0) then
            self.keys = self:copyTable(self.keys1)
            self.keysT = self.keys1T
        elseif (self.newState == 1 or self.newState == 2) then
            self.keys = self:copyTable(self.keys2)
            self.keysT = self.keys2T
        end
        self.keyState = self.newState
        self:checkKeys()
    end
end

--===== DRAWING STUFF =====--
--Main draw function called
function Keyboard:draw()
    if (not self.active) then
        return
    end

    --Draw background
    love.graphics.setColor(0,0,0,0.7)
    love.graphics.rectangle("fill",0,0,self.width,self.height)

    --Draw the appropriate type
    if (self.type == "numpad") then
        self:drawNumpad()
    elseif (self.type == "keyboard") then
        self:drawKeyboard()
    end

    --Draw keyboard buffer part
    love.graphics.setColor(1,1,1,1)
    self:drawRectangle(self.width*0.05, self.height*0.05, self.width*0.9, self.height*0.35,3)
    love.graphics.setFont(self.fontSmall)
    if (#self.message > 0 and #self.buffer == 0) then
        love.graphics.setColor(1,1,1,0.4)
        love.graphics.printf(self.message,self.width*0.065,self.height*0.07,self.width*0.86,"left")
    end
    love.graphics.printf(self.buffer,self.width*0.065,self.height*0.07,self.width*0.86,"left")
    if (self.limit >= 0) then
        local txt = #self.buffer.."/"..self.limit
        love.graphics.setFont(self.fontSmaller)
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.print(txt,self.width*0.95-love.graphics.getFont():getWidth(txt),self.height*0.41)
    end
end

function Keyboard:drawKeyboard()
    --Background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill",0,self.height*0.45,self.width,self.height*0.55)
    --Key 'grid'
    love.graphics.setColor(1,1,1,1)
    for y=1,4 do
        for x=1,11 do
            if (self.keys[x+((y-1)*11)] == '') then
                love.graphics.setColor(0.92,0.92,0.92,1)
                love.graphics.draw(self.keysT[x+((y-1)*11)],self.width*0.042+(x-1)*self.width*0.075,self.height*0.51+(y-1)*self.height*0.089)
            else
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(self.keysT[x+((y-1)*11)],self.width*0.042+(x-1)*self.width*0.075,self.height*0.51+(y-1)*self.height*0.089)
                if (self.keyTouch[x][y] ~= nil) then
                    love.graphics.setColor(unpack(self.keyPressedColor))
                    love.graphics.rectangle("fill",self.width*0.042+(x-1)*self.width*0.075,self.height*0.51+(y-1)*self.height*0.089,self.width*0.072,self.height*0.083)
                    love.graphics.setColor(1,1,1,1)
                end
            end
            if (not self.isTouch and self.selectedKey == (x+((y-1)*11))) then
                love.graphics.setColor(0,self.boxColor,1,1)
                self:drawRectangle(self.width*0.042+(x-1)*self.width*0.075,self.height*0.51+(y-1)*self.height*0.089,self.width*0.072,self.height*0.083,5)
            end
        end
    end
    --Keys (bottom row)
    for x=1,3 do
        love.graphics.setColor(unpack(self.key2Color))
        love.graphics.rectangle("fill",self.width*0.042+(x-1)*self.width*0.075,self.height*0.866,self.width*0.072,self.height*0.083)
    end
    --Numpad key
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.draw(self.numpadIcon,math.ceil(self.width*0.078-(self.scaleX*self.numpadIcon:getWidth()/2)),math.ceil(self.height*0.908-(self.scaleY*self.numpadIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
    --Shift key
    if (self.keyState == 0 or self.keyState == 4) then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.shiftIcon,math.ceil(self.width*0.1535-(self.scaleX*self.shiftIcon:getWidth()/2)),math.ceil(self.height*0.908-(self.scaleY*self.shiftIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
        love.graphics.setColor(0.7,0.7,0.7)
        love.graphics.draw(self.ellipse,math.ceil(self.width*0.126),math.ceil(self.height*0.881),0,self.scaleX,self.scaleY)
    end
    if (self.keyState == 1) then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.shiftIconOn,math.ceil(self.width*0.1535-(self.scaleX*self.shiftIcon:getWidth()/2)),math.ceil(self.height*0.908-(self.scaleY*self.shiftIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
        love.graphics.setColor(0.7,0.7,0.7)
        love.graphics.draw(self.ellipse,math.ceil(self.width*0.126),math.ceil(self.height*0.881),0,self.scaleX,self.scaleY)
    end
    if (self.keyState == 2) then
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.shiftIconOn,math.ceil(self.width*0.1535-(self.scaleX*self.shiftIcon:getWidth()/2)),math.ceil(self.height*0.908-(self.scaleY*self.shiftIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
        love.graphics.setColor(unpack(self.returnKeyColor))
        love.graphics.draw(self.ellipse,math.ceil(self.width*0.126),math.ceil(self.height*0.881),0,self.scaleX,self.scaleY)
    end
    --Symbol key
    love.graphics.setFont(self.fontSmall)
    love.graphics.setColor(unpack(self.fontColor))
    if (self.keyState == 4) then
        self:printC("ABC",self.width*0.227,self.height*0.89,self.fontSmall)
    else
        self:printC("#+=",self.width*0.227,self.height*0.89,self.fontSmall)
    end
    --Highlight if pressed
    for x=1,3 do
        if (self.keyTouch[x][5] ~= nil) then
            love.graphics.setColor(unpack(self.keyPressedColor))
            love.graphics.rectangle("fill",self.width*0.042+(x-1)*self.width*0.075,self.height*0.866,self.width*0.072,self.height*0.083)
        end
        if (not self.isTouch and self.selectedKey == 49+x) then
            love.graphics.setColor(0,self.boxColor,1,1)
            self:drawRectangle(self.width*0.042+(x-1)*self.width*0.075,self.height*0.866,self.width*0.072,self.height*0.083,5)
        end
    end
    --Space key
    if (self.noSpace) then
        love.graphics.setColor(unpack(self.key2ColorNo))
    else
        love.graphics.setColor(unpack(self.key2Color))
    end
    love.graphics.rectangle("fill",self.width*0.267,self.height*0.866,self.width*0.597,self.height*0.083)
    if (self.noSpace) then
        love.graphics.setColor(unpack(self.fontColorNo))
    else
        love.graphics.setColor(unpack(self.fontColor))
    end
    self:printC("Space",self.width*0.566,self.height*0.89,self.fontSmall)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.buttonY,math.ceil(self.width*0.839),math.ceil(self.height*0.869),0,self.scaleX,self.scaleY)
    --Highlight if pressed
    if (self.spacePressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.267,self.height*0.866,self.width*0.597,self.height*0.083)
    end
    if (not self.isTouch and self.selectedKey == 53) then
        love.graphics.setColor(0,self.boxColor,1,1)
        self:drawRectangle(self.width*0.267,self.height*0.866,self.width*0.597,self.height*0.083,5)
    end
    --Keys (side column)
    --Backspace key
    love.graphics.setColor(unpack(self.backspaceColor))
    love.graphics.rectangle("fill",self.width*0.867,self.height*0.51,self.width*0.091,self.height*0.083)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.backspaceIcon,math.ceil(self.width*0.912-(self.scaleX*self.backspaceIcon:getWidth()/2)),math.ceil(self.height*0.55-(self.scaleY*self.backspaceIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
    love.graphics.draw(self.buttonB,math.ceil(self.width*0.935),math.ceil(self.height*0.51),0,self.scaleX,self.scaleY)
    --Highlight if selected
    if (self.backspacePressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.867,self.height*0.51,self.width*0.091,self.height*0.083)
    end
    if (not self.isTouch and self.selectedKey == 100) then
        love.graphics.setColor(0,self.boxColor,1,1)
        self:drawRectangle(self.width*0.867,self.height*0.51,self.width*0.091,self.height*0.083,5)
    end
    --Return key
    if (self.noReturn) then
        love.graphics.setColor(unpack(self.key2ColorNo))
    else
        love.graphics.setColor(unpack(self.key2Color))
    end
    love.graphics.rectangle("fill",self.width*0.867,self.height*0.599,self.width*0.091,self.height*0.172)
    if (self.noReturn) then
        love.graphics.setColor(unpack(self.fontColorNo))
    else
        love.graphics.setColor(unpack(self.fontColor))
    end
    self:printC("Return",self.width*0.912,self.height*0.665,self.fontSmall)
    --Highlight if pressed
    if (self.returnPressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.867,self.height*0.599,self.width*0.091,self.height*0.172)
    end
    if (not self.isTouch and self.selectedKey == 101) then
        love.graphics.setColor(0,self.boxColor,1,1)
        self:drawRectangle(self.width*0.867,self.height*0.599,self.width*0.091,self.height*0.172,5)
    end
    --OK/Enter/Finish key
    love.graphics.setColor(unpack(self.returnKeyColor))
    love.graphics.rectangle("fill",self.width*0.867,self.height*0.777,self.width*0.091,self.height*0.172)
    if (self.theme == "light") then
        love.graphics.setColor(1,1,1,1)
    else
        love.graphics.setColor(unpack(self.backgroundColor))
    end
    self:printC("OK",self.width*0.912,self.height*0.845,self.fontSmall)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.buttonPlus,math.ceil(self.width*0.935),math.ceil(self.height*0.777),0,self.scaleX,self.scaleY)
    --Highlight if pressed
    if (self.okPressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.867,self.height*0.777,self.width*0.091,self.height*0.172)
    end
    if (not self.isTouch and self.selectedKey == 102) then
        love.graphics.setColor(0,self.boxColor,1,1)
        self:drawRectangle(self.width*0.867,self.height*0.777,self.width*0.091,self.height*0.172,5)
    end
end

function Keyboard:drawNumpad()
    --Background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill",0,self.height*0.5,self.width,self.height*0.5)

    --Numpad grid
    for x=1,3 do
        for y=1,3 do
            if (self.nums[x+((y-1)*3)] == '') then
                love.graphics.setColor(0.92,0.92,0.92,1)
                love.graphics.draw(self.numsT[x+((y-1)*3)],self.width*0.28+(x-1)*self.width*0.15,self.height*0.54+(y-1)*self.height*0.09)
            else
                love.graphics.setColor(1,1,1,1)
                love.graphics.draw(self.numsT[x+((y-1)*3)],self.width*0.28+(x-1)*self.width*0.15,self.height*0.54+(y-1)*self.height*0.09)
                if (self.keyTouch[x][y] ~= nil) then
                    love.graphics.setColor(unpack(self.keyPressedColor))
                    love.graphics.rectangle("fill",self.width*0.28+(x-1)*self.width*0.15,self.height*0.54+(y-1)*self.height*0.09,self.width*0.143,self.height*0.083)
                    love.graphics.setColor(1,1,1,1)
                end
            end
        end
    end

    --0
    if (self.noZero) then
        love.graphics.setColor(0.92,0.92,0.92,1)
        love.graphics.draw(self.nums0,self.width*0.43,self.height*0.81)
    else
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.nums0,self.width*0.43,self.height*0.81)
        if (self.zeroPressed) then
            love.graphics.setColor(unpack(self.keyPressedColor))
            love.graphics.rectangle("fill",self.width*0.43,self.height*0.81,self.width*0.143,self.height*0.083)
        end
    end

    --Backspace key
    love.graphics.setColor(unpack(self.backspaceColor))
    love.graphics.rectangle("fill",self.width*0.728,self.height*0.54,self.width*0.091,self.height*0.083)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.backspaceIcon,math.ceil(self.width*0.773-(self.scaleX*self.backspaceIcon:getWidth()/2)),math.ceil(self.height*0.58-(self.scaleY*self.backspaceIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
    love.graphics.draw(self.buttonB,math.ceil(self.width*0.796),math.ceil(self.height*0.54),0,self.scaleX,self.scaleY)
    --Highlight if selected
    if (self.backspacePressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.728,self.height*0.54,self.width*0.091,self.height*0.083)
    end

    --OK/Enter/Finish key
    love.graphics.setColor(unpack(self.returnKeyColor))
    love.graphics.rectangle("fill",self.width*0.728,self.height*0.63,self.width*0.091,self.height*0.172)
    if (self.theme == "light") then
        love.graphics.setColor(1,1,1,1)
    else
        love.graphics.setColor(unpack(self.backgroundColor))
    end
    self:printC("OK",self.width*0.773,self.height*0.7,self.fontSmall)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.buttonPlus,math.ceil(self.width*0.796),math.ceil(self.height*0.63),0,self.scaleX,self.scaleY)
    --Highlight if pressed
    if (self.okPressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.728,self.height*0.63,self.width*0.091,self.height*0.172)
    end

    --Keyboard key
    love.graphics.setColor(unpack(self.key2Color))
    love.graphics.rectangle("fill",self.width*0.728,self.height*0.81,self.width*0.091,self.height*0.083)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.keyboardIcon,math.ceil(self.width*0.773-(self.scaleX*self.keyboardIcon:getWidth()/2)),math.ceil(self.height*0.85-(self.scaleY*self.keyboardIcon:getHeight()/2)),0,self.scaleX,self.scaleY)
    --Highlight if pressed
    if (self.togglePressed) then
        love.graphics.setColor(unpack(self.keyPressedColor))
        love.graphics.rectangle("fill",self.width*0.728,self.height*0.81,self.width*0.091,self.height*0.083)
    end
end

--Used for "linewidth" for rectangles
function Keyboard:drawRectangle(x,y,w,h,linewidth)
    local line = linewidth or 1
    for i=0,line-1 do
        love.graphics.rectangle("line",x-i,y-i,w+2*i,h+2*i)
    end
end

--Used for key text
function Keyboard:printC(txt,x,y,font)
    love.graphics.setFont(font)
    love.graphics.print(txt,math.ceil(x - font:getWidth(txt)/2),math.ceil(y - font:getHeight(txt)/2))
end

--Used for behind the scenes stuff :D
function Keyboard:copyTable(tbl)
    local tbl2 = {}
    for i=1, #tbl do
        tbl2[i] = tbl[i]
    end
    return tbl2
end

--===== GAMEPAD EVENTS =====--
function Keyboard:gamepadPressed(j, b)
    self.isTouch = false
    if (not self.active) then
        return
    end
    if (b == "dpright") then
        --Move right
        if (self.selectedKey == 11) then
            self.selectedKey = 100
        elseif (self.selectedKey == 22 or self.selectedKey == 33) then
            self.selectedKey = 101
        elseif (self.selectedKey == 44 or self.selectedKey == 53) then
            self.selectedKey = 102
        elseif (self.selectedKey ~= 100 and self.selectedKey ~= 101 and self.selectedKey ~= 102) then
            self.selectedKey = self.selectedKey + 1
        end
    elseif (b == "dpleft") then
        --Move left
        if (self.selectedKey == 100) then
            self.selectedKey = 11
        elseif (self.selectedKey == 101) then
            self.selectedKey = 22
        elseif (self.selectedKey == 102) then
            self.selectedKey = 44
        elseif (self.selectedKey ~= 1 and self.selectedKey ~= 12 and self.selectedKey ~= 23 and self.selectedKey ~= 34 and self.selectedKey ~= 50) then
            self.selectedKey = self.selectedKey - 1
        end
    elseif (b == "dpup") then
        --Move up
        if (self.selectedKey == 50) then
            self.selectedKey = 34
        elseif (self.selectedKey == 51) then
            self.selectedKey = 35
        elseif (self.selectedKey == 52) then
            self.selectedKey = 36
        elseif (self.selectedKey == 53) then
            self.selectedKey = 40
        elseif (self.selectedKey > 11 and self.selectedKey ~= 100) then
            if (self.selectedKey > 99) then
                self.selectedKey = self.selectedKey - 1
            else
                self.selectedKey = self.selectedKey - 11
            end
        end
    elseif (b == "dpdown") then
        --Move down
        if (self.selectedKey == 34) then
            self.selectedKey = 50
        elseif (self.selectedKey == 35) then
            self.selectedKey = 51
        elseif (self.selectedKey == 36) then
            self.selectedKey = 52
        elseif (self.selectedKey > 36 and self.selectedKey < 45) then
            self.selectedKey = 53
        elseif (self.selectedKey ~= 50 and self.selectedKey ~= 51 and self.selectedKey ~= 52 and self.selectedKey ~= 53 and self.selectedKey ~= 102) then
            if (self.selectedKey > 99) then
                self.selectedKey = self.selectedKey + 1
            else
                self.selectedKey = self.selectedKey + 11
            end
        end
    end
    if (b == "a") then
        --Over Grid
        if (self.selectedKey < 45) then
            local key = self.selectedKey
            local row = 1
            while (key > 11) do
                row = row + 1
                key = key - 11
            end
            self.keyTouch[key][row] = 1
        end
    end
end

function Keyboard:gamepadReleased(j ,b)
    if (not self.active) then
        return
    end
    --Grid
    for a=1,11 do
        for b=1,4 do
            if (self.keyTouch[a][b] == 1) then
                --Insert a character
                if (a < 12 and b < 5 and (#self.buffer < self.limit or self.limit == -1)) then
                    self.buffer = self.buffer..self.keys[a+((b-1)*11)]
                    if (self.keyState ~= 2 and self.keyState ~= 4) then
                        self.newState = 0
                    end
                end
                --Delete touch coords
                self.keyTouch[a][b] = nil
                self.keyTouch[a][b] = nil
            end
        end
    end
end

--===== TOUCH EVENTS =====--
function Keyboard:touchPressed(id,x,y)
    self.isTouch = true
    if (not self.active) then
        return
    end
    if (self.type == "keyboard") then
        --Determine x key
        for a=1,11 do
            if (x > self.width*0.042+(a-1)*self.width*0.075 and x < self.width*0.042+(a-1)*self.width*0.075+self.width*0.072) then
                --Determine y key
                for b=1,5 do
                    if (y > self.height*0.51+(b-1)*self.height*0.089 and y < self.height*0.51+(b-1)*self.height*0.089+self.height*0.083) then
                        self.keyTouch[a][b] = id
                        break
                    end
                end
            end
        end
        --Toggle
        if (x < self.width*0.114 and x > self.width*0.042 and y < self.height*0.949 and y > self.height*0.866) then
            self.togglePressed = true
        end
        --Shift
        if (x < self.width*0.189 and x > self.width*0.117 and y < self.height*0.949 and y > self.height*0.866) then
            self.shiftPressed = true
        end
        --Symbols
        if (x < self.width*0.264 and x > self.width*0.192 and y < self.height*0.949 and y > self.height*0.866) then
            self.symbolPressed = true
        end
        --Spacebar
        if (x > self.width*0.267 and x < self.width*0.864 and y > self.height*0.866 and y < self.height*0.949 and not self.noSpace) then
            self.spacePressed = true
        end
        --Backspace
        if (x > self.width*0.867 and x < self.width*0.958 and y > self.height*0.51 and y < self.height*0.593) then
            self.backspacePressed = true
            self.backHeld = false
            self.backTime = 0
        end
        --Return
        if (x > self.width*0.867 and x < self.width*0.958 and y > self.height*0.599 and y < self.height*0.771 and not self.noReturn) then
            self.returnPressed = true
        end
        --OK/Finished
        if (x > self.width*0.867 and x < self.width*0.958 and y > self.height*0.777 and y < self.height*0.949) then
            self.okPressed = true
        end
    elseif (self.type == "numpad") then
        --Num grid
        for a=1,3 do
            if (x > self.width*0.28+(a-1)*self.width*0.15 and x < self.width*0.28+(a-1)*self.width*0.15+self.width*0.143) then
                for b=1,3 do
                    if (y > self.height*0.54+(b-1)*self.height*0.09 and y < self.height*0.54+(b-1)*self.height*0.09+self.height*0.083) then
                        self.keyTouch[a][b] = id
                        break
                    end
                end
            end
        end
        --0
        if (x > self.width*0.43 and x < self.width*0.573 and y > self.height*0.81 and y < self.height*0.893) and not self.noZero then
            self.zeroPressed = true
        end
        --Backspace
        if (x > self.width*0.728 and x < self.width*0.819 and y > self.height*0.54 and y < self.height*0.623) then
            self.backspacePressed = true
            self.backHeld = false
            self.backTime = 0
        end
        --OK
        if (x > self.width*0.728 and x < self.width*0.819 and y > self.height*0.63 and y < self.height*0.802) then
            self.okPressed = true
        end
        --Toggle
        if (x > self.width*0.728 and x < self.width*0.819 and y > self.height*0.81 and y < self.height*0.893) then
            self.togglePressed = true
        end
    end
end

function Keyboard:touchMoved(id,x,y)
    if (not self.active) then
        return
    end
    --Deselect certain keys if moved off
    if (self.type == "keyboard") then
        --Toggle
        if (x > self.width*0.114 or x < self.width*0.042 or y > self.height*0.949 or y < self.height*0.866) and self.togglePressed then
            self.togglePressed = true
        end
        --Shift
        if (x > self.width*0.189 or x < self.width*0.117 or y > self.height*0.949 or y < self.height*0.866) and self.shiftPressed then
            self.shiftPressed = false
            return
        end
        --Symbols
        if (x > self.width*0.264 or x < self.width*0.192 or y > self.height*0.949 or y < self.height*0.866) and self.symbolPressed then
            self.symbolPressed = false
            return
        end
        --Spacebar
        if (x < self.width*0.267 or x > self.width*0.864 or y < self.height*0.866 or y > self.height*0.949) and self.spacePressed then
            self.spacePressed = nil
            return
        end
        --Backspace
        if (x < self.width*0.867 or x > self.width*0.958 or y < self.height*0.51 or y > self.height*0.593) and self.backspacePressed then
            self.backspacePressed = false
            return
        end
        --Return
        if (x < self.width*0.867 or x > self.width*0.958 or y < self.height*0.599 or y > self.height*0.771) and self.returnPressed then
            self.returnPressed = false
        end
        --OK/Finish
        if (x < self.width*0.867 or x > self.width*0.958 or y < self.height*0.777 or y > self.height*0.949) and self.okPressed then
            self.okPressed = false
        end
    elseif (self.type == "numpad") then
        --Backspace
        if (x < self.width*0.728 or x > self.width*0.819 or y < self.height*0.54 or y > self.height*0.623) then
            self.backspacePressed = false
        end
        --OK
        if (x < self.width*0.728 or x > self.width*0.819 or y < self.height*0.63 or y > self.height*0.802) then
            self.okPressed = false
        end
        --Toggle
        if (x < self.width*0.728 or x > self.width*0.819 or y < self.height*0.81 or y > self.height*0.893) then
            self.togglePressed = false
        end
    end
end

function Keyboard:touchReleased(id,x,y)
    if (not self.active) then
        return
    end
    if (self.type == "keyboard") then
        --Key grid
        for a=1,11 do
            for b=1,5 do
                if (self.keyTouch[a][b] == id) then
                    --Insert a character
                    if (a < 12 and b < 5 and (#self.buffer < self.limit or self.limit == -1)) then
                        self.buffer = self.buffer..self.keys[a+((b-1)*11)]
                        if (self.keyState ~= 2 and self.keyState ~= 4) then
                            self.newState = 0
                        end
                    end
                    --Delete touch coords
                    self.keyTouch[a][b] = nil
                    self.keyTouch[a][b] = nil
                end
                --Toggle
                if (self.togglePressed) then
                    self.togglePressed = nil
                    self.type = "numpad"
                    self:checkKeys()
                end
                --Shift
                if (self.shiftPressed and self.newState ~= 4) then
                    self.shiftPressed = nil
                    if (self.keyState == 2) then
                        self.newState = 0
                    else
                        self.newState = self.newState + 1
                    end
                end
                --Symbols
                if (self.symbolPressed) then
                    self.symbolPressed = nil
                    if (self.keyState == 4) then
                        self.newState = 0
                    else
                        self.newState = 4
                    end
                end
                --Spacebar (delete later?)
                if (self.spacePressed) then
                    self.spacePressed = nil
                    if (#self.buffer < self.limit or self.limit == -1) then
                        self.buffer = self.buffer.." "
                    end
                end
                --backspace (delete later?)
                if (self.backspacePressed) then
                    self.backspacePressed = nil
                    self.buffer = string.sub(self.buffer,1,-2)
                end
                --return
                if (self.returnPressed) then
                    self.returnPressed = nil
                    if (#self.buffer < self.limit or self.limit == -1) then
                        self.buffer = self.buffer.."\n"
                    end
                end
                if (self.okPressed) then
                    self.okPressed = false
                    self.active = false
                end
            end
        end
    elseif (self.type == "numpad") then
        for a=1,3 do
            for b=1,3 do
                if (self.keyTouch[a][b] == id) then
                    --Insert a character
                    if (#self.buffer < self.limit or self.limit == -1) then
                        self.buffer = self.buffer..self.nums[a+((b-1)*3)]
                    end
                    --Delete touch coords
                    self.keyTouch[a][b] = nil
                    self.keyTouch[a][b] = nil
                end
            end
        end
        if (self.zeroPressed) then
            --Insert a character
            if (#self.buffer < self.limit or self.limit == -1) then
                self.buffer = self.buffer..'0'
            end
            self.zeroPressed = nil
        end
        --Toggle
        if (self.togglePressed) then
            self.togglePressed = nil
            self.type = "keyboard"
            self:checkKeys()
        end
        --Backspace
        if (self.backspacePressed) then
            self.backspacePressed = nil
            self.buffer = string.sub(self.buffer,1,-2)
        end
        --OK
        if (self.okPressed) then
            self.okPressed = false
            self.active = false
        end
    end
end
