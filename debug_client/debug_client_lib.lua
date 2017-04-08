local crypt = require "crypt"
local infos = {}

function logD(msg)
	-- body
	-- print("[DEBUG]"..msg)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_response(v)
	local size = #v - 5
	local content, ok, session = string.unpack("c"..tostring(size).."B>I4", v)
	return ok ~=0 , content, session
end

function readOnePack(sock)
	-- body
	while true do
		local ret
		local last
		logD("try receive")
		s,st = sock:receive(1)
		logD("rec=>"..s)
		if st == "closed" then
			return s,st
		else
			ret,last = unpack_package(infos.last..s)
			infos.last = last
			if ret then
				return ret
			end
		end
	end
end

function readPack(sock,decode,unpack_type)
	assert(sock,"sock is nil.")
	if unpack_type == 'p' then
		if infos.last==nil then
			infos.last = ""
		end
		s,st = readOnePack(sock)
	else
		s,st = sock:receive("*l")
	end
	if st == "closed" then
		return nil
	else
		if decode=='b' then
			local ret = crypt.base64decode(s)
			logD("readPack=>"..ret)
			return ret
		elseif decode==nil then
			logD("readPack=>"..s)
			return s
		else
			error("not support decode type.")
		end
	end
end

function readMSG(sock)
	-- body
	local result = readPack(sock)
	local code = tonumber(string.sub(result, 1, 3))
	assert(code == 200)
	return result
end

function readResponse(sock)
	-- body
	local ret = readPack(sock,nil,'p')
	local ok,content,session = recv_response(ret)
	return content
end

function sendPack(sock,content,encode)
	-- body
	assert(sock,"sock is nil.")
	assert(content,"content is nil.")
	local text = nil
	if encode == 'b' then
		text = crypt.base64encode(content)
		text = text.."\n"
	elseif encode == "hb" then
		text = crypt.hmac64(content,infos.secret)
		text = crypt.base64encode(text)
		text = text.."\n"
	else
		text = content
	end
	logD("send<"..text..">")
	local remain = string.len(text)
	while remain>0 do
		local index = sock:send(text)
		logD("send("..index..")=>"..string.sub(text,1,index))
		remain = string.len(text) - index
		if remain>0 then
			text = string.sub(text,index+1,-1)
		end
	end
	logD("sendEDN=>")
end

function sendRequest(msg)
	assert(msg)
	print("[REQ]"..msg)
	local session = infos.msgindex
	local sock = infos.msgsock

	local size = #msg + 4
	local package = string.pack(">I2", size)..msg..string.pack(">I4", session)
	sendPack(sock,package)

	infos.msgindex = session + 1

	local ret = readResponse(sock)
	print("[RES]"..ret)
	return ret
end

function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

return infos