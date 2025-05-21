local AudioSwitcher = {}
AudioSwitcher.__index = AudioSwitcher

-- Metadata
AudioSwitcher.name = "AudioSwitcher"
AudioSwitcher.version = "0.1"
AudioSwitcher.author = "Simon Holywell <simon@holywell.au>"
AudioSwitcher.homepage = "https://github.com/Hammerspoon/Spoons"
AudioSwitcher.license = "Apache-2.0"

local hyper = {"ctrl", "alt", "cmd"}
AudioSwitcher.defaultHotkeys = {
  speakers = {hyper, "s"},
  headphones = {hyper, "h"},
}

local speakersName = "EDIFIER R1280DB"
local headphonesName = "External Headphones"

function AudioSwitcher.setAudioOutputDevice(deviceName)
	  local device = hs.audiodevice.findOutputByName(deviceName)
  	if device then
		device:setDefaultOutputDevice()
		print(string.format("Set default output device to: %s", device:name()))
	else
		print(string.format("No %s device found.", deviceName))
	end
end

AudioSwitcher.onHeadphones = hs.fnutils.partial(AudioSwitcher.setAudioOutputDevice, headphonesName)
AudioSwitcher.onSpeakers = hs.fnutils.partial(AudioSwitcher.setAudioOutputDevice, speakersName)

function AudioSwitcher:bindHotkeys(mapping)
  local hotkeyDefinitions = {
		headphones = self.onHeadphones,
		speakers = self.onSpeakers
	}
  -- Use defaultHotkeys if mapping is nil or empty
  mapping = mapping or self.defaultHotkeys
  hs.spoons.bindHotkeysToSpec(hotkeyDefinitions, mapping)
  return self
end

return AudioSwitcher
