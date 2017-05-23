game = {}

function game:init()
  
end

function game:enter()
  if isServer then
    
  end
end

function game:update(dt)
  if isServer then
    server:update(dt)
  end
  
  if isClient then
    client:update(dt)
  end
end

function game:draw()
  if isServer then
    server:draw()
  end
  
  if isClient then
    client:draw()
  end
end

function game:mousepressed(x, y, button, istouch)
  if isClient then
    client:mousepressed(x, y, button, istouch)
  end
end

function game:keypressed(key)
  if key == "escape" then
    if isClient and not isServer then
      client.sender:disconnectNow()
      client = nil
      isClient = false
      isServer = false
      Gamestate.switch(menu)
    end
    
    if isServer then
      server:setupLobby()
    end
  end
end

function game:quit()
  if isClient then
    client.sender:disconnectNow()
  end
end

