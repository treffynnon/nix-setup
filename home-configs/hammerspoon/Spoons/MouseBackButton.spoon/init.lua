local obj = {}
obj.__index = obj

-- Metadata
obj.name = "MouseBackButton"
obj.version = "0.1"
obj.author = "Simon Holywell <simon@holywell.com.au>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "Apache-2.0"

--- OpenApplication.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('MouseBackButton')

-- handle back button press
local backButtonWindows = {} -- memoise the windows that can be backed
setmetatable(backButtonWindows, {_mode = "v"}) -- makes values weak
local function handleBackButtonPress(e)
	local window = hs.window.focusedWindow()
	local id = window:id()
	if backButtonWindows[id] then
		hs.eventtap.keyStroke({"cmd"}, "[")
		return true, {}
	else
		local application = window:application()
		local title = application:title()
		if hs.fnutils.contains({"Firefox", "Brave Browser", "Google Chrome"}, title) then
			backButtonWindows[id] = id
			hs.eventtap.keyStroke({"cmd"}, "[")
			return true, {}
		end
	end
end

function obj:init()
	obj.logger.i("Binding mouse back button handling")
	self.backButton =
		hs.eventtap.new(
		{
			hs.eventtap.event.types.otherMouseUp
		},
		function(e)
			if e:getProperty(hs.eventtap.event.properties["mouseEventButtonNumber"]) == 3 then
				return handleBackButtonPress(e)
			end
		end
	)
end

function obj:start()
	self.backButton:start()
end

function obj:stop()
	self.backButton:stop()
end

return obj
