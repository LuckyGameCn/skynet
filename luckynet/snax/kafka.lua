local skynet = require 'skynet'
local log = require 'lnlog'

local subs = {}

function accept.pub(event,...)
	-- body
	log.info(name)
	log.info(...)
end

function response.sub(event,name,cmd)
	-- body
	
end

function  init( ... )
	-- body
	log.info('kafka init.')
end

function exit( ... )
	-- body
	log.info('kafka exit.')
end