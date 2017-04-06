function login(uid)
	assert(uid,"login uid")

	
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

function handleCMD(cmds)
	local subs = string.split(cmds," ")
	local cmd = subs[1]
	if cmd == 'login' then
		login(subs[2])
	elseif cmd == '' then
	else
		print("not support cmd:"..cmd)
	end
end

while true do
	cmds = io.read()
	handleCMD(cmds)
end