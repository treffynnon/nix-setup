local obj={}
local hyper = {"ctrl", "alt", "cmd"}
obj.__index = obj

-- Metadata
obj.name = "OpenApplication"
obj.version = "0.1"
obj.author = "Simon Holywell <simon@holywell.com.au>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "Apache-2.0"

--- OpenApplication.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('OpenApplication')

--- OpenApplication.defaultHotkeys
--- Variable
--- Table containing a sample set of hotkeys that can be
--- assigned to the different operations. These are not bound
--- by default - if you want to use them you have to call:
--- `spoon.OpenApplication:bindHotkeys(spoon.OpenApplication.defaultHotkeys)`
--- after loading the spoon. Value:
--- ```
---  {
--     { hyper, "c", obj.open("Visual Studio Code") },
--     { hyper, "s", obj.open("Slack") },
--   }
--- ```
obj.defaultHotkeys = {
  { hyper, "c", "Visual Studio Code" },
  { hyper, "s", "Slack" },
  { hyper, "f", "Finder" },
  { hyper, "w", "Firefox" },
  { hyper, "t", "Kitty" },
}

function obj.open(name)
  return function()
    hs.application.launchOrFocus(name)
    if name == 'Finder' then
      hs.appfinder.appFromName(name):activate()
    end
  end
end

function obj:bindHotkeys(mapping)
	for i,k in ipairs(mapping) do
		hs.hotkey.bind(k[1], k[2], obj.open(k[3]))
  end
	return self
end

return obj
