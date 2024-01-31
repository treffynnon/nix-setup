local obj = {}
obj.__index = obj

-- Metadata
obj.name = "ScreenPresets"
obj.version = "0.1"
obj.author = "Simon Holywell <simon@holywell.com.au>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "Apache-2.0"

local function buildUniqueScreenLayoutIdentifier(fn, screens)
  local identifiers = hs.fnutils.imap(screens, fn)
  table.sort(identifiers)
  return table.concat(identifiers, "*")
end
local function getUniqueIdentifierForAllScreens(allScreens)
  return buildUniqueScreenLayoutIdentifier(function(screen) return screen:getUUID() end, allScreens)
end
local function getUniqueIdentifierForAllScreenPresets(presets, screenCount)
  return hs.fnutils.map(presets, function(setup)
    if #setup == screenCount then
      return buildUniqueScreenLayoutIdentifier(function(x) return x.id end, setup)
    end
    return ""
  end)
end

-- memoise the presets as they never change
local presetIdentifiers = nil
function obj:getScreenPresetId(screens, presets)
  if nil == presetIdentifiers then
    -- memoise the presets as they never change
    presetIdentifiers = getUniqueIdentifierForAllScreenPresets(presets, #screens)
  end
  local uniqueIdentifier = getUniqueIdentifierForAllScreens(screens)
  local presetId = hs.fnutils.indexOf(presetIdentifiers, uniqueIdentifier)
  if presetId == nil then
    self.log.i(
      "No preset found for the current screen layout with identifiers: " .. uniqueIdentifier)
  end
  return presetId
end

function obj:getScreenPreset(screens, presets)
  local presetId = obj:getScreenPresetId(screens, presets)
  if presetId ~= nil then
    self.log.i("Using " .. presetId .. " screen layout preset")
    return presets[presetId]
  end
  return nil
end

function obj:handleRotation(screen, x)
  return function()
    local currentRotation = screen:rotate()
    if currentRotation ~= x.rotation then
      hs.alert("Rotated screen by " .. x.rotation .. " degrees", screen, 3)
      self.log.i("  * Screen rotation is " .. currentRotation .. " expected it to be " .. x.rotation
                   .. " degrees. Rotating now.")
      return screen:rotate(x.rotation)
    end
    self.log.i("  * Rotation is already correct")
    return nil
  end
end

function obj:handleOrigin(screen, x)
  return function()
    local fullFrame = screen:fullFrame()
    local current = table.concat({fullFrame._x, fullFrame._y}, "x")
    local expected = table.concat({x.origin.x, x.origin.y}, "x")
    if (current ~= expected) then
      if _G['hs'] and _G['hs']['screen'] and _G['hs']['screen']['setOrigin'] ~= nil then
        -- we need to fix the origin
        hs.alert("Re-origined screen from " .. current .. " to " .. expected, screen, 3)
        self.log.i("  * Screen origin is " .. current .. " expected it to be " .. expected
                     .. ". Adjusting now.")
        return screen:setOrigin(x.origin.x, x.origin.y)
      end
      self.log.i(
        "  * Could not set screen origin because your build of Hammerspoon doesn't include it")
    end
    self.log.i("  * Origin is already correct")
    return nil
  end
end

function obj:setScreenPreset(preset)
  hs.fnutils.map(preset, function(x)
    self.log.i("Setting preset for " .. x.name .. " (" .. x.id .. ")")
    local screen = hs.screen(x.id)
    return hs.fnutils.sequence(self:handleRotation(screen, x), self:handleOrigin(screen, x))()
  end)
end

function obj:setScreenLayout(allScreens)
  local preset = self:getScreenPreset(allScreens, self.screenPresets)
  if preset ~= nil then
    self.changeInProgress = true
    self:setScreenPreset(preset)
    self.changeInProgress = false
  end
end

function obj:updateScreenLayout()
  return function()
    -- only try to update the screen layout when we're not already attempting to do so
    if self.changeInProgress == false then
      self.allScreens = hs.screen.allScreens()
      self.screenCount = #self.allScreens
      if self.currentScreenCount ~= self.screenCount then
        self.log.i("Screen count changed to " .. self.screenCount)
        self:setScreenLayout(self.allScreens)
      end
      self.currentScreenCount = self.screenCount
    end
  end
end

function obj:menuIdentifyScreens()
  hs.fnutils.each(self.allScreens, function(screen)
    return hs.alert("ID: " .. screen:getUUID() .. "\nName: " .. screen:name(), screen, 5)
  end)
end

local function screenToPreset(screen)
  local mode = screen:currentMode()
  local frame = screen:fullFrame()
  return {
    {
      id = screen:getUUID(),
      name = screen:name(),
      resolution = {w = mode.w, h = mode.h},
      scaling = mode.scale,
      origin = {x = frame._x, y = frame._y},
      rotation = screen:rotate(),
    },
  }
end

function obj:menuCurrentConfigToClipboard()
  local btn, presetName = hs.dialog.textPrompt("Screen preset name",
                                               "Enter a name for this screen preset. Suggest sticking with alphanumerics and underscores.",
                                               hs.host.localizedName())
  if btn == "OK" then
    local screens = hs.fnutils.mapCat(self.allScreens, screenToPreset)
    if hs.pasteboard.setContents(presetName .. " = " .. hs.inspect(screens)) then
      hs.alert("Paste the preset into your Hammerspoon init.lua file")
      return nil
    end
    hs.alert("Failed to export the screen configuration")
  end
end

function obj:menuResetPreset()
  -- hs.dialog.alert(x, y, callbackFn, message, [informativeText], [buttonOne], [buttonTwo], [style])
  local presetId = obj:getScreenPresetId(self.allScreens, self.screenPresets)
  if presetId ~= nil then
    hs.dialog.alert(nil, nil, function(btn)
      if btn == "Yes" then self:setScreenLayout(self.allScreens) end
    end, "Do you really want to set the preset?",
                    "This will set the screens to use the '" .. presetId .. "' configuration", "No",
                    "Yes")
  else
    hs.alert("No matching preset was found. Export a configuration for these screens first.")
  end
end

function obj:initMenu()
  self.menubar = hs.menubar.new()
  self.menubar:setTitle("S")
  self.menubar:setMenu({
    {title = "Identify screens", fn = function() obj:menuIdentifyScreens() end},
    {
      title = "Copy current screen layout...",
      fn = function() obj:menuCurrentConfigToClipboard() end,
    }, {title = "Set the current preset...", fn = function() obj:menuResetPreset() end},
  })
end

function obj:init()
  --- OpenApplication.logger
  --- Variable
  --- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
  self.log = hs.logger.new("ScreenPresets", "debug")

  self.log.i("Binding screen watcher")
  self.screenwatcher = hs.screen.watcher.new(self:updateScreenLayout())

  self.log.i("Initialising")
  self.allScreens = hs.screen.allScreens()
  self.screenCount = #self.allScreens
  self.log.i("There are " .. self.screenCount .. " screens connected")
  self.currentScreenCount = self.screenCount
  self.changeInProgress = false
  self.screenPresets = {}

  self:initMenu()
end

function obj:setPresets(presets) self.screenPresets = presets end

function obj:start()
  -- ensure the presets are set at initialisation
  -- sometimes it is screwed at boot up!
  self:setScreenLayout(self.allScreens)

  self.screenwatcher:start()
  self.log.i("Initialisation complete")
end

function obj:stop() self.screenwatcher:stop() end

return obj
