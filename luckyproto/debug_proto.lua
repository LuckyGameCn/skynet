DPROTO_TYEP_OK = 0
DPROTO_TYEP_FAIL = -1

DPROTO_TYEP_LOGOUT = 1
DPROTO_TYEP_PUSH = 2

DPROTO_TYEP_LADDERIN = 100 --下行指天梯重新开始排队，上行指开始排队
DPROTO_TYEP_LADDERREADY = 101
DPROTO_TYEP_LADDERCON = 102
DPROTO_TYEP_LADDEROK = 103 --天梯全部确认完毕

DPROTO_TYEP_DATA_INIT = 10
DPROTO_TYEP_DATA = 11
DPROTO_TYEP_DATA_END = 12

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
}

.user{
	uid 1 : string
	score 2 : integer
}

.res{
	type 1 : integer
	resmsg 2 : string

#天梯用
	lid 3 : integer
	uid 4 : string
	average 5 : string
	linelist 6 : *user

#从天梯进入游戏场景服务
	play_server_add 7 : string
	play_server_port 8 : integer
}

]]

return sproto.new(proto.all)
