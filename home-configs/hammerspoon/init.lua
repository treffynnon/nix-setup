local hyper = {"ctrl", "alt", "cmd"}
hs.window.animationDuration = 0.2

-- Load some spoons from ~/.hammerspoon/Spoons
hs.loadSpoon("MiroWindowsManager")
hs.loadSpoon("WindowScreenLeftAndRight")
hs.loadSpoon("OpenApplication")

-- Tap control for `escape` and hold for `control`
hs.loadSpoon('ControlEscape'):start()

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
local currentScreenCount = 1
local displayplacerPath = "/run/current-system/sw/bin/displayplacer"
local screenSetups = {
	pademelon_work = {
		{
			id = "402D58C8-046B-82A8-CD93-2D5C7DCB94BB", -- Dell
			name = "DELL P2412H",
			position =
				"res:1920x1080 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0",
		},
		{
			id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3", -- Laptop screen
			name = "Color LCD",
			position =
				"res:1680x1050 color_depth:4 scaling:on origin:(1920,387) degree:0",
		},
		{
			id = "EEA3B508-6CD9-9ABF-3900-1777A3A46A91", -- Dell
			name = "DELL P2412H",
			position =
				"res:1080x1920 hz:60 color_depth:8 scaling:off origin:(-1080,-423) degree:90"
		}
	}
}
local screenwatcher = hs.screen.watcher.new(function()
	local screens = hs.screen.allScreens()
	if #screens == 3 and currentScreenCount ~= #screens then
		local names = hs.fnutils.map(screens, function(screen)
			return screen:name()
		end)
		if hs.fnutils.every(names, function(name) return (name == "Color LCD" or name == "DELL P2412H") end) then
			hs.fnutils.map(xs, function(x)
				return "'id:" .. x.id .. " " .. x.position .. "'"
			end)

			hs.execute("/run/current-system/sw/bin/displayplacer
			'id:402D58C8-046B-82A8-CD93-2D5C7DCB94BB res:1920x1080 hz:60 color_depth:8 scaling:off origin:(0,0) degree:0'
			'id:6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3 res:1680x1050 color_depth:4 scaling:on origin:(1920,387) degree:0'
			'id:EEA3B508-6CD9-9ABF-3900-1777A3A46A91 res:1080x1920 hz:60 color_depth:8 scaling:off origin:(-1080,-423) degree:90'")
		end
	end
	currentScreenCount = #screens
end)
screenwatcher:start()

-- handle back button press
-- eventtapOtherMouseDragged = eventtap.new( {
-- 	eventTypes.otherMouseUp
-- }, function(event)
-- 	if event:getProperty(eventProps.mouseEventButtonNumber) == 4 then
-- 		return true, { hs.eventtap.event.newKeyEvent({ cmd }, hs.keycodes.map.alt, false) }
-- 	end
-- end)
