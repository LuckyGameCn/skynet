local snax = require 'snax'
local log = require 'lnlog'
local users = {}
local ladder = nil

function response.ladderIn(uid)
	-- body
	local u = users[uid]
	return ladder.req.In(uid,u.score)
end

function response.ladderRes(uid,lid,stid)
	-- body
	return ladder.req.Res(uid,lid,stid)
end

function response.ladderCon(uid,lid)
	-- body
	local uservalide,allcon = ladder.req.Con(uid,lid)
	if uservalide then
		if allcon then
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

function response.login(uid,login_type)
	-- body
	local u = {}
	u.score = 500

	users[uid] = u

	return uid
end

function  init( ... )
	-- body
	log.info('game agent init.')

	ladder = snax.queryglobal("ladder")
end

function exit( ... )
	-- body
	log.info('game agent exit.')
end