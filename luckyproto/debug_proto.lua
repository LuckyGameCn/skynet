DPROTO_TYEP_LADDERIN = 100
DPROTO_TYEP_LADDERRES = 101

local sprotoparser = require "sprotoparser"
local sproto = require "sproto"

local proto = {}

proto.all = sprotoparser.parse [[

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
	linelist 5 : *string
}

]]

return sproto.new(proto.all)
