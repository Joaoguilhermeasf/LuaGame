-- Estado do jogo
local estado = "menu"
local levelAtual = nil

-- Lista de fases
local levels = {
    "levels.level1"
}

local selecionado = 1

-- Área clicável do menu
local botoes = {}

function carregarLevel(index)
    package.loaded[levels[index]] = nil
    levelAtual = require(levels[index])
    levelAtual.load()
end

function love.load()
end

function love.update(dt)
    if estado == "jogo" and levelAtual then
        levelAtual.update(dt)
    end
end

function love.draw()
    if estado == "menu" then
        love.graphics.print("SELECIONE UMA FASE", 300, 100)

        botoes = {} -- limpa e recria a cada frame

        for i, lvl in ipairs(levels) do
            local x = 320
            local y = 150 + i * 40
            local largura = 200
            local altura = 30

            -- salva área do botão
            table.insert(botoes, {
                x = x,
                y = y,
                w = largura,
                h = altura,
                index = i
            })

            if i == selecionado then
                love.graphics.print("> Fase " .. i, x, y)
            else
                love.graphics.print("Fase " .. i, x + 20, y)
            end
        end

    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()
    end
end

function love.keypressed(key)
    if estado == "menu" then
        if key == "down" then
            selecionado = selecionado % #levels + 1
        elseif key == "up" then
            selecionado = (selecionado - 2) % #levels + 1
        elseif key == "return" then
            carregarLevel(selecionado)
            estado = "jogo"
        elseif key == "escape" then
            love.event.quit()
        end
    elseif estado == "jogo" then
        if levelAtual.keypressed then
            levelAtual.keypressed(key)
    

        if key == "escape" then
            estado = "menu"
            levelAtual = nil
        end
end

-- 🔥 TOUCH (celular)
function love.touchpressed(id, x, y)
    if estado == "menu" then
      carregarLevel(selecionado)
     estado = "jogo"
            end
        end
    end
end