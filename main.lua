local estado = "menu"   -- PODE SER MENU OU JOGO
local levelAtual = nil
local selecionado = 1

local levels = {
    "levels.level1"
}

function loadLevel(index)
    
    package.loaded[levels[index]] = nil -- SERVE PARA LIMPAR O CACHE ANTES DE INICIAR A FASE
    
    levelAtual = require(levels[index]) --LEVE ATUAL RECEBE O LEVEL DA LISTA
    
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
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()

    if estado == "menu" then
        love.graphics.setColor(1, 1, 1)

        love.graphics.printf("PRESSIONE ENTER OU TOQUE PARA COMEÇAR", 0, altura/2, largura, "center")

    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()
    end
end

function love.keypressed(key) --imput do teclado

    if estado == "menu" then
        if key == "return" then
            loadLevel(selecionado)
            estado = "jogo"
        elseif key == "escape" then
            love.event.quit()
        end
    end

    if estado == "jogo" then
        if levelAtual and levelAtual.keypressed then
            levelAtual.keypressed(key)
        end

        -- voltar pro menu
        if key == "escape" then
            estado = "menu"
            levelAtual = nil
        end
    end
end

-- ==============================
-- INPUT: TOQUE (CELULAR)
-- ==============================
function love.touchpressed(id, x, y)

    -- MENU
    if estado == "menu" then
        loadLevel(selecionado)
        estado = "jogo"
    end

    -- JOGO
    if estado == "jogo" and levelAtual and levelAtual.touchpressed then
        levelAtual.touchpressed(id, x, y)
    end
end

function love.touchmoved(id, x, y, dx, dy)
    if estado == "jogo" and levelAtual and levelAtual.touchmoved then
        levelAtual.touchmoved(id, x, y, dx, dy)
    end
end

function love.touchreleased(id, x, y)
    if estado == "jogo" and levelAtual and levelAtual.touchreleased then
        levelAtual.touchreleased(id, x, y)
    end
end