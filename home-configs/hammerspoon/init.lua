local hyper = {"ctrl", "alt", "cmd"}
hs.window.animationDuration = 0.2

hs.alert.defaultStyle.fillColor = {hex = "#2f1e2e", alpha = 0.9}
hs.alert.defaultStyle.strokeColor = {hex = "#828282", alpha = 0.9}
hs.alert.defaultStyle.textColor = {hex = "#a39e9b", alpha = 0.9}
hs.alert.defaultStyle.textSize = 18

hs.loadSpoon("MiroWindowsManager")
hs.loadSpoon("WindowScreenLeftAndRight")
hs.loadSpoon("OpenApplication")
hs.loadSpoon("ScreenPresets")

hs.loadSpoon("MouseBackButton"):start()

-- Tap control for `escape` and hold for `control`
hs.loadSpoon("ControlEscape"):start()

-- A little window manager for pushing around windows with
-- the keyboard
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "space"},
})

-- Move windows from screen to screen
spoon.WindowScreenLeftAndRight:bindHotkeys({screen_left = {hyper, ","}, screen_right = {hyper, "."}})

spoon.OpenApplication:bindHotkeys(spoon.OpenApplication.defaultHotkeys)

-- https://www.hammerspoon.org/docs/hs.hotkey.html#bind
hs.hotkey.bind(hyper, "z", function()
  if hs.window.focusedWindow() then
    hs.window.frontmostWindow():toggleZoom()
  end
end)

-- watch for changes in the screens attached to the machine
spoon.ScreenPresets:setPresets({
  pademelon_work = {
    {
      id = "402D58C8-046B-82A8-CD93-2D5C7DCB94BB", -- Dell
      name = "DELL P2412H",
      resolution = {w = 1920, h = 1080},
      colourDepth = 8,
      scaling = 1,
      position = {x = 0.0, y = 0.0},
      rotation = 0,
    }, {
      id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3", -- Laptop screen
      name = "Color LCD",
      resolution = {w = 1680, h = 1050},
      colourDepth = 4,
      scaling = 2,
      position = {x = 1920.0, y = 387.0},
      rotation = 0,
    }, {
      id = "EEA3B508-6CD9-9ABF-3900-1777A3A46A91", -- Dell
      name = "DELL P2412H",
      resolution = {w = 1080, h = 1920},
      hz = 60,
      colourDepth = 8,
      scaling = 1,
      position = {x = -1080.0, y = -423.0},
      rotation = 90,
    },
  },
})
spoon.ScreenPresets:start()
