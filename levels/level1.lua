local level = {}

local touches = {}
local movingDir = 0
local camX, camY = 0,0

local sw = love.graphics.getWidth() --LARGURA DA TELA
local sh = love.graphics.getHeight() --ALTURA DA TELA

local checkpointX = sw/3
local checkpointY = (sh/2) * 1.6

function level.load()
    love.graphics.setDefaultFilter("linear","linear",64) -- FILTRO DE IMAGEM COM BLUR
    world = love.physics.newWorld(0, 1000, true)
    
    
    --ASSETS
    background = love.graphics.newImage("/assets/background.png")
    playerImg = love.graphics.newImage("/assets/bLob.png")
    lostPonkas = love.graphics.newImage("/assets/lostPonkas.png")
    bush = love.graphics.newImage("/assets/bush.png")

     -- PLAYER
    player = {}
    player.body = love.physics.newBody(world, checkpointX, checkpointY, "dynamic")
    player.shape = love.physics.newCircleShape(24)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.accel = 200
    player.jumps = 0

    -- TEXTO
    font = love.graphics.newFont(24)
    welcomeText = love.graphics.newText(font, "Slide the left side of your screen to move!")
    textX = sw/2
    textY = sh/2
    fade = 0
    fadeVel = 0.5

    font = love.graphics.newFont(24)
    jumpText = love.graphics.newText(font, "Touch on the right side to jump!")
    jumptextX = sw*1.3
    jumptextY = sh/2
    fade = 0
    fadeVel = 0.5

    -- CHÃO
    ground = {}
    local groundHeight = sh / 2
    ground.body = love.physics.newBody(world, sw/2, sh + groundHeight*0.2, "static")
    ground.shape = love.physics.newRectangleShape(sw*1.5, groundHeight)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setUserData({allowJump = true})

    --CHÃO(2)
    local gap = 200
    local ground1RightEdge = sw/2 + (sw * 1.5) / 2 -- PEGA O CANTO DIREITO DO CHÃO
    local ground2Width = sw
    local ground2X = ground1RightEdge + gap + ground2Width / 2

    ground2 = {}
    local ground2Height = sh / 2
    ground2.body = love.physics.newBody(world, ground2X, sh + groundHeight*0.2, "static")
    ground2.shape = love.physics.newRectangleShape(ground2Width, ground2Height)
    ground2.fixture = love.physics.newFixture(ground2.body, ground2.shape)
    ground2.fixture:setUserData({allowJump = true})

    -- WALL
    wall ={}
    wall.body = love.physics.newBody(world, -sw/2, sh/2, "static")
    wall.shape = love.physics.newRectangleShape(sw, sh)
    wall.fixture = love.physics.newFixture(wall.body, wall.shape)


    -- CALLBACKS
   world:setCallbacks(function(a, b, coll)
        local dataA, dataB = a:getUserData(), b:getUserData()
        if (a == player.fixture and dataB and dataB.allowJump) or 
           (b == player.fixture and dataA and dataA.allowJump) then
            player.jumps = 0
        end
    end)
end

function playerSpawn(x,y)
    player.body:setPosition(x,y)
    player.body:setLinearVelocity(0, 0)
    player.jumps = 0
end

function level.update(dt)
    world:update(dt)

    local x, y = player.body:getPosition()

    if (math.abs(x - textX) < sw/5) or (math.abs(x - jumptextX) < sw/5) then
        fade = fade + fadeVel * dt
    else
        fade = fade - fadeVel * dt
    end

    if fade > 1 then fade = 1 end
    if fade < 0 then fade = 0 end
            
    if y > sh then
        playerSpawn(checkpointX,checkpointY)
    end

    local vx, vy = player.body:getLinearVelocity()
    local speedMax = 500
    local accel = player.accel

    if love.keyboard.isDown("right") or movingDir == 1 then
        if vx < speedMax then vx = vx + accel * dt else vx = speedMax end
    elseif love.keyboard.isDown("left") or movingDir == -1 then
        if vx > -speedMax then vx = vx - accel * dt else vx = -speedMax end
    else
        vx = vx * 0.95
    end

    player.body:setLinearVelocity(vx, vy)

    local px, py = player.body:getPosition()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local targetX = px - sw / 2
    local targetY = py - sh / 2
    camX = camX + (targetX - camX) * 5 * dt
    camY = camY + (targetY - camY) * 5 * dt
end

function level.keypressed(key)
    if key == "up" and player.jumps < 2 then
        player.jumps = player.jumps + 1

        local vx = 0
        if love.keyboard.isDown("right") then vx = 350
        elseif love.keyboard.isDown("left") then vx = -350 end

        player.body:setLinearVelocity(vx, -500)

    end

    if key == "r" then
        playerSpawn(checkpointX, checkpointY)
    end

end

function level.touchpressed(id, x, y)
    local sw = love.graphics.getWidth()

    if x < sw / 2 then --SÓ PEGA O MOVIMENTO NA ESQUERDA DA TELA
        touches[id] = {x = x, side = "move"}
    else -- SÓ PEGA O MOVIMENTO NA PARTE DIREITA DA TELA
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
    --GUIDE
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill",0,0,sw/2,sh)

    -- FUNDO
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, sw/background:getWidth(), sh/background:getHeight())

   

    -- CAMERA
    love.graphics.push()
    love.graphics.translate(-camX, 0)

     -- BUSH
    local bs = sw*0.25
    local scale = bs / bush:getWidth()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(bush, sw/2, sh*0.65, 0, scale, scale)

    -- CHAO
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- CHAO 2
    love.graphics.setColor(0.8, 0.7, 0.6)
    love.graphics.polygon("fill", ground2.body:getWorldPoints(ground2.shape:getPoints()))

    love.graphics.setColor(0.8,0.7,0.6)
    love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))


love.graphics.setColor(1, 1, 1, fade)

    love.graphics.draw(
        welcomeText,
        textX - welcomeText:getWidth()/2,
        textY - welcomeText:getHeight()/2
    )


    love.graphics.draw(
        jumpText,
        jumptextX - welcomeText:getWidth()/2,
        jumptextY - welcomeText:getHeight()/2
    )

    love.graphics.setColor(1, 1, 1)

    -- Player
    local px, py = player.body:getPosition()
    local pScale = (player.shape:getRadius() * 2.5) / playerImg:getWidth()
    love.graphics.draw(playerImg, px, py, player.body:getAngle(), pScale, pScale, playerImg:getWidth()/2, playerImg:getHeight()/2)

    love.graphics.pop()
end

return level