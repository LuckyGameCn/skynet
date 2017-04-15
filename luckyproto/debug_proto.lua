DPROTO_TYEP_LADDERIN = 100
DPROTO_TYEP_LADDERRES = 101
DPROTO_TYEP_LADDERCON = 102

DPROTO_TYEP_DATA_INIT = 10

local sprotoparser = require "sprotoparser"
local sproto = require "sproto"

local proto = {}

proto.all = sprotoparser.parse [[

.data{
	type 1 : integer
}

.req{
	type 1 : integer
	id 2 : string

#天梯用
	lid 3 : integer
	stid 4 : integer
}

.res{
	res 1 : boolean
	resmsg 2 : string

#天梯用
	lid 3 : integer
	stid 4 : integer
	average 5 : integer
	linelist 6 : *string

#从天梯进入游戏场景服务
	play_server_add 7 : string
	play_server_port 8 : integer
}

]]

return sproto.new(proto.all)
