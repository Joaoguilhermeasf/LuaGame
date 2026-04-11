function love.conf(t)
    t.identity = "ponka"
    t.version = "11.4"

    t.window.title = "Ponka"

    t.window.width = 1920
    t.window.height = 1080
    t.window.highdpi = true
    t.window.usedpiscale = true
    t.window.resizable = true
    t.window.borderless = false
    t.window.fullscreen = true

    t.modules.physics = true
    t.modules.touch = true
    t.modules.graphics = true
end