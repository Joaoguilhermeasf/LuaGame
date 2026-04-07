-- Estado do jogo
local estado = "menu" 
local levelAtual = nil
local selecionado = 1

local levels = {
    "level" -- Certifique-se que o arquivo se chama level.lua
}

function carregarLevel(index)
    -- Limpa o cache para permitir recarregar a fase do zero
    package.loaded[levels[index]] = nil
    levelAtual = require(levels[index])
    if levelAtual and levelAtual.load then
        levelAtual.load()
    end
end

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function love.update(dt)
    if estado == "jogo" and levelAtual and levelAtual.update then
        levelAtual.update(dt)
    end
end

function love.draw()
    if estado == "menu" then
        local largura = love.graphics.getWidth()
        local altura = love.graphics.getHeight()
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("TOQUE NA TELA PARA COMEÇAR", 0, altura / 2, largura, "center")
    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()
    end
end

-- --- EVENTOS DE TOUCH (ESSENCIAL PARA O IOS) ---

function love.touchpressed(id, x, y, dx, dy, pressure)
    if estado == "menu" then
        carregarLevel(selecionado)
        estado = "jogo"
    elseif estado == "jogo" and levelAtual and levelAtual.touchpressed then
        -- Repassa o toque para o level.lua
        levelAtual.touchpressed(id, x, y, dx, dy, pressure)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if estado == "jogo" and levelAtual and levelAtual.touchmoved then
        -- Repassa o movimento para o level.lua (isso faz o swipe funcionar!)
        levelAtual.touchmoved(id, x, y, dx, dy, pressure)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if estado == "jogo" and levelAtual and levelAtual.touchreleased then
        -- Repassa o soltar do dedo para o level.lua (isso faz o boneco parar!)
        levelAtual.touchreleased(id, x, y, dx, dy, pressure)
    end
end

-- MOUSE (para testes no PC)
function love.mousepressed(x, y, button)
    if estado == "menu" then
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