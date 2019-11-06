local hyper = {"ctrl", "alt", "cmd"}
hs.window.animationDuration = 0.2

hs.alert.defaultStyle.fillColor = {
	hex = "#2f1e2e",
	alpha = 0.9
}
hs.alert.defaultStyle.strokeColor = {
	hex = "#828282",
	alpha = 0.9
}
hs.alert.defaultStyle.textColor = {
	hex = "#a39e9b",
	alpha = 0.9
}
hs.alert.defaultStyle.textSize = 18

hs.loadSpoon("MiroWindowsManager")
hs.loadSpoon("WindowScreenLeftAndRight")
hs.loadSpoon("OpenApplication")
hs.loadSpoon("MouseBackButton"):start()

-- Tap control for `escape` and hold for `control`
hs.loadSpoon("ControlEscape"):start()

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
spoon.WindowScreenLeftAndRight:bindHotkeys({screen_left = {hyper, ","}, screen_right = {hyper, "."}})

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

function round(num)
	if num >= 0 then
		return math.floor(num + .5)
	else
		return math.ceil(num - .5)
	end
end

-- watch for changes in the screens attached to the machine
local currentScreenCount = 1
local displayplacerPath = "/run/current-system/sw/bin/displayplacer"
local screenPresets = {
	pademelon_work = {
		{
			id = "402D58C8-046B-82A8-CD93-2D5C7DCB94BB", -- Dell
			name = "DELL P2412H",
			resolution = {
				width = 1920,
				height = 1080
			},
			colourDepth = 8,
			scaling = false,
			position = {
				x = 0,
				y = 0
			},
			rotation = 0
		},
		{
			id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3", -- Laptop screen
			name = "Color LCD",
			resolution = {
				width = 1680,
				height = 1050
			},
			colourDepth = 4,
			scaling = true,
			position = {
				x = 1920,
				y = 387
			},
			rotation = 0
		},
		{
			id = "EEA3B508-6CD9-9ABF-3900-1777A3A46A91", -- Dell
			name = "DELL P2412H",
			resolution = {
				width = 1080,
				height = 1920
			},
			hz = 60,
			colourDepth = 8,
			scaling = false,
			position = {
				x = -1080,
				y = -423
			},
			rotation = 90
		}
	}
}

local log = hs.logger.new("ScreenPresets", "debug")

local function buildUniqueScreenLayoutIdentifier(fn, screens)
	local identifiers = hs.fnutils.imap(screens, fn)
	table.sort(identifiers)
	return table.concat(identifiers, "*")
end
local function getUniqueIdentifierForAllScreens(allScreens)
	return buildUniqueScreenLayoutIdentifier(
		function(screen)
			return screen:getUUID()
		end,
		allScreens
	)
end
local function getUniqueIdentifierForAllScreenPresets(presets, screenCount)
	return hs.fnutils.map(
		presets,
		function(setup)
			log.i("Testing preset has the same screen count (" .. #setup .. " == " .. screenCount .. ")")
			if #setup == screenCount then
				return buildUniqueScreenLayoutIdentifier(
					function(x)
						return x.id
					end,
					setup
				)
			end
			return ""
		end
	)
end

-- memoise the presets as they never change
local presetIdentifiers = nil
local function getScreenPreset(screens, presets)
	if nil == presetIdentifiers then
		-- memoise the presets as they never change
		presetIdentifiers = getUniqueIdentifierForAllScreenPresets(presets, #screens)
	end
	local uniqueIdentifier = getUniqueIdentifierForAllScreens(screens)
	local presetId = hs.fnutils.indexOf(presetIdentifiers, uniqueIdentifier)
	if presetId ~= nil then
		log.i("Using " .. presetId .. " screen layout preset")
		return presets[presetId]
	end
	log.i("No preset found for the current screen layout with identifiers: " .. uniqueIdentifier)
	return nil
end

local function handleRotation(screen, x)
	return function()
		local currentRotation = screen:rotate()
		if currentRotation ~= x.rotation then
			hs.alert("Rotated screen by " .. x.rotation .. " degrees", screen, 3)
			log.i("Screen rotation is " .. currentRotation .. " expected it to be " .. x.rotation .. " degrees. Rotating now.")
			return screen:rotate(x.rotation)
		end
		return nil
	end
end

local function handlePosition(screen, x)
	return function()
		local fullFrame = screen:fullFrame()
		local current = table.concat({round(fullFrame._x), round(fullFrame._y)}, "x")
		local expected = table.concat({x.position.x, x.position.y}, "x")
		if (current ~= expected) then
			-- we need to fix the position
			hs.alert("Re-positioned screen from " .. current .. " to " .. expected, screen, 3)
			log.i(
				"Screen position is " ..
					current .. " expected it to be " .. expected .. ". You need displayplacer to move it to the correct position."
			)
			return nil
		end
		return nil
	end
end

local function setScreenPreset(preset)
	hs.fnutils.map(
		preset,
		function(x)
			log.i("Setting preset for " .. x.name .. " (" .. x.id .. ")")
			local screen = hs.screen(x.id)
			return hs.fnutils.sequence(handleRotation(screen, x), handlePosition(screen, x))()
		end
	)
end

log.i("Initialising")
local allScreens = hs.screen.allScreens()
local screenCount = #allScreens
log.i("There are " .. screenCount .. " screens connected")
local currentScreenCount = screenCount
local changeInProgress = false

-- ensure the presets are set at initialisation
-- sometimes it is screwed at boot up!
local preset = getScreenPreset(allScreens, screenPresets)
if preset ~= nil then
	changeInProgress = true
	setScreenPreset(preset)
	changeInProgress = false
end

local function updateScreenLayout()
	-- only try to update the screen layout when we're not already attempting to do so
	if changeInProgress == false then
		allScreens = hs.screen.allScreens()
		screenCount = #allScreens
		if currentScreenCount ~= screenCount then
			log.i("Screen count changed to " .. screenCount)
			local preset = getScreenPreset(allScreens, screenPresets)
			if preset ~= nil then
				changeInProgress = true
				setScreenPreset(preset)
				changeInProgress = false
			end
		end
		currentScreenCount = screenCount
	end
end

log.i("Binding screen watcher")
local screenwatcher = hs.screen.watcher.new(updateScreenLayout)
screenwatcher:start()
log.i("Initialisation complete")
