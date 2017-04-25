local login = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"
local log = require "lnlog"
local snax = require "snax"

local server = {
	host = "127.0.0.1",
	port = 8001,
	multilogin = false,	-- disallow multilogin
	name = "login_master",
	instance = 1
}

local user_online = {}

function server.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)
	local user, server, login_type = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	login_type = crypt.base64decode(login_type)
	return server, user
end

function server.login_handler(server, uid, secret)
	local last = user_online[uid]
	if last then
		local msggate = skynet.queryservice(true,"msggate")
		skynet.call(msggate,"lua","kick",uid,secret)
		log.info("user is already online.kick last."..uid)
	else
		log.info(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	end
	
	local subid
	if server == 'msggate_sample' then
		local msggate = skynet.queryservice(true,"msggate")
		subid = tostring(skynet.call(msggate, "lua", "login", uid, secret))
	else
		log.err("invalide server:"..server)
	end
	
	user_online[uid] = uid

	return subid
end

function server.command_handler(command, ...)
	
end

login(server)
