local skynet = require 'skynet'
local log = require 'lnlog'
local snax = require 'snax'
local kafka = require 'kafkaapi'

LADDER_RANGE = 100
LADDER_LINE_NUM = 10

local lines = {}
lines.lid = 1

function lineForScore(score)
	-- body
	for i,l in ipairs(lines) do
		if score<l.up and score>l.down and l.locked == false then
			return l
		end
	end

	local l={}
	l.locked = false
	l.ucount=0
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
	updateLine(line,uid,{uid=uid,score=score})

	if #(line.users) >= LADDER_LINE_NUM then
		line.locked = true
		log.info("上限到了，通知所有客户端接受游戏")
	else
		log.info("通知客户端更新天梯排队列表，或者不通知，这里需要讨论下")
	end
end

function updateLine(line,uid,u)
	-- body
	local oldu = line.users[uid]
	line.users[uid] = u
	if u then
		line.ucount = line.ucount + 1
		line.total = line.total + u.score
	else
		line.ucount = line.ucount - 1
		line.total = line.total - oldu.score
	end
	line.av = line.total / line.ucount
	line.up = line.av + LADDER_RANGE
	line.down = line.av - LADDER_RANGE
	line.stid = line.stid + 1
end

function removeUserFromLine(uid)
	-- body
	local line
	local index

	for i,l in ipairs(lines) do
		if l.users[uid] then
			line=l
			index=i
			break
		end
	end

	if line then
		updateLine(line,uid,nil)
		log.info("用户%s被移出了天梯队列，通知相应队列的客户端.",uid)

		if line.ucount == 0 then
			log.info("队列%s没有用户了，删除掉.这里和Res是否存在多线程问题还需要研究下.",line.lid)
			table.remove(lines,index)
		end
	end
end

function response.In(uid,score)
	-- body
	assert(uid)
	local line = lineForScore(score)

	if line.users[uid] then
		log.error("队列中存在了相同uid的用户.%s",uid)
		return false
	end

	insertLine(line,uid,score)
	return true,line.lid
end

function response.Res(uid,lid,stid)
	assert(lid,"请求的lid为空.")

	local line
	for i,l in ipairs(lines) do
		if l.lid == lid then
			line = l
			break
		end
	end
	assert(line,"查找了一个不存在队列的结果，lid="..lid)

	if line.locked then
		if line.users[uid] then
			return line.lid,-1
		else
			return -1
		end
	end

	if stid == line.stid then
		log.info("队列%s没有变化",line.lid)
		return nil
	end

	local ret = {}
	for k,v in pairs(line.users) do
		table.insert(ret,v.uid)
	end

	return line.lid,line.stid,line.av,ret
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	log.info('ladder init.')

	kafka.sub("disconnect",function(uid)
		-- body
		removeUserFromLine(uid)
	end)

	kafka.sub("logout",function(uid)
		-- body
		removeUserFromLine(uid)
	end)
end

function exit( ... )
	-- body
	log.info('ladder exit.')

	kafka.unsub("disconnect")
	kafka.unsub("logout")
end