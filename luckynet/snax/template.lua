local skynet = require 'skynet'
local log = require 'lnlog'

function response.xx( ... )
	-- body
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	log.info('ladder init.')
end

function exit( ... )
	-- body
	log.info('ladder exit.')
end