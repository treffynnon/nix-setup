-- KeyLightNeo.spoon
--
-- Reads and sets the power of an Elgato Key Light Neo.
--
-- The light is plugged into USB, where it has no IP address and speaks HID
-- rather than the Elgato HTTP API. Hammerspoon cannot write HID reports, so
-- this spoon shells out to the elgato-usb helper that home-manager installs.
--
-- Brightness and colour temperature are deliberately left alone - only power
-- is controlled here.
local KeyLightNeo = {}
KeyLightNeo.__index = KeyLightNeo

-- Metadata
KeyLightNeo.name = "KeyLightNeo"
KeyLightNeo.version = "0.2"
KeyLightNeo.author = "Simon Holywell <simon@holywell.au>"
KeyLightNeo.homepage = "https://github.com/Hammerspoon/Spoons"
KeyLightNeo.license = "Apache-2.0"

-- Power states. Strings rather than booleans so "we could not reach the light"
-- stays distinct from "the light is off".
KeyLightNeo.power = {on = "on", off = "off", unknown = "unknown"}

-- Outcome of a power request.
KeyLightNeo.result = {ok = "ok", failed = "failed", skipped = "skipped"}

-- Absolute path to the elgato-usb helper, assigned in init.lua.
KeyLightNeo.helperPath = nil

-- The helper answers in milliseconds when the light is plugged in, so this only
-- covers a wedged USB device.
KeyLightNeo.timeout = 5

local powerFromOnValue = {[0] = KeyLightNeo.power.off, [1] = KeyLightNeo.power.on}

local helperArguments = {[KeyLightNeo.power.on] = "on", [KeyLightNeo.power.off] = "off"}

local resultForPower = {[KeyLightNeo.power.unknown] = KeyLightNeo.result.failed}

-- Wrap a callback so it runs at most once: the helper and its timeout race.
local function once(callback)
  local state = "pending"
  return function(...)
    if state == "done" then return end
    state = "done"
    callback(...)
  end
end

-- Runs the helper and hands its stdout to the callback, or nil when the light
-- could not be reached.
local function run(argument, callback)
  local finish = once(callback)

  local task = hs.task.new(KeyLightNeo.helperPath, function(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
      print(string.format("KeyLightNeo: %s failed: %s", argument, stdErr))
      finish(nil)
      return
    end
    finish(stdOut)
  end, {argument})

  hs.timer.doAfter(KeyLightNeo.timeout, function()
    task:terminate()
    finish(nil)
  end)

  task:start()
end

local function powerFromReply(reply)
  if not reply then return KeyLightNeo.power.unknown end
  local decoded, payload = pcall(hs.json.decode, reply)
  local light = decoded and payload and payload.lights and payload.lights[1]
  if not light then return KeyLightNeo.power.unknown end
  return powerFromOnValue[light.on] or KeyLightNeo.power.unknown
end

function KeyLightNeo.getPower(callback)
  run("get", function(reply) callback(powerFromReply(reply)) end)
end

function KeyLightNeo.setPower(power, callback)
  local argument = helperArguments[power]
  if not argument then
    callback({status = KeyLightNeo.result.skipped, power = KeyLightNeo.power.unknown})
    return
  end

  run(argument, function(reply)
    -- The light echoes its new state, so trust that over what was asked for.
    local reported = powerFromReply(reply)
    callback({status = resultForPower[reported] or KeyLightNeo.result.ok, power = reported})
  end)
end

return KeyLightNeo
