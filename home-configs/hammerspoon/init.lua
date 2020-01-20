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
spoon.MiroWindowsManager:bindHotkeys(
	{
		up = {hyper, "up"},
		right = {hyper, "right"},
		down = {hyper, "down"},
		left = {hyper, "left"},
		fullscreen = {hyper, "space"}
	}
)

-- Move windows from screen to screen
spoon.WindowScreenLeftAndRight:bindHotkeys(
	{screen_left = {hyper, ","}, screen_right = {hyper, "."}}
)

spoon.OpenApplication:bindHotkeys(spoon.OpenApplication.defaultHotkeys)

-- https://www.hammerspoon.org/docs/hs.hotkey.html#bind
hs.hotkey.bind(
	hyper,
	"z",
	function()
		if hs.window.focusedWindow() then
			hs.window.frontmostWindow():toggleZoom()
		end
	end
)

-- watch for changes in the screens attached to the machine
spoon.ScreenPresets:setPresets(
	{
		pademelon_work = {
			{
				id = "29024FE7-925B-A34D-85B1-81674DCEA3C1",
				name = "DELL P2719H",
				origin = {x = 0.0, y = 0.0},
				resolution = {h = 1920, w = 1080},
				rotation = 270,
				scaling = 1.0
			},
			{
				id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3",
				name = "Color LCD",
				origin = {x = 1080.0, y = 1207.0},
				resolution = {h = 1050, w = 1680},
				rotation = 0,
				scaling = 2.0
			},
			{
				id = "FA6C6ED8-1160-EFE5-5696-78F1AFC5184E",
				name = "DELL P2719H",
				origin = {x = -1920.0, y = 483.0},
				resolution = {h = 1080, w = 1920},
				rotation = 0,
				scaling = 1.0
			}
		},
		pademelon_home = {
			{
				id = "CC6F3D60-BB40-DBA1-E4A8-8C4388E352F7",
				name = "VA2746 SERIES",
				origin = { x = 0.0, y = 0.0 },
				resolution = { h = 1920, w = 1080 },
				rotation = 270,
				scaling = 1.0
			},
			{
				id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3",
				name = "Color LCD",
				origin = { x = -1680.0, y = 1556.0 },
				resolution = { h = 800, w = 1280 },
				rotation = 0,
				scaling = 2.0
			},
			{
				id = "662C50EE-BF07-E4F4-7EFB-0DC98939812E",
				name = "Philips 221V",
				origin = { x = -1920.0, y = 476.0 },
				resolution = { h = 1080, w = 1920 },
				rotation = 0,
				scaling = 1.0
			}
		}
	}
)
spoon.ScreenPresets:start()
