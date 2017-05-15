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
			if isEmpty(i,j,w,h) then
				table.insert(rands,{x=i,y=j})
			end
		end
	end
	return rands
end

function isEmpty( i,j,w,h )
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
end

function map:get( x,y )
	return self.mdata[x..MAP_COORD_SEP..y]
end

function map:set( x,y,v )
	local k = x..MAP_COORD_SEP..y
	self.mdata[k] = v
end

return map