local skynet = require 'skynet'
local log = require 'lnlog'

local index = 0

function response.login( user,login_type )
	local ret = nil
	-- body
	if login_type == "yk" then
		ret = user
	else
		error("不支持的登陆方式-"..login_type)
	end

	return ret
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	log.info('visitor init.')
end

function exit( ... )
	-- body
	log.info('visitor exit.')
end