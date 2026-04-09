local level = {}

-- Controles, Câmera e Resolução
local touches = {}
local movingDir = 0 
local camX, camY = 0, 0 

function level.load()
    love.graphics.setDefaultFilter("linear", "linear", 64)
    world = love.physics.newWorld(0, 1000, true)

    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    
    -- Assets
    background = love.graphics.newImage("assets/background.png")
    playerImg = love.graphics.newImage("assets/bLob.png")
    lostMerpY = love.graphics.newImage("assets/LostMerpY.png")
    bush = love.graphics.newImage("assets/bush.png")

    -- Player
    local spawnP = sh/2 - 60
    player = {}
    player.body = love.physics.newBody(world, sw/2, spawnP, "dynamic")
    player.shape = love.physics.newCircleShape(30)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.accel = 150
    player.jumps = 0

    -- Chão 1
    ground = {}
    local groundHeight = sh / 2
    ground.body = love.physics.newBody(world, sw/2, sh + groundHeight*0.2, "static")
    ground.shape = love.physics.newRectangleShape(sw*1.5, groundHeight)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData({allowJump = true})

    -- Chão 2 (com gap)
    local gap = 200
    local ground1RightEdge = sw/2 + (sw * 1.5) / 2
    local ground2Width = sw
    local ground2X = ground1RightEdge + gap + ground2Width / 2

    ground2 = {}
    local ground2Height = sh / 2
    ground2.body = love.physics.newBody(world, ground2X, sh + groundHeight*0.2, "static")
    ground2.shape = love.physics.newRectangleShape(ground2Width, ground2Height)
    ground2.fixture = love.physics.newFixture(ground2.body, ground2.shape)
    ground2.fixture:setUserData({allowJump = true})

    -- Callback de colisão
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
    
    -- Movimentação do Player
    local vx, vy = player.body:getLinearVelocity()
    local speedMax = 500
    local accel = player.accel

    if love.keyboard.isDown("right") or movingDir == 1 then
        if vx < speedMax then
            vx = vx + accel * dt
        else
            vx = speedMax
        end
    elseif love.keyboard.isDown("left") or movingDir == -1 then
        if vx > -speedMax then
            vx = vx - accel * dt
        else
            vx = -speedMax
        end
    else
        vx = vx * 0.9
    end

    player.body:setLinearVelocity(vx, vy)

    -- Câmera Suave (Lerp)
    local px, py = player.body:getPosition()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    local targetX = px - sw / 2
    local targetY = py - sh / 2

    camX = camX + (targetX - camX) * 5 * dt
    camY = camY + (targetY - camY) * 5 * dt
end

function level.touchpressed(id, x, y)
    local sw = love.graphics.getWidth()

    if x > sw / 2 then
        -- Metade direita: controle de movimento
        touches[id] = {x = x, side = "move"}
    else
        -- Metade esquerda: pulo
        touches[id] = {x = x, side = "jump"}
        if player.jumps < 2 then
            player.jumps = player.jumps + 1
            local vx, vy = player.body:getLinearVelocity()
            player.body:setLinearVelocity(vx, -650)
        end
    end
end

function level.touchmoved(id, x, y)
    if touches[id] and touches[id].side == "move" then
        local dx = x - touches[id].x
        if dx > 40 then
            movingDir = 1
        elseif dx < -40 then
            movingDir = -1
        else
            movingDir = 0
        end
    end
end

function level.touchreleased(id, x, y)
    touches[id] = nil
    if next(touches) == nil then
        movingDir = 0
    end
end

function level.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- Fundo (sem câmera)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, sw/background:getWidth(), sh/background:getHeight())

    -- Câmera
    love.graphics.push()
    love.graphics.translate(-camX, 0)


   
    -- Chão 1
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- Chão 2
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.polygon("fill", ground2.body:getWorldPoints(ground2.shape:getPoints()))

     -- Bush
    local xB, yB = ground.body:getWorldPoints(ground.shape:getPoints())
    local scale = (sw * 0.25) / bush:getWidth()
    xB = xB * 0.9
    yB = yB - yB * 0.8
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bush, xB, yB, 0, scale, scale)


    love.graphics.setColor(1, 1, 1)

    -- Player
    local px, py = player.body:getPosition()
    local pScale = (player.shape:getRadius() * 2.5) / playerImg:getWidth()
    love.graphics.draw(playerImg, px, py, player.body:getAngle(), pScale, pScale, playerImg:getWidth()/2, playerImg:getHeight()/2)

    love.graphics.pop()
end

return level