local AudioSwitcher = {}
AudioSwitcher.__index = AudioSwitcher

-- Metadata
AudioSwitcher.name = "AudioSwitcher"
AudioSwitcher.version = "0.2"
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

local destinationLabels = {headphones = "Headphones", speakers = "Speakers"}

local function currentPlaybackOutputName()
  local device = hs.audiodevice.defaultOutputDevice()
  if device then
    return device:name()
  end
  return "unknown"
end

function AudioSwitcher.switchTo(destination)
  local preferred = AudioSwitcher.destinations[destination]
  local label = destinationLabels[destination] or destination

  for _, deviceName in ipairs(preferred) do
    local device = hs.audiodevice.findOutputByName(deviceName)
    if device and device:setDefaultOutputDevice() then
      local message = string.format("%s: %s", label, device:name())
      hs.alert.show(message)
      print(message)
      return
    end
  end

  local message = string.format("%s failed. Still: %s", label, currentPlaybackOutputName())
  hs.alert.show(message)
  print(message)
end

function AudioSwitcher.onHeadphones()
  AudioSwitcher.switchTo("headphones")
end

function AudioSwitcher.onSpeakers()
  AudioSwitcher.switchTo("speakers")
end

function AudioSwitcher.listAudioDevices()
  local devices = hs.audiodevice.allOutputDevices()
  print("Available audio output devices:")
  for _, device in ipairs(devices) do
    print(string.format("- %s", device:name()))
  end
end

function AudioSwitcher:bindHotkeys(mapping)
  local hotkeyDefinitions = {headphones = self.onHeadphones, speakers = self.onSpeakers}
  mapping = mapping or self.defaultHotkeys
  hs.spoons.bindHotkeysToSpec(hotkeyDefinitions, mapping)
  self.listAudioDevices()
  return self
end

return AudioSwitcher
