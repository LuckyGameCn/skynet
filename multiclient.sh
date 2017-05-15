cd debug_client

ps aux | grep debug_client | awk '{print $2}' | xargs kill

lua debug_client.lua huji &
lua debug_client.lua py &
lua debug_client.lua mm &
#3rd/lua/lua debug_client/debug_client.lua
