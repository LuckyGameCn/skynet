local skynet = require 'skynet'
local log = require 'lnlog'
local mc = require "multicast"

local subrepos = {}

function accept.pub(event,...)
	-- body
	local channel = subrepos[event]
	if channel then
		channel:publish(...)
	else
		log.info(event.." has no subscriber.ignore.")
	end
end

function response.sub(event)
	-- body
	local chan = subrepos[event]
	if not subs then
		chan = mc.new()
		subrepos[event] = chan
	end
	return chan.channel
end

-- function accept.unsub(event,addr)
-- end

function  init( ... )
	-- body
	log.info('kafka init.')
end

function exit( ... )
	-- body
	log.info('kafka exit.')
end