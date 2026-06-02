-- ElgatoStreamDeck.spoon
--
-- Manages Elgato Stream Deck USB power during system sleep/wake cycles
-- Uses uhubctl library to control USB port power
--
-- Usage in init.lua:
--   hs.loadSpoon("ElgatoStreamDeck")
--   spoon.ElgatoStreamDeck:start()
--
--   -- Optional: specify custom device name if auto-detection fails
--   spoon.ElgatoStreamDeck.deviceName = "Stream Deck"
--   spoon.ElgatoStreamDeck:start()
--
local ElgatoStreamDeck = {}
ElgatoStreamDeck.__index = ElgatoStreamDeck

-- Metadata
ElgatoStreamDeck.name = "ElgatoStreamDeck"
ElgatoStreamDeck.version = "0.1"
ElgatoStreamDeck.author = "Simon Holywell <simon@holywell.au>"
ElgatoStreamDeck.homepage = "https://github.com/Hammerspoon/Spoons"
ElgatoStreamDeck.license = "Apache-2.0"

-- Configuration
ElgatoStreamDeck.deviceName = nil -- Will auto-detect if nil
ElgatoStreamDeck.devicePatterns = { -- Patterns to match Stream Deck devices
  "Stream Deck", "Elgato", "streamdeck",
}
ElgatoStreamDeck.uhubctl = nil -- Will be loaded via require
ElgatoStreamDeck.sleepWatcher = nil
ElgatoStreamDeck.isEnabled = false

-- State tracking
ElgatoStreamDeck.wasOnBeforeSleep = true
ElgatoStreamDeck.currentPage = 1 -- For future multi-page support

function ElgatoStreamDeck:init()
  -- Load uhubctl library
  local success, uhubctl = pcall(require, 'uhubctl')
  if not success then
    print("ElgatoStreamDeck: Failed to load uhubctl library. Make sure uhubctl.lua is available.")
    return self
  end

  self.uhubctl = uhubctl
  return self
end

function ElgatoStreamDeck:start()
  -- Ensure init is called if not already done
  if not self.uhubctl then self:init() end

  if not self.uhubctl then
    print(
      "ElgatoStreamDeck: uhubctl library not available. Call init() first or ensure uhubctl.lua exists.")
    return self
  end

  -- Start uhubctl if not already started
  self.uhubctl.start()

  -- If device name is already set, start immediately, otherwise wait for discovery
  if self.deviceName then
    self:setupSleepWatcher()
    self.isEnabled = true
    print("ElgatoStreamDeck: Started monitoring '" .. self.deviceName .. "' for sleep/wake events")
  else
    -- Wait a moment for device discovery to complete, then find Stream Deck
    hs.timer.doAfter(2.0, function()
      self:findStreamDeckDevice()

      if not self.deviceName then
        print(
          "ElgatoStreamDeck: No Stream Deck device found. You can manually set spoon.ElgatoStreamDeck.deviceName")
        return
      end

      self:setupSleepWatcher()
      self.isEnabled = true
      print("ElgatoStreamDeck: Started monitoring '" .. self.deviceName .. "' for sleep/wake events")
    end)
  end

  return self
end

function ElgatoStreamDeck:stop()
  if self.sleepWatcher then
    self.sleepWatcher:stop()
    self.sleepWatcher = nil
  end

  self.isEnabled = false
  print("ElgatoStreamDeck: Stopped monitoring sleep/wake events")

  return self
end

-- Auto-detect Stream Deck device
function ElgatoStreamDeck:findStreamDeckDevice()
  if not self.uhubctl then return end

  local deviceNames = self.uhubctl.getDeviceNames()

  for _, deviceName in ipairs(deviceNames) do
    for _, pattern in ipairs(self.devicePatterns) do
      if deviceName:lower():find(pattern:lower(), 1, true) then
        self.deviceName = deviceName
        print("ElgatoStreamDeck: Auto-detected Stream Deck device: '" .. deviceName .. "'")
        return
      end
    end
  end

  print("ElgatoStreamDeck: No Stream Deck device auto-detected from available devices:")
  for _, deviceName in ipairs(deviceNames) do print("  - " .. deviceName) end
end

-- Set up sleep/wake event watchers
function ElgatoStreamDeck:setupSleepWatcher()
  if self.sleepWatcher then self.sleepWatcher:stop() end

  self.sleepWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.systemWillSleep then
      self:onSystemWillSleep()
    elseif event == hs.caffeinate.watcher.systemDidWake then
      self:onSystemDidWake()
    end
  end)

  self.sleepWatcher:start()
end

-- Handle system going to sleep
function ElgatoStreamDeck:onSystemWillSleep()
  if not self.isEnabled or not self.deviceName then
    print("ElgatoStreamDeck: Sleep event ignored - enabled:", self.isEnabled, "deviceName:",
          self.deviceName)
    return
  end

  print("ElgatoStreamDeck: System going to sleep, checking Stream Deck state...")
  print("ElgatoStreamDeck: Looking for device:", self.deviceName)

  -- Remember current state before turning off
  local currentState = self.uhubctl.getDeviceState(self.deviceName)
  print("ElgatoStreamDeck: Current device state:", currentState)

  if currentState == nil then
    -- Device not found in uhubctl, assume it's on and try to turn it off
    print("ElgatoStreamDeck: Device state unknown (device not found), assuming it's on")
    self.wasOnBeforeSleep = true
  else
    self.wasOnBeforeSleep = currentState
    print("ElgatoStreamDeck: Device was", currentState and "ON" or "OFF", "before sleep")
  end

  if self.wasOnBeforeSleep then
    print("ElgatoStreamDeck: Turning off Stream Deck before sleep")
    self.uhubctl.turnOffDevice(self.deviceName)
  else
    print("ElgatoStreamDeck: Stream Deck was already off")
  end
end

-- Handle system waking from sleep
function ElgatoStreamDeck:onSystemDidWake()
  if not self.isEnabled or not self.deviceName then return end

  print("ElgatoStreamDeck: System waking up, restoring Stream Deck state...")

  if self.wasOnBeforeSleep then
    print("ElgatoStreamDeck: Turning Stream Deck back on")
    self.uhubctl.turnOnDevice(self.deviceName)

    -- Future: Navigate to specific page
    self:navigateToPage(self.currentPage)
  else
    print("ElgatoStreamDeck: Keeping Stream Deck off (was off before sleep)")
  end
end

-- Manual control methods
function ElgatoStreamDeck:turnOn()
  if not self.deviceName then
    print("ElgatoStreamDeck: No device configured")
    return false
  end

  print("ElgatoStreamDeck: Manually turning on Stream Deck")
  return self.uhubctl.turnOnDevice(self.deviceName)
end

function ElgatoStreamDeck:turnOff()
  if not self.deviceName then
    print("ElgatoStreamDeck: No device configured")
    return false
  end

  print("ElgatoStreamDeck: Manually turning off Stream Deck")
  return self.uhubctl.turnOffDevice(self.deviceName)
end

function ElgatoStreamDeck:toggle()
  if not self.deviceName then
    print("ElgatoStreamDeck: No device configured")
    return false
  end

  print("ElgatoStreamDeck: Toggling Stream Deck power")
  return self.uhubctl.toggleDevice(self.deviceName)
end

function ElgatoStreamDeck:getState()
  if not self.deviceName then return nil end

  return self.uhubctl.getDeviceState(self.deviceName)
end

-- Future: Multi-page support
function ElgatoStreamDeck:navigateToPage(pageNumber)
  -- Placeholder for future implementation
  -- This will handle navigating to specific pages on the Stream Deck
  -- when we implement multi-page functionality

  self.currentPage = pageNumber or 1
  print("ElgatoStreamDeck: Future feature - navigate to page " .. self.currentPage)

  -- Future implementation might:
  -- 1. Send specific USB/HID commands to the Stream Deck
  -- 2. Use Stream Deck software API if available
  -- 3. Trigger specific button sequences
end

function ElgatoStreamDeck:getCurrentPage() return self.currentPage end

function ElgatoStreamDeck:setPage(pageNumber)
  if pageNumber and pageNumber > 0 then self:navigateToPage(pageNumber) end
end

-- Utility methods
function ElgatoStreamDeck:refreshDeviceList()
  if self.uhubctl then
    print("ElgatoStreamDeck: Refreshing device list...")
    self.uhubctl.refreshDevices()

    -- If we don't have a device name yet, try to find one
    if not self.deviceName then
      hs.timer.doAfter(1.0, function()
        self:findStreamDeckDevice()
        if self.deviceName and not self.isEnabled then
          self:setupSleepWatcher()
          self.isEnabled = true
          print("ElgatoStreamDeck: Started monitoring '" .. self.deviceName
                  .. "' for sleep/wake events")
        end
      end)
    end
  end
end

function ElgatoStreamDeck:listAvailableDevices()
  if not self.uhubctl then
    print("ElgatoStreamDeck: uhubctl library not available")
    return {}
  end

  local devices = self.uhubctl.getDeviceNames()
  print("ElgatoStreamDeck: Available USB devices:")
  for _, deviceName in ipairs(devices) do
    local isStreamDeck = false
    for _, pattern in ipairs(self.devicePatterns) do
      if deviceName:lower():find(pattern:lower(), 1, true) then
        isStreamDeck = true
        break
      end
    end

    local marker = isStreamDeck and " (potential Stream Deck)" or ""
    print("  - " .. deviceName .. marker)
  end

  return devices
end

-- Configuration methods
function ElgatoStreamDeck:setDeviceName(deviceName)
  self.deviceName = deviceName
  print("ElgatoStreamDeck: Device name set to '" .. deviceName .. "'")
  return self
end

function ElgatoStreamDeck:getDeviceName() return self.deviceName end

-- Debug methods
function ElgatoStreamDeck:checkDeviceState()
  if not self.deviceName then
    print("ElgatoStreamDeck: No device name set")
    return nil
  end

  if not self.uhubctl then
    print("ElgatoStreamDeck: uhubctl library not loaded")
    return nil
  end

  local state = self.uhubctl.getDeviceState(self.deviceName)
  print("ElgatoStreamDeck: Current state of '" .. self.deviceName .. "':", state)
  return state
end

function ElgatoStreamDeck:debugInfo()
  print("ElgatoStreamDeck Debug Info:")
  print("  - Enabled:", self.isEnabled)
  print("  - Device Name:", self.deviceName or "not set")
  print("  - uhubctl loaded:", self.uhubctl ~= nil)
  print("  - Was on before sleep:", self.wasOnBeforeSleep)
  print("  - Current page:", self.currentPage)

  if self.uhubctl then
    print("  - Available devices:")
    local devices = self.uhubctl.getDeviceNames()
    for _, deviceName in ipairs(devices) do
      local state = self.uhubctl.getDeviceState(deviceName)
      print("    - " .. deviceName .. ": " .. (state and "ON" or "OFF"))
    end
  end
end

return ElgatoStreamDeck
