local snax = require 'snax'
local skynet = require 'skynet'
local log = require 'lnlog'
local kafka = require 'kafkaapi'

local agent_user = nil
local ladder = nil

function response.ladderIn(uid)
	-- body
	local u = agent_user.req.getu(uid)
	return ladder.req.In(uid,u.score)
end

function response.ladderCon(uid,lid)
	-- body
	return ladder.req.Con(uid,lid)
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	log.info('game agent init.')

	ladder = snax.queryglobal("ladder")
	agent_user = snax.queryglobal("agent_user")

	kafka.sub("ladder_all_confirm",function ( lid,av,users )
		-- body
		local wd = skynet.queryservice(true,"watchdog")
		skynet.call(wd,"lua","open_agent",lid,users)

		local msg = {type=DPROTO_TYEP_LADDEROK,average=tostring(av),linelist=users,play_server_add="127.0.0.1",play_server_port=6024}

		local pusher = snax.queryglobal("pusher")
		for k,v in pairs(users) do
			pusher.post.push(k,msg)
		end

	end)
end

function exit( ... )
	-- body
	log.info('game agent exit.')

	kafka.unsub("ladder_all_confirm")
end