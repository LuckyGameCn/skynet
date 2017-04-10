local skynet = require "skynet"
local snax = require "snax"

local kafkaapi = {}
function kafkaapi.pub(event, ... )
	-- body
	local kafka = snax.queryglobal("kafka")
	kafka.post.pub(event,...)
end

function kafkaapi.sub(event,callback)
	skynet.dispatch("lua",function(session, source, cmd, ...)
  		if cmd == event then
  			callback(...)
  		end
	end)

	-- body
	local kafka = snax.queryglobal("kafka")
	kafka.post.sub(event,skynet.self())

end

function kafkaapi.unsub(event)
	-- body
	local kafka = snax.queryglobal("kafka")
	kafka.post.unsub(event,skynet.self())
end

return kafkaapi