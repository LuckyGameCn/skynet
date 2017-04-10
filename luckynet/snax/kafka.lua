local skynet = require 'skynet'
local log = require 'lnlog'

local subrepos = {}

function accept.pub(event,...)
	-- body
	local subs = subrepos[event]
	if subs then
		for i,v in ipairs(subs) do
			skynet.send(v.addr,'lua',event,...)
		end
	else
		log.info(event.." has no subscriber.ignore.")
	end
end

function accept.sub(event,addr,callback)
	-- body
	local subs = subrepos[event]
	if not subs then
		subs = {}
		subrepos[event] = subs
	end

	v = {}
	v.addr = addr
	v.callback = callback

	table.insert(subs,v)

	log.info("订阅事件 "..event.." for "..addr)
end

function accept.unsub(event,addr)
	local subs = subrepos[event]
	if subs then
		local rindex = -1
		for i,v in ipairs(subs) do
			if v.addr == addr then
				rindex = i
				break
			end
		end
		if rindex>=0 then
			table.remove(subs,rindex)
			log.info("unsub "..event.." for "..addr)
		end
	end
end

function  init( ... )
	-- body
	log.info('kafka init.')
end

function exit( ... )
	-- body
	log.info('kafka exit.')
end