local crypt = require "crypt"
local debug_proto = require "debug_proto"
local infos = {}

function PrintTable( tbl , level, filteDefault)
  local retstr =""
  local msg = ""
  filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
  level = level or 1
  local indent_str = ""
  for i = 1, level do
    indent_str = indent_str.."  "
  end

  -- print(indent_str .. "{")
  retstr=retstr.."{"
  for k,v in pairs(tbl) do
    if filteDefault then
      if k ~= "_class_type" and k ~= "DeleteMe" then
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        -- print(item_str)
        retstr=retstr..item_str
        if type(v) == "table" then
          retstr=retstr..PrintTable(v, level + 1)
        end
      end
    else
      local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
      retstr=retstr..item_str
      if type(v) == "table" then
        retstr=retstr..PrintTable(v, level + 1)
      end
    end
  end
  retstr=retstr.."}"
  return retstr
end

function logT(t)
	-- body
	print(PrintTable(t))
end

function logD(msg)
	-- body
	-- print("[DEBUG]"..msg)
end

function logE(msg)
	-- body
	print("[==ERR==]"..msg)
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
		local s,st = sock:receive(1)
			if s then
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
		else
			logE("socket get a nil receive.")
		end
	end
end

function readPack(sock,decode,unpack_type)
	assert(sock,"sock is nil.请确保服务器的地址和端口号有效.")
	if unpack_type == 'p' then
		if infos.last==nil then
			infos.last = ""
		end
		s,st = readOnePack(sock)
	else
		s,st = sock:receive("*l")
	end
	if st == "closed" then
		logE("socket is closed.")
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
	assert(code == 200,result)
	return result
end

function readResponse(sock)
	-- body
	local ret = readPack(sock,nil,'p')
	local ok,content,session = recv_response(ret)
	return ok,content
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
	local remain = string.len(text)
	logD("send("..remain..")<"..text..">")
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

function sendRequest(reqtype,restype,msg)
	assert(reqtype)
	assert(msg)
	msg = debug_proto:encode(reqtype,msg)
	print("[REQ]("..msg:len()..")"..msg)
	local session = infos.msgindex
	local sock = infos.msgsock

	local size = #msg + 4
	local package = string.pack(">I2", size)..msg..string.pack(">I4", session)
	sendPack(sock,package)

	infos.msgindex = session + 1

	local ok,ret = readResponse(sock)
	if ok == false then
		assert(nil,"服务端返回数据有误.")
	end
	print("[RES]["..tostring(ok).."]("..ret:len()..")"..ret)
	ret = debug_proto:decode(restype,ret)
	return ok,ret
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