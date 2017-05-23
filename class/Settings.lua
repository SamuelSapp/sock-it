Settings = Class{
  init = function(self) 
    self.ipAddress = "192.168.0.16"
    self.name = "Player"
    self.color = {0, 0, 0}
    self.mass = 500
    self.activeItem = 1
    self.items = {}
    table.insert(self.items, 1, self.name)
    table.insert(self.items, 2, tostring(self.color[1]))
    table.insert(self.items, 3, tostring(self.color[2]))
    table.insert(self.items, 4, tostring(self.color[3]))
    table.insert(self.items, 5, tostring(self.mass))
  end;
  
  textinputLobby = function(self, key)
    local activeItem = self.activeItem
    
    if activeItem == 1 then
      self.items[activeItem] = self.items[activeItem] .. key
      self.name = self.items[activeItem]
    elseif activeItem == 2 then
      local toAdd = tonumber(key)
      if toAdd then
        self.items[activeItem] = self.items[activeItem] .. toAdd
      end
      if tonumber(self.items[activeItem]) > 255 then
        self.items[activeItem] = tostring(255)
      end
      self.color[1] = tonumber(self.items[activeItem])
    elseif activeItem == 3 then
      local toAdd = tonumber(key)
      if toAdd then
        self.items[activeItem] = self.items[activeItem] .. toAdd
      end
      if tonumber(self.items[activeItem]) > 255 then
        self.items[activeItem] = tostring(255)
      end
      self.color[2] = tonumber(self.items[activeItem])
    elseif activeItem == 4 then
      local toAdd = tonumber(key)
      if toAdd then
        self.items[activeItem] = self.items[activeItem] .. toAdd
      end
      if tonumber(self.items[activeItem]) > 255 then
        self.items[activeItem] = tostring(255)
      end
      self.color[3] = tonumber(self.items[activeItem])
    elseif activeItem == 5 then
      local toAdd = tonumber(key)
      if toAdd then
        self.items[activeItem] = self.items[activeItem] .. toAdd
      end
      if tonumber(self.items[activeItem]) > 1000 then
        self.items[activeItem] = tostring(1000)
      end
      self.mass = tonumber(self.items[activeItem])
    end
    
    self.setValues(self)
  end;
  
  textinputMenu = function(self, key)
    local toAdd = tonumber(key)
    if toAdd then
      self.ipAddress = self.ipAddress .. toAdd
    end
    
    if key == "." then
      self.ipAddress = self.ipAddress .. key
    end
  end;
  
  
  keypressedLobby = function(self, key)
    
    if key == "tab" then
      self.activeItem = self.activeItem + 1
      if self.activeItem > #self.items then
        self.activeItem = 1
      end
    end
    
    if key == "backspace" then
      self.items[self.activeItem] = self.items[self.activeItem]:sub(1, -2)
      self.setValues(self)
    end
  end;
  
  keypressedMenu = function(self, key)
    if key == "backspace" then
      self.ipAddress = self.ipAddress:sub(1, -2)
      self.setValues(self)
    end
  end;
  
  setValues = function(self)
    self.name = self.items[1]
    self.color = {tonumber(self.items[2]), tonumber(self.items[3]), tonumber(self.items[4])}
    self.mass = tonumber(self.items[5])
  end;
}