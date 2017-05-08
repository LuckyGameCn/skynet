local MAP_Width = 1000
local MAP_Height = 1000

local game = {}

function game:init( ... )
	-- body
	self.map = require "map"
	self.map:init(MAP_Width,MAP_Height)
	
end

return game