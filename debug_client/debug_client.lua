package.path = "../luckyproto/?.lua;"..package.path
-- package.cpath = "luaclib/?.so;debug_client/?.so;"..package.cpath

local infos = require "debug_client_lib"
local socket = require "socket"
local crypt = require "crypt"

--search game to join.ladder
function search(subid)
	-- body
	local msg = {type=DPROTO_TYEP_LADDERIN,id=subid}
	local ok,ret = sendRequest("req","res",msg)
	if ok and ret.res then
		g_lid=ret.lid
		g_stid=0
		local line_id = nil
		while true do
			msg = {type=DPROTO_TYEP_LADDERRES,id=subid,lid=g_lid,stid=g_stid}
			ok,ret = sendRequest("req","res",msg)
			if ret.res then
				if ret.lid == -1 then
					print("something wrong.quit.")
					break
				elseif ret.stid == -1 then
					print("line is ok.send confirm here.")
					line_id = ret.lid
					break
				else
					print("normal case.")
				end

				print('no change request again.')
				g_lid = ret.lid
				g_stid = ret.stid
				linelist = ret.linelist
				print("linelist:")
				logT(linelist)
			else
				print("ladderres some error.quit.")
				break
			end
			socket.select(nil,nil,5)
		end

		if line_id then
			print("排队人数达到开局标准，输入confirm命令确认.")
			infos.lid = line_id
		end
	else
		print("ladder in fail.try again."..ret.resmsg)
	end
end

function play(addr,port,subid,lid)
	-- body
	local sock = socket.connect(addr,port)
	assert(sock,"connect play server error.")

	sendData(sock,"req",{id=subid,lid=lid})
end

function confirm(subid,lid)
	local addr,port

	while true do
		local ok,ret = sendRequest("req","res",{type=DPROTO_TYEP_LADDERCON,id=subid,lid=lid})
		if ret.res then
			if ret.play_server_add then
				print("all ready.connect "..ret.play_server_add)
				addr = ret.play_server_add
				port = ret.play_server_port
				break
			else
				print("wait for all confirm.query again in 5s.")
				socket.select(nil,nil,5)
			end
		else
			print("some error.quit.")
			break
		end
	end

	if addr then
		play(addr,port,infos.subid,infos.lid)
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

function handleCMD(cmds)
	print("[CMD]"..cmds)
	local subs = string.split(cmds," ")
	local cmd = subs[1]
	if cmd == 'login' then
		login(subs[2])
	elseif cmd == 'search' then
		search(infos.subid)
	elseif cmd == 'confirm' then
		confirm(infos.subid,infos.lid)
	elseif cmd == '' then
	elseif cmd == '' then
	elseif cmd == '' then
	else
		print("not support cmd:"..cmd)
	end
end

-- handleCMD("login huji")
-- handleCMD("search "..infos.subid)
while true do
	print("请输入命令：")
	cmds = io.read()
	handleCMD(cmds)
end