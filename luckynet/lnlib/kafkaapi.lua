local skynet = require "skynet"
local snax = require "snax"
local mc = require "multicast"

local subscribers = {}

local kafkaapi = {}
function kafkaapi.pub(event, ... )
	-- body
	local kafka = snax.queryglobal("kafka")
	kafka.post.pub(event,...)
end

function kafkaapi.sub(event,callback)

	local kafka = snax.queryglobal("kafka")
	local cid = kafka.post.sub(event,skynet.self())

	local c = mc.new({channel = cid,
				dispatch = function (channel, source, ...) 
						callback(...) 
				end,}
	)
	c:subscribe()
	local key = event..addr
	subscribers[key] = c

	log.info("订阅事件 "..event.." for "..addr)
	
end

function kafkaapi.unsub(event)
	-- body
	-- local kafka = snax.queryglobal("kafka")
	-- kafka.post.unsub(event,skynet.self())
	local key = event..addr
	local c = subscribers[key]
	c:unsubscribe()
	c:delete()
	subscribers[key] = nil
end

return kafkaapi