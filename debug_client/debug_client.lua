package.path = "debug_client/?.lua;"..package.path
-- package.cpath = "luaclib/?.so;debug_client/?.so;"..package.cpath

local infos = require "debug_client_lib"
local socket = require "socket"
local crypt = require "crypt"

--search game to join.ladder
function search(subid)
	-- body
	local ret = sendRequest(subid)
	
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
		search(subs[2])
	elseif cmd == '' then
	elseif cmd == '' then
	elseif cmd == '' then
	elseif cmd == '' then
	else
		print("not support cmd:"..cmd)
	end
end

handleCMD("login huji")
handleCMD("search "..infos.subid)
while true do
	cmds = io.read()
	handleCMD(cmds)
end