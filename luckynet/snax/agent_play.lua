local skynet = require 'skynet'
local netpack = require 'netpack'
local log = require 'lnlog'
local debug_proto = require "debug_proto"
local socket = require 'socket'
local snax = require 'snax'
local kafka = require 'kafkaapi'

local ag_lid
local ag_users = {}
local ag_allready = false

local ag_msg = 0

function sendToAll(msg)
	-- body
	log.info("send msg to all."..msg.type)
	msg = debug_proto:encode("data",msg)
	local pack = string.pack(">s2", msg)
	for k,v in pairs(ag_users.list) do
		socket.write(v.fd,pack)
	end

	ag_msg = ag_msg + 1
end

function exitGame(uid)
	local u = ag_users.list[uid]
	kafka.pub("exitGame",uid,u.fd)
	log.info("这里的消息暂时因为嵌套使用没有解决，以后再解决.")

	ag_users.count = ag_users.count - 1

	if ag_users.count == 0 then
		log.info("agent_game end.lid=%d",ag_lid)
		snax.exit()
	end
end

function accept.data(fd,msg)
	msg = debug_proto:decode("data",msg)

	log.info("get msg %d from user %s.",msg.type,msg.id)

	if msg.type == DPROTO_TYEP_DATA_END then
		exitGame(msg.id)
	end
end

function accept.connect(lid,uid,fd)
	-- body
	assert(lid==ag_lid,"lid not match.")
	assert(ag_users.list[uid],"uid not in users.")

	log.info("user %s connect agentplay.",uid)

	local u = ag_users.list[uid]
	u.ready = true
	u.fd = fd

	if ag_allready then
		log.info("all ready.do noting.这个用户可能是重连进来的，需要设计崩溃恢复的逻辑.")
	else
		local result = true
		for k,v in pairs(ag_users.list) do
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

			skynet.fork(function()
				while true do
					log.info("ag_msg %s",ag_msg)
					if ag_msg < 10 then
						local msg = {type=DPROTO_TYEP_DATA}
						sendToAll(msg)
					else
						local msg = {type=DPROTO_TYEP_DATA_END}
						sendToAll(msg)
						break
					end
					skynet.sleep(500)
				end
			end)
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
	ag_users.list = users
	local count = 0
	for k,v in pairs(ag_users.list) do
		count = count + 1
	end
	ag_users.count = count
end

function exit( ... )
	-- body
	log.info('agentplay exit.')
end