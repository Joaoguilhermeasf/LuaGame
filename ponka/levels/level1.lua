local level = {}

function level.load()
    world = love.physics.newWorld(0, 1000, true)
    
    background = love.graphics.newImage("/assets/background.png")

    bush1 = love.graphics.newImage("/assets/bush.png")

    font = love.graphics.newFont(48)
    welcomeText = love.graphics.newText(font, "Move with the arrow keys!")
    textX = -300
    textY = 100
    fade = 0
    fadeVel = 0.8

    fallText = love.graphics.newText(font, "PS: you can double jump!")
    fallX = 1950
    fallY = 100
    fadeFall = 0
    fadeVel = 0.8

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

    player = {}
    local px, py = ground.body:getPosition()
    player.body = love.physics.newBody(world, px, py - 36, "dynamic")
    player.shape = love.physics.newCircleShape(25)
    player.image = love.graphics.newImage("/assets/bLob.png")
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setFriction(1)
    player.fixture:setRestitution(0.3)
    player.vel = 0
    player.grounded = false
    player.jumps = 0
    player.touchLeft = false
    player.touchRight = false

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

    world:setCallbacks(
        function(a, b, coll)
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
        function(a, b, coll)
            if a == player.fixture or b == player.fixture then
                player.grounded = false
            end
        end
    )
end

function level.update(dt, activeTouches)
    world:update(dt)

    -- TOUCH INPUT
    local w = love.graphics.getWidth()
    player.touchLeft  = false
    player.touchRight = false

    for _, tx in pairs(activeTouches or {}) do
        if tx < w * 0.35 then
            player.touchLeft = true
        elseif tx > w * 0.65 then
            player.touchRight = true
        end
    end

    -- PLAYER MOVEMENT
    local vx, vy = player.body:getLinearVelocity()

    local accel = 1200
    local maxSpeed = 550
    local friction = 2000

    if love.keyboard.isDown("right") or player.touchRight then
        vx = math.min(vx + accel * dt, maxSpeed)
    elseif love.keyboard.isDown("left") or player.touchLeft then
        vx = math.max(vx - accel * dt, -maxSpeed)
    else
        if vx > 0 then
            vx = math.max(vx - friction * dt, 0)
        elseif vx < 0 then
            vx = math.min(vx + friction * dt, 0)
        end
    end

    player.body:setLinearVelocity(vx, vy)

    if love.keyboard.isDown("r") then
        level.load()
    end

    local px, py = player.body:getPosition()

    local bAccel = 850
    local bMaxSpeed = 550
    local bFriction = 5000

    for _, ball in ipairs(balls) do
        if ball.active then
            local bx, by = ball.body:getPosition()
            local vx_ball, vy_ball = ball.body:getLinearVelocity()

            if bx > px + 100 then
                vx_ball = math.min(vx_ball + bAccel * dt, -bMaxSpeed)
            elseif bx < px - 100 then
                vx_ball = math.min(vx_ball + bAccel * dt, bMaxSpeed)
            else
                if vx_ball > 0 then
                    vx_ball = math.max(vx_ball - bFriction * dt, 0)
                elseif vx_ball < 0 then
                    vx_ball = math.min(vx_ball + bFriction * dt, 0)
                end
            end

            ball.body:setLinearVelocity(vx_ball, vy_ball)
        end
    end

    if py > love.graphics.getHeight() then
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

function level.keypressed(key)
    if key == "up" and player.jumps < 2 then
        player.jumps = player.jumps + 1

        local vx = 0
        if love.keyboard.isDown("right") or player.touchRight then vx = 350
        elseif love.keyboard.isDown("left") or player.touchLeft then vx = -350 end

        player.body:setLinearVelocity(vx, -500)

        for _, ball in ipairs(balls) do
            if ball.active then
                ball.body:setLinearVelocity(vx, -400)
            end
        end
    end
end

function level.draw()
    love.graphics.draw(background, 0, 0)

    local x, y = player.body:getPosition()
    local r = player.shape:getRadius()

    love.graphics.push()
    love.graphics.translate(
        love.graphics.getWidth() / 2 - x,
        love.graphics.getHeight() / 2 - y
    )

    love.graphics.draw(bush1, -900, 120, 0, 0.5, 0.5)

    love.graphics.setColor(1, 1, 1, fade)
    love.graphics.draw(welcomeText, textX, textY)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(1, 1, 1, fadeFall)
    love.graphics.draw(fallText, fallX, fallY)
    love.graphics.setColor(1, 1, 1, 1)

    local scale = (r * 4) / player.image:getWidth()
    local angle = player.body:getAngle() / 3
    local ox = player.image:getWidth() / 2
    local oy = player.image:getHeight() / 2
    love.graphics.draw(player.image, x, y - 22, angle, scale, scale, ox, oy)

    for _, ball in ipairs(balls) do
        local bx, by = ball.body:getPosition()
        local br = ball.shape:getRadius()
        local ball_angle = ball.body:getAngle()
        local ball_ox = ball.image:getWidth() / 2
        local ball_oy = ball.image:getHeight() / 2
        local ball_scale = (br * 2) / ball.image:getWidth()
        love.graphics.draw(ball.image, bx, by, ball_angle, ball_scale, ball_scale, ball_ox, ball_oy)
    end

    love.graphics.setColor(0.9, 0.7, 0.6, 1)
    local groundX, groundY = ground.body:getPosition()
    love.graphics.rectangle("fill", groundX - 1940, groundY - 10, (love.graphics.getWidth()*2) - 10, 800)

    love.graphics.setColor(0.9, 0.7, 0.6, 1)
    local ground2x, ground2y = ground2.body:getPosition()
    love.graphics.rectangle("fill", ground2x - 1900, ground2y - 10, (love.graphics.getWidth()*2) - 35, 800)

    local wallX, wallY = wall:getPosition()
    love.graphics.rectangle("fill", wallX - 1010, wallY - 500, 1000, 2500)

    local obs1X, obs1Y = obstacle1.body:getPosition()
    love.graphics.rectangle("fill", obs1X - 505, obs1Y - 100, 995, 450, 10, 10)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

return level