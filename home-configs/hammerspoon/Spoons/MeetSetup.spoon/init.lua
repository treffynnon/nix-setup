-- MeetSetup.spoon
--
-- Prepares audio and lighting when a Google Meet URL is opened through the
-- system URL handler, and reverts it on demand.
--
-- Only URLs dispatched by macOS reach this spoon; navigating to a Meet link
-- inside an already open browser does not.
--
-- Each part is applied independently. A missing microphone or an unreachable
-- light must not stop the meeting from opening.
local MeetSetup = {}
MeetSetup.__index = MeetSetup

-- Metadata
MeetSetup.name = "MeetSetup"
MeetSetup.version = "0.1"
MeetSetup.author = "Simon Holywell <simon@holywell.au>"
MeetSetup.homepage = "https://github.com/Hammerspoon/Spoons"
MeetSetup.license = "Apache-2.0"

MeetSetup.defaultHotkeys = {revert = {{"cmd", "alt"}, "x"}}

-- Preferred devices, first successful switch wins.
MeetSetup.playbackOutputs = {
  "US-2x2", "External Headphones", "EDIFIER R1280DB", "MacBook Pro Speakers",
}
MeetSetup.captureInputs = {"Yeti Stereo Microphone", "MacBook Pro Microphone"}

MeetSetup.browserBundleID = "com.google.Chrome"

-- Collaborators, assigned in init.lua so this spoon stays testable.
MeetSetup.audioSwitcher = nil
MeetSetup.keyLight = nil

-- The state in place before the first unrestored Meet URL open. Later Meet URL
-- opens leave it alone, so reverting always returns to pre-meeting state.
MeetSetup.snapshot = nil

-- Keyed by AudioSwitcher.status.
local audioLines = {
  switched = function(label, device) return string.format("%s: %s", label, device) end,
  failed = function(label, device) return string.format("%s failed. Still: %s", label, device) end,
}

-- Keyed by KeyLightNeo.result.
local lightLines = {
  ok = function(power) return string.format("Key Light: %s", power) end,
  failed = function() return "Key Light failed. Unreachable" end,
  skipped = function() return "Key Light: unchanged" end,
}

-- One alert covering all three parts, so a failure is never silent and a
-- success never stacks three alerts.
local function report(title, playback, capture, light)
  local message = table.concat({
    title, audioLines[playback.status]("Playback", playback.device),
    audioLines[capture.status]("Capture", capture.device), lightLines[light.status](light.power),
  }, "\n")
  hs.alert.show(message)
  print(message)
end

-- Latches the snapshot. Returns it only when this call created it, so a second
-- Meet URL open cannot overwrite the light state recorded by the first.
local function latchSnapshot(playback, capture)
  if MeetSetup.snapshot then return nil end
  MeetSetup.snapshot = {
    playback = playback,
    capture = capture,
    light = MeetSetup.keyLight.power.unknown,
  }
  return MeetSetup.snapshot
end

function MeetSetup.apply()
  local audio = MeetSetup.audioSwitcher
  local keyLight = MeetSetup.keyLight

  -- Read the current devices before switching them.
  local pending = latchSnapshot(audio.currentDeviceName("playback"),
                                audio.currentDeviceName("capture"))

  local playback = audio.switchChannel("playback", MeetSetup.playbackOutputs)
  local capture = audio.switchChannel("capture", MeetSetup.captureInputs)

  keyLight.getPower(function(current)
    -- An unreachable light leaves the snapshot as unknown, and reverting then
    -- leaves the light as it is.
    if pending then pending.light = current end
    keyLight.setPower(keyLight.power.on,
                      function(light) report("Meet", playback, capture, light) end)
  end)
end

function MeetSetup.open(url)
  MeetSetup.apply()
  hs.application.launchOrFocusByBundleID(MeetSetup.browserBundleID)
  hs.urlevent.openURLWithBundle(url, MeetSetup.browserBundleID)
end

-- Restoring an unknown light means leaving it alone.
local function restoreLight(power, callback)
  local keyLight = MeetSetup.keyLight
  local restores = {
    [keyLight.power.unknown] = function()
      callback({status = keyLight.result.skipped, power = power})
    end,
  }
  local restore = restores[power] or function() keyLight.setPower(power, callback) end
  restore()
end

function MeetSetup.revert()
  local snapshot = MeetSetup.snapshot
  if not snapshot then
    hs.alert.show("Nothing to revert")
    return
  end

  -- Cleared up front: a partial restore still ends the latch, so the next Meet
  -- URL open snapshots afresh.
  MeetSetup.snapshot = nil

  local audio = MeetSetup.audioSwitcher
  local playback = audio.switchChannel("playback", {snapshot.playback})
  local capture = audio.switchChannel("capture", {snapshot.capture})

  restoreLight(snapshot.light, function(light) report("Reverted", playback, capture, light) end)
end

function MeetSetup:bindHotkeys(mapping)
  local hotkeyDefinitions = {revert = self.revert}
  hs.spoons.bindHotkeysToSpec(hotkeyDefinitions, mapping or self.defaultHotkeys)
  return self
end

return MeetSetup
