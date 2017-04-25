local snax = require 'snax'
local skynet = require 'skynet'
local log = require 'lnlog'
local agent_user = nil
local ladder = nil

function response.ladderIn(uid)
	-- body
	local u = agent_user.req.getu(uid)
	return ladder.req.In(uid,u.score)
end

function response.ladderRes(uid,lid,stid)
	-- body
	return ladder.req.Res(uid,lid,stid)
end

function response.ladderCon(uid,lid)
	-- body
	local uservalide,allcon,alluser = ladder.req.Con(uid,lid)
	if uservalide then
		if allcon then
			if alluser then
				local wd = skynet.queryservice(true,"watchdog")
				skynet.call(wd,"lua","open_agent",lid,alluser)
			end

			return true,"127.0.0.1",6024
		else
			return true
		end
	else
		return false
	end
end

function accept.xx( ... )
	-- body
end

function response.login(uid)
	-- body

	agent_user.post.readu(uid)

	return uid
end

function  init( ... )
	-- body
	log.info('game agent init.')

	ladder = snax.queryglobal("ladder")
	agent_user = snax.queryglobal("agent_user")
end

function exit( ... )
	-- body
	log.info('game agent exit.')
end