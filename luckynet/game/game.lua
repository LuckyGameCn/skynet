local MAP_Width = 1000
local MAP_Height = 1000
local Brick_Count = 20

local game = {}

function game:init( users )
	-- body
	self.map = require "map"
	self.map:init(MAP_Width,MAP_Height)
	
	local bricks = {}
	for i=1,Brick_Count do
		local brick = require "brick"
		table.insert(bricks,brick)
	end
	self.map:randomPutSome(bricks)

	self.players = {}
	for i,v in ipairs(users) do
		local player = require "player"
		player.init(v.uid)
		table.insert(self.players,player)
	end
	self.map:randomPutSome(self.players)
end

return game