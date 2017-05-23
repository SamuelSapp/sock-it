StaticBody = Class{__includes = Entity,
  init = function(self, x, y, mass, name, color)
    Entity.init(self, x, y, mass, name, color)
    self.acceleration = 0
    self.maxSpeed = 0
    self.isStatic = true
    self.isActive = false
  end;
  
  update = function(self, dt)
    self.body:moveTo(self.position.x, self.position.y)
  end;
  
  draw = function(self)
    love.graphics.setColor(WHITE,255)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
    love.graphics.circle("line", self.position.x, self.position.y, self.radius)
    love.graphics.setColor(BLACK,255)
    love.graphics.print(self.name, self.position.x, self.position.y, 0)
  end;
}