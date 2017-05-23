Player = Class{__includes = Entity,
  init = function(self, x, y, mass, name, color, index)
    Entity.init(self, x, y, mass, name, color)
    self.jet = 0
    self.jetCooldown = 0
    self.jetCooldownMax = self.mass/1000
    self.acceleration = 4000000
    self.maxSpeed = 250
    self.index = index
    self.destructable = true
    self.isReady = false
    self.isActive = true
    self.score = 0
  end;
  
  updateClientOwn = function(self, dt, mouseX, mouseY)
    if self.isActive then
      self.body:moveTo(self.position.x, self.position.y)
      self:handleRotation(mouseX,mouseY)
      if self.jetCooldown > 0 then
        self.jetCooldown = self.jetCooldown - dt
      end
      self.jet = 0
    end
  end;
  
  updateClientOther = function(self, dt)
    if self.isActive then
      self.body:moveTo(self.position.x, self.position.y)
      self.line = self.position + Vector(math.cos(self.dir)*self.radius, math.sin(self.dir)*self.radius)
    end
  end;
  
  updateServer = function(self, dt, bodies)
    if self.isActive then
      if Gamestate.current() == game then
        self:handleMovement(dt, bodies)
        self:inbounds()
      end
      self.line = self.position + Vector(math.cos(self.dir)*self.radius, math.sin(self.dir)*self.radius)
    end
  end;

  draw = function(self)
    if self.isActive then
      love.graphics.setColor(self.color,255)
      self.body:draw("fill")
      love.graphics.setColor(255,255,255,255)
      love.graphics.line(self.position.x, self.position.y, self.line.x, self.line.y)
      love.graphics.setColor(255,255,255,255)
      self.body:draw("line")
      love.graphics.setColor(255,255,255,255)
      love.graphics.printf(self.name, self.position.x-self.radius, self.position.y, self.radius*2, "center")
    end
    love.graphics.setColor(WHITE,255)
    love.graphics.print(self.name, math.floor(self.index*SWIDTH/5), math.floor(SHEIGHT/12))
    love.graphics.print(self.score, math.floor(self.index*SWIDTH/5), math.floor(SHEIGHT/10))
  end;
  
  handleMovement = function(self, dt, bodies)
    local delta = Vector(0,0)
    
    if self.jetCooldown > 0 then
      self.jetCooldown = self.jetCooldown - dt
    end
    
    if self.jet ~= 0 then
      delta = Vector(math.cos(self.dir), math.sin(self.dir))
    end
    
    delta:normalizeInplace()
    
    local force = Vector(0,0)
    
    for index, target in pairs(bodies) do
      if target.isActive then
        local g = 1
        local direction = target.position - self.position
        local distanceSquared = self.position:dist2(target.position)
        local m1 = self.mass
        local m2 = target.mass
        local addForce = direction*(g*m1*m2/distanceSquared)
        force = force + addForce
      end
    end
    
    force = force / self.mass
    
    local boost = self.acceleration / self.mass
    
    self.velocity = self.velocity + delta * self.jet * boost * dt + force * dt
    
    --[[if self.velocity:len() > self.maxSpeed then
      self.velocity = self.velocity:normalized() * self.maxSpeed
    end]]--
    
    self.position = self.position + self.velocity * dt
    self.body:moveTo(self.position.x, self.position.y)
    
    self.jet = 0
  end;
  
  inbounds = function(self)
    if self.position.x - self.radius <= 0 or self.position.x + self.radius >= SWIDTH then
      self.velocity.x = -1 * self.velocity.x
    end
    
    if self.position.y - self.radius <= 0 or self.position.y + self.radius >= SHEIGHT then
      self.velocity.y = -1 * self.velocity.y
    end
    
    if self.position.x - self.radius <= 0 then
      self.position.x = 1 + self.radius
    end
    
    if self.position.x + self.radius >= SWIDTH then
      self.position.x = SWIDTH - 1 - self.radius
    end
    
    if self.position.y - self.radius <= 0 then
      self.position.y = 1 + self.radius
    end
    
    if self.position.y + self.radius >= SHEIGHT then
      self.position.y = SHEIGHT - 1 - self.radius
    end
  end;
  
  handleRotation = function(self, x, y)
    self.dir = math.atan2(y-self.position.y, x-self.position.x)
    
    self.line = self.position + Vector(math.cos(self.dir)*self.radius, math.sin(self.dir)*self.radius)
  end;
  
  setPosition = function(self, position)
    self.position.x = position.x
    self.position.y = position.y
    self.body:moveTo(self.position.x, self.position.y)
    self.line = self.position + Vector(math.cos(self.dir)*self.radius, math.sin(self.dir)*self.radius)
  end;
  
  setVelocity = function(self, velocity)
    self.velocity.x = velocity.x
    self.velocity.y = velocity.y
  end;
  
  mousePressed = function(self, x, y, button, istouch)
    if button == 1 and self.jetCooldown <= 0 then
      self.jet = 1
      self.jetCooldown = self.jetCooldownMax
    end
  end;
  
  boost = function(self)
    self.jet = 1
    self.jetCooldown = self.jetCooldownMax
  end;
  
  destroy = function(self)
    self.isActive = false
  end;
  
}