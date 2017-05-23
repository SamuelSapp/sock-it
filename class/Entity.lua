Entity = Class{
  init = function(self, x, y, mass, name, color)
    self.acceleration = 0
    self.velocity = Vector(0,0)
    self.position = Vector(x,y)
    self.mass = mass
    self.name = name
    self.dir = 0
    self.radius = 30
    self.color = color
    self.physCheck = false
    self.line = Vector(x + math.cos(self.dir)*self.radius, y + math.sin(self.dir)*self.radius)
    self.isDestructable = false
    self.isStatic = false
    self.body = Shape.newCircleShape(self.position.x, self.position.y, self.radius)
  end;
}