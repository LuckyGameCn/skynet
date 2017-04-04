local msgserver = require "snax.msgserver"
local crypt = require "crypt"
local skynet = require "skynet"
require "skynet.manager"
local log = require "lnlog"

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

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	log.info("get request:"..username.." - "..msg)
	return "request_handler"..username..msg
end

-- call by self (when gate open)
function server.register_handler(name)
	servername = name
	log.info("msgserver "..name.." has opened.")
end

msgserver.start(server)

