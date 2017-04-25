local skynet = require 'skynet'
local log = require 'lnlog'
local redis = require 'redis'
local kafka = require 'kafkaapi'
local db
local users = {}

function initUser(uid)
	-- body
	local u = {}
	u.uid = uid
	u.score = 500
	return u
end

function readUserDataToMem( uid )
	-- body
	local u = db:hgetall(uid)
	if u.uid == nil then
		u = initUser(uid)
	end
	users[uid] = u
end

function saveUserDataToDB( uid )
	-- body
	local u = users[uid]
	db:hmset("uid",u.uid,"score",u.score)
end

function cleanUserDataInMem( uid )
	-- body
	users[uid] = nil
end

function accept.readu( uid )
	-- body
	readUserDataToMem(uid)
end

function response.getu( uid )
	-- body
	local u = users[uid]
	return u
end

function response.get( uid,key )
	-- body
	local u = users[uid]
	return u[key]
end

function accept.set( uid,key,value )
	-- body
	local u = users[uid]
	u[key] = value
end

--这个接口谨慎提供
function accept.setu( uid,user )
	-- body
	users[u] = user
end

function  init( ... )
	-- body
	log.info('user init.')
	db = redis.connect({host="127.0.0.1"})
	assert(db)

	kafka.sub("login",function (uid)
		-- body
		readUserDataToMem(uid)
	end)
	kafka.sub("logout",function (uid)
		-- body
		saveUserDataToDB(uid)
		cleanUserDataInMem(uid)
	end)
end

function exit( ... )
	-- body
	log.info('user exit.')

	kafka.unsub("login")
	kafka.unsub("logout")
end