function love.conf(t)
    t.window = t.window or t.screen

    -- Set window/screen flags here.
    t.window.width = 800
    t.window.height = 800

    t.screen = t.screen or t.window
end