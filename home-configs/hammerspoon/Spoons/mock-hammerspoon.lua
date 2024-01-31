local fnutils = require('fnutils')
local inspect = require('inspect')

local M = {
  inspect = inspect,
  fnutils = fnutils,
  logger = {new = function() end, i = function() end},
  alert = function() end,
}

return M
