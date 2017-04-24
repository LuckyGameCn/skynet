local skynet = require 'skynet'
local log = require 'lnlog'
local redis = require 'redis'
local db

function response.xx( ... )
	-- body
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	log.info('user init.')
	db = redis.connect({host="127.0.0.1"})
end

function exit( ... )
	-- body
	log.info('user exit.')
end