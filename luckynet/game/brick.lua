local brick = {}

function brick:new(w,h)
	-- body
	local o = {}
	o.w = w
	o.h = h
	o.type = BLOCK_TYPE_BRICK
	setmetatable(o,self)
	self.__index = self
	return o
end

function brick:init( ... )
	-- body
end

return brick