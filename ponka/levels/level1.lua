local level = {}

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

function level.load()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

    scale = math.min(sw / BASE_WIDTH, sh / BASE_HEIGHT)
    offsetX = (sw - BASE_WIDTH * scale) / 2
    offsetY = (sh - BASE_HEIGHT * scale) / 2

    world = love.physics.newWorld(0, 1000, true)

    background = love.graphics.newImage("/assets/background.png")
    bush1 = love.graphics.newImage("/assets/bush.png")

    font = love.graphics.newFont(48)
    welcomeText = love.graphics.newText(font, "Arraste para mover!")
    textX = -300
    textY = 100
    fade = 0
    fadeVel = 0.8

    fallText = love.graphics.newText(font, "Toque para pular (duplo pulo!)")
    fallX = 1950
    fallY = 100
    fadeFall = 0

    -- GROUND
    ground = {}
    ground.body = love.physics.newBody(world, 0, 400, "static")
    ground.shape = love.physics.newRectangleShape(0, 390, BASE_WIDTH * 2, 800)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.allowJump = true
    ground.fixture:setUserData(ground)

    ground2 = {}
    ground2.body = love.physics.newBody(world, 4500, 400, "static")
    ground2.shape = love.physics.newRectangleShape(0, 390, BASE_WIDTH * 2, 800)
    ground2.fixture = love.physics.newFixture(ground2.body, ground2.shape)
    ground2.allowJump = true
    ground2.fixture:setUserData(ground2)

    -- WALL
    wall = love.physics.newBody(world, -970, 0, "static")
    wallShape = love.physics.newRectangleShape(20, 1000)
    wallFixture = love.physics.newFixture(wall, wallShape)

    -- OBSTACLE
    obstacle1 = {}
    obstacle1.body = love.physics.newBody(world, 1400, 400, "static")
    obstacle1.shape = love.physics.newRectangleShape(1045, 200)
    obstacle1.fixture = love.physics.newFixture(obstacle1.body, obstacle1.shape)
    obstacle1.allowJump = true
    obstacle1.fixture:setUserData(obstacle1)

    -- PLAYER
    player = {}
    local px, py = ground.body:getPosition()
    player.body = love.physics.newBody(world, px, py - 36, "dynamic")
    player.shape = love.physics.newCircleShape(25)
    player.image = love.graphics.newImage("/assets/bLob.png")
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setFriction(1)
    player.fixture:setRestitution(0.3)
    player.grounded = false
    player.jumps = 0

    -- BALLS
    balls = {}
    local lostImage = love.graphics.newImage("/assets/LostMerpY.png")
    local foundImage = love.graphics.newImage("/assets/merpY.png")

    local spawnPositions = {
        {220, 200}
    }

    for _, pos in ipairs(spawnPositions) do
        local num = math.random(5, 30)
        local b = {}
        b.body = love.physics.newBody(world, pos[1], pos[2], "dynamic")
        b.shape = love.physics.newCircleShape(num)
        b.image = lostImage
        b.foundImage = foundImage
        b.fixture = love.physics.newFixture(b.body, b.shape)
        b.fixture:setDensity(5)
        b.fixture:setFriction(0.05)
        b.body:resetMassData()
        b.active = false
        table.insert(balls, b)
    end

    -- TOUCH
    touch = {
        active = false,
        startX = 0,
        currentX = 0,
        moved = false
    }

    -- CALLBACKS
    world:setCallbacks(
        function(a, b)
            if a == player.fixture or b == player.fixture then
                local other = (a == player.fixture) and b or a
                local data = other:getUserData()

                if data and data.allowJump then
                    player.grounded = true
                    player.jumps = 0
                end
            end

            for _, ball in ipairs(balls) do
                if not ball.active then
                    if (a == player.fixture and b == ball.fixture) or
                       (b == player.fixture and a == ball.fixture) then
                        ball.active = true
                        ball.image = ball.foundImage
                    end
                end
            end
        end,
        function(a, b)
            if a == player.fixture or b == player.fixture then
                player.grounded = false
            end
        end
    )
end

-- TOUCH
function love.touchpressed(id, x, y)
    x, y = screenToWorld(x, y)
    touch.active = true
    touch.startX = x
    touch.currentX = x
    touch.moved = false
end

function love.touchmoved(id, x, y)
    x, y = screenToWorld(x, y)
    if touch.active then
        touch.currentX = x
        if math.abs(x - touch.startX) > 20 then
            touch.moved = true
        end
    end
end

function love.touchreleased(id, x, y)
    if not touch.moved and player.jumps < 2 then
        player.jumps = player.jumps + 1

        local vx = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -500)

        for _, ball in ipairs(balls) do
            if ball.active then
                ball.body:setLinearVelocity(vx, -400)
            end
        end
    end

    touch.active = false
end

function level.update(dt)
    world:update(dt)

    local vx, vy = player.body:getLinearVelocity()

    local accel = 1200
    local maxSpeed = 550
    local friction = 2000

    if touch.active then
        local dx = touch.currentX - touch.startX

        if dx > 20 then
            vx = math.min(vx + accel * dt, maxSpeed)
        elseif dx < -20 then
            vx = math.max(vx - accel * dt, -maxSpeed)
        else
            if vx > 0 then
                vx = math.max(vx - friction * dt, 0)
            elseif vx < 0 then
                vx = math.min(vx + friction * dt, 0)
            end
        end
    else
        if vx > 0 then
            vx = math.max(vx - friction * dt, 0)
        elseif vx < 0 then
            vx = math.min(vx + friction * dt, 0)
        end
    end

    player.body:setLinearVelocity(vx, vy)

    local px, py = player.body:getPosition()

    if py > BASE_HEIGHT then
        level.load()
    end

    if math.abs(px - textX) < 400 then
        fade = math.min(1, fade + fadeVel * dt)
    else
        fade = math.max(0, fade - fadeVel * dt)
    end

    if math.abs(px - fallX) < 400 then
        fadeFall = math.min(1, fadeFall + fadeVel * dt)
    else
        fadeFall = math.max(0, fadeFall - fadeVel * dt)
    end
end

function level.draw()
    love.graphics.push()

    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    love.graphics.draw(background, 0, 0)

    local x, y = player.body:getPosition()
    local r = player.shape:getRadius()

    love.graphics.push()
    love.graphics.translate(BASE_WIDTH/2 - x, BASE_HEIGHT/2 - y)

    love.graphics.draw(bush1, -900, 120, 0, 0.5, 0.5)

    love.graphics.setColor(1, 1, 1, fade)
    love.graphics.draw(welcomeText, textX, textY)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(1, 1, 1, fadeFall)
    love.graphics.draw(fallText, fallX, fallY)
    love.graphics.setColor(1, 1, 1, 1)

    local scaleP = (r * 4) / player.image:getWidth()
    love.graphics.draw(player.image, x, y - 22, 0, scaleP, scaleP,
        player.image:getWidth()/2, player.image:getHeight()/2)

    for _, ball in ipairs(balls) do
        local bx, by = ball.body:getPosition()
        local br = ball.shape:getRadius()
        local scaleB = (br * 2) / ball.image:getWidth()
        love.graphics.draw(ball.image, bx, by, 0, scaleB, scaleB,
            ball.image:getWidth()/2, ball.image:getHeight()/2)
    end

    love.graphics.pop()
    love.graphics.pop()
end

return level