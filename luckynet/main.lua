local skynet = require 'skynet'
local snax = require 'snax'
local log = require 'lnlog'

skynet.start(
function()
	-- body
	log.info('luckynet start.')

	local wd = skynet.newservice('watchdog')

	local gate  = skynet.newservice('gate')
	skynet.call(gate, "lua", "open", {
	    address = "127.0.0.1", -- 监听地址 127.0.0.1
		port = 8888,    -- 监听端口 8888
		maxclient = 1024,   -- 最多允许 1024 个外部连接同时建立
		nodelay = true,     -- 给外部连接设置  TCP_NODELAY 属性
		watchdog = wd,
	})

	snax.newservice('ladder')
end
	)