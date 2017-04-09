local skynet = require 'skynet'

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

local lnlogger = {}

function lnlogger.info(msg)
	-- body
	skynet.error('[INFO]'..msg)
end

function lnlogger.error(msg)
	-- body
	skynet.error('[ERR]'..msg)
end

return lnlogger