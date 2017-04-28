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
local agent

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(uid, secret)
	assert(uid)
	assert(secret)

	log.info("msggate login %s",uid)
	
	local username = msgserver.username(uid, uid, servername)

	msgserver.login(username, secret)

	users[username] = uid

	kafka.pub("login",uid)

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
	local uid = users[username]

	log.info("user:%s disconnect.",uid)

	kafka.pub("disconnect",uid)
end

function retRequest(uid,msg)
	assert(msg,"msg nil of user "..uid)
	assert(msg.type,"msg type of user "..uid)

	log.info("ret [%s] %s",uid,ptable(msg))
	return debug_proto:encode("res",msg)
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	msg = debug_proto:decode("req",msg)
	log.info("get ["..users[username].."] %s",ptable(msg))
	if msg.type == DPROTO_TYEP_LADDERIN then
		local id = msg.id
		local ret,lid = agent.req.ladderIn(id)
		return retRequest(id,{type=ret,lid=lid})
	elseif msg.type == DPROTO_TYEP_LADDERCON then
		local ret,resmsg = agent.req.ladderCon(msg.id,msg.lid)
		return retRequest(msg.id,{type=ret,resmsg=resmsg})
	elseif msg.type == DPROTO_TYEP_LOGOUT then
		local uid = users[username]
		server.kick_handler(uid,uid)
		return retRequest(uid,{type=DPROTO_TYEP_OK})
	elseif msg.type == DPROTO_TYEP_PUSH then
		local pusher = snax.queryglobal("pusher")
		return retRequest(users[username],pusher.req.getpush(users[username]))
	else
		local em = "invalide msg =>"..msg
		log.error(em)
		return retRequest({type=DPROTO_TYEP_FAIL,resmsg=em})
	end
end

-- call by self (when gate open)
function server.register_handler(name)
	servername = name
	log.info("msgserver "..name.." has opened.")

	agent = snax.queryglobal("agent_game")
end

msgserver.start(server)

