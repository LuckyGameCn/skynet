local skynet = require 'skynet'
local snax = require 'snax'
local log = require 'lnlog'

skynet.start(
function()
	-- body
	log.info('luckynet start.')

	snax.globalservice("kafka")

	snax.globalservice('ladder')

	snax.globalservice('agent_game')

	local wd = skynet.uniqueservice(true,'watchdog')
	skynet.send(wd, "lua", "open", {
	    address = "127.0.0.1", -- 监听地址 127.0.0.1
		port = 6024,
		maxclient = 102400,   -- 最多允许 1024 个外部连接同时建立
		nodelay = true,     -- 给外部连接设置  TCP_NODELAY 属性
	})

	local msggate = skynet.uniqueservice(true,"msggate")
	skynet.call(msggate, "lua", "open" , {
		port = 8888,
		maxclient = 102400,
		servername = "msggate_sample",
	})

	skynet.uniqueservice(true,"login")

	log.info("启动调试服务")
	skynet.newservice("debug_console",8000)
end
	)