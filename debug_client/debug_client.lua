package.path = "../luckyproto/?.lua;"..package.path
-- package.cpath = "luaclib/?.so;debug_client/?.so;"..package.cpath

local infos = require "debug_client_lib"
local socket = require "socket"
local crypt = require "crypt"

--search game to join.ladder
function search(subid)
	if not subid then
		print("login first.")
		return
	end
	
	-- body
	local msg = {type=DPROTO_TYEP_LADDERIN,id=subid}
	local ok,ret = sendRequest("req","res",msg)
	if ok and ret.type == DPROTO_TYEP_OK  then
		local line_id

		while true do
			msg = {type=DPROTO_TYEP_PUSH}
			ok,ret = sendRequest("req","res",msg)
			if ret.type == DPROTO_TYEP_LADDERCON then
				line_id = ret.lid
				break
			else
				print("发生了某种错误，退出排队")
				break
			end
		end

		if line_id then
			print("排队人数达到开局标准，输入confirm命令确认.")
			infos.lid = line_id
		else
			print("排队的时候发生了某种错误.")
		end
	else
		print("ladder in fail.try again."..ret.resmsg)
	end
end

function play(addr,port,subid,lid)
	-- body
	local sock = socket.connect(addr,port)
	assert(sock,"connect play server error.")

	sendData(sock,"req",{type=DPROTO_TYEP_DATA_INIT,id=subid,lid=lid})

	-- body
	while true do
		local msg = readData(sock)
		print("get data type "..msg.type)
		sendData(sock,"data",{type=msg.type,id=subid})
		if msg.type == DPROTO_TYEP_DATA_END then
			print("game over.go to game over scence.")
			break
		end
	end
		
end

function confirm(subid,lid)
	local addr,port

	local ok,ret = sendRequest("req","res",{type=DPROTO_TYEP_LADDERCON,id=subid,lid=lid})
	if ret.type == DPROTO_TYEP_OK then
		while true do
			local ok,ret = sendRequest("req","res",{type=DPROTO_TYEP_PUSH})
			if ret.type == DPROTO_TYEP_LADDEROK then
				print("all ready.connect "..ret.play_server_add)
				addr = ret.play_server_add
				port = ret.play_server_port
				break
			elseif ret.type == DPROTO_TYEP_LADDERREADY then
				print("用户 "..ret.uid.." 确认")
			elseif ret.type == DPROTO_TYEP_LADDERIN then
				print("有人没有确认开始，重新开始排队")
				break
			else
				print("some error.quit.")
				break
			end
		end
	else
		print(ret.resmsg)
	end

	if addr then
		play(addr,port,infos.subid,infos.lid)
	else
		if ret.type == DPROTO_TYEP_LADDERIN  then
			search(subid)
		end
	end
end

function login(uid)
	assert(uid,"login uid")

	local sock = socket.connect("127.0.0.1",8001)
	local challenge = readPack(sock,'b')

	local clientkey = crypt.randomkey()
	local en_clientkey = crypt.dhexchange(clientkey)
	--写出clientKey
	sendPack(sock,en_clientkey,'b')

	--读取secret
	local sec = readPack(sock,'b')
	local secret = crypt.dhsecret(sec, clientkey)
	infos.secret = secret

	print("sceret is ", crypt.hexencode(secret))
	
	sendPack(sock,challenge,'hb')

	local token = {
		server = "msggate_sample",
		user = uid,
		lt = "yk",
	}
	local function encode_token(token)
		return string.format("%s@%s:%s",
			crypt.base64encode(token.user),
			crypt.base64encode(token.server),
			crypt.base64encode(token.lt))
	end
	local etoken = crypt.desencode(secret, encode_token(token))
	sendPack(sock, etoken,'b')

	local result = readMSG(sock)
	sock:close()
	local subid = crypt.base64decode(string.sub(result, 5))
	print("login ok, subid=", subid)

	local sock = socket.connect("127.0.0.1", 8888)

	infos.subid = subid
	infos.msgindex = 1


	local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(subid) , infos.msgindex)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)
	local en_handshake = handshake .. ":" .. crypt.base64encode(hmac)
	local hspack = string.pack(">s2", en_handshake)

	sendPack(sock,hspack)
	local result = readPack(sock,nil,'p')
	print("handshake=>"..result)

	infos.msgsock = sock
end

function logout(  )
	-- body
	local msg = {type=DPROTO_TYEP_LOGOUT}
	local ok,ret = sendRequest("req","res",msg)
	if ret.type == DPROTO_TYEP_OK then
		print("退出登陆成功")
	else
		print("退出登陆失败")
	end
end

function handleCMD(cmds)
	print("[CMD]"..cmds)
	local subs = string.split(cmds," ")
	local cmd = subs[1]
	if cmd == 'login' or cmd == 'ln' then
		login(subs[2])
	elseif cmd == 'search' or cmd == 's' then
		search(infos.subid)
	elseif cmd == 'confirm' or cmd == 'c' then
		confirm(infos.subid,infos.lid)
	elseif cmd == 'logout' or cmd == 'lt' then
		logout()
	elseif cmd == '' then
	elseif cmd == '' then
	else
		print("not support cmd:"..cmd)
	end
end

info = [[
登陆 login[ln] [username]
退出登陆 logout[lt]
寻找天梯 search[s]
确认天梯 confirm[c]
]]
-- handleCMD("login jj")
-- handleCMD("logout")

-- handleCMD("login "..crypt.randomkey())
-- handleCMD("search "..infos.subid)
-- handleCMD(string.format("confirm %s %s",infos.subid,infos.lid))
while true do
	print(info)
	print("请输入命令：")
	cmds = io.read()
	handleCMD(cmds)
end