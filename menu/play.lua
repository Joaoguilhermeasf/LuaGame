local play = {}

local levels = {
    "levels.level1",
    "levels.level2",
    "levels.level3"
}

local botoes = {}

function play.draw()
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()

    botoes = {}

    love.graphics.printf("SELECIONE UMA FASE", 0, altura/3, largura, "center")

    for i = 1, #levels do
        local y = altura/2 + i * 40

        love.graphics.printf("Level " .. tostring(i), 0, y, largura, "center")

        table.insert(botoes, {
            x = 0,
            y = y,
            w = largura,
            h = 30,
            level = levels[i]
        })
    end
end

function play.mousepressed(x, y, loadLevel)
    for _, b in ipairs(botoes) do
        if x >= b.x and x <= b.x+b.w and y >= b.y and y <= b.y+b.h then
            loadLevel(b.level)
        end
    end
end

return play