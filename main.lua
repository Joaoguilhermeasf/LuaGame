-- Estado do jogo
local estado = "menu" -- "menu" ou "jogo"
local levelAtual = nil

-- Lista de fases
local levels = {
    "levels.level1"
}

local selecionado = 1

-- Carrega a fase
function carregarLevel(index)
    package.loaded[levels[index]] = nil
    levelAtual = require(levels[index])
    levelAtual.load()
end

-- LOAD
function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

-- UPDATE
function love.update(dt)
    if estado == "jogo" and levelAtual then
        levelAtual.update(dt)
    end
end

-- DRAW
function love.draw()
    if estado == "menu" then
        local largura = love.graphics.getWidth()
        local altura = love.graphics.getHeight()

        love.graphics.setColor(1, 1, 1)

        love.graphics.printf(
            "TOQUE NA TELA PARA COMEÇAR",
            0,
            altura / 2 - 20,
            largura,
            "center"
        )

    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()
    end
end

-- TOUCH (iPhone)
function love.touchpressed(id, x, y)
    if estado == "menu" then
        print("TOCOU NA TELA")

        carregarLevel(selecionado)
        estado = "jogo"
    end
end

-- TOUCH RELEASE (backup para iOS)
function love.touchreleased(id, x, y)
    if estado == "menu" then
        carregarLevel(selecionado)
        estado = "jogo"
    end
end

-- MOUSE (para testar no PC)
function love.mousepressed(x, y, button)
    if estado == "menu" then
        print("CLIQUE NO MOUSE")

        carregarLevel(selecionado)
        estado = "jogo"
    end
end

-- TECLADO
function love.keypressed(key)
    if estado == "jogo" then
        if levelAtual and levelAtual.keypressed then
            levelAtual.keypressed(key)
        end

        if key == "escape" then
            estado = "menu"
            levelAtual = nil
        end
    end
end