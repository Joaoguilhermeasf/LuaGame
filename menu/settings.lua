local settings = {}

local volume = 0.5

function settings.load()
    love.audio.setVolume(volume)
end

function settings.draw()
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()

    love.graphics.printf("SETTINGS", 0, altura/3, largura, "center")
    love.graphics.printf("Volume: "..math.floor(volume*100).."%", 0, altura/2, largura, "center")
    love.graphics.printf("← / → para ajustar", 0, altura/2 + 40, largura, "center")
end

function settings.keypressed(key)
    if key == "right" then
        volume = math.min(1, volume + 0.1)
    elseif key == "left" then
        volume = math.max(0, volume - 0.1)
    end

    love.audio.setVolume(volume)
end

return settings