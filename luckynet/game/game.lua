local log = require 'lnlog'

local MAP_Width = 300
local MAP_Height = 300
local Brick_Count = 20

local game = {}

function game:init( users )
	-- body
	self.map = require "map"
	self.map:init(MAP_Width,MAP_Height)
	
	log.info("start init bricks.")
	local bricks = {}
	for i=1,Brick_Count do
		local brick = require "brick"
		table.insert(bricks,brick)
	end
	self.map:randomPutSome(bricks)

	log.info("start init players.")
	self.players = {}
	for i,v in ipairs(users) do
		local player = require "player"
		player.init(v.uid)
		table.insert(self.players,player)
	end
	self.map:randomPutSome(self.players)

	log.info("start generate init data.")
	local blocks = {}
	for k,v in pairs(self.map.blocks) do
		local block = {}
		block.x = v.x
		block.y = v.y
		block.w = v.w
		block.h = v.h
		block.id = v.id
		block.type = v.type
		table.insert(blocks,block)
	end
	return blocks,MAP_Width,MAP_Height
end

return game