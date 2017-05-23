menu = {}

local buttons = {}
local mousePos = nil

function menu:init()
  mySettings = Settings()
  mousePos = HC.point(love.mouse.getX(),love.mouse.getY())
  
  
  buttons.makeClient = Button(SWIDTH/2,300,200,70, "Start as a Client")
  buttons.makeServer = Button(SWIDTH/2,400,200,70, "Start as a Server")
  buttons.makeServerClient = Button(SWIDTH/2,500,200,70, "Start as a Server and Client")
  
  cur_highlight = love.mouse.getSystemCursor("hand")
end

function menu:enter(previous)
  if isServer then
    server = {}
  end
  
  if isClient then
    client = {}
  end
end

function menu:update(dt)
  mousePos:moveTo(love.mouse.getX(),love.mouse.getY())
  local highlight = false
  
  for i, button in pairs(buttons) do
    if button:highlight(mousePos) then
      highlight = true
    end
  end
  
  if highlight then
    love.mouse.setCursor(cur_highlight)
  else
    love.mouse.setCursor()
  end
end

function menu:draw()
  love.graphics.setColor(WHITE,255)
  love.graphics.print(TITLE, (SWIDTH/2)-(love.graphics.getFont():getWidth(TITLE)/2), (SHEIGHT/4)-(love.graphics.getFont():getHeight()))
  love.graphics.setColor(WHITE,255)
  love.graphics.print("IP Address: " .. mySettings.ipAddress, (SWIDTH/2)-75, math.floor(3*SHEIGHT/10))
  for i, button in pairs(buttons) do
    button:draw()
  end
end

function menu:textinput(t)
  mySettings:textinputMenu(t)
end


function menu:keypressed(key)
  mySettings:keypressedMenu(key)
  
  if key == "escape" then
    love.event.quit()
  end
end

function menu:mousepressed(x,y,key)
  if key == 1 then
    local targetIndex = nil
    for index, button in pairs(buttons) do
      if button:highlight(mousePos) then
        targetIndex = index
      end
    end
    
    if targetIndex == "makeClient" then
      if checkSettings() then
        isClient = true
        love.mouse.setCursor()
        Gamestate.switch(lobby)
      end
    end

    if targetIndex == "makeServer" then
      if checkSettings() then
        isServer = true
        love.mouse.setCursor()
        Gamestate.switch(lobby)
      end
    end
    
    if targetIndex == "makeServerClient" then
      if checkSettings() then
        isServer = true
        isClient = true
        love.mouse.setCursor()
        Gamestate.switch(lobby)
      end
    end
  end
end