local settings = {}

local volume = 0.5
local botoes = {}

function settings.load()
    love.audio.setVolume(volume)
end

function settings.draw()
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()

    botoes = {}

    love.graphics.setColor(1,1,1)
    love.graphics.printf("SETTINGS", 0, altura/3, largura, "center")

    love.graphics.printf("Volume: "..math.floor(volume*100).."%", 0, altura/2, largura, "center")

    -- BOTÃO MENOS
    local bx = largura/2 - 100
    local by = altura/2 + 50
    local bw = 80
    local bh = 50

    love.graphics.rectangle("line", bx, by, bw, bh)
    love.graphics.printf("-", bx, by + 10, bw, "center")

    table.insert(botoes, {
        x = bx,
        y = by,
        w = bw,
        h = bh,
        tipo = "menos"
    })

    -- BOTÃO MAIS
    local bx2 = largura/2 + 20

    love.graphics.rectangle("line", bx2, by, bw, bh)
    love.graphics.printf("+", bx2, by + 10, bw, "center")

    table.insert(botoes, {
        x = bx2,
        y = by,
        w = bw,
        h = bh,
        tipo = "mais"
    })
end

function settings.mousepressed(x, y)
    for _, b in ipairs(botoes) do
        if x >= b.x and x <= b.x + b.w and
           y >= b.y and y <= b.y + b.h then

            if b.tipo == "mais" then
                volume = math.min(1, volume + 0.1)

            elseif b.tipo == "menos" then
                volume = math.max(0, volume - 0.1)
            end

            love.audio.setVolume(volume)
        end
    end
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