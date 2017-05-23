title = {}

titleTune = love.audio.newSource("assets/sounds/title_screen_01.wav")



function title:enter()
  titleTune:setVolume(0.5)
  titleTune:play()
end

function title:update(dt)
  if titleTune:isStopped() then
    Gamestate.switch(menu)
  end
end

function title:draw()
  love.graphics.printf("SOCK-IT", (SWIDTH/2)-100, SHEIGHT/3, 200, "center")
  love.graphics.printf("by Zabutongl", (SWIDTH/2)-100, (SHEIGHT/3)+20, 200, "center")
end
