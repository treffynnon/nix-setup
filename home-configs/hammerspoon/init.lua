local hyper = {"ctrl", "alt", "cmd"}

hs.loadSpoon("MiroWindowsManager")
hs.loadSpoon("WindowScreenLeftAndRight")
hs.loadSpoon('ControlEscape'):start()

hs.window.animationDuration = 0.1
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"}
})

spoon.WindowScreenLeftAndRight:bindHotkeys({
  screen_left = { hyper, "," },
  screen_right= { hyper, "." },
})
