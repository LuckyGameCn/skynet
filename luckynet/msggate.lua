local msgserver = require "snax.msgserver"
local crypt = require "crypt"
local skynet = require "skynet"
local snax = require "snax"
require "skynet.manager"
local log = require "lnlog"
local debug_proto = require "debug_proto"

local server = {}

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(uid, secret)
	assert(uid)
	assert(secret)

	log.info("msggate login "..uid.." - "..secret)
	
	local username = msgserver.username(uid, uid, servername)

	log.info("username "..username)

	msgserver.login(username, secret)

	-- you should return unique subid
	return uid
end

-- call by agent
function server.logout_handler(uid, subid)
	msgserver.logout(u.username)
end

-- call by login server
function server.kick_handler(uid, subid)
	local username = msgserver.username(uid, uid, servername)
	msgserver.logout(username)
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	
end

function retRequest(msg)
	log.info("ret request:"..PrintTable(msg))
	return debug_proto:encode("res",msg)
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	msg = debug_proto:decode("req",msg)
	log.info("get request:"..username.." - "..msg.type)
	if msg.type == DPROTO_TYEP_LADDERIN then
		local id = msg.id
		local agent = snax.queryglobal("agent_game")
		local ret,lid = agent.req.ladderIn(id)
		return retRequest({res=ret,lid=lid})
	elseif msg.type == DPROTO_TYEP_LADDERRES then
		local agent = snax.queryglobal("agent_game")
		local lid,stid,list = agent.req.ladderRes(msg.id,msg.lid,msg.stid)
		return retRequest({res=(lid~=nil),lid=lid,stid=stid,linelist=list})
	else
		local em = "invalide msg =>"..msg
		log.error(em)
		return retRequest({res=false,resmsg=em})
	end
end

-- call by self (when gate open)
function server.register_handler(name)
	servername = name
	log.info("msgserver "..name.." has opened.")
end

msgserver.start(server)

