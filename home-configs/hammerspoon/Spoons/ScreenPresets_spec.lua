package.path = './ScreenPresets.spoon/?.lua;./?.lua;' .. package.path

local function setupHsMock()
  local mhs = require('mock-hammerspoon')
  local hs = mhs
  hs.logger = mock(mhs.logger, true)
  hs.alert = spy.on(mhs, 'alert')
  hs.inspect = spy.on(mhs, 'inspect')
  _G.hs = hs
end
local function teardownHsMock()
  package.loaded['mock-hammerspoon'] = nil
  _G.hs = nil
end

local function getInstance()
  setupHsMock()
  package.loaded['init'] = nil
  local x = require('init')
  x.log = hs.logger
  return x
end

local sp = getInstance()

local presets = {
  work = {
    {
      id = "402D58C8-046B-82A8-CD93-2D5C7DCB94BB",
      name = "DELL P2412H",
      resolution = {w = 1920, h = 1080},
      colourDepth = 8,
      scaling = 1,
      origin = {x = 0.0, y = 0.0},
      rotation = 0,
    }, {
      id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3",
      name = "Color LCD",
      resolution = {w = 1680, h = 1050},
      colourDepth = 4,
      scaling = 2,
      origin = {x = 1920.0, y = 387.0},
      rotation = 0,
    }, {
      id = "EEA3B508-6CD9-9ABF-3900-1777A3A46A91",
      name = "DELL P2412H",
      resolution = {w = 1080, h = 1920},
      hz = 60,
      colourDepth = 8,
      scaling = 1,
      origin = {x = -1080.0, y = -423.0},
      rotation = 90,
    },
  },
  home = {
    {
      id = "6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3",
      name = "Color LCD",
      resolution = {w = 1680, h = 1050},
      colourDepth = 4,
      scaling = 2,
      origin = {x = 1920.0, y = 387.0},
      rotation = 0,
    }, {
      id = "782D58C8-046B-82A8-CD93-2D5C7DCBGHT6",
      name = "ViewSonic 27",
      resolution = {w = 1920, h = 1080},
      colourDepth = 8,
      scaling = 1,
      origin = {x = 0.0, y = 0.0},
      rotation = 0,
    },
  },
}

local function buildScreen(uuid)
  local screen = {}
  function screen:getUUID() -- luacheck: no self
    return uuid
  end
  function screen:rotate(rotation) -- luacheck: no self
    if rotation == nil then
      return 0
    end
    return rotation
  end
  function screen:fullFrame() -- luacheck: no self
    return {_x = 200, _y = -100}
  end
  return screen
end

insulate("ScreenPresets", function()
  before_each(function()
    sp = getInstance()
  end)
  after_each(function()
    sp = nil
    teardownHsMock()
  end)
  insulate("getScreenPreset", function()
    it("should return nil given an empty table", function()
      assert.same(nil, sp:getScreenPreset({}, {}))
      assert.same(nil, sp:getScreenPreset({}, presets))
    end)
    it("succeeds with valid data", function()
      local preset = sp:getScreenPreset({
        buildScreen("402D58C8-046B-82A8-CD93-2D5C7DCB94BB"),
        buildScreen("6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3"),
        buildScreen("EEA3B508-6CD9-9ABF-3900-1777A3A46A91"),
      }, presets)
      assert.spy(sp.log.i).was.called_with(match.is_string())
      assert.same(presets['work'], preset)
    end)
    it('succeeds with out of order UUIDs', function()
      local preset = sp:getScreenPreset({
        buildScreen("782D58C8-046B-82A8-CD93-2D5C7DCBGHT6"),
        buildScreen("6AECDDE9-288C-0715-DBA7-0CE2A25D2BF3"),
      }, presets)
      assert.spy(sp.log.i).was.called_with(match.is_string())
      assert.same(presets['home'], preset)
    end)
  end)

  insulate("handleRotation", function()
    it('correctly identifiers when the rotation is incorrect', function()
      local rotation = sp:handleRotation(buildScreen("8765557679809877"), {rotation = 90})()
      assert.spy(sp.log.i).was.called_with(
        "  * Screen rotation is 0 expected it to be 90 degrees. Rotating now.")
      assert.spy(hs.alert).was_called_with("Rotated screen by 90 degrees", match.is_not_nil(), 3)
      assert.same(90, rotation)
    end)
    it('should not make a change when the rotation is already correct', function()
      local rotation = sp:handleRotation(buildScreen("8765557679809877"), {rotation = 0})()
      assert.spy(hs.alert).was_not.called()
      assert.spy(sp.log.i).was.called_with("  * Rotation is already correct")
      assert.same(nil, rotation)
    end)
  end)

  insulate("handleOrigin", function()
    it('correctly identifiers when the origin is incorrect', function()
      local origin = sp:handleOrigin(buildScreen("8765557679809877"), {origin = {x = 0, y = 0}})()
      assert.spy(sp.log.i).was.called_with(
        "  * Screen origin is 200x-100 expected it to be 0x0. You need displayplacer to move it to the correct origin.")
      assert.same(nil, origin)
    end)
    it('should not make a change when the origin is already correct', function()
      local origin =
        sp:handleOrigin(buildScreen("8765557679809877"), {origin = {x = 200, y = -100}})()
      assert.spy(hs.alert).was_not.called()
      assert.spy(sp.log.i).was_not.called()
      assert.same(nil, origin)
    end)
  end)
end)
