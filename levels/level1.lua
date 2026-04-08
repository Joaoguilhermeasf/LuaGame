local level = {}

-- Controles, Câmera e Resolução
local touchStartX = nil
local movingDir = 0 
local camX, camY = 0, 0 

function level.load()
    love.graphics.setDefaultFilter("linear", "linear", 16)
    world = love.physics.newWorld(0, 1000, true)

    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    
    -- Assets
    background = love.graphics.newImage("assets/background.png")
    playerImg = love.graphics.newImage("assets/bLob.png")
    lostMerpY = love.graphics.newImage("assets/LostMerpY.png")
    bush = love.graphics.newImage("assets/bush.png")

    -- Player
    local spawnP = sh/2 - 60 -- acima do chão
    player = {}
    player.body = love.physics.newBody(world, sw/2, spawnP, "dynamic")
    player.shape = love.physics.newCircleShape(30)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.accel = 130
    player.jumps = 0

    -- Chão (metade inferior da tela)
    ground = {}
    local groundHeight = sh / 2
    ground.body = love.physics.newBody(world, sw/2, sh - groundHeight/2, "static")
    ground.shape = love.physics.newRectangleShape(sw, groundHeight)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData({allowJump = true})

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
    touchStartX = x
    
    -- Pulo na metade superior da tela
    if y < (love.graphics.getHeight() / 2) then
        if player.jumps < 2 then
            player.jumps = player.jumps + 1
            local vx, vy = player.body:getLinearVelocity()
            player.body:setLinearVelocity(vx, -650) 
        end
    end
end

function level.touchmoved(id, x, y)
    if touchStartX then
        local dx = x - touchStartX
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
    touchStartX = nil
    movingDir = 0
end

function level.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- Fundo (sem câmera)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, sw/background:getWidth(), sh/background:getHeight())

    -- Câmera
    love.graphics.push()
    love.graphics.translate(-camX, -camY)

    -- Chão
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- Bush
    local x = sw * 0.2
    local y = sh*0.4
    local scale = (sw * 0.25) / bush:getWidth()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bush, x, y, 0, scale, scale)

    -- Player
    local px, py = player.body:getPosition()
    local pScale = (player.shape:getRadius() * 2.5) / playerImg:getWidth()
    love.graphics.draw(playerImg, px, py, player.body:getAngle(), pScale, pScale, playerImg:getWidth()/2, playerImg:getHeight()/2)

    love.graphics.pop()
end

return level