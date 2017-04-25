local snax = require "snax"
local mc = require "multicast"
local log = require "lnlog"

local subscribers = {}

local kafkaapi = {}
function kafkaapi.pub(event, ... )
	-- body
	local kafka = snax.queryglobal("kafka")
	kafka.post.pub(event,...)
end

function kafkaapi.sub(event,callback)

	assert(not subscribers[event])

	local kafka = snax.queryglobal("kafka")
	local cid = kafka.req.sub(event)

	local c = mc.new({channel = cid,
				dispatch = function (channel, source, ...) 
						callback(...) 
				end,}
	)
	c:subscribe()
	
	subscribers[event] = c

	log.info("订阅事件 "..event)
	
end

function kafkaapi.unsub(event)
	-- body
	local key = event..addr
	local c = subscribers[key]
	c:unsubscribe()
	c:delete()
	subscribers[key] = nil
end

return kafkaapi