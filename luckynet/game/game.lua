local log = require 'lnlog'
local brick = require "brick"
local player = require "player"

local MAP_Width = 300
local MAP_Height = 300
local Brick_Count = 20

local game = {}

function game:init( users,notifyAllFunc )
	-- body
	self.notifyAll=notifyAllFunc

	self.map = require "map"
	self.map:init(MAP_Width,MAP_Height)
	
	log.info("start init bricks.")
	local bricks = {}
	for i=1,Brick_Count do
		local abrick = brick:new(1,1)
		table.insert(bricks,abrick)
	end
	self.map:randomPutSome(bricks)

	log.info("start init players.")
	self.players = {}
	local randomPlayers = {}
	for k,v in pairs(users.list) do
		local aplayer = player:new()
		aplayer:init(v.uid)
		self.players[k] = aplayer
		table.insert(randomPlayers,aplayer)
	end
	self.map:randomPutSome(randomPlayers)

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

function game:move( uid,di )
	-- body
	local aplayer = self.players[uid]
	assert(aplayer,"aplayer can not be found.")

	local res = self.map:move(aplayer,di)
	if res then
		self.notifyAll(NOTIFY_TYPE_MOVE,{x=aplayer.x,y=aplayer.y,id=aplayer.uid})
	else
		log.warn("player %s move fail.",uid)
	end
end

return game