local estado = "menu"
local levelAtual = nil

local levels = {
    "levels.level1"
}

local selecionado = 1
local activeTouches = {}

function carregarLevel(index)
    package.loaded[levels[index]] = nil
    levelAtual = require(levels[index])
    levelAtual.load()
end

function love.load()
end

function love.update(dt)
    if estado == "jogo" and levelAtual then
        -- Repassa touches ativos para o level calcular movimento
        levelAtual.update(dt, activeTouches)
    end
end

function love.draw()
    if estado == "menu" then
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()

        love.graphics.print("SELECIONE UMA FASE", 300, 100)

        for i, lvl in ipairs(levels) do
            if i == selecionado then
                love.graphics.print("> Fase " .. i, 320, 150 + i*40)
            else
                love.graphics.print("Fase " .. i, 340, 150 + i*40)
            end
        end

        -- Instrução para touch
        love.graphics.print("Toque para iniciar", 300, h - 80)

    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()
    end
end

-- TECLADO
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
        if key == "escape" then
            estado = "menu"
            levelAtual = nil
            activeTouches = {}
        end
        if levelAtual and levelAtual.keypressed then
            levelAtual.keypressed(key)
        end
    end
end

-- TOUCH
function love.touchpressed(id, x, y)
    activeTouches[id] = x

    if estado == "menu" then
        -- Qualquer toque inicia a fase selecionada
        carregarLevel(selecionado)
        estado = "jogo"

    elseif estado == "jogo" and levelAtual then
        local w = love.graphics.getWidth()

        -- Meio da tela = pulo
        if x > w * 0.35 and x < w * 0.65 then
            if levelAtual.keypressed then
                levelAtual.keypressed("up")
            end
        end
    end
end

function love.touchmoved(id, x, y)
    activeTouches[id] = x
end

function love.touchreleased(id, x, y)
    activeTouches[id] = nil
end