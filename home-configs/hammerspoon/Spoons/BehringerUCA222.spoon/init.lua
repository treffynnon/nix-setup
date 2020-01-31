--- === ControlEscape ===
---
--- Make the `control` key more useful: If the `control` key is tapped, treat it
--- as the `escape` key. If the `control` key is held down and used in
--- combination with another key, then provide the normal `control` key
--- behavior.
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "BehringerUCA222"
obj.version = "0.1"
obj.author = "Simon Holywell <simon@holywell.com.au>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "Apache-2.0"

obj.device = {
	productName = "USB Audio CODEC ",
	vendorName = "Burr-Brown from TI              ",
}

obj.logger = hs.logger.new("BehringerUCA222", "debug")

function obj:connected()
	local behringer = nil

	hs.timer.waitUntil(
		function()
	    behringer = hs.audiodevice.findOutputByName(obj.device.productName)
			return behringer ~= nil
		end,
		function()
			if (behringer:setDefaultOutputDevice()) then
				obj.logger.i("behringer is now default")
				behringer:setOutputMuted(false)
				obj.logger.i("behringer audio unmuted")
			else
				obj.logger.i("could not set behringer as default :(")
			end
		end,
		0.1
	)
end

function obj:disconnected()
	obj.logger.i("Muting everything!")
	hs.fnutils.each(
		hs.audiodevice.allOutputDevices(),
		function(x)
			x:setOutputMuted(true)
		end
	)
end

function obj:handleUsbChange()
	return function(event)
		if (event.productName == obj.device.productName and event.vendorName == obj.device.vendorName) then
			if (event.eventType == "added") then
				return obj:connected()
			end
			return obj:disconnected()
		end
	end
end

function obj:init()
	self.usbwatcher = hs.usb.watcher.new(self:handleUsbChange())
end

function obj:start()
	obj.logger.i('BehringerUCA222 bound and watching')
	self.usbwatcher:start()
end

return obj
