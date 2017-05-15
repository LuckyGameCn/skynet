local player = {}
player.w = 3
player.h = 3
player.type = BLOCK_TYPE_PLAYER

function player:init( uid )
	-- body
	self.uid = uid
end

return player