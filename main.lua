local estado = "menu"

local telaAtual = nil
local levelAtual = nil

local botoes = {}


function loadTela(nome)
    package.loaded[nome] = nil
    telaAtual = require(nome)
    if telaAtual.load then
        telaAtual.load()
    end
end

function loadLevel(nome)
    package.loaded[nome] = nil
    levelAtual = require(nome)

    if levelAtual.load then
        levelAtual.load()
    end

    estado = "jogo"
end

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function love.update(dt)
    if estado == "jogo" and levelAtual then
        if levelAtual.update then
            levelAtual.update(dt)
        end
        return
    end

    if telaAtual and telaAtual.update then
        telaAtual.update(dt)
    end
end

function love.draw()
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()

    if estado == "menu" then
        botoes = {}

        love.graphics.setColor(1,1,1)
        love.graphics.printf("PONKA", 0, altura/3, largura, "center")

        local opcoes = {"Play", "Settings"}

        for i = 1, #opcoes do
            local y = altura/2 + i * 50

            love.graphics.printf(opcoes[i], 0, y, largura, "center")

            table.insert(botoes, {
                x = 0,
                y = y,
                w = largura,
                h = 40,
                nome = opcoes[i]
            })
        end

    elseif estado == "play" or estado == "settings" then
        if telaAtual and telaAtual.draw then
            telaAtual.draw()
        end

    elseif estado == "jogo" and levelAtual then
        if levelAtual.draw then
            levelAtual.draw()
        end
    end
end

function love.keypressed(key)

    if estado == "menu" then
        if key == "escape" then
            love.event.quit()
        end
    end

    if estado == "play" or estado == "settings" then
        if telaAtual and telaAtual.keypressed then
            telaAtual.keypressed(key)
        end

        if key == "escape" then
            estado = "menu"
            telaAtual = nil
        end
    end

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

function love.mousepressed(x, y, button)

    if estado == "menu" then
        for _, b in ipairs(botoes) do
            if x >= b.x and x <= b.x+b.w and y >= b.y and y <= b.y+b.h then
                
                if b.nome == "Play" then
                    loadTela("menu.play")
                    estado = "play"

                elseif b.nome == "Settings" then
                    loadTela("menu.settings")
                    estado = "settings"
                end
            end
        end

    elseif estado == "play" then
        if telaAtual and telaAtual.mousepressed then
            telaAtual.mousepressed(x, y, loadLevel)
        end

    elseif estado == "settings" then
        if telaAtual and telaAtual.mousepressed then
            telaAtual.mousepressed(x, y)
        end
    end
end


function love.touchpressed(id, x, y)
    local largura = love.graphics.getWidth()
    local altura = love.graphics.getHeight()

    x = x * largura
    y = y * altura

    love.mousepressed(x, y, 1)
end