local estado = "menu"
local levelAtual = nil

local levels = {
    "levels.level1"
}

local selecionado = 1

-- ========================
-- RESOLUÇÃO VIRTUAL
-- ========================
BASE_WIDTH = 1920
BASE_HEIGHT = 1080

scale = 1
offsetX = 0
offsetY = 0

local function screenToWorld(x, y)
    x = x * love.graphics.getWidth()
    y = y * love.graphics.getHeight()

    x = (x - offsetX) / scale
    y = (y - offsetY) / scale

    return x, y
end

-- ========================
-- BOTÕES DO MENU
-- ========================
menuButtons = {}

local function criarMenu()
    menuButtons = {}

    for i = 1, #levels do
        table.insert(menuButtons, {
            x = BASE_WIDTH/2 - 200,
            y = 300 + i * 120,
            w = 400,
            h = 80,
            level = i
        })
    end
end

-- ========================
-- LOAD LEVEL
-- ========================
function carregarLevel(index)
    package.loaded[levels[index]] = nil
    levelAtual = require(levels[index])
    levelAtual.load()
end

-- ========================
-- LOVE LOAD
-- ========================
function love.load()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

    scale = math.min(sw / BASE_WIDTH, sh / BASE_HEIGHT)
    offsetX = (sw - BASE_WIDTH * scale) / 2
    offsetY = (sh - BASE_HEIGHT * scale) / 2

    criarMenu()
end

-- ========================
-- UPDATE
-- ========================
function love.update(dt)
    if estado == "jogo" and levelAtual then
        levelAtual.update(dt)
    end
end

-- ========================
-- DRAW
-- ========================
function love.draw()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    if estado == "menu" then
        love.graphics.printf("SELECIONE UMA FASE",
            0, 100, BASE_WIDTH, "center")

        for i, btn in ipairs(menuButtons) do
            love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
            love.graphics.printf("FASE " .. i,
                btn.x, btn.y + 20, btn.w, "center")
        end

    elseif estado == "jogo" and levelAtual then
        levelAtual.draw()

        -- BOTÃO VOLTAR
        love.graphics.rectangle("line", 50, 50, 200, 80)
        love.graphics.print("VOLTAR", 80, 80)
    end

    love.graphics.pop()
end

-- ========================
-- TOUCH
-- ========================
function love.touchpressed(id, x, y)
    x, y = screenToWorld(x, y)

    if estado == "menu" then
        for _, btn in ipairs(menuButtons) do
            if x > btn.x and x < btn.x + btn.w and
               y > btn.y and y < btn.y + btn.h then
                
                carregarLevel(btn.level)
                estado = "jogo"
            end
        end

    elseif estado == "jogo" then
        -- BOTÃO VOLTAR
        if x > 50 and x < 250 and y > 50 and y < 130 then
            estado = "menu"
            levelAtual = nil
        end
    end
end