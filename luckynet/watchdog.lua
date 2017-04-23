local skynet = require 'skynet'
local log = require 'lnlog'
local snax = require 'snax'
local debug_proto = require "debug_proto"
local kafka = require "kafkaapi"
local gate
local handshake = {}
local agents = {}
local forward = {}

local SOCKET = {}
function SOCKET.open(fd, addr)
	log.info("New client from : " .. addr)
	handshake[fd] = addr
	skynet.call(gate,"lua","accept",fd)

	-- kafka.sub("exitGame",function (uid,fd)
	-- 	-- body
	-- 	skynet.call(gate,"lua","kick",fd)
	-- 	forward[fd]	= nil
	-- end)
end
function SOCKET.close(fd)
	-- body
	local agent = agents[lid]
	if agent then
		agent.post.disconnect(fd)
	else
		log.error("disconnect an unexsit fd.%s",fd)
	end
end

function SOCKET.data(fd,msg)
	-- body
	if handshake[fd] then
		local msg = debug_proto:decode("req",msg)
		if msg.type == DPROTO_TYEP_DATA_INIT then
			local lid = msg.lid
			local uid = msg.id
			local agent = agents[lid]
			if agent then
				agent.post.connect(lid,uid,fd)
				forward[fd] = agent
				handshake[fd] = nil
			else
				log.error("can not find play agent.")
			end
		else
			log.error("here only accept init type.")
		end
	else
		local agent = forward[fd]
		if agent then
			agent.post.data(fd,msg)
		else
			log.error("msg should be forward.")
		end
	end
end

local CMD = {}
function CMD.open_agent(lid,users)
	-- body
	local agent = snax.newservice("agent_play",lid,users)
	agents[lid] = agent
end
function CMD.open(conf)
	-- body
	skynet.call(gate, "lua", "open" , conf)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			log.debug("get cmd %s %s",cmd,subcmd)
			SOCKET[subcmd](...)
		else
			local ret = CMD[cmd](subcmd,...)
			skynet.ret(skynet.pack(ret))
		end
	end)

	log.info("watch dog start.")

	gate = skynet.newservice("gate")
end)