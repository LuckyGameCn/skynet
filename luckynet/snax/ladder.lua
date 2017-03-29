local skynet = require 'skynet'

function response.xx( ... )
	-- body
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	skynet.error('ladder init.')
end

function exit( ... )
	-- body
	skynet.error('ladder exit.')
end