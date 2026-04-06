local level = {}

function level.load()
    world = love.physics.newWorld(0, 1000, true) -- gravidade mais forte
    
    -- BACKGROUND
    background = love.graphics.newImage("/assets/background.png")

    -- GROUND
    ground = love.physics.newBody(world, 0, 400, "static")
    groundShape = love.physics.newRectangleShape(800, 20)
    groundFixture = love.physics.newFixture(ground, groundShape)

    ground2 = love.physics.newBody(world, 1200, 400, "static")
    ground2Shape = love.physics.newRectangleShape(800, 20)
    ground2Fixture = love.physics.newFixture(ground2, ground2Shape)

    wall = love.physics.newBody(world, -200, 0, "static")
    wallShape = love.physics.newRectangleShape(20,1000)
    wallFixture = love.physics.newFixture(wall, wallShape)


    -- PLAYER
    player = {}
    local px, py = ground:getPosition()
    player.body = love.physics.newBody(world, px + 10, py - 36, "dynamic")
    player.shape = love.physics.newCircleShape(25)
    player.image = love.graphics.newImage("/assets/bLob.png")
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setFriction(1)
    player.fixture:setRestitution(0.3)
    player.grounded = false
    player.jumps = 0

    -- BALL
    local num = math.random(5, 30)
    ball = {}
    ball.body = love.physics.newBody(world, 120, 380, "dynamic")
    ball.shape = love.physics.newCircleShape(num)
    ball.image = love.graphics.newImage("/assets/merpY.png")
    ball.fixture = love.physics.newFixture(ball.body, ball.shape)
    ball.fixture:setDensity(5)
    ball.body:resetMassData() 

    -- ARC
    local radius = 200
    local segments = 30
    local startAngle = 0
    local endAngle = math.pi

    points = {}
    for i = 0, segments do
        local angle = startAngle + (endAngle - startAngle) * (i / segments)
        table.insert(points, math.cos(angle) * radius)
        table.insert(points, math.sin(angle) * radius)
    end

    arcBody = love.physics.newBody(world, 600, 400, "static")
    arcShape = love.physics.newChainShape(false, unpack(points))
    arcFixture = love.physics.newFixture(arcBody, arcShape)

    -- CALLBACKS
    world:setCallbacks(
    function(a, b, coll) 
        if a == player.fixture or b == player.fixture then
            if (a == groundFixture or a == ground2Fixture) or (b == groundFixture or b == ground2Fixture) then
                player.grounded = true
                player.jumps = 0
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

function level.update(dt)
    world:update(dt)

    -- MOVIMENTO PLAYER
    local vx, vy = player.body:getLinearVelocity()
    if love.keyboard.isDown("right") then
        player.body:setLinearVelocity(350, vy)
    elseif love.keyboard.isDown("left") then
        player.body:setLinearVelocity(-350, vy)
    else
        player.body:setLinearVelocity(0, vy)
    end

    -- RESTART
    if love.keyboard.isDown("r") then
        level.load()
    end

    -- SEGUIR BOLA
    local x, y = player.body:getPosition()
    local bx, by = ball.body:getPosition()
    local vx_ball, vy_ball = ball.body:getLinearVelocity()

    -- horizontal: segue player
    if bx > x + 100 then
        vx_ball = -100
    elseif bx < x - 100 then
        vx_ball = 100
    else
        vx_ball = 0
    end

    ball.body:setLinearVelocity(vx_ball, vy_ball)

    if vy > love.graphics.getHeight() then

           level.load() 

    end

end

function level.keypressed(key)
    if key == "up" and player.jumps < 2 then
        player.jumps = player.jumps + 1

        local vx = 0
        if love.keyboard.isDown("right") then vx = 350
        elseif love.keyboard.isDown("left") then vx = -350 end

        -- PULAR PLAYER
        player.body:setLinearVelocity(vx, -500)

        -- PULAR BOLA (menor impulso)
        local _, vy_ball = ball.body:getLinearVelocity()
        ball.body:setLinearVelocity(vx, -400)
    end
end

function level.draw()
    love.graphics.draw(background, 0, 0)
  
  
    
    local x, y = player.body:getPosition()
    local r = player.shape:getRadius()

    -- CAMERA

    love.graphics.push()
    love.graphics.translate(
        love.graphics.getWidth()/2 - x,
        love.graphics.getHeight()/2 - y
    )

    -- PLAYER

    local scale = (r * 4) / player.image:getWidth()

    local angle = player.body:getAngle() / 3
    local ox = player.image:getWidth() / 2
    local oy = player.image:getHeight() / 2

    love.graphics.draw(player.image, x, y-22, angle, scale, scale, ox, oy)
    
    -- BALL
    local bx, by = ball.body:getPosition()
    local br = ball.shape:getRadius()
    local ball_angle = ball.body:getAngle() 
    local ball_ox = ball.image:getWidth() / 2
    local ball_oy = ball.image:getHeight() / 2
    local ball_scale = (br * 2) / ball.image:getWidth()

    love.graphics.draw(ball.image, bx, by, ball_angle, ball_scale, ball_scale, ball_ox, ball_oy)

    -- OBJECTS
    

    -- GROUND
    local groundX, groundY = ground:getPosition()
    love.graphics.rectangle("fill", groundX - 400, groundY - 10, 800, 800)

    local ground2X, ground2Y = ground2:getPosition()
    love.graphics.rectangle("fill", ground2X - 400, ground2Y - 10, 800, 800)

    local wallX, wallY = wall:getPosition()
      love.graphics.rectangle("fill", wallX-1030, wallY -500, 1000, 2500)


    -- ARC
    local ax, ay = arcBody:getPosition()
    love.graphics.push()
    love.graphics.translate(ax, ay)
    love.graphics.line(points)
    love.graphics.pop()

    love.graphics.pop()
end

return level