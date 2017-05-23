debug = false

Sock = require "sock"
Bitser = require "bitser"

HC = require "hc"
Shape = require "hc.shapes"

Gamestate = require "hump.gamestate"
Class = require "hump.class"
Vector = require "hump.vector"

require "class/ClientObject"
require "class/ServerObject"
require "class/Player"
require "class/Entity"
require "class/Settings"
require "class/StaticBody"
require "class/Button"

require "state/game"
require "state/lobby"
require "state/menu"
require "state/title"

HASH = 200

TITLE = "Sock-It"
WHITE = {255,255,255}
BLACK = {0,0,0}

function love.load(arg)
  if debug then require("mobdebug").start() end
  isServer = false
  isClient = false
  inGame = false
  love.mouse.setGrabbed(true)
  SWIDTH = love.graphics.getWidth()
  SHEIGHT = love.graphics.getHeight()
  LOBBYY = SHEIGHT/5
  love.keyboard.setKeyRepeat(true)
  love.graphics.setBackgroundColor(BLACK,255)
  Gamestate.registerEvents()
  Gamestate.switch(title)
end

function love.update(dt)
  
end

function love.draw(dt)

end

function love.keypressed(key)

end
