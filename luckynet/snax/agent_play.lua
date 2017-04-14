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
	log.info('agentplay init.')
end

function exit( ... )
	-- body
	log.info('agentplay exit.')
end