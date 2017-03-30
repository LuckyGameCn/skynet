local skynet = require 'skynet'
local log = require 'lnlog'
local snax = require 'snax'

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			log.info("socket.."..subcmd)
			local kafka = snax.globalservice("kafka")
			kafka.post.pub(cmd.."_"..subcmd,...)
		else
			log.info("watch dog get no socket cmd."..cmd)
		end
	end)

	log.info("watch dog start.")
end)