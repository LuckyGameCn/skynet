local log = require "lnlog"
local block = {}

function block:new( )
	-- body
end

function block:coordsOn( di )
	-- body
	local x = self.x
	local y = self.y
	local coords = {}
	if di == MOVE_DI_RIGHT then
		for i=y,y+self.h-1 do
			table.insert(coords,{x=(x+1),y=i})
		end
	elseif di == MOVE_DI_DOWN then
		for i=x,x+self.w-1 do
			table.insert(coords,{x=i,y=(y-1)})
		end
	elseif di == MOVE_DI_LEFT then
		for i=y,y+self.h-1 do
			table.insert(coords,{x=(x-1),y=i})
		end
	elseif di == MOVE_DI_UP then
		for i=x,x+self.w-1 do
			table.insert(coords,{x=i,y=(y+1)})
		end
	else
		log.error("invalid di in block move.")
	end

	return coords
end

return block