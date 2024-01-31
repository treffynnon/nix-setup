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

hs.loadSpoon("BehringerUCA222"):start()

-- A little window manager for pushing around windows with
-- the keyboard
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "space"},
  nextscreen = {hyper, "n"},
})

-- Move windows from screen to screen
spoon.WindowScreenLeftAndRight:bindHotkeys({screen_left = {hyper, ","}, screen_right = {hyper, "."}})

spoon.OpenApplication:bindHotkeys(spoon.OpenApplication.defaultHotkeys)

-- https://www.hammerspoon.org/docs/hs.hotkey.html#bind
hs.hotkey.bind(hyper, "z", function()
  if hs.window.focusedWindow() then hs.window.frontmostWindow():toggleZoom() end
end)

-- watch for changes in the screens attached to the machine
spoon.ScreenPresets:setPresets({
  pademelon_work = {
    {
      id = "29024FE7-925B-A34D-85B1-81674DCEA3C1",
      name = "DELL P2719H",
      origin = {x = 0.0, y = 0.0},
      resolution = {h = 1920, w = 1080},
      rotation = 270,
      scaling = 1.0,
    }, {
      id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3",
      name = "Color LCD",
      origin = {x = 1080.0, y = 1207.0},
      resolution = {h = 1050, w = 1680},
      rotation = 0,
      scaling = 2.0,
    }, {
      id = "FA6C6ED8-1160-EFE5-5696-78F1AFC5184E",
      name = "DELL P2719H",
      origin = {x = -1920.0, y = 483.0},
      resolution = {h = 1080, w = 1920},
      rotation = 0,
      scaling = 1.0,
    },
  },
  pademelon_home = {
    {
      id = "662C50EE-BF07-E4F4-7EFB-0DC98939812E",
      name = "Philips 221V",
      origin = {x = 0.0, y = 0.0},
      resolution = {h = 1080, w = 1920},
      rotation = 0,
      scaling = 1.0,
    }, {
      id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3",
      name = "Color LCD",
      origin = {x = 520.0, y = 1080.0},
      resolution = {h = 800, w = 1280},
      rotation = 0,
      scaling = 2.0,
    }, {
      id = "D857386D-1A37-B3E0-D3C3-7B4ED8B31867",
      name = "VA2746 SERIES",
      origin = {x = 1920.0, y = -476.0},
      resolution = {h = 1920, w = 1080},
      rotation = 270,
      scaling = 1.0,
    },
  },

  thylacine_home = {
    {
      id = "54FA99AE-7460-427B-C3BA-326D27EAE58D",
      name = "DELL S2722QC (2)",
      origin = {x = 0.0, y = 0.0},
      resolution = {h = 1440, w = 2560},
      rotation = 0,
      scaling = 2.0,
    }, {
      id = "C705FF01-976B-8D0C-6E02-51D75CD3123D",
      name = "Built-in Retina Display",
      origin = {x = -1792.0, y = 1080.0},
      resolution = {h = 1120, w = 1792},
      rotation = 0,
      scaling = 2.0,
    }, {
      id = "3D2B059D-B890-5E46-9702-DF2017843E08",
      name = "DELL S2722QC (1)",
      origin = {x = 2560.0, y = -531.0},
      resolution = {h = 2560, w = 1440},
      rotation = 270,
      scaling = 2.0,
    },
  },
})
spoon.ScreenPresets:start()
