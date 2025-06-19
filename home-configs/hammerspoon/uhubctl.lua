-- uhubctl.lua
--
-- A Lua wrapper for uhubctl to control USB device power
--
-- Usage:
--   local uhubctl = require('uhubctl')
--   uhubctl.start()
--   uhubctl.turnOffDevice("My USB Device")
--   uhubctl.turnOnDevice("My USB Device")
--   local isOn = uhubctl.getDeviceState("My USB Device")
--

local uhubctl = {}

-- Configuration
uhubctl.uhubctlPath = "uhubctl"  -- Will use PATH to find uhubctl
uhubctl.stateFile = hs.configdir .. "/uhubctl_state.json"
uhubctl.discoveredDevices = {}  -- Will store discovered USB devices
uhubctl.deviceStates = {}  -- Will store current device states
uhubctl.isDiscovering = false

-- Initialise the library
function uhubctl.start()
  uhubctl.loadState()
  uhubctl.discoverDevices()
end

-- Load device states from file
function uhubctl.loadState()
  local file = io.open(uhubctl.stateFile, "r")
  if file then
    local content = file:read("*all")
    file:close()
    local success, data = pcall(hs.json.decode, content)
    if success and data then
      uhubctl.deviceStates = data.deviceStates or {}
      print("uhubctl: Loaded device states from " .. uhubctl.stateFile)
    else
      print("uhubctl: Failed to parse state file, starting with empty states")
      uhubctl.deviceStates = {}
    end
  else
    print("uhubctl: No state file found, starting fresh")
    uhubctl.deviceStates = {}
  end
end

-- Save device states to file
function uhubctl.saveState()
  local data = {
    deviceStates = uhubctl.deviceStates,
    lastSaved = os.time()
  }

  local file = io.open(uhubctl.stateFile, "w")
  if file then
    file:write(hs.json.encode(data))
    file:close()
    print("uhubctl: Saved device states to " .. uhubctl.stateFile)
  else
    print("uhubctl: Failed to save state file")
  end
end

-- Discover USB devices using uhubctl and parse the output
function uhubctl.discoverDevices()
  if uhubctl.isDiscovering then
    return
  end

  uhubctl.isDiscovering = true
  print("uhubctl: Discovering USB devices...")

  local task = hs.task.new(uhubctl.uhubctlPath, function(exitCode, stdOut, stdErr)
    uhubctl.isDiscovering = false

    if exitCode == 0 then
      uhubctl.parseUhubctlOutput(stdOut)
      print("uhubctl: Device discovery completed")
      uhubctl.listDiscoveredDevices()
    else
      print("uhubctl: Failed to discover devices. Make sure uhubctl is installed.")
      print("Error: " .. stdErr)
    end
  end, {})

  task:start()
end

-- Parse uhubctl output to discover devices
function uhubctl.parseUhubctlOutput(output)
  uhubctl.discoveredDevices = {}

  local currentHub = nil
  local currentLocation = nil

  for line in output:gmatch("[^\r\n]+") do
    -- Look for hub lines like "Current status for hub 1 [1a40:0101 USB 2.0 Hub, USB 2.00, 4 ports]"
    local hubMatch = line:match("Current status for hub (%d+)")
    if hubMatch then
      currentHub = hubMatch
    end

    -- Look for port lines like "  Port 1: 0100 power"
    local port, status = line:match("^%s*Port (%d+):%s*(%S+)")
    if port and status and currentHub then
      currentLocation = currentHub .. "-" .. port

      -- Look for device information on the same line or next lines
      local deviceInfo = line:match("Port %d+:%s*%S+%s+(.+)")
      if deviceInfo and deviceInfo ~= "" and not deviceInfo:match("^power") then
        -- Clean up device name
        deviceInfo = deviceInfo:gsub("%s+", " "):gsub("^%s*", ""):gsub("%s*$", "")

        if deviceInfo ~= "" then
          local isPowered = status:match("power") ~= nil

          uhubctl.discoveredDevices[deviceInfo] = {
            name = deviceInfo,
            location = currentLocation,
            hub = currentHub,
            powered = isPowered
          }

          -- Initialise state if not exists
          if uhubctl.deviceStates[deviceInfo] == nil then
            uhubctl.deviceStates[deviceInfo] = isPowered
          end
        end
      end
    end
  end

  uhubctl.saveState()
end

-- List discovered devices
function uhubctl.listDiscoveredDevices()
  if next(uhubctl.discoveredDevices) == nil then
    print("uhubctl: No USB devices discovered")
    return
  end

  print("uhubctl: Discovered USB devices:")
  for name, device in pairs(uhubctl.discoveredDevices) do
    local state = uhubctl.deviceStates[name] and "ON" or "OFF"
    print(string.format("- '%s': %s (hub: %s, location: %s)", name, state, device.hub, device.location))
  end
end

-- Find device by name (case-insensitive partial match)
function uhubctl.findDevice(deviceName)
  -- First try exact match
  if uhubctl.discoveredDevices[deviceName] then
    return uhubctl.discoveredDevices[deviceName]
  end

  -- Then try case-insensitive exact match
  local lowerDeviceName = deviceName:lower()
  for name, device in pairs(uhubctl.discoveredDevices) do
    if name:lower() == lowerDeviceName then
      return device
    end
  end

  -- Finally try partial match
  for name, device in pairs(uhubctl.discoveredDevices) do
    if name:lower():find(lowerDeviceName, 1, true) then
      return device
    end
  end

  return nil
end

-- Set device power state
function uhubctl.setDevicePower(deviceName, powerOn)
  local device = uhubctl.findDevice(deviceName)
  if not device then
    print("uhubctl: Device '" .. deviceName .. "' not found")
    return false
  end

  local action = powerOn and "on" or "off"
  local args = {"-l", device.location, "-a", action}

  -- Add hub parameter if specified
  if device.hub then
    table.insert(args, 1, "-h")
    table.insert(args, 2, device.hub)
  end

  print(string.format("uhubctl: Turning %s device '%s' at location '%s'",
                      action, device.name, device.location))

  local task = hs.task.new(uhubctl.uhubctlPath, function(exitCode, stdOut, stdErr)
    if exitCode == 0 then
      uhubctl.deviceStates[device.name] = powerOn
      uhubctl.saveState()
      print(string.format("uhubctl: Successfully turned %s '%s'", action, device.name))
    else
      print(string.format("uhubctl: Failed to turn %s '%s'", action, device.name))
      print("Error: " .. stdErr)
    end
  end, args)

  task:start()
  return true
end

-- Turn device on
function uhubctl.turnOnDevice(deviceName)
  return uhubctl.setDevicePower(deviceName, true)
end

-- Turn device off
function uhubctl.turnOffDevice(deviceName)
  return uhubctl.setDevicePower(deviceName, false)
end

-- Toggle device power
function uhubctl.toggleDevice(deviceName)
  local device = uhubctl.findDevice(deviceName)
  if not device then
    print("uhubctl: Device '" .. deviceName .. "' not found")
    return false
  end

  local currentState = uhubctl.deviceStates[device.name]
  local newState = not currentState

  return uhubctl.setDevicePower(device.name, newState)
end

-- Get device state
function uhubctl.getDeviceState(deviceName)
  local device = uhubctl.findDevice(deviceName)
  if not device then
    return nil
  end
  return uhubctl.deviceStates[device.name]
end

-- Refresh device discovery
function uhubctl.refreshDevices()
  return uhubctl.discoverDevices()
end

-- Get list of all discovered device names
function uhubctl.getDeviceNames()
  local names = {}
  for name, _ in pairs(uhubctl.discoveredDevices) do
    table.insert(names, name)
  end
  return names
end

-- Check if uhubctl is available
function uhubctl.isAvailable()
  local task = hs.task.new("/usr/bin/which", function(exitCode, stdOut, stdErr)
    if exitCode == 0 then
      print("uhubctl: Found uhubctl at " .. stdOut:gsub("%s+", ""))
      return true
    else
      print("uhubctl: uhubctl not found in PATH")
      return false
    end
  end, {uhubctl.uhubctlPath})

  task:start()
end

return uhubctl
