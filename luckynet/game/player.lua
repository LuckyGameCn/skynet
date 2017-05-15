local player = {}
player.w = 2
player.h = 2
function player:init( uid )
	-- body
	self.uid = uid
end

return player