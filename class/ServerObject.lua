ServerObject = Class{
  init = function(self, ip, port)
    self.tickRate = 1/60
    self.tick = 0
    self.sender = Sock.newServer(ip, port)
    self.sender:setSerialization(Bitser.dumps, Bitser.loads)
    self.numActivePlayers = 0
    self.numPlayers = 0
    self.players = {}
    self.playerSettings = {}
    self.serverSettings = {}
    self.sun = StaticBody(SWIDTH/2, SHEIGHT/2, 2000, "sun")
    self.bodies = {self.sun}
    self:setCallbacks()
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
  
    self.sender:on("connect", function(data, client)
      local index = client:getIndex()
      if index > 4 then
        client:send("lobbyFull", {})
      else
        client:send("playerJoin", {index, self.playerSettings})
        self.numPlayers = self.numPlayers + 1
      end
    end)
    
    self.sender:on("addPlayer", function(data, client)
      self.sender:sendToAllBut(client, "addPlayer", {data.index, data.name, data.color, data.mass})
      self.players[data.index] = Player(data.index*SWIDTH/5, LOBBYY, data.mass, data.name, data.color, data.index)
      self.playerSettings[data.index] = data
    end)
    
    self.sender:on("playerSettings", function(data, client)
      self.sender:sendToAllBut(client, "playerSettings", {data.index, data.settings})
      self.players[data.index].name = data.settings[1]
      self.players[data.index].color[1] = tonumber(data.settings[2])
      self.players[data.index].color[2] = tonumber(data.settings[3])
      self.players[data.index].color[3] = tonumber(data.settings[4])
      self.players[data.index].mass = tonumber(data.settings[5])
      self.playerSettings[data.index].items = data.settings
    end)
    
    self.sender:on("disconnect", function(data, client)
      local index = client:getIndex()
      self.players[index] = nil
      self.playerSettings[index] = nil
      self.sender:sendToAllBut(client, "removePlayer", index)
      self.numPlayers = self.numPlayers - 1
      self.numActivePlayers = self.numActivePlayers - 1
    end)
    
    self.sender:on("playerDirection", function(data, client)
      local index = data.index
      local direction = data.direction
      
      if direction then
        self.players[index].dir = direction
      end
    end)
    
    self.sender:on("boostStart", function(data, client)
      local index = data.index
      local direction = data.direction
      
      self.players[index].dir = direction
      self.players[index]:boost()
    end)
    
    self.sender:on("ready", function(ready, client)
      local index = client:getIndex()
      if self.players[index] then
        self.players[index].isReady = ready
        self.sender:sendToAllBut(client, "playerReady", {index, ready})
      end
    end)
  end;
  
  update = function(self, dt)
    self.sender:update()
    
    self.tick = self.tick + dt
    
    if self.tick >= self.tickRate then
      self.tick = 0
      
      for value, subject in pairs(self.players) do
        subject.physCheck = true
        for value2, other in pairs(self.players) do
          if subject.isActive and other.isActive then
            if not other.physCheck and subject.position:dist(other.position) < HASH then
              local test, dx, dy = subject.body:collidesWith(other.body)
              if test then
                self:on_collide(subject, other, dx, dy, dt)
              end
            end
          end
        end
        for value2, other in pairs(self.bodies) do
          if subject.position:dist(other.position) < HASH then
            if subject.isActive then
              local hitSun = subject.body:collidesWith(other.body)
              if hitSun then
                subject:destroy()
                self.numActivePlayers = self.numActivePlayers - 1
                self.sender:sendToAll("destroyPlayer", subject.index)
              end
            end
          end
        end
      
        for value, subject in pairs(self.players) do
          subject.physCheck = false
        end
        
        for index, player in pairs(self.players) do
          player:updateServer(dt, self.bodies)
          self.sender:sendToAll("playerState", {index, player.position, player.velocity, player.dir})
        end
        
        if self.numActivePlayers < 2 then
          local winner = 0
          for i, player in pairs(self.players) do
            if player.isActive then
              winner = i
              player.score = player.score + 1
              break
            end
          end
          self.sender:sendToAll("score", winner)
          self:setupGame()
        end
        if self.numPlayers < 2 then
          self:setupLobby()
        end
      end
    end
  end;
  
  updateLobby = function(self, dt)
    self.sender:update()
    for index, player in pairs(self.players) do
      player:updateServer(dt, self.bodies)
      self.sender:sendToAll("playerState", {index, player.position, player.velocity, player.dir})
    end
  end;
  
  draw = function(self)
    love.graphics.setColor(255,255,255,255)
    love.graphics.print(self.sender:getSocketAddress(), 5, 65)
    if not isClient then
      for i, player in pairs(self.players) do
        player:draw()
      end
      for i, body in pairs(self.bodies) do
        body:draw()
      end
    end
    
  end;
  
  drawLobby = function(self)
    love.graphics.setColor(255,255,255,255)
    love.graphics.print(self.sender:getSocketAddress(), 5, 65)
    if not isClient then
      for i, player in pairs(self.players) do
        player:draw()
        if player.isReady then
          love.graphics.setColor(255,255,255,255)
          love.graphics.print("Ready", player.position.x, player.position.y + player.radius*2)
        end
      end
    end
  end;
  
  allReady = function(self)
    areReady = true
    if #self.players < 2 then
      return false
    end
    
    for i, player in pairs(self.players) do
      if player then
        if not player.isReady then
          areReady = false
        end
      end
    end
    return areReady
  end;
  
  setupGame = function(self)
    local startingPositions = {Vector(SWIDTH/8, SHEIGHT-SWIDTH/8), Vector(SWIDTH/8, SWIDTH/8), Vector(SWIDTH-SWIDTH/8, SHEIGHT-SWIDTH/8), Vector(SWIDTH-SWIDTH/8, SWIDTH/8)}
    for i, player in pairs(self.players) do
      local place = love.math.random(table.maxn(startingPositions))
      local playerPos = table.remove(startingPositions, place)
      local playerVel = Vector(0,0)
      
      player:setPosition(playerPos)
      player:setVelocity(playerVel)
      self.sender:sendToAll("startingPositions", {i, playerPos})
      player.isActive = true
    end
    
    self.numActivePlayers = self.numPlayers
    
    for i, body in pairs(self.bodies) do
      body.isActive = true
    end
    
    self.sender:sendToAll("beginGame", {})
    self.tick = 0
  end;
  
  setupLobby = function(self)
    for i, player in pairs(self.players) do
      local position = Vector(i*SWIDTH/5, LOBBYY)
      local playerVel = Vector(0,0)
      player:setPosition(position)
      player:setVelocity(playerVel)
      player.score = 0
      player.dir = 0
    end
    
    for i, body in pairs(self.bodies) do
      body.isActive = false
    end
    
    Gamestate.switch(lobby)
    server.sender:sendToAll("returnToLobby", {})
  end;
  
  elasticCollision = function(self, shape_a, shape_b, dx, dy, dt)
    local v1 = shape_a.velocity:len()
    local v2 = shape_b.velocity:len()
    local phi = math.atan2(dy, dx)
    local theta1phi = math.atan2(shape_a.velocity.y, shape_a.velocity.x) - phi
    local theta2phi = math.atan2(shape_b.velocity.y, shape_b.velocity.x) - phi
    local m1 = shape_a.mass
    local m2 = shape_b.mass
    
    local v1primex = (((v1*math.cos(theta1phi)*(m1-m2) + 2*m2*v2*math.cos(theta2phi))/(m1+m2))*math.cos(phi))+(v1*math.sin(theta1phi)*math.cos(phi+(math.pi/2)))
    local v1primey = (((v1*math.cos(theta1phi)*(m1-m2) + 2*m2*v2*math.cos(theta2phi))/(m1+m2))*math.sin(phi))+(v1*math.sin(theta1phi)*math.sin(phi+(math.pi/2)))
    
    local v2primex = (((v2*math.cos(theta2phi)*(m2-m1) + 2*m1*v1*math.cos(theta1phi))/(m2+m1))*math.cos(phi))+(v2*math.sin(theta2phi)*math.cos(phi+(math.pi/2)))
    local v2primey = (((v2*math.cos(theta2phi)*(m2-m1) + 2*m1*v1*math.cos(theta1phi))/(m2+m1))*math.sin(phi))+(v2*math.sin(theta2phi)*math.sin(phi+(math.pi/2)))
    
    shape_a.velocity.x = v1primex
    shape_a.velocity.y = v1primey
    
    shape_b.velocity.x = v2primex
    shape_b.velocity.y = v2primey
  end;

  on_collide = function(self, shape_a, shape_b, dx, dy, dt)
    local delta = Vector(dx, dy)
    if shape_a.isStatic then
      if shape_b.isStatic then
        
      else
        
      end
    else 
      if shape_b.isStatic then
        
      else
        local alpha = 0.5
        shape_a.position = shape_a.position + alpha*delta
        shape_b.position = shape_b.position - alpha*delta
        
        --shape_a:updateServer()
        --shape_b:updateServer()
        
        self:elasticCollision(shape_a, shape_b, dx, dy, dt)
        
        --self.sender:sendToAll("collision", {shape_a.index, shape_a.position, shape_a.velocity})
        --self.sender:sendToAll("collision", {shape_b.index, shape_b.position, shape_b.velocity})
      end
    end
  end;
}