lu = require('luaunit')
package.path = '../home-configs/hammerspoon/Spoons/?/?.lua;' .. package.path
sp = require('init')

function testAddPositive()
	lu.assertEquals(add(1,1),2)
end

function testAddZero()
	lu.assertEquals(add(1,0),0)
	lu.assertEquals(add(0,5),0)
	lu.assertEquals(add(0,0),0)
end

os.exit( lu.LuaUnit.run() )
