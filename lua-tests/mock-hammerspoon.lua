local fnutils = require('fnutils')
local M = {
	fnutils = fnutils,
	logger = {
		new = function (name, logLevel) end,
		i = function (message) end
	}
}
return M
