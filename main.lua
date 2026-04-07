local estado = "menu" 
local levelAtual = nil
local selecionado = 1

-- Caminho usando ponto para indicar pasta/arquivo
local caminhos = {
    "levels.level1" 
}

function carregarLevel(index)
    -- Limpa o cache para permitir reiniciar a fase corretamente
    package.loaded[caminhos[index]] = nil
    levelAtual = require(caminhos[index])
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
        love.graphics.printf("TOQUE PARA COMEÇAR", 0, altura / 2, largura, "center")
    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()
    end
end

-- --- CONEXÃO DOS EVENTOS DE TOQUE ---

function love.touchpressed(id, x, y, dx, dy, pressure)
    if estado == "menu" then
        carregarLevel(selecionado)
        estado = "jogo"
    elseif estado == "jogo" and levelAtual and levelAtual.touchpressed then
        levelAtual.touchpressed(id, x, y)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if estado == "jogo" and levelAtual and levelAtual.touchmoved then
        levelAtual.touchmoved(id, x, y)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if estado == "jogo" and levelAtual and levelAtual.touchreleased then
        levelAtual.touchreleased(id, x, y)
    end
end

function love.keypressed(key)
    if estado == "jogo" and levelAtual and levelAtual.keypressed then
        levelAtual.keypressed(key)
    end
    if key == "escape" then estado = "menu" end
end