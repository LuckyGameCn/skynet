local skynet = require 'skynet'
local log = require 'lnlog'

LADDER_RANGE = 100
LADDER_LINE_NUM = 10

local lines = {}
lines.lid = 1

function lineForScore(score)
	-- body
	for i,l in ipairs(lines) do
		if score<l.up and score>l.down then
			return l
		end
	end

	local l={}
	l.up=0
	l.down=0
	l.av=0
	l.total=0
	l.users={}
	l.stid = 1
	l.lid = lines.lid
	lines.lid = lines.lid + 1
	if lines.lid == 999999 then
		lines.lid = 1
		log.info("里程碑，lines.lid重置了.")
	end

	table.insert(lines,l)

	log.info(string.format("新建了一个天梯队列 lid=%s",l.lid))

	return l
end

function insertLine(line,uid,score)
	-- body
	table.insert(line.users,{uid=uid,score=score})
	line.total = line.total + score
	line.av = line.total / #(line.users)
	line.up = line.av + LADDER_RANGE
	line.down = line.av - LADDER_RANGE
	line.stid = line.stid + 1

	if #(line.users) >= LADDER_LINE_NUM then
		log.info("上限到了，通知所有客户端接受游戏")
	else
		log.info("通知客户端更新天梯排队列表，或者不通知，这里需要讨论下")
		skynet.wakeup(skynet.self())
	end
end

function response.In(uid,score)
	-- body
	assert(uid)
	local line = lineForScore(score)
	insertLine(line,uid,score)
	return true,line.lid
end

function response.Res(uid,lid,stid)
	local line
	for i,l in ipairs(lines) do
		if l.lid == lid then
			line = l
			break
		end
	end
	assert(line,"查找了一个不存在队列的结果，lid="..lid)

	if stid == line.stid then
		skynet.wait()
	end

	local ret = {}
	for i,v in ipairs(line.users) do
		table.insert(ret,v.uid)
	end

	return line.lid,line.stid,ret
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	log.info('ladder init.')
end

function exit( ... )
	-- body
	log.info('ladder exit.')
end