local level = {}

-- 🔥 CONTROLE DE TOQUE
local touchStartX = nil
local movingDir = 0 

function level.load()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 1000, true)
    
    -- Assets (Certifique-se que os caminhos estão corretos)
    background = love.graphics.newImage("assets/background.png")
    bush1 = love.graphics.newImage("assets/bush.png")
    font = love.graphics.newFont(48)
    
    welcomeText = love.graphics.newText(font, "Move with the arrow keys!")
    textX, textY = -300, 100
    fade, fadeVel = 0, 0.8

    fallText = love.graphics.newText(font, "PS: you can double jump!")
    fallX, fallY = 1950, 100
    fadeFall = 0

    -- Chão e Obstáculos
    ground = {} 
    ground.body = love.physics.newBody(world, 0, 400, "static")
    ground.shape = love.physics.newRectangleShape(0, 390, love.graphics.getWidth()*2, 800)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.allowJump = true
    ground.fixture:setUserData(ground)

    ground2 = {}
    ground2.body = love.physics.newBody(world, 4500, 400, "static")
    ground2.shape = love.physics.newRectangleShape(0, 390, love.graphics.getWidth()*2, 800)
    ground2.fixture = love.physics.newFixture(ground2.body, ground2.shape)
    ground2.allowJump = true
    ground2.fixture:setUserData(ground2)

    wall = love.physics.newBody(world, -970, 0, "static")
    wallShape = love.physics.newRectangleShape(20, 1000)
    wallFixture = love.physics.newFixture(wall, wallShape)

    obstacle1 = {}
    obstacle1.body = love.physics.newBody(world, 1400, 400, "static")
    obstacle1.shape = love.physics.newRectangleShape(1045, 200)
    obstacle1.fixture = love.physics.newFixture(obstacle1.body, obstacle1.shape)
    obstacle1.allowJump = true
    obstacle1.fixture:setUserData(obstacle1)

    -- Player
    player = {}
    player.body = love.physics.newBody(world, 0, 0, "dynamic")
    player.shape = love.physics.newCircleShape(25)
    player.image = love.graphics.newImage("assets/bLob.png")
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setFriction(1)
    player.fixture:setRestitution(0.3)
    player.grounded = false
    player.jumps = 0

    -- Colecionáveis (Balls)
    balls = {}
    local lostImage = love.graphics.newImage("assets/LostMerpY.png")
    local foundImage = love.graphics.newImage("assets/merpY.png")
    local spawnPositions = {{x = 120, y = 380}}

    for _, pos in ipairs(spawnPositions) do
        local b = {}
        b.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
        b.shape = love.physics.newCircleShape(math.random(15, 25))
        b.image = lostImage
        b.foundImage = foundImage
        b.fixture = love.physics.newFixture(b.body, b.shape)
        b.fixture:setDensity(5)
        b.body:resetMassData()
        b.active = false
        table.insert(balls, b)
    end

    -- Callbacks de Colisão
    world:setCallbacks(
        function(a, b, coll)
            local fixtureA, fixtureB = a, b
            if fixtureA == player.fixture or fixtureB == player.fixture then
                local other = (fixtureA == player.fixture) and fixtureB or fixtureA
                local data = other:getUserData()
                if data and data.allowJump then
                    player.grounded = true
                    player.jumps = 0
                end
            end
            for _, ball in ipairs(balls) do
                if not ball.active then
                    if (a == player.fixture and b == ball.fixture) or (b == player.fixture and a == ball.fixture) then
                        ball.active = true
                        ball.image = ball.foundImage
                    end
                end
            end
        end,
        function(a, b, coll)
            if a == player.fixture or b == player.fixture then player.grounded = false end
        end
    )
end

function level.update(dt)
    world:update(dt)
    
    local vx, vy = player.body:getLinearVelocity()
    local accel, maxSpeed, friction = 1200, 550, 2000

    -- Movimentação Híbrida (Teclado + Touch)
    if love.keyboard.isDown("right") or movingDir == 1 then
        vx = math.min(vx + accel * dt, maxSpeed)
    elseif love.keyboard.isDown("left") or movingDir == -1 then
        vx = math.max(vx - accel * dt, -maxSpeed)
    else
        if vx > 0 then vx = math.max(vx - friction * dt, 0)
        elseif vx < 0 then vx = math.min(vx + friction * dt, 0) end
    end

    player.body:setLinearVelocity(vx, vy)

    -- Reiniciar Jogo
    if love.keyboard.isDown("r") then level.load() end

    -- Lógica das Balls e Textos (Mantida do original)
    local px, py = player.body:getPosition()
    for _, ball in ipairs(balls) do
        if ball.active then
            local bx, by = ball.body:getPosition()
            local vxb, vyb = ball.body:getLinearVelocity()
            if bx > px + 100 then vxb = math.max(vxb - 950 * dt, -550)
            elseif bx < px - 100 then vxb = math.min(vxb + 950 * dt, 550)
            else vxb = vxb * 0.95 end
            ball.body:setLinearVelocity(vxb, vyb)
        end
    end

    if py > 2000 then level.load() end -- Queda infinita

    fade = (math.abs(px - textX) < 400) and math.min(1, fade + fadeVel * dt) or math.max(0, fade - fadeVel * dt)
    fadeFall = (math.abs(px - fallX) < 400) and math.min(1, fadeFall + fadeVel * dt) or math.max(0, fadeFall - fadeVel * dt)
end

function level.keypressed(key)
    if (key == "up" or key == "space" or key == "touch_jump") and player.jumps < 2 then
        player.jumps = player.jumps + 1
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -550)
        
        for _, ball in ipairs(balls) do
            if ball.active then ball.body:setLinearVelocity(vx, -450) end
        end
    end
end

-- 🔥 CORREÇÃO DO TOUCH PARA IOS
function level.touchpressed(id, x, y)
    touchStartX = x
    -- Aciona o pulo no primeiro toque
    level.keypressed("touch_jump")
end

function level.touchmoved(id, x, y)
    if touchStartX then
        local dx = x - touchStartX
        -- Sensibilidade: 30 pixels de deslocamento para detectar movimento
        if dx > 30 then movingDir = 1
        elseif dx < -30 then movingDir = -1
        else movingDir = 0 end
    end
end

function level.touchreleased(id, x, y)
    touchStartX = nil
    movingDir = 0
end

function level.draw()
    love.graphics.draw(background, 0, 0)
    local x, y = player.body:getPosition()

    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2 - x, love.graphics.getHeight()/2 - y)

    -- Desenhar Objetos
    love.graphics.draw(bush1, -900, 120, 0, 0.5, 0.5)
    
    love.graphics.setColor(1, 1, 1, fade)
    love.graphics.draw(welcomeText, textX, textY)
    love.graphics.setColor(1, 1, 1, fadeFall)
    love.graphics.draw(fallText, fallX, fallY)
    
    love.graphics.setColor(1, 1, 1, 1)
    local angle = player.body:getAngle()
    love.graphics.draw(player.image, x, y, angle, 0.2, 0.2, player.image:getWidth()/2, player.image:getHeight()/2)

    for _, ball in ipairs(balls) do
        local bx, by = ball.body:getPosition()
        love.graphics.draw(ball.image, bx, by, ball.body:getAngle(), 0.1, 0.1, ball.image:getWidth()/2, ball.image:getHeight()/2)
    end

    -- Chão
    love.graphics.setColor(0.9, 0.7, 0.6)
    love.graphics.rectangle("fill", -2000, 390, 4000, 800)
    love.graphics.rectangle("fill", 2500, 390, 4000, 800)
    love.graphics.rectangle("fill", 900, 300, 1000, 450)

    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
end

return level