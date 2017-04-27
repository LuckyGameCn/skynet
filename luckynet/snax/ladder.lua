local skynet = require 'skynet'
local log = require 'lnlog'
local snax = require 'snax'
local kafka = require 'kafkaapi'
require 'util'

local pusher

LADDER_RANGE = 100
LADDER_LINE_NUM = 3

local lines = {}
lines.lid = 1

function notifyLine( line,msg )
	-- body
	for k,v in pairs(line.users) do
		pusher.post.push(k,msg)
	end
end

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

	if line.ucount >= LADDER_LINE_NUM then
		line.locked = true
		log.info("上限到了，通知所有客户端接受游戏，这里没有处理超时的情况.")
		local msg = {type=DPROTO_TYEP_LADDERCON,lid=line.lid}
		notifyLine(line,msg)

		local cancel = cancelable_timeout(500,function (  )
			-- body
			log.info("ladder timeout.lid="..line.lid)

			for k,v in pairs(line.users) do
				if v.con ~= true then
					log.info("user %s timeout.lid %d",k,line.lid)
					line.users[k] = nil
				else
					log.info("notify user %s someone confirm timeout.lid %d",k,line.lid)
					local msg = {type=DPROTO_TYEP_LADDERIN}
					pusher.post.push(k,msg)
					v.con = false
				end
			end

			line.locked = false

		end)
		line.timeout = cancel

	else
		log.info("队列%s有%s加入，平均分为%s",line.lid,uid,tostring(line.av))
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

function removeLine( lid )
	-- body
	local index
	for i,l in ipairs(lines) do
		if l.lid == lid then
			index=i
			break
		end
	end

	if index then
		log.info("游戏开始了，可以移除该队列了.lid %s",lid)
		table.remove(lines,index)
	end
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
		log.info("用户%s被移出了天梯队列，这里没有考虑lock的情况，可能有问题.",uid)

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
		return DPROTO_TYEP_FAIL,"same user in again."
	end

	insertLine(line,uid,score)
	return DPROTO_TYEP_OK,line.lid
end

function response.Con(uid,lid)
	-- body
	assert(uid)
	if not lid then
		return DPROTO_TYEP_FAIL,"lid 为空."
	end

	log.info("get confirm %s - %s - %s",uid,lid,ptable(lines))


	local line
	local index
	local user

	for i,l in ipairs(lines) do
		if lid == l.lid then
			line=l
			index=i
			user=l.users[uid]
			break
		end
	end

	if not user then
		return DPROTO_TYEP_FAIL,"找不到用户 "..uid
	end

	if user.con == true then
		return DPROTO_TYEP_OK
	end

	if not line then
		return DPROTO_TYEP_FAIL,"找不到队列 "..lid
	end

	if line.locked == false then
		return DPROTO_TYEP_FAIL,"还没有匹配成功 "..lid
	end

	user.con = true
	local msg = {type=DPROTO_TYEP_LADDERREADY,uid=uid}
	notifyLine(line,msg)

	local allcon = true
	for k,v in pairs(line.users) do
		if v.con ~= true then
			allcon = false
			break
		end
	end

	if allcon then
		log.info("通知客户端全部准备完毕lid=%s",lid)

		if line.timeout then
			line.timeout()
		end

		kafka.pub("ladder_all_confirm",lid,line.av,line.users)

		removeLine(lid)
	end

	return DPROTO_TYEP_OK
end

function accept.xx( ... )
	-- body
end

function  init( ... )
	-- body
	log.info('ladder init.')

	pusher = snax.queryglobal("pusher")

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