local level = {}

local touches = {}
local movingDir = 0
local camX, camY = 0,0

local sw = love.graphics.getWidth()
local sh = love.graphics.getHeight()

local xJump = 0
local movePlat = false
local checkpointX = sw*2
local checkpointY = (sh/2) * 1.6

local PLAT_SCALE = 2
local BUTTON_SCALE = 2

endLevelX, endLevelY = 0, 0

function spawnBall(x, y)
    local b = {}
    b.body    = love.physics.newBody(world, x, y, "dynamic")
    b.shape   = love.physics.newCircleShape(math.random(10,20))
    b.fixture = love.physics.newFixture(b.body, b.shape)
    b.img     = lostPonkas
    b.fixture:setFriction(0.5)
    b.body:setAngularDamping(1)
    b.body:setLinearDamping(0.5)
    b.accel     = 190
    b.jumps     = 0
    b.active    = false
    b.goingHome = false
    b.dead      = false
    table.insert(balls, b)
    return b
end

function level.load()
    love.graphics.setDefaultFilter("linear","linear",64)
    world = love.physics.newWorld(0, 1000, true)

    -- ASSETS
    background = love.graphics.newImage("/assets/background.png")
    biggie     = love.graphics.newImage("/assets/biggie.png")
    playerImg  = love.graphics.newImage("/assets/bLob.png")
    playerImg2 = love.graphics.newImage("/assets/bLob2.png")
    lostPonkas = love.graphics.newImage("/assets/lostPonkas.png")
    ponka      = love.graphics.newImage("/assets/ponka.png")
    bush       = love.graphics.newImage("/assets/bush.png")
    foot       = love.graphics.newImage("/assets/foot.png")
    mom1       = love.graphics.newImage("/assets/mom1.png")
    mom2       = love.graphics.newImage("/assets/mom2.png")
    houseImg = mom1

    -- PLAYER
    player = {}
    player.body    = love.physics.newBody(world, checkpointX, checkpointY, "dynamic")
    player.shape   = love.physics.newCircleShape(24)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.accel   = 200
    player.jumps   = 0
    player.img     = playerImg
    player.flipTimer = math.random(10, 15) / 100

    -- TEXTO
    font = love.graphics.newFont(24)

    welcomeText = love.graphics.newText(font, "Slide the left side of your screen to move!")
    textX = sw/2
    textY = sh/2
    fade = 0
    fadeVel = 0.5

    jumpText = love.graphics.newText(font, "Touch on the right side to jump!")
    jumptextX = sw*1.3
    jumptextY = sh/2
    fadeJ = 0
    fadeJVel = 0.5

    -- CHÃO 1
    ground = {}
    local groundHeight = sh / 2
    ground.body    = love.physics.newBody(world, sw/2, sh + groundHeight*0.2, "static")
    ground.shape   = love.physics.newRectangleShape(sw*2, groundHeight)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData({allowJump = true})

    -- CHÃO 2
    local gap = 200
    local ground2Width = sw * 1.5
    local ground2Height = sh / 2
    local ground1RightEdge = sw/2 + (sw * 2) / 2
    local ground2X = ground1RightEdge + gap + ground2Width / 2

    ground2 = {}
    ground2.body    = love.physics.newBody(world, ground2X, sh + groundHeight*0.2, "static")
    ground2.shape   = love.physics.newRectangleShape(ground2Width, ground2Height)
    ground2.fixture = love.physics.newFixture(ground2.body, ground2.shape)
    ground2.fixture:setUserData({allowJump = true})

    -- PLATAFORMA
    local baseH = sh
    local baseW = baseH * (biggie:getWidth() / biggie:getHeight())  
    
    plat = {}
    plat.w = baseW * PLAT_SCALE
    plat.h = baseH * PLAT_SCALE
     platX, platY = ground2.body:getPosition()

    plat.body = love.physics.newBody(world, platX, platY*0.4, "kinematic")

    local w = plat.w * 0.7
    local h = plat.h
    local r = sw/10 -- RAIO DOS CANTOS

    plat.fixtures = {}

    local rectShape = love.physics.newRectangleShape(w - 2*r, h)
    local rectFix = love.physics.newFixture(plat.body, rectShape)
    rectFix:setUserData({allowJump = true})
    table.insert(plat.fixtures, rectFix)

    local sideLeft  = love.physics.newRectangleShape(-w/2 + r/2, 0, r, h - 2*r)
    local sideRight = love.physics.newRectangleShape( w/2 - r/2, 0, r, h - 2*r)

    for _, shape in ipairs({sideLeft, sideRight}) do
        local fix = love.physics.newFixture(plat.body, shape)
        fix:setUserData({allowJump = true})
        table.insert(plat.fixtures, fix)
    end

    local corners = {
        { w/2 - r,  h/2 - r},
        {-w/2 + r,  h/2 - r},
        { w/2 - r, -h/2 + r},
        {-w/2 + r, -h/2 + r},
    }

    for _, c in ipairs(corners) do
        local shape = love.physics.newCircleShape(c[1], c[2], r)
        local fix = love.physics.newFixture(plat.body, shape)
        fix:setUserData({allowJump = true})
        table.insert(plat.fixtures, fix)
    end

    plat.speed = 300

    -- O OLHO QUE SEGUE O PLAYER
    eye = {}
    eye.x, eye.y = plat.body:getPosition()
    eye.y = eye.y * (-0.4)

    eye.offsetX1 = -(sw/10)
    eye.offsetX2 =  (sw/10)
    eye.offsetY  = -(sw/10)

    -- BALLS
    balls = {}
    pX, pY = plat.body:getPosition()

    local b = spawnBall(pX, pY - sh)

    -- BUTTON
    local bw = sh/10
    local pX2, pY2 = plat.body:getPosition()

    button = {}
    button.w = (bw*1.5) * BUTTON_SCALE
    button.h = bw * BUTTON_SCALE

    buttonX = pX2 - plat.w/2
    buttonY = (sh + (sh/2)*0.2) - (sh/2)/2 - button.h/2

    button.body    = love.physics.newBody(world, buttonX*1.001, buttonY, "kinematic")
    button.shape   = love.physics.newRectangleShape(button.w, button.h)
    button.fixture = love.physics.newFixture(button.body, button.shape)
    button.fixture:setUserData({allowJump = true})

    -- WALL
    wall = {}
    wall.body    = love.physics.newBody(world, -sw/2, sh/2, "static")
    wall.shape   = love.physics.newRectangleShape(sw, sh*4)
    wall.fixture = love.physics.newFixture(wall.body, wall.shape)

    -- HOUSE OLHO
    houseEye = {}
    houseEye.offsetX1 = -sw/50
    houseEye.offsetX2 =  sw/50
    houseEye.offsetY  = -sh/18

    -- CALLBACKS
    world:setCallbacks(function(a, b, coll)
        local dataA, dataB = a:getUserData(), b:getUserData()

        -- botão ativa plataforma
        if (a == player.fixture and b == button.fixture) or
           (b == player.fixture and a == button.fixture) then
            movePlat = true
        end

        -- reset de pulo player
        if (a == player.fixture and dataB and dataB.allowJump) or
           (b == player.fixture and dataA and dataA.allowJump) then
            player.jumps = 0
        end

        -- ativar balls ao tocar player
        for _, ball in ipairs(balls) do
            if (a == player.fixture and b == ball.fixture) or
               (b == player.fixture and a == ball.fixture) then
                if ball.active == false then
                ball.img    = ponka
                ball.active = true
                else
                ball.img    = lostPonkas
                ball.active = false
                end
            end
        end
    end)

    -- END LEVEL
    local g2x, g2y = ground2.body:getPosition()
    local houseW = sw / 5
    local houseH = sh / 5

    endLevelX = g2x + ground2Width/2 - houseW/2
    endLevelY = g2y - ground2Height/2 - houseH/2
end

function playerSpawn(x, y, ent)
    tp = ent
    tp.body:setPosition(x, y)
    tp.body:setLinearVelocity(0, 0)
    tp.body:setAngularVelocity(0)
    tp.jumps = 0
    if tp == "ball" then
        tp.img = lostPonkas
    end
end

function level.update(dt)
    world:update(dt)

    local x, y = player.body:getPosition()

    player.flipTimer = player.flipTimer - dt
    if player.flipTimer <= 0 then
        if player.img == playerImg then
            player.img = playerImg2
        else
            player.img = playerImg
        end
        player.flipTimer = math.random(10, 15) / 100
    end

    if math.abs(x - textX) < sw/5 then
        fade = math.min(fade + fadeVel * dt, 1)
    else
        fade = math.max(fade - fadeVel * dt, 0)
    end

    if math.abs(x - jumptextX) < sw/5 then
        fadeJ = math.min(fadeJ + fadeJVel * dt, 1)
    else
        fadeJ = math.max(fadeJ - fadeJVel * dt, 0)
    end

    if y > sh then
        playerSpawn(checkpointX, checkpointY, player)
    end

    if movePlat then
        local px, py = plat.body:getPosition()

        local limitY = sh*1.15

        if py < limitY then
            plat.body:setLinearVelocity(0, plat.speed)
        else
            plat.body:setLinearVelocity(0, 0)
        end

        if py < limitY then
            eye.y = eye.y + plat.speed * dt
        end

    end

    -- BOLAS
    local someoneNearHouse = false

    for _, b in ipairs(balls) do
        local bx, by = b.body:getPosition()

        if by > sh then
            local px, py = plat.body:getPosition()
            local safeY = py - plat.h/2 - b.shape:getRadius() - 10
            b.body:setPosition(px, safeY)
            b.body:setLinearVelocity(0,0)
            b.body:setAngularVelocity(0)
            b.body:setBullet(true)

            b.active    = false
            b.goingHome = false
            b.img       = lostPonkas
            b.body:setGravityScale(1)
        end

        local dx   = endLevelX - bx
        local dy   = endLevelY - by
        local dist = math.sqrt(dx*dx + dy*dy)

        -- 🔥 ativa automaticamente perto da house
        if not b.active and dist < sw * 0.3 then
            b.active = true
            b.img = ponka
        end

        if dist < sw * 0.3 then
            b.goingHome = true
            someoneNearHouse = true
        end

        if b.active then
            local bvx, bvy = b.body:getLinearVelocity()

            if b.goingHome then
                b.fixture:setSensor(true)
                if dist < 12 then
                    b.dead = true  
                else
                    local speed = 400
                    b.body:setLinearVelocity((dx/dist)*speed, (dy/dist)*speed)
                    b.body:setGravityScale(0)  
                end
            else
                if (x - bx) > sh/5 then
                    bvx = math.min(bvx + b.accel * dt, 1600)
                elseif (x - bx) < -sh/5 then
                    bvx = math.max(bvx - b.accel * dt, -1600)
                else
                    bvx = bvx * 0.95
                end
                b.body:setLinearVelocity(bvx, bvy)
            end
        end
    end

    -- 🔥 troca imagem da house
    if someoneNearHouse then
        houseImg = mom2
    else
        houseImg = mom1
    end

    for i = #balls, 1, -1 do
        if balls[i].dead then
            balls[i].body:destroy()
            table.remove(balls, i)
        end
    end

    local vx, vy   = player.body:getLinearVelocity()
    local speedMax = 500
    local accel    = player.accel

    if love.keyboard.isDown("right") or movingDir == 1 then
        if vx < speedMax then vx = vx + accel * dt else vx = speedMax end
    elseif love.keyboard.isDown("left") or movingDir == -1 then
        if vx > -speedMax then vx = vx - accel * dt else vx = -speedMax end
    else
        vx = vx * 0.95
    end

    player.body:setLinearVelocity(vx, vy)

    local px, py  = player.body:getPosition()
    local sw, sh  = love.graphics.getWidth(), love.graphics.getHeight()
    local targetX = px - sw / 2
    local targetY = py - sh / 2
    camX = camX + (targetX - camX) * 5 * dt
    camY = camY + (targetY - camY) * 5 * dt
end

function level.keypressed(key)
    if key == "up" and player.jumps < 2 then
        xJump, _ = player.body:getPosition()

        for _, b in ipairs(balls) do
            b.hasJumped = false
        end

        player.jumps = player.jumps + 1

        local vx = 0
        if love.keyboard.isDown("right") then vx = 350
        elseif love.keyboard.isDown("left") then vx = -350 end

        player.body:setLinearVelocity(vx, -900)
    end

    if key == "r" then
        love.draw()
        playerSpawn(checkpointX, checkpointY, player)
    end
end

function love.touchpressed(id, x, y)
    local sw = love.graphics.getWidth()

    if x < sw / 2 then
        touches[id] = {x = x, side = "move"}
    else
        touches[id] = {x = x, side = "jump"}
        if player.jumps < 2 then
            xJump, _ = player.body:getPosition()

            for _, b in ipairs(balls) do
                b.hasJumped = false
            end

            player.jumps = player.jumps + 1
            local vx, vy = player.body:getLinearVelocity()
            player.body:setLinearVelocity(vx, -650)
        end
    end
end

function love.touchmoved(id, x, y)
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

function love.touchreleased(id, x, y)
    touches[id] = nil
    if next(touches) == nil then
        movingDir = 0
    end
end

local function drawEye(eyeX, eyeY, targetX, targetY, eyeRadius, pupilRadius)
    local dx = targetX - eyeX
    local dy = targetY - eyeY

    local dist = math.sqrt(dx*dx + dy*dy)
    if dist ~= 0 then
        dx = dx / dist
        dy = dy / dist
    end

    local maxOffset = eyeRadius - pupilRadius

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", eyeX, eyeY, eyeRadius)

    local pupilX = eyeX + dx * maxOffset
    local pupilY = eyeY + dy * maxOffset

    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", pupilX, pupilY, pupilRadius)
end

function level.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- GUIDE
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", 0, 0, sw/2, sh)

    -- FUNDO
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, sw/background:getWidth(), sh/background:getHeight())

    -- CAMERA
    love.graphics.push()
    love.graphics.translate(-camX, -math.min(camY, 0))

    -- BUSH
    local bs    = sw * 0.25
    local scale = bs / bush:getWidth()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bush, sw/2, sh*0.65, 0, scale, scale)

    -- CHÃO
    love.graphics.setColor(0.8, 0.7, 0.6)
    do
        local x, y = ground.body:getPosition()
        local w, h = sw*2, sh/2
        love.graphics.rectangle("fill", x - w/2, y - h/2, w, h, 20, 20)
    end

    

    -- PLATAFORMA
    love.graphics.setColor(1, 1, 1)
    do
        local x, y = plat.body:getPosition()
        local scale = plat.h / biggie:getHeight()

        -- desenha a imagem da plataforma
        love.graphics.draw(
            biggie,
            x, y,
            0,
            scale, scale,
            biggie:getWidth()/2,
            biggie:getHeight()/2
        )
    end

    local px, py = player.body:getPosition()

   drawEye(
    eye.x + eye.offsetX1,
    eye.y + eye.offsetY,
    px, py,
     sw/18,
        sw/36
    )

    drawEye(
        eye.x + eye.offsetX2,
        eye.y + eye.offsetY,
        px, py,
        sw/18,
        sw/36
    )

    -- CHÃO 2
    love.graphics.setColor(0.8, 0.7, 0.6)
    do
        local x, y = ground2.body:getPosition()
        local w, h = sw*1.5, sh/2
        love.graphics.rectangle("fill", x - w/2, y - h/2, w, h, 20, 20)
    end

    -- BUTTON
    love.graphics.setColor(1, 1, 1)
    do
        local x, y = button.body:getPosition()
        local sx = button.w / foot:getWidth()
        local sy = button.h / foot:getHeight()
        love.graphics.draw(foot, x, y, 0, sx, sy, foot:getWidth()/2, foot:getHeight()/2)
    end


    -- WALL
    love.graphics.setColor(0.8, 0.7, 0.6)
    do
        local x, y = wall.body:getPosition()
        local w, h = sw, sh*4
        love.graphics.rectangle("fill", x - w/2, y - h/2, w, h, 20, 20)
    end

    love.graphics.setColor(1, 1, 1)
   

    -- TEXTOS
    love.graphics.setColor(1, 1, 1, fade)
    love.graphics.draw(
        welcomeText,
        textX - welcomeText:getWidth()/2,
        textY - welcomeText:getHeight()/2
    )

    love.graphics.setColor(1, 1, 1, fadeJ)
    love.graphics.draw(
        jumpText,
        jumptextX - welcomeText:getWidth()/2,
        jumptextY - welcomeText:getHeight()/2
    )

    -- HOUSE (imagem)
    love.graphics.setColor(1,1,1)
    do
        local w, h = sw/5, sh/5

        local sx = w / houseImg:getWidth()
        local sy = h / houseImg:getHeight()

        love.graphics.draw(
            houseImg,
            endLevelX,
            endLevelY,
            0,
            sx,
            sy,
            houseImg:getWidth()/2,
            houseImg:getHeight()/2
        )
            local px, py
        for _, b in ipairs(balls) do
             px, py = b.body:getPosition()
        end
       

        -- posição base da house
        local hx = endLevelX
        local hy = endLevelY

        drawEye(
        hx + houseEye.offsetX1,
        hy + houseEye.offsetY,
        px, py,
        sw/90,
        sw/180
    )

    drawEye(
        hx + houseEye.offsetX2,
        hy + houseEye.offsetY,
        px, py,
        sw/90,
        sw/180
    )
    end
    

    

    love.graphics.setColor(1, 1, 1)

    -- PLAYER
    local px, py = player.body:getPosition()
    local pScale = (player.shape:getRadius() * 2.5) / playerImg:getWidth()
    love.graphics.draw(playerImg, px, py, player.body:getAngle(), pScale, pScale, playerImg:getWidth()/2, playerImg:getHeight()/2)

    -- BALLS
    for _, b in ipairs(balls) do
        local bx, by = b.body:getPosition()
        local bScale = (b.shape:getRadius() * 2.5) / lostPonkas:getWidth()
        love.graphics.draw(b.img, bx, by, b.body:getAngle(), bScale, bScale, lostPonkas:getWidth()/2, lostPonkas:getWidth()/2)
    end

    love.graphics.pop()
end

return level