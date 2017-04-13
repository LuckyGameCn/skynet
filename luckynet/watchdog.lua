local skynet = require 'skynet'
local log = require 'lnlog'
local snax = require 'snax'

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			log.info("socket %s %s",cmd,subcmd)
		else
			log.info("watch dog get no socket cmd.%s",cmd)
		end
	end)

	log.info("watch dog start.")
end)