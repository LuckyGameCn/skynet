local log = require 'lnlog'

MAP_COORD_SEP = "#"

local map = {}

function map:init( width,height )
	-- body
	self.width = width
	self.height = height
	self.id = 1

	self.mdata = {}
	self.blocks = {}
end

function map:randomFit( w,h )
	local rands = {}
	for i=1,self.width do
		for j=1,self.height do
			if self:isEmpty(i,j,w,h) then
				table.insert(rands,{x=i,y=j})
			end
		end
	end
	return rands
end

function map:isEmpty( i,j,w,h )
	-- body
	for x=i,i+w-1 do
		for y=j,j+h-1 do
			if self:get(x,y) then
				return false
			end
		end
	end

	return true
end

function map:randomPut( block )
	-- body
	assert(block.w)
	assert(block.h)

	local rands = self:randomFit(block.w,block.h)

	local rand = rands[math.random(1,#rands)]

	self:put(block,rand.x,rand.y)
end

--大小必须是一个类型的
function map:randomPutSome( blocks )
	-- body 先用简单的实现试试
	log.info("这里的性能问题还比较大，需要优化.")
	for i,v in ipairs(blocks) do
		self:randomPut(v)
	end
	-- local cw = blocks[1].w
	-- local ch = blocks[1].h
	-- assert(cw)
	-- assert(ch)
	-- for i,v in ipairs(blocks) do
	-- 	assert(cw==v.w,"must has same width")
	-- 	assert(ch==v.h,"must has same height")
	-- end
	-- local rands = self:randomFit(cw,ch)
	-- for i,v in ipairs(blocks) do
	-- 	local rand = popRand(rands)
	-- 	self:put(v,rand.x,rand.y)
	-- end
end

function popRand( rands )
	-- body
	local rl = #rands
	local ri = math.random(1,rl)
	local rand = rands[ri]
	for i=ri,rl do
		rands[i] = rands[i+1]
	end
	return rand
end

function map:put( block,x,y )
	-- body
	if block.id == nil then
		block.id = self.id
		self.id = self.id + 1
	end

	for i=x,x+block.w do
		for j=y,y+block.h do
			self:set(x,y,block.id)
		end
	end

	self.blocks[block.id] = block

	block.x = x
	block.y = y
end

function map:get( x,y )
	return self.mdata[x..MAP_COORD_SEP..y]
end

function map:set( x,y,v )
	local k = x..MAP_COORD_SEP..y
	self.mdata[k] = v
end

function map:move( block,di )
	-- body
	local coords = nil
	local cleans = nil

	if di == MOVE_DI_UP then
		if block.y+block.h-1 == self.height then
			return false
		else
			coords = block:coordsOn(di)
			cleans = block:coordsOn(MOVE_DI_DOWN)
		end
	elseif di == MOVE_DI_LEFT then
		if block.x == 1 then
			return false
		else
			coords = block:coordsOn(di)
			cleans = block:coordsOn(MOVE_DI_RIGHT)
		end
	elseif di == MOVE_DI_DOWN then
		if block.y == 1 then
			return false
		else
			coords = block:coordsOn(di)
			cleans = block:coordsOn(MOVE_DI_UP)
		end
	elseif di == MOVE_DI_RIGHT then
		if block.x+block.w-1 == self.width then
			return false
		else
			coords = block:coordsOn(di)
			cleans = block:coordsOn(MOVE_DI_LEFT)
		end
	else
		log.error("not valide direction.")
		return false
	end

	assert(coords)
	for i,v in ipairs(coords) do
		if self:get(v.x,v.y) then
			return false
		end
	end

	for i,v in ipairs(coords) do
		self:set(v.x,v.y,block.id)
	end

	for i,v in ipairs(cleans) do
		self:set(v.x,v.y,nil)
	end

	if di == MOVE_DI_UP then
		block.y =  block.y + 1
	elseif di == MOVE_DI_LEFT then
		block.x = block.x - 1
	elseif di == MOVE_DI_DOWN then
		block.y =  block.y - 1
	elseif di == MOVE_DI_RIGHT then
		block.x = block.x + 1
	end

	return true
end

return map