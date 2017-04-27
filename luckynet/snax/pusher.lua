local skynet = require 'skynet'
local log = require 'lnlog'
local coroutine = require 'skynet.coroutine'

local pushes = {}
local crs = {}

function dequeue( uid )
	-- body
	local q = pushes[uid]
	if q and #q > 0 then
		return table.remove(q)
	else
		return nil
	end
end

function enqueue( uid,msg )
	assert(msg,"can not enqueue nil msg.uid="..uid)
	-- body
	local q = pushes[uid]
	if q == nil then
		q = {}
		pushes[uid] = q
	end

	table.insert(q,1,msg)
end

function response.getpush(uid)
	-- body
	assert(uid)

	local msg = dequeue(uid)

	if msg then
		return msg
	else
		local c = coroutine.running()
		crs[uid] = c
		skynet.wait(c)

		local msg = dequeue(uid)
		return msg
	end
end

function accept.push( uid,msg )
	-- body
	assert(uid)
	assert(msg)

	enqueue(uid,msg)
	
	local co = crs[uid]

	if co then
		crs[uid] = nil
		skynet.wakeup(co)
	end
end

function  init( ... )
	-- body
	log.info('pusher init.')
end

function exit( ... )
	-- body
	log.info('pusher exit.')
end