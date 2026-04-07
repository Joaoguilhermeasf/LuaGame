local level = {}

-- 🔥 CONTROLES E RESOLUÇÃO
local touchStartX = nil
local movingDir = 0 
local scaleRetina = 1

function level.load()
    -- 1. CONFIGURAÇÃO GRÁFICA (ADEUS PIXELS)
    love.graphics.setDefaultFilter("linear", "linear", 16)
    scaleRetina = love.window.getDPIScale() -- Detecta se é iPhone Retina (2x ou 3x)

    -- 2. FÍSICA (AJUSTADA PARA ESCALA ALTA)
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 128, true)
    
    -- 3. CARREGAR ASSETS
    background = love.graphics.newImage("assets/background.png")
    playerImg = love.graphics.newImage("assets/bLob.png")
    -- Ativa Mipmaps para nitidez ao diminuir a imagem
    playerImg:setFilter("linear", "linear", 16)

    -- 4. CONFIGURAR PLAYER
    -- Usamos dimensões lógicas, o LÖVE HighDPI cuida do resto
    player = {}
    player.body = love.physics.newBody(world, 200, 200, "dynamic")
    player.shape = love.physics.newCircleShape(30) -- Tamanho do colisor
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setFriction(1.0)
    player.fixture:setRestitution(0.2)
    player.jumps = 0

    -- 5. CONFIGURAR CHÃO (Largo o suficiente para qualquer tela)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    ground = {}
    ground.body = love.physics.newBody(world, screenW/2, screenH - 50, "static")
    ground.shape = love.physics.newRectangleShape(screenW * 20, 100)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData({allowJump = true})

    -- 6. CALLBACKS DE COLISÃO
    world:setCallbacks(function(a, b, coll)
        local dataA = a:getUserData()
        local dataB = b:getUserData()
        if (a == player.fixture and dataB and dataB.allowJump) or 
           (b == player.fixture and dataA and dataA.allowJump) then
            player.jumps = 0
        end
    end)
end

function level.update(dt)
    world:update(dt)
    
    local vx, vy = player.body:getLinearVelocity()
    local accel = 2500 
    local maxSpeed = 600

    -- MOVIMENTAÇÃO (Teclado + Touch Swipe)
    if love.keyboard.isDown("right") or movingDir == 1 then
        vx = math.min(vx + accel * dt, maxSpeed)
    elseif love.keyboard.isDown("left") or movingDir == -1 then
        vx = math.max(vx - accel * dt, -maxSpeed)
    else
        vx = vx * 0.9 -- Atrito para não deslizar no gelo
    end

    player.body:setLinearVelocity(vx, vy)
end

-- 🔥 INTERAÇÃO TOUCH (Chamada pelo main.lua)
function level.touchpressed(id, x, y)
    touchStartX = x
    -- Tap na tela = Pulo
    if player.jumps < 2 then
        player.jumps = player.jumps + 1
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -750) 
    end
end

function level.touchmoved(id, x, y)
    if touchStartX then
        local dx = x - touchStartX
        -- Sensibilidade ajustada para telas de alta densidade
        local threshold = 30 * scaleRetina
        if dx > threshold then 
            movingDir = 1 
        elseif dx < -threshold then 
            movingDir = -1 
        else 
            movingDir = 0 
        end
    end
end

function level.touchreleased(id, x, y)
    touchStartX = nil
    movingDir = 0
end

function level.draw()
    -- Pegamos o tamanho da tela para o fundo
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

    -- 1. DESENHAR FUNDO (Escalonado para preencher a tela nitidamente)
    love.graphics.setColor(1, 1, 1)
    local sx = sw / background:getWidth()
    local sy = sh / background:getHeight()
    love.graphics.draw(background, 0, 0, 0, sx, sy)

    -- 2. DESENHAR CHÃO
    love.graphics.setColor(0.15, 0.6, 0.25)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- 3. DESENHAR PLAYER (O SEGREDO DA NITIDEZ)
    love.graphics.setColor(1, 1, 1)
    local px, py = player.body:getPosition()
    local pAngle = player.body:getAngle()
    
    -- Se sua imagem bLob.png for 512px, o scale 0.15 a deixará super nítida
    -- porque o iPhone usará muitos pixels reais para desenhar cada detalhe.
    local playerScale = (player.shape:getRadius() * 2.5) / playerImg:getWidth()
    
    love.graphics.draw(playerImg, px, py, pAngle, playerScale, playerScale, 
                       playerImg:getWidth()/2, playerImg:getHeight()/2)
end

function level.keypressed(key)
    if (key == "up" or key == "space") and player.jumps < 2 then
        player.jumps = player.jumps + 1
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -750)
    end
end

return level