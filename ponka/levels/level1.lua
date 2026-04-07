local level = {}

function level.load()
    world = love.physics.newWorld(0, 1000, true)

    -- ========================
    -- PLAYER
    -- ========================
    player = {}

    player.body = love.physics.newBody(world, 300, 300, "dynamic")
    player.shape = love.physics.newCircleShape(25)
    player.fixture = love.physics.newFixture(player.body, player.shape)

    player.fixture:setUserData({type = "player"})

    player.speed = 500
    player.accel = 1200
    player.friction = 2000
    player.jumps = 0
    player.maxJumps = 2

    -- ========================
    -- CHÃO
    -- ========================
    ground = {}

    ground.body = love.physics.newBody(world, 960, 900, "static")
    ground.shape = love.physics.newRectangleShape(1920, 200)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)

    ground.fixture:setUserData({type = "ground"})

    -- ========================
    -- CONTROLE TOUCH
    -- ========================
    touch = {
        active = false,
        startX = 0,
        currentX = 0,
        moved = false
    }

    -- ========================
    -- COLISÃO
    -- ========================
    world:setCallbacks(beginContact)
end

function beginContact(a, b)
    local dataA = a:getUserData()
    local dataB = b:getUserData()

    if not dataA or not dataB then return end

    if (dataA.type == "player" and dataB.type == "ground") or
       (dataB.type == "player" and dataA.type == "ground") then
        player.jumps = 0
    end
end

-- ========================
-- TOUCH INPUT
-- ========================
function level.touchpressed(id, x, y)
    touch.active = true
    touch.startX = x
    touch.currentX = x
    touch.moved = false
end

function level.touchmoved(id, x, y)
    if touch.active then
        touch.currentX = x
        if math.abs(x - touch.startX) > 20 then
            touch.moved = true
        end
    end
end

function level.touchreleased(id, x, y)
    -- TAP = pulo
    if not touch.moved and player.jumps < player.maxJumps then
        player.jumps = player.jumps + 1

        local vx = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -600)
    end

    touch.active = false
end

-- ========================
-- UPDATE
-- ========================
function level.update(dt)
    world:update(dt)

    local vx, vy = player.body:getLinearVelocity()

    if touch.active then
        local dx = touch.currentX - touch.startX

        if dx > 20 then
            vx = math.min(vx + player.accel * dt, player.speed)
        elseif dx < -20 then
            vx = math.max(vx - player.accel * dt, -player.speed)
        else
            vx = vx * 0.9
        end
    else
        vx = vx * 0.9
    end

    player.body:setLinearVelocity(vx, vy)
end

-- ========================
-- DRAW + CÂMERA
-- ========================
function level.draw()
    local px, py = player.body:getPosition()

    local camX = px - BASE_WIDTH / 2
    local camY = py - BASE_HEIGHT / 2

    love.graphics.push()
    love.graphics.translate(-camX, -camY)

    -- chão
    love.graphics.rectangle("fill", 0, 900, 1920, 200)

    -- player
    love.graphics.circle("fill", px, py, 25)

    love.graphics.pop()
end

return level