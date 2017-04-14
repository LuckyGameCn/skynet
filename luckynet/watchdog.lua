local skynet = require 'skynet'
local log = require 'lnlog'
local gate

local SOCKET = {}
function SOCKET.open(fd, addr)
	log.info("New client from : " .. addr)
	agent[fd] = skynet.newservice("agent")
	skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self() })
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			log.info("socket %s %s",cmd,subcmd)
			SOCKET[subcmd](...)
		else
			log.info("watch dog get no socket cmd.%s",cmd)
		end
	end)

	log.info("watch dog start.")

	gate = skynet.newservice("gate")
end)