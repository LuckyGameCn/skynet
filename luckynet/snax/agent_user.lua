local skynet = require 'skynet'
local log = require 'lnlog'
local redis = require 'redis'
local kafka = require 'kafkaapi'
local db
local users = {}

function redis_unpack(msg)
	-- body
	local obj = {}
	for i=1,#msg,2 do
		local k = msg[i]
		local v = msg[i+1] 
		if k == "score" then
			v = tonumber(v)
		end
		obj[k] = v
	end
	return obj
end

function redis_pack( ... )
	-- body
end

function initUser(uid)
	-- body
	local u = {}
	u.uid = uid
	u.score = 500
	return u
end

function readUserDataToMem( uid )
	-- body
	local u = redis_unpack(db:hgetall(uid))
	log.info("redis user %s.",ptable(u))
	if u.uid == nil then
		log.info("user %s not exsit.init.",uid)
		u = initUser(uid)
	else
		log.info("user %s got data.read from redis.",uid)
	end
	users[uid] = u
end

function saveUserDataToDB( uid )
	-- body
	local u = users[uid]
	db:hmset(uid,"uid",u.uid,"score",u.score)
end

function saveValueToDB( uid,key,value )
	-- body
	db:hset(uid,key,value)
end

function cleanUserDataInMem( uid )
	-- body
	users[uid] = nil
end

function accept.readu( uid )
	-- body
	if users[uid] == nil then
		readUserDataToMem(uid)
	end
end

function accept.saveu( uid )
	-- body
	saveUserDataToDB(uid)
end

function accept.saveScore( uid,value )
	-- body
	local u = users[uid]
	u.score = value

	saveValueToDB(uid,"score",value)
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