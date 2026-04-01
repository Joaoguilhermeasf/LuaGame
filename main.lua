-- Estado do jogo
local estado = "menu"  -- "menu" ou "jogo"
local levelAtual = nil

-- Lista de fases
local levels = {
    "levels.level1",
    "levels.level2"
}

-- Controle do menu
local selecionado = 1

-- Carrega o menu/fase
function carregarLevel(index)
    -- Recarrega se já tinha carregado antes
    package.loaded[levels[index]] = nil
    levelAtual = require(levels[index])
    levelAtual.load()
end

-- LOVE LOAD
function love.load()
    -- nada aqui, menu aparece automaticamente
end

-- LOVE UPDATE
function love.update(dt)
    if estado == "jogo" and levelAtual then
        levelAtual.update(dt)
    end
end

-- LOVE DRAW
function love.draw()
    if estado == "menu" then
        love.graphics.print("SELECIONE UMA FASE", 300, 100)

        for i, lvl in ipairs(levels) do
            if i == selecionado then
                love.graphics.print("> Fase " .. i, 320, 150 + i*40)
            else
                love.graphics.print("Fase " .. i, 340, 150 + i*40)
            end
        end

    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()
    end
end

-- LOVE KEYPRESSED
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
        end
        -- Voltar para o menu
        if key == "escape" then
            estado = "menu"
            levelAtual = nil
        end
    end
end