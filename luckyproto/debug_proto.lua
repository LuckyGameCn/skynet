local sprotoparser = require "sprotoparser"
local sproto = require "sproto"

local proto = {}

proto.all = sprotoparser.parse [[

.data{
	type 1 : integer
	id 2 : string
}

.req{
	type 1 : integer
	id 2 : string

#天梯用
	lid 3 : integer
	stid 4 : integer
}

.user{
	uid 1 : string
	score 2 : integer
}

.res{
	res 1 : integer
	resmsg 2 : string

#天梯用
	lid 3 : integer
	uid 4 : string
	average 5 : integer
	linelist 6 : *user

#从天梯进入游戏场景服务
	play_server_add 7 : string
	play_server_port 8 : integer
}

]]

return sproto.new(proto.all)
