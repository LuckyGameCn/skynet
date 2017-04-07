local infos = require "debug_client_lib"
local socket = require "socket"
local crypt = require "crypt"

local function sendReq(msg)
	local session = infos.msgindex
	local sock = infos.msgsock

	local size = #msg + 4
	local package = string.pack(">I2", size)..msg..string.pack(">I4", session)
	sock:send(package)
end

--search game to join.ladder
function search(subid)
	-- body

end

function login(uid)
	assert(uid,"login uid")

	local sock = socket.connect("127.0.0.1",8001)
	local challenge = readPack(sock)

	local clientkey = crypt.randomkey()
	local en_clientkey = crypt.dhexchange(clientkey)
	--写出clientKey
	sendPack(sock,en_clientkey)

	--读取secret
	local sec = readPack(sock)
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
	sendPack(sock, etoken)

	local result = readPack(sock,"n")
	print(result)
	local code = tonumber(string.sub(result, 1, 3))
	assert(code == 200)
	sock:close()
	local subid = crypt.base64decode(string.sub(result, 5))
	print("login ok, subid=", subid)

	local sock = socket.connect("127.0.0.1", 8888)

	infos.subid = subid
	infos.msgsock = sock
	infos.msgindex = 1

	local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(subid) , index)
	local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)


	send_package(fd, handshake .. ":" .. crypt.base64encode(hmac))

end

function handleCMD(cmds)
	print("[CMD]"..cmds)
	local subs = string.split(cmds," ")
	local cmd = subs[1]
	if cmd == 'login' then
		login(subs[2])
	elseif cmd == '' then
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
	break
end