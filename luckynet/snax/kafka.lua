local skynet = require 'skynet'
local log = require 'lnlog'

local subrepos = {}

function accept.pub(event,...)
	-- body
	local subs = subrepos[event]
	for i,v in ipairs(subs) do
		skynet.send(v.addr,'lua',event,v.cmd,...)
	end
end

function accept.sub(event,addr,cmd)
	-- body
	local subs = subrepos[event]
	if not subs then
		subs = {}
	end

	v = {}
	v.addr = addr
	v.cmd = cmd

	table.insert(subs,v)

	lnlog.info("sub "..event.." for "..addr)
end

function accept.unsub(event,addr)
	local subs = subrepos[event]
	if subs then
		local rindex = -1
		for i,v in ipairs(subs) do
			if v.addr = addr then
				rindex = i
				break
			end
		end
		if rindex>=0 then
			table.remove(subs,rindex)
			lnlog.info("unsub "..event.." for "..addr)
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