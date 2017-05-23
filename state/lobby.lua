lobby = {}

local buttons = {}
local allReady = false

local settingsX = 20
local settingsY = 200

function lobby:enter()
  mousePos = HC.point(love.mouse.getX(),love.mouse.getY())
  if isServer and server == nil then
    server = ServerObject(mySettings.ipAddress, 1992)
  end
  
  if isClient then
    if client == nil then
      client = ClientObject(mySettings.ipAddress, 1992, mySettings)
    end
    client.beginGame = false
    buttons.ready = Button(SWIDTH/2,300,200,70, "I'm Ready!")
    buttons.startGame = Button(SWIDTH/2,600,200,70, "Begin Game")
    buttons.startGame.isActive = false
  end
end

function lobby:update(dt)
  mousePos:moveTo(love.mouse.getX(),love.mouse.getY())
  local highlight = false
  
  
  if isServer then
    allReady = server:allReady()
    if allReady and client.index == 1 then
      buttons.startGame.isActive = true
    else 
      buttons.startGame.isActive = false
    end
    server:updateLobby(dt)
  end
  
  if isClient then
    if not checkSettings() then
      client:setReady(false)
    else
      client:updateSettings()
    end
  
    if client.beginGame then
      love.mouse.setCursor()
      Gamestate.switch(game)
    end
    
    client:updateLobby(dt)
    
    for i, button in pairs(buttons) do
      if button:highlight(mousePos) then
        highlight = true
      end
    end
  end
    
  if highlight then
    love.mouse.setCursor(cur_highlight)
  else
    love.mouse.setCursor()
  end

end

function lobby:draw()
  if isServer then
    server:drawLobby()
  end
  
  if isClient then
    client:drawLobby()
    for i, button in pairs(buttons) do
      button:draw()
    end
    
    love.graphics.setColor(255,255,255,255)
    love.graphics.print("Name: " .. mySettings.items[1], settingsX, settingsY)
    love.graphics.print("R: " .. mySettings.items[2], settingsX, settingsY+20)
    love.graphics.print("G: " .. mySettings.items[3], settingsX, settingsY+40)
    love.graphics.print("B: " .. mySettings.items[4], settingsX, settingsY+60)
    love.graphics.print("Mass: " .. mySettings.items[5], settingsX, settingsY+80)
    love.graphics.print(">", settingsX-15, settingsY - 20 + mySettings.activeItem*20)
  end
end

function lobby:keypressed(key)
  if isClient then
    client:keypressed(key)
    mySettings:keypressedLobby(key)
  end
  
  if key == "escape" then
    if isClient then
      client.sender:disconnectNow()
      client = nil
    end
    
    if isServer then
      server.sender:destroy()
      server = nil
    end
    
    isClient = false
    isServer = false
    Gamestate.switch(menu)
  end
end

function lobby:mousepressed(x,y,key)
  if key == 1 then
    
    local targetIndex = nil
    for index, button in pairs(buttons) do
      if button:highlight(mousePos) then
        targetIndex = index
      end
    end

    if targetIndex == "startGame" and allReady then
      love.mouse.setCursor()
      server.sender:sendToAll("setupGame", {})
      server:setupGame()
      Gamestate.switch(game)
    end
    
    if targetIndex == "ready" and checkSettings() then
      client:toggleReady()
    end
  end
end

function lobby:textinput(t)
  mySettings:textinputLobby(t)
end

function checkSettings()
  if string.gsub(mySettings.name, " ", "") == "" then
    return false
  end
  
  if mySettings.color[1] == nil or mySettings.color[2] == nil or mySettings.color[3] == nil or mySettings.mass == nil then
    return false
  end
  
  if mySettings.color[1] >= 0 and mySettings.color[1] <=255 then
    
  else
    return false
  end
  
  if mySettings.color[2] >= 0 and mySettings.color[2] <=255 then
    
  else
    return false
  end
  
  if mySettings.color[3] >= 0 and mySettings.color[3] <=255 then
    
  else
    return false
  end
  
  if mySettings.mass >= 100 and mySettings.mass <= 1000 then
    
  else
    return false
  end
  
  return true
end

function lobby:quit()
  if isClient then
    client.sender:disconnectNow()
  end
end