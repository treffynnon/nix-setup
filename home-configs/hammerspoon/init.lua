local hyper = {"ctrl", "alt", "cmd"}
hs.window.animationDuration = 0.2

-- Load some spoons from ~/.hammerspoon/Spoons
hs.loadSpoon("MiroWindowsManager")
hs.loadSpoon("WindowScreenLeftAndRight")

-- Tap control for `escape` and hold for `control`
hs.loadSpoon('ControlEscape'):start()

-- A little window manager for pushing around windows with
-- the keyboard
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "space"}
})

-- Move windows from screen to screen
spoon.WindowScreenLeftAndRight:bindHotkeys({
  screen_left = { hyper, "," },
  screen_right= { hyper, "." },
})

-- https://www.hammerspoon.org/docs/hs.hotkey.html#bind
hs.hotkey.bind(hyper, "z", function()
  if hs.window.focusedWindow() then
    hs.window.frontmostWindow():toggleZoom()
  end
end)
