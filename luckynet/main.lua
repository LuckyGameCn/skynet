local skynet = require 'skynet'
local snax = require 'snax'
local log = require 'lnlog'

skynet.start(
function()
	-- body
	log.info('luckynet start.')

	snax.globalservice('agent_game')

	-- local wd = skynet.newservice('watchdog')
	-- local gate  = skynet.newservice('gate')
	-- skynet.call(gate, "lua", "open", {
	--     address = "127.0.0.1", -- 监听地址 127.0.0.1
	-- 	port = 8080,    -- 监听端口 8888
	-- 	maxclient = 1024,   -- 最多允许 1024 个外部连接同时建立
	-- 	nodelay = true,     -- 给外部连接设置  TCP_NODELAY 属性
	-- 	watchdog = wd,
	-- })

	local msggate = skynet.uniqueservice(true,"msggate")
	skynet.call(msggate, "lua", "open" , {
		port = 8888,
		maxclient = 1024,
		servername = "msggate_sample",
	})

	snax.globalservice("visitor")

	skynet.uniqueservice(true,"login")

	snax.newservice('ladder')

	log.info("启动调试服务")
	skynet.newservice("debug_console",8000)
end
	)