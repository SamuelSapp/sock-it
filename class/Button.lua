Button = Class{
  init = function(self, x, y, w, h, text)
    self.w = w
    self.h = h
    self.x = x - w/2
    self.y = y - h/2
    self.body = HC.rectangle(self.x, self.y, w, h)
    self.text = text
    self.yOffset = self.h/2
    self.xOffset = love.graphics.getLineWidth()
    self.outlineColor = WHITE
    self.isToggle = false
    self.isActive = true
  end;
  
  init = function(self, x, y, w, h, text, isToggle)
    self.w = w
    self.h = h
    self.x = x - w/2
    self.y = y - h/2
    self.body = HC.rectangle(self.x, self.y, w, h)
    self.text = text
    self.yOffset = self.h/2
    self.xOffset = love.graphics.getLineWidth()
    self.outlineColor = WHITE
    self.isToggle = isToggle
    self.isActive = true
  end;
  
  draw = function(self)
    if self.isActive then
      love.graphics.setColor(self.outlineColor,255)
      self.body:draw("line")
      love.graphics.setColor(WHITE,255)
      love.graphics.printf(self.text, self.x+self.xOffset, self.y+self.yOffset, self.w-10, "center", 0, 1, 1, 0, love.graphics.getFont():getHeight()/2)
    end
  end;
  
  highlight = function(self, mousePos)
    if self.isActive then
      local test = mousePos:collidesWith(self.body)
      return test
    end
    return false
  end;
  
  toggle = function(self)
    if self.isToggle and self.isActive then
      if self.outlineColor == {0,0,0} then
        self.outlineColor = {255,255,255}
      else
        self.outlineColor = {0,0,0}
      end
    end
  end;
  
}