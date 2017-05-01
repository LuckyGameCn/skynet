local skynet = require 'skynet'
local netpack = require 'netpack'
local log = require 'lnlog'
local debug_proto = require "debug_proto"
local socket = require 'socket'
local snax = require 'snax'
local kafka = require 'kafkaapi'

local ag_lid
local ag_users = {}
local ag_token
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

	ag_users.count = ag_users.count - 1

	if ag_users.count == 0 then
		log.info("agent_game end.lid=%d",ag_lid)
		snax.exit()
	end
end

function gameOver()
	-- body
	local msg = {type=DPROTO_TYEP_DATA_END}
	sendToAll(msg)

	local agent_user = snax.queryglobal("agent_user")
	for k,v in pairs(ag_users.list) do
		local dt = math.random(-10,10)
		v.score = v.score + dt
		log.info("set user %s score %d",k,v.score)
		agent_user.post.saveScore(k,v.score)
	end
end

function accept.data(fd,msg)
	msg = debug_proto:decode("data",msg)

	log.info("get msg %d from user %s.",msg.type,msg.id)

	if msg.type == DPROTO_TYEP_DATA_END then
		exitGame(msg.id)
	end
end

function response.connect(lid,token,uid,fd)
	-- body
	if token~=ag_token then
		log.info("token invalide")
		return false
	end
	if lid ~= ag_lid then
		log.info("lid not match.")
		return false
	end
	if not ag_users.list[uid] then
		log.info("uid not in users.")
		return false
	end

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
					if ag_msg < 5 then
						local msg = {type=DPROTO_TYEP_DATA}
						sendToAll(msg)
					else
						gameOver()
						break
					end
					skynet.sleep(200)
				end
			end)
		end
	end

	return true
end

function accept.disconnect(fd)
	-- body
	log.info("用户断开游戏场景长链接，暂时没有处理.")
end

function  init(lid,token,users)
	-- body
	log.info('agentplay init.lid %s.',lid)

	ag_lid = lid
	ag_users.list = users
	ag_token = token
	local count = 0
	for k,v in pairs(ag_users.list) do
		count = count + 1
	end
	ag_users.count = count
end

function exit( ... )
	-- body
	log.info('agentplay exit.')
	
	kafka.pub("agent_play_exit",ag_lid)
end