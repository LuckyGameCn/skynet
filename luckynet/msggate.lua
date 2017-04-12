local msgserver = require "snax.msgserver"
local crypt = require "crypt"
local skynet = require "skynet"
local snax = require "snax"
require "skynet.manager"
local log = require "lnlog"
local debug_proto = require "debug_proto"
local kafka = require "kafkaapi"

local server = {}
local users = {}

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(uid, secret)
	assert(uid)
	assert(secret)

	log.info("msggate login %s",uid)
	
	local username = msgserver.username(uid, uid, servername)

	msgserver.login(username, secret)

	users[username] = {uid = uid}

	-- you should return unique subid
	return uid
end

-- call by agent
function server.logout_handler(uid, subid)
	local username = msgserver.username(uid, uid, servername)
	msgserver.logout(username)

	log.info("user:%s logout.",uid)

	kafka.pub("logout",uid)
end

-- call by login server
function server.kick_handler(uid, subid)
	server.logout_handler(uid,subid)
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local user = users[username]

	log.info("user:%s disconnect.",user.uid)

	kafka.pub("disconnect",user.uid)
end

function retRequest(msg)
	log.info("ret request:"..ptable(msg))
	return debug_proto:encode("res",msg)
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	msg = debug_proto:decode("req",msg)
	log.info("get request["..users[username].uid.."] - "..msg.type)
	if msg.type == DPROTO_TYEP_LADDERIN then
		local id = msg.id
		local agent = snax.queryglobal("agent_game")
		local ret,lid = agent.req.ladderIn(id)
		return retRequest({res=ret,lid=lid})
	elseif msg.type == DPROTO_TYEP_LADDERRES then
		local agent = snax.queryglobal("agent_game")
		local ret,lid,stid,av,list = agent.req.ladderRes(msg.id,msg.lid,msg.stid)
		return retRequest({res=ret,lid=lid,stid=stid,average=av,linelist=list})
	elseif msg.type == DPROTO_TYEP_LADDERCON then
		local agent = snax.queryglobal("agent_game")
		local ret,addr,port = agent.req.ladderCon(msg.id,msg.lid)
		return retRequest({res=ret,play_server_add=addr,play_server_port=port})
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

