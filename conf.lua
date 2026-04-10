function love.conf(t)
    t.identity = "ponka"
    t.version = "11.4"

    t.window.title = "Ponka High Res"

    t.window.width = 1280
    t.window.height = 720
    t.window.highdpi = true
    t.window.usedpiscale = true
    t.window.resizable = true
    t.window.borderless = false
    t.window.fullscreen = false

    t.modules.physics = true
    t.modules.touch = true
    t.modules.graphics = true
end