local crypt = require "crypt"
local infos = {}

function readPack(sock,decode)
	assert(sock,"sock is nil.")
	s,st = sock:receive("*l")
	if st == "closed" then
		return nil
	else
		if decode=='b' then
			local ret = crypt.base64decode(s)
			print("readPack=>"..ret)
			return ret
		elseif decode==nil then
			print("readPack=>"..s)
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

function sendPack(sock,content,encode)
	-- body
	assert(sock,"sock is nil.")
	local text = nil
	if encode == nil then
		text = crypt.base64encode(content)
	elseif encode == "hb" then
		text = crypt.hmac64(content,infos.secret)
		text = crypt.base64encode(text)
	end
	print("send<"..text..">")
	text = text.."\n"
	local remain = string.len(text)
	while remain>0 do
		print("send=>"..text)
		local index = sock:send(text)
		remain = string.len(text) - index
		if remain>0 then
			text = string.sub(text,index+1,-1)
		end
	end
	print("sendEDN=>")
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