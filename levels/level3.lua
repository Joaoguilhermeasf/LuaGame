local level = {}

local touches = {}
local movingDir = 0
local camX, camY = 0, 0

local sw = love.graphics.getWidth()  --LARGURA DA TELA
local sh = love.graphics.getHeight() --ALTURA DA TELA

local checkpointX = -800
local checkpointY = -100
local xJump = 0
local movePlat = false
local checkpointX = sw/2
local checkpointY = (sh/2) * 1.6

local inWater = false  -- flag para saber se player está na água

-- ==============================
-- SPAWN DE BOLA
-- ==============================
function spawnBall(x, y)
    local b = {}
    b.body    = love.physics.newBody(world, x, y, "dynamic")
    b.shape   = love.physics.newCircleShape(math.random(10, 20))
    b.fixture = love.physics.newFixture(b.body, b.shape)
    b.img     = lostPonkas
    b.fixture:setFriction(0.5)
    b.body:setAngularDamping(1)
    b.body:setLinearDamping(0.5)
    b.accel   = 190
    b.jumps   = 0
    b.active  = false
    b.hasJumped = false
    table.insert(balls, b)
    return b
end

-- ==============================
-- LOAD
-- ==============================
function level.load()
    love.graphics.setDefaultFilter("linear", "linear", 64)
    world = love.physics.newWorld(0, 1000, true)

    -- ASSETS
    background = love.graphics.newImage("/assets/background.png")
    playerImg = love.graphics.newImage("/assets/bLob.png")
    lostPonkas = love.graphics.newImage("/assets/lostPonkas.png")
    ponka = love.graphics.newImage("/assets/ponka.png")
    bush = love.graphics.newImage("/assets/bush.png")

    -- PLAYER
    player = {}
    player.body = love.physics.newBody(world, 100, 200, "dynamic") --Onde o palyer vai spaenar
    player.shape = love.physics.newCircleShape(24)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.accel = 200
    player.jumps = 0


    -- BOLAS (posições baseadas no mapa)
    balls = {}
    spawnBall(sw * 0.15, sh * 0.1)   -- primeira bola
    spawnBall(sw * 1.13, - sh * 0.4)   -- segunda bola
    spawnBall(sw * 0.7, sh * 0.2)   -- terceira bola

    -- FONTE
    font = love.graphics.newFont(20)

    -- ==============================
    -- PLATAFORMAS (amarelas)
    -- Cada entrada: {cx, cy, w, h}
    -- cx/cy = centro; w/h = largura/altura
    -- Coordenadas em proporção da tela para se adaptar a qualquer resolução
    -- ==============================
    platforms = {}
    local function addPlat(cx, cy, w, h, jump)
        local p = {}
        p.body    = love.physics.newBody(world, cx, cy, "static")
        p.shape   = love.physics.newRectangleShape(w, h)
        p.fixture = love.physics.newFixture(p.body, p.shape)
        p.fixture:setFriction(0.8)
        p.fixture:setUserData({ allowJump = jump, type = "ground" })
        p.w, p.h  = w, h
        table.insert(platforms, p)
    end

    -- Parede esquerda
    addPlat(-sw*0.8,  sh*0.8,   sw/2, sh*3, false) --Localização, localização, Largura penultimo

    -- ==========================
    -- INICIO PRIMEIRO PISO
    -- ==========================
    -- Bloco topo esquerdo (plataforma inicial)
    addPlat(-sw*0.5,   sh*0.05,  sw*0.5, sh*0.1, true) -- quanto 1>y, mais alto fica
    
    -- Bloco BASE DO TOPO
    addPlat(-sw*0.4,   sh*0.1,  sw*3.9, sh*0.02, true)
    
    -- Blocos do primeiro salto
    addPlat(sw*0.04,   -sh*0.05,  sw*0.1, sh*0.3, true) -- Parede primeiro salto
    addPlat(-sw*0.01,   -sh*0.05,  sw*0.001, sh*0.3, false) -- Antipulo da parede
    addPlat(sw*0.25, -sh*0.14, sw*0.4, sh*0.12, true) -- Parte de cima caverna
    addPlat(sw*0.75,   sh*0.05,  sw*0.08, sh*0.1, true) -- Parede pós cavenar (Priemiro piscina)
    addPlat(sw*1.13,   -sh*0.095,  sw*0.3, sh*0.04, true) -- Plataforma cima da psicina
    addPlat(sw*1.51,   sh*0.05,  sw*0.08, sh*0.1, true) -- Parede fim piscina
    -- ===========================
    -- FIM PRIMEIRO PISO
    -- ===========================
   
    -- ==========================
    -- INICIO SEGUNDO PISO
    -- ==========================
    addPlat(sw*1.4,   sh*0.7,   sw*0.9,    sh*0.09, true) -- Local onde começa
    addPlat(sw*0.7,   sh*0.58,  sw*0.211,  sh*0.03, true) -- Plat sobre a lava
    addPlat(sw*0.15,  sh*0.7,   sw*0.66,   sh*0.09, true) -- Base do local pós lava

    addPlat(sw*0.4744, sh*0.65,  sw*0.011, sh*0.1,  true) --Bloco de segurança pós lava

    addPlat(sw*0.07,  sh*0.62, sw*0.5,    sh*0.18,  true) --Primeiro degrau
    addPlat(sw*0.001, sh*0.5,  sw*0.362,  sh*0.18,  true) --Segundo degrau
    addPlat(-sw*0.08, sh*0.37,  sw*0.2,  sh*0.18,  true) --Terceiro degrau
    -- ==========================
    -- FIM SEGUNDO PISO
    -- ==========================

    -- ==========================
    -- INICIO TERCEIRO PISO
    -- ==========================
    addPlat(-sw*0.2, sh*1.5, sw*0.8, sh*0.7, true) --Primeiro piso, ond cai
    addPlat(sw, sh*1.55, sw*1.8, sh*0.5, true) -- Plataforma em baixo meio
    addPlat(sw*0.5,   sh*1.16,  sw*0.216,  sh*0.03, true) -- Priemira plataforma flutuante
    addPlat(sw*0.9,   sh*1.1,  sw*0.216,  sh*0.03, true) -- Segunda plataforma flutuante
    addPlat(sw*1.3,   sh*1.06,  sw*0.216,  sh*0.03, true) -- Terceira plataforma flutuante

    addPlat(sw*1.7,   sh*1.15,  sw*0.4,  sh*0.4, true) -- Plataforma final
    -- ==========================
    -- FIM TERCEIRO PISO
    -- ==========================

    -- Parede direita
    addPlat(sw*2.2,   sh*0.5,   sw*0.7, sh*3, false)

    -- ==============================
    -- ÁGUA (sensor — não bloqueia, só detecta)
    -- ==============================
    water = {}
    water.x = sw * 0.79
    water.y = sh * 0.035
    water.w = sw * 0.68
    water.h = sh * 0.055
    water.body    = love.physics.newBody(world, water.x + water.w/2, water.y + water.h/2, "static")
    water.shape   = love.physics.newRectangleShape(water.w, water.h)
    water.fixture = love.physics.newFixture(water.body, water.shape)
    water.fixture:setSensor(true)   -- não tem colisão sólida
    water.fixture:setUserData({ type = "water" })

    -- ==============================
    -- LAVA (sensor — não bloqueia, mata)
    -- ==============================
    lava = {}
    lava.x = sw * 0.48
    lava.y = sh * 0.724
    lava.w = sw * 0.47
    lava.h = sh * 0.018
    lava.body    = love.physics.newBody(world, lava.x + lava.w/2, lava.y + lava.h/2, "static")
    lava.shape   = love.physics.newRectangleShape(lava.w, lava.h)
    lava.fixture = love.physics.newFixture(lava.body, lava.shape)
    lava.fixture:setSensor(true)
    lava.fixture:setUserData({ type = "lava" })

    -- ==============================
    -- CALLBACKS DE COLISÃO
    -- ==============================
    world:setCallbacks(
        function(a, b, coll)
            local dataA = a:getUserData()
            local dataB = b:getUserData()
 
            -- Resetar pulos ao tocar chão
            if (a == player.fixture and dataB and dataB.allowJump) or
               (b == player.fixture and dataA and dataA.allowJump) then
                player.jumps = 0
            end
 
            -- Entrar na água
            if (a == player.fixture and dataB and dataB.type == "water") or
               (b == player.fixture and dataA and dataA.type == "water") then
                inWater = true
            end
 
            -- Tocar lava → agenda respawn (não pode chamar direto no callback)
            if (a == player.fixture and dataB and dataB.type == "lava") or
               (b == player.fixture and dataA and dataA.type == "lava") then
                needsRespawn = true
            end
 
            -- Tocar bola → ativar (igual level1)
            for _, ball in ipairs(balls) do
                if (a == player.fixture and b == ball.fixture) or
                   (b == player.fixture and a == ball.fixture) then
                    ball.img    = ponka
                    ball.active = true
                end
            end
        end,
 
        function(a, b, coll)
            local dataA = a:getUserData()
            local dataB = b:getUserData()
 
            -- Sair da água
            if (a == player.fixture and dataB and dataB.type == "water") or
               (b == player.fixture and dataA and dataA.type == "water") then
                inWater = false
            end
        end
    )
 
    -- Estado inicial da câmera
    local px, py = player.body:getPosition()
    camX = px - sw / 2
    camY = py - sh / 2
end
 
-- ==============================
-- RESPAWN
-- ==============================
function respawnPlayer()
    player.body:setPosition(-800, -100)
    player.body:setLinearVelocity(0, 0)
    player.body:setAngularVelocity(0)
    player.jumps = 0
    inWater = false
end
 
-- ==============================
-- UPDATE
-- ==============================
function level.update(dt)
    world:update(dt)
 
    local px, py = player.body:getPosition()
 
    -- Respawn agendado pela lava (não pode rodar dentro do callback)
    if needsRespawn then
        needsRespawn = false
        respawnPlayer()
        return
    end

    -- Caiu fora da tela → respawn
    if py > sh * 2 then
        respawnPlayer()
        return
    end

     -- ==============================
     --            BOLAS
     -- ==============================
     -- seguir o player quando ativas
    for _, b in ipairs(balls) do
        local bx, by = b.body:getPosition()

 
        -- Respawn da bola se cair
        if by > sh then
            b.body:setPosition(checkpointX, checkpointY)
            b.body:setLinearVelocity(0, 0)
            b.active = false
            b.img    = lostPonkas
        end
 
        -- Seguir o player horizontalmente
        if b.active then
            local bvx, bvy = b.body:getLinearVelocity()
            if (px - bx) > sh / 5 then
                bvx = math.min(bvx + b.accel * dt, 1600)
            elseif (px - bx) < -sh / 5 then
                bvx = math.max(bvx - b.accel * dt, -1600)
            else
                bvx = bvx * 0.95
            end
            b.body:setLinearVelocity(bvx, bvy)
        end
    end
     -- ==============================
     --          FIM  BOLAS
     -- ==============================
 

 
    player.body:setLinearVelocity(vx, vy)
 
    -- Câmera suave (lerp)
    local targetX = px - sw / 2
    local targetY = py - sh / 2
    camX = camX + (targetX - camX) * 5 * dt
    camY = camY + (targetY - camY) * 5 * dt
end
 
-- ==============================
-- KEYPRESSED
-- ==============================
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

        player.body:setLinearVelocity(vx, -500)

    end

    if key == "r" then
        love.draw()
        respawnPlayer()
    end
end
 
-- ==============================
-- INPUT TOUCH
-- ==============================
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
 
function level.touchreleased(id, x, y)
    touches[id] = nil
    if next(touches) == nil then movingDir = 0 end
end
 
-- ==============================
-- DRAW
-- ==============================
function level.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
 
    -- Fundo
    love.graphics.setColor(0.44, 0.82, 0.91)
    love.graphics.rectangle("fill", 0, 0, sw, sh)
 
    love.graphics.push()
    love.graphics.translate(-camX, -camY, 0)
 
    -- PLATAFORMAS
    love.graphics.setColor(0.93, 0.75, 0.35)
    for _, p in ipairs(platforms) do
        local x, y = p.body:getPosition()
        love.graphics.rectangle("fill", x - p.w/2, y - p.h/2, p.w, p.h, 6, 6)
    end
 
    -- ÁGUA
    do
        love.graphics.setColor(0.10, 0.30, 0.90, 0.55)
        love.graphics.rectangle("fill", water.x, water.y, water.w, water.h, 4, 4)
        love.graphics.setColor(0.40, 0.65, 1.0, 0.8)
        local t = love.timer.getTime()
        local steps = 12
        local segW = water.w / steps
        for i = 0, steps - 1 do
            local wx = water.x + i * segW
            local wy = water.y + 4 + math.sin(t * 3 + i * 0.8) * 3
            love.graphics.rectangle("fill", wx, wy, segW - 1, 3, 2, 2)
        end
    end
 
    -- LAVA
    do
        local t = love.timer.getTime()
        local pulse = 0.7 + 0.3 * math.sin(t * 6)
        love.graphics.setColor(1.0, 0.18 * pulse, 0.0, 1)
        love.graphics.rectangle("fill", lava.x, lava.y, lava.w, lava.h, 3, 3)
        love.graphics.setColor(1.0, 0.8, 0.2, pulse)
        love.graphics.rectangle("fill", lava.x + 4, lava.y + lava.h*0.3,
                                  lava.w - 8, lava.h * 0.35, 2, 2)
    end
 
    -- BOLAS (sempre visíveis, mudam de imagem ao serem ativadas)
    for _, b in ipairs(balls) do
        local bx, by = b.body:getPosition()
        local sc = (b.shape:getRadius() * 2.5) / b.img:getWidth()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(b.img, bx, by, b.body:getAngle(),
            sc, sc, b.img:getWidth()/2, b.img:getHeight()/2)
    end
 
    -- PLAYER
    do
        local px, py = player.body:getPosition()
        local sc = (player.shape:getRadius() * 2.5) / playerImg:getWidth()
        if inWater then
            love.graphics.setColor(1, 1, 1, 0.5)
            local t = love.timer.getTime()
            love.graphics.circle("fill", px - 10, py - 20 + math.sin(t*4)*4, 4)
            love.graphics.circle("fill", px + 8,  py - 28 + math.sin(t*3)*3, 3)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(playerImg, px, py, player.body:getAngle(),
            sc, sc, playerImg:getWidth()/2, playerImg:getHeight()/2)
    end
 
    love.graphics.pop()
 
    -- Indicador de água
    if inWater then
        love.graphics.setColor(0.10, 0.30, 0.90, 0.25)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf("~ água ~", 0, sh * 0.08, sw, "center")
    end
end
 
return level