local skynet = require 'skynet'
local log = require 'lnlog'
local debug_proto = require "debug_proto"
local socket = require 'socket'

local ag_lid
local ag_users
local ag_allready = false

function sendToAll(msg)
	-- body
	msg = debug_proto:encode("data",msg)
	for k,v in pairs(ag_users) do
		socket.write(v.fd,msg)
	end
end

function accept.connect(lid,uid,fd)
	-- body
	assert(lid==ag_lid,"lid not match.")
	assert(ag_users[uid],"uid not in users.")

	log.info("user %s connect agentplay.",uid)

	local u = ag_users[uid]
	u.ready = true
	u.fd = fd

	if ag_allready then
		log.info("all ready.do noting.这个用户可能是重连进来的，需要设计崩溃恢复的逻辑.")
	else
		local result = true
		for k,v in pairs(ag_users) do
			if v.ready then
			else
				result=false
				break
			end
		end
		if result then
			ag_allready = true
			local msg = {type=DPROTO_TYEP_DATA_INIT}
			log.info("游戏场景准备完毕，发送游戏初始化数据给所有用户.")
			sendToAll(msg)
		end
	end

end

function accept.disconnect(fd)
	-- body
	log.info("用户断开游戏场景长链接，暂时没有处理.")
end

function  init(lid,users)
	-- body
	log.info('agentplay init.lid %s.',lid)

	ag_lid = lid
	ag_users = users

	-- skynet.dispatch("client", function(session, source, cmd, subcmd, ...)
	-- 	log.info("get cmd %s",cmd)
	-- end)
end

function exit( ... )
	-- body
	log.info('agentplay exit.')
end