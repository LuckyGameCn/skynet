local skynet = require 'skynet'

local lnlogger = {}

function lnlogger.info(msg)
	-- body
	skynet.error('[INFO]'..msg)
end

function lnlogger.error(msg)
	-- body
	skynet.error('[ERR]'..msg)
end

return lnlogger