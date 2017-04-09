local snax = require 'snax'
local log = require 'lnlog'
local users = {}
local ladder = nil

function response.ladderIn(uid)
	-- body
	u = users[uid]
	return ladder.req.In(uid,u.score)
end

function response.ladderRes(uid,lid,stid)
	-- body
	return ladder.req.Res(uid,lid,stid)
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