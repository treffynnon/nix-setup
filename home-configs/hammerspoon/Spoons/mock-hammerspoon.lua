local fnutils = require('fnutils')
local _logger = {
	new = function (name, logLevel) end,
	i = function (message) end
}

local M = {
	fnutils = fnutils,
	logger = mock(_logger, true) -- stubs out the logger with busted
}

return M
