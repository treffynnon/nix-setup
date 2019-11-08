package.path = './?.lua;' .. package.path
i = require "inspect"
hs = require "mock-hammerspoon"
_G.hs = hs
i(hs)
package.path = './ScreenPresets.spoon/?.lua;' .. package.path
sp = require('init')

local presets = {
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
}

describe("ScreenPresets", function()
  hs = require('mock-hammerspoon')
	insulate("getScreenPreset", function()
		local screens = {}
		function screens:getUUID()
			return {}
		end
		setup(function()
			sp.log = hs.logger
		end)
		teardown(function()
			sp.log = nil
		end)
		it("should return nil given an empty table", function()
			local preset = sp:getScreenPreset({}, {})
			assert.same(nil, preset)
		end)
		it("succeeds with valid data", function()
			local preset = sp:getScreenPreset(screens, presets)
			assert.same({}, preset)
		end)
	end)
end)
