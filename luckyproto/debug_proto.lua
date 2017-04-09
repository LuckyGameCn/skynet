DPROTO_TYEP_LADDERIN = 100

local sprotoparser = require "sprotoparser"
local sproto = require "sproto"

local proto = {}

proto.all = sprotoparser.parse [[

.req{
	type 1 : integer
	id 2 : string
}

.res{
	res 1 : boolean
	resmsg 2 : string
}

]]

return sproto.new(proto.all)
