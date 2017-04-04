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
	log.info('game agent init.')
end

function exit( ... )
	-- body
	log.info('game agent exit.')
end