local level = {}

-- Variáveis de controle
local touchStartX = nil
local movingDir = 0 

function level.load()
    -- 1. Configuração de Física
    love.physics.setMeter(64) 
    world = love.physics.newWorld(0, 9.81 * 100, true)
    
    -- 2. Assets em Alta Definição
    -- DICA: Use imagens com o dobro do tamanho que você quer exibir
    background = love.graphics.newImage("assets/background.png")
    playerImg = love.graphics.newImage("assets/bLob.png")
    
    -- Melhorar a filtragem para não borrar ao redimensionar
    background:setFilter("linear", "linear")
    playerImg:setFilter("linear", "linear")

    -- 3. Player (Física)
    player = {}
    player.body = love.physics.newBody(world, 200, 200, "dynamic")
    player.shape = love.physics.newCircleShape(35) -- Aumentei um pouco o corpo
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setFriction(0.9)
    player.jumps = 0

    -- 4. Chão Automático (Se adapta à largura da tela do iPhone)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    ground = {}
    ground.body = love.physics.newBody(world, screenW/2, screenH - 50, "static")
    ground.shape = love.physics.newRectangleShape(screenW * 10, 100)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData({allowJump = true})

    -- Callbacks de colisão
    world:setCallbacks(function(a, b, coll)
        local dataA, dataB = a:getUserData(), b:getUserData()
        if (a == player.fixture and dataB and dataB.allowJump) or 
           (b == player.fixture and dataA and dataA.allowJump) then
            player.jumps = 0
        end
    end)
end

function level.update(dt)
    world:update(dt)
    
    local vx, vy = player.body:getLinearVelocity()
    local accel = 1500
    local maxSpeed = 600

    -- Movimento suave
    if love.keyboard.isDown("right") or movingDir == 1 then
        vx = math.min(vx + accel * dt, maxSpeed)
    elseif love.keyboard.isDown("left") or movingDir == -1 then
        vx = math.max(vx - accel * dt, -maxSpeed)
    else
        vx = vx * 0.92 -- Atrito para parar suavemente
    end

    player.body:setLinearVelocity(vx, vy)
end

-- --- INPUTS (CHAMADOS PELO MAIN.LUA) ---

function level.touchpressed(id, x, y)
    touchStartX = x
    if player.jumps < 2 then
        player.jumps = player.jumps + 1
        local vx = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -700) -- Pulo mais forte para alta res
    end
end

function level.touchmoved(id, x, y)
    if touchStartX then
        local dx = x - touchStartX
        if dx > 40 then movingDir = 1 
        elseif dx < -40 then movingDir = -1 
        else movingDir = 0 end
    end
end

function level.touchreleased(id, x, y)
    touchStartX = nil
    movingDir = 0
end

function level.draw()
    -- Pegar dimensões reais da tela (High DPI)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- 1. Desenhar Fundo esticado para preencher a tela
    love.graphics.setColor(1, 1, 1)
    local scaleX = screenW / background:getWidth()
    local scaleY = screenH / background:getHeight()
    love.graphics.draw(background, 0, 0, 0, scaleX, scaleY)

    -- 2. Desenhar Chão (Simples)
    love.graphics.setColor(0.1, 0.6, 0.2)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- 3. Desenhar Player com alta nitidez
    -- DICA: Se playerImg for 512px, a escala 0.15 mantém ele nítido e pequeno
    love.graphics.setColor(1, 1, 1)
    local px, py = player.body:getPosition()
    local angle = player.body:getAngle()
    
    -- Ajuste a escala conforme o tamanho da sua imagem original
    local pScale = 0.25 
    love.graphics.draw(playerImg, px, py, angle, pScale, pScale, playerImg:getWidth()/2, playerImg:getHeight()/2)
end

function level.keypressed(key)
    if (key == "up" or key == "space") and player.jumps < 2 then
        player.jumps = player.jumps + 1
        local vx = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -700)
    end
end

return level