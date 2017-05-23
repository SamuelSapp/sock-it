ClientObject = Class{
  init = function(self, ip, port, settings)
    self.tickRate = 1/60
    self.tick = 0
    self.sender = Sock.newClient(ip, port)
    self.sender:setSerialization(Bitser.dumps, Bitser.loads)
    self.beginGame = false
    self.isPlaying = false
    self.isColliding = false
    self.index = 0
    self.settings = settings
    self.state = self.sender:getState()
    self.players = {}
    self.sun = StaticBody(SWIDTH/2, SHEIGHT/2, 2000, "sun")
    self.bodies = {self.sun}
    self:setCallbacks()
    self.sender:connect()
  end;
  
  setCallbacks = function(self)
    self.sender:setSchema("playerSettings", {
      "index",
      "settings"
    })
    
    self.sender:setSchema("playerState", {
      "index",
      "position",
      "velocity",
      "direction"
    })
    
    self.sender:setSchema("playerDirection", {
      "index",
      "direction"
    })
    
    self.sender:setSchema("collision", {
      "index",
      "position",
      "velocity",
    })
    
    self.sender:setSchema("boostStart", {
      "index",
      "direction"
    })
    
    self.sender:setSchema("startingPositions", {
      "index",
      "position"
    })
    
    self.sender:setSchema("playerReady", {
      "index",
      "ready"
    })
  
    self.sender:setSchema("addPlayer", {
      "index",
      "name",
      "color",
      "mass"
    })
  
    self.sender:setSchema("playerJoin", {
      "index",
      "playerSettings"
    })
    
    self.sender:on("connect", function(data)
      self.state = self.sender:getState()
    end)
    
    self.sender:on("addPlayer", function(data)
      self.players[data.index] = Player(data.index*SWIDTH/5, LOBBYY, data.mass, data.name, data.color, data.index)
    end)
  
    self.sender:on("lobbyFull", function(data)
      self.sender:disconnect()
    end)
    
    self.sender:on("removePlayer", function(index)
      self.players[index] = nil
    end)
    
    self.sender:on("playerJoin", function(data)
      self.index = data.index
      for i, settings in pairs(data.playerSettings) do
        self.players[i] = Player(i*SWIDTH/5, LOBBYY, data.playerSettings[i].mass, data.playerSettings[i].name, data.playerSettings[i].color, i)
      end
      self.players[data.index] = Player(data.index*SWIDTH/5, LOBBYY, self.settings.mass, self.settings.name, self.settings.color, self.index)
      self.sender:send("addPlayer", {data.index, self.settings.name, self.settings.color, self.settings.mass})
    end)
    
    self.sender:on("playerState", function(data)
      local index = data.index
      local position = data.position
      local velocity = data.velocity
      local direction = data.direction
      
      if position ~= nil then
        self.players[index].position.x = position.x
        self.players[index].position.y = position.y
      end
      if velocity ~= nil then
        self.players[index].velocity.x = velocity.x
        self.players[index].velocity.y = velocity.y
      end
      if direction ~= nil and index ~= self.index then
        self.players[index].dir = direction
      end
    end)
    
    self.sender:on("collision", function(data)
      local index = data.index
      local position = data.position
      local velocity = data.velocity
      
      if position ~= nil then
        self.players[index].position.x = position.x
        self.players[index].position.y = position.y
      end
      if velocity ~= nil then
        self.players[index].velocity.x = velocity.x
        self.players[index].velocity.y = velocity.y
      end
      
      if index == self.index then
        self.isColliding = false
      end
    end)
  
    self.sender:on("playerReady", function(data)
      local index = data.index
      if index then
        self.players[index].isReady = data.ready
      end
    end)
    
    self.sender:on("setupGame", function(data)
      table.insert(self.bodies, StaticBody(SWIDTH/2, SHEIGHT/2, 0, "sun"))
      self.beginGame = true
      self.tick = 0
    end)
    
    self.sender:on("startingPositions", function(data)
      local index = data.index
      local position = data.position
      
      if position ~= nil then
        self.players[index].position.x = position.x
        self.players[index].position.y = position.y
      end
      self.players[index].jetCooldown = 0
      self.players[index].isActive = true
      self.players[index]:setPosition(data.position)
    end)
    
    self.sender:on("beginGame", function(data)
      self.isPlaying = true
    end)
    
    self.sender:on("destroyPlayer", function(data)
      local index = data
      self.players[index]:destroy()
    end)
    
    self.sender:on("returnToLobby", function(data)
      for i, player in pairs(self.players) do
        local position = Vector(i*SWIDTH/5, LOBBYY)
        player:setPosition(position)
        local playerVel = Vector(0,0)
        player:setVelocity(playerVel)
        player.score = 0
        player.dir = 0
      end
      Gamestate.switch(lobby)
    end)
    
    self.sender:on("score", function(data)
      self.players[data].score = self.players[data].score + 1
    end)
    
    self.sender:on("playerSettings", function(data, client)
      self.players[data.index].name = data.settings[1]
      self.players[data.index].color[1] = tonumber(data.settings[2])
      self.players[data.index].color[2] = tonumber(data.settings[3])
      self.players[data.index].color[3] = tonumber(data.settings[4])
      self.players[data.index].mass = tonumber(data.settings[5])
    end)
  end;
  
  update = function(self, dt)
    self.sender:update()
    
    if self.sender:getState() == "connected" then
      self.tick = self.tick + dt
    end
    
    if self.tick >= self.tickRate and self.isPlaying then
      self.tick = 0
      
      local mousePosX = love.mouse.getX()
      local mousePosY = love.mouse.getY()
      
      for i, player in pairs(self.players) do
        if i ~= self.index then
          player:updateClientOther(dt)
        end
      end
      
      self.players[self.index]:updateClientOwn(dt, mousePosX, mousePosY)
      self.sender:send("playerDirection", {self.index, self.players[self.index].dir})
    end
  end;
  
  draw = function(self)
    for i, player in pairs(self.players) do
      player:draw()
    end
    for i, body in pairs(self.bodies) do
      body:draw()
    end
  end;
  
  updateLobby = function(self, dt)
    self.sender:update()
    self.state = self.sender:getState()
    
    if self.sender:getState() == "connected" then
      self.tick = self.tick + dt
    end
    
    local mousePosX = love.mouse.getX()
    local mousePosY = love.mouse.getY()
    
    if self.tick >= self.tickRate then
      self.tick = 0
      
      if self.index ~= 0 then
        self.sender:send("ready", self.players[self.index].isReady)
      end
      
      for i, player in pairs(self.players) do
        if i ~= self.index then
          player.line = player.position + Vector(math.cos(player.dir)*player.radius, math.sin(player.dir)*player.radius)
        else
          player:handleRotation(mousePosX, mousePosY)
          self.sender:send("playerDirection", {self.index, self.players[self.index].dir})
        end
      end
    end
  end;
  
  drawLobby = function(self)
    for i, player in pairs(self.players) do
      if player ~= nil then
        player:draw()
        if player.isReady then
          love.graphics.setColor(255,255,255,255)
          love.graphics.printf("Ready", math.floor(player.position.x-player.radius), math.floor(player.position.y + player.radius*2), player.radius*2, "center")
        end
      end
    end
    love.graphics.setColor(255,255,255,255)
    if self.state then
      love.graphics.print(self.state, SWIDTH/2, 50)
    else
      love.graphics.print("Connection State Unknown", SWIDTH/2, 50)
    end
  end;
  
  keypressed = function(self, key)
    
  end;
  
  mousepressed = function(self, x, y, button, istouch)
    if button == 1 and self.players[self.index].jetCooldown <= 0 and self.players[self.index].isActive then
      self.sender:send("boostStart", {self.index, self.players[self.index].dir})
      self.players[self.index]:boost()
    end
  end;
  
  toggleReady = function(self)
    self.players[self.index].isReady = not self.players[self.index].isReady
  end;
  
  setReady = function(self, state)
    self.players[self.index].isReady = state
  end;
  
  updateSettings = function(self)
    if self.index ~= nil and self.index ~= 0 then
      self.players[self.index].name = self.settings.items[1]
      self.players[self.index].color[1] = tonumber(self.settings.items[2])
      self.players[self.index].color[2] = tonumber(self.settings.items[3])
      self.players[self.index].color[3] = tonumber(self.settings.items[4])
      self.players[self.index].mass = tonumber(self.settings.items[5])
      self.sender:send("playerSettings", {self.index, self.settings.items})
    end
  end;
  }