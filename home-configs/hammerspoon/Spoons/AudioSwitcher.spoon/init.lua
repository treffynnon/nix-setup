local AudioSwitcher = {}
AudioSwitcher.__index = AudioSwitcher

-- Metadata
AudioSwitcher.name = "AudioSwitcher"
AudioSwitcher.version = "0.3"
AudioSwitcher.author = "Simon Holywell <simon@holywell.au>"
AudioSwitcher.homepage = "https://github.com/Hammerspoon/Spoons"
AudioSwitcher.license = "Apache-2.0"

local hyper = {"ctrl", "alt", "cmd"}
AudioSwitcher.defaultHotkeys = {speakers = {hyper, "s"}, headphones = {hyper, "h"}}

-- Destination name → preferred playback outputs, first match wins.
AudioSwitcher.destinations = {
  headphones = {"US-2x2", "External Headphones"},
  speakers = {"EDIFIER R1280DB", "MacBook Pro Speakers"},
}

-- Outcome of a switch, as strings rather than booleans so callers can match on
-- the result when building a report.
AudioSwitcher.status = {switched = "switched", failed = "failed"}

-- The two macOS defaults this spoon can set. The destination hotkeys only ever
-- touch playback; capture exists for callers like Meet setup.
local channels = {
  playback = {
    find = function(name) return hs.audiodevice.findOutputByName(name) end,
    current = function() return hs.audiodevice.defaultOutputDevice() end,
    setDefault = function(device) return device:setDefaultOutputDevice() end,
    list = function() return hs.audiodevice.allOutputDevices() end,
  },
  capture = {
    find = function(name) return hs.audiodevice.findInputByName(name) end,
    current = function() return hs.audiodevice.defaultInputDevice() end,
    setDefault = function(device) return device:setDefaultInputDevice() end,
    list = function() return hs.audiodevice.allInputDevices() end,
  },
}

local destinationLabels = {headphones = "Headphones", speakers = "Speakers"}

local switchMessages = {
  [AudioSwitcher.status.switched] = function(label, device)
    return string.format("%s: %s", label, device)
  end,
  [AudioSwitcher.status.failed] = function(label, device)
    return string.format("%s failed. Still: %s", label, device)
  end,
}

function AudioSwitcher.currentDeviceName(channel)
  local device = channels[channel].current()
  if device then return device:name() end
  return "unknown"
end

-- Try each preferred device in order and keep the first that becomes the
-- default. Returns the outcome instead of alerting so that callers switching
-- more than one channel can report once.
function AudioSwitcher.switchChannel(channel, preferred)
  local spec = channels[channel]
  local winner = hs.fnutils.find(preferred, function(deviceName)
    local device = spec.find(deviceName)
    return device ~= nil and spec.setDefault(device) == true
  end)

  if winner then return {status = AudioSwitcher.status.switched, device = winner} end
  return {status = AudioSwitcher.status.failed, device = AudioSwitcher.currentDeviceName(channel)}
end

function AudioSwitcher.switchTo(destination)
  local result = AudioSwitcher.switchChannel("playback", AudioSwitcher.destinations[destination])
  local label = destinationLabels[destination] or destination
  local message = switchMessages[result.status](label, result.device)
  hs.alert.show(message)
  print(message)
end

function AudioSwitcher.onHeadphones() AudioSwitcher.switchTo("headphones") end

function AudioSwitcher.onSpeakers() AudioSwitcher.switchTo("speakers") end

local function printDevices(channel, heading)
  print(heading)
  hs.fnutils.each(channels[channel].list(),
                  function(device) print(string.format("- %s", device:name())) end)
end

function AudioSwitcher.listAudioDevices()
  printDevices("playback", "Available audio output devices:")
  printDevices("capture", "Available audio input devices:")
end

function AudioSwitcher:bindHotkeys(mapping)
  local hotkeyDefinitions = {headphones = self.onHeadphones, speakers = self.onSpeakers}
  mapping = mapping or self.defaultHotkeys
  hs.spoons.bindHotkeysToSpec(hotkeyDefinitions, mapping)
  self.listAudioDevices()
  return self
end

return AudioSwitcher
