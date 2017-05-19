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
end
function SOCKET.close(fd)
	-- body
	local agent = forward[fd]
	if agent then
		agent.post.disconnect(fd)
	else
		log.info("disconnect an unexsit fd.%s",fd)
	end
end

function SOCKET.data(fd,msg)
	-- body
	if handshake[fd] then
		local msg = debug_proto:decode("req",msg)
		if msg.type == DPROTO_TYEP_DATA_INIT then
			local lid = msg.lid
			local uid = msg.id
			local token = msg.token
			local agent = agents[lid]
			if agent then
				local ok = agent.req.connect(lid,token,uid,fd)
				if ok then
					forward[fd] = agent
					handshake[fd] = nil
				else
					log.error("connect agent play fail.")
					skynet.call(gate,"lua","kick",fd)
					handshake[fd] = nil
				end
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
function CMD.open_agent(lid,token,users)
	-- body
	local agent = snax.newservice("agent_play",lid,token,users)
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
			SOCKET[subcmd](...)
		else
			local ret = CMD[cmd](subcmd,...)
			skynet.ret(skynet.pack(ret))
		end
	end)

	log.info("watch dog start.")

	gate = skynet.newservice("gate")

	kafka.sub("exitGame",function (uid,fd)
		-- body
		log.info("用户 %s 完成游戏，踢出gate.",uid)
		
		skynet.call(gate,"lua","kick",fd)
		forward[fd]	= nil
	end)

	kafka.sub("agent_play_exit",function ( lid )
		-- body
		agents[lid] = nil
	end)
end)