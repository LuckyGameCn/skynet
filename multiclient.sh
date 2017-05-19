cd debug_client

ps aux | grep debug_client | awk '{print $2}' | xargs kill
rm debug.log

lua debug_client.lua huji >> debug.log &
lua debug_client.lua py >> debug.log &
lua debug_client.lua mm >> debug.log &
#3rd/lua/lua debug_client/debug_client.lua
