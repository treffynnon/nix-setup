package.path = './?.lua;' .. package.path
hs = require('mock-hammerspoon')
hs.logger = mock(hs.logger, true)
hs.inspect = spy.on(hs, 'inspect')
_G.hs = hs
package.path = './ScreenPresets.spoon/?.lua;' .. package.path

local function getInstance()
  package.loaded['init'] = nil
  local x = require('init')
  x.log = hs.logger
  return x
end

local sp = getInstance()

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

local function buildScreen(uuid)
  local screen = {}
  function screen:getUUID() -- luacheck: no self
    return uuid
  end
  return screen
end

describe("ScreenPresets", function()
  insulate("getScreenPreset", function()
    local screens = {
      buildScreen("402D58C8-046B-82A8-CD93-2D5C7DCB94BB"),
      buildScreen("6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3"),
      buildScreen("EEA3B508-6CD9-9ABF-3900-1777A3A46A91"),
    }
    before_each(function()
      sp = getInstance()

    end)
    after_each(function()
      sp = nil
    end)

    it("should return nil given an empty table", function()
      assert.same(nil, sp:getScreenPreset({}, {}))
      assert.same(nil, sp:getScreenPreset({}, presets))
    end)
    it("succeeds with valid data", function()
      local preset = sp:getScreenPreset(screens, presets)
      assert.spy(sp.log.i).was.called_with(match.is_string())
      assert.are.equal(3, #screens)
      assert.are.equal(3, #preset)
      assert.same(presets['pademelon_work'], preset)
    end)
  end)
end)
