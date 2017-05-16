local player = {}

function player:new()
	-- body
	local o = {}
	o.w = 3
	o.h = 3
	o.type = BLOCK_TYPE_PLAYER
	setmetatable(o,self)
	self.__index = self
	return o
end

function player:init( uid )
	-- body
	self.uid = uid
end

return player