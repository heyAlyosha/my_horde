-- ЯДро Api накамы
local M = {}

local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local json = require "nakama.util.json"

-- Отправка данных в rpc функцию накамы
function M.rpc_push(self, rpc_name, payload, function_result)
	nakama.rpc_func(storage_player.client, rpc_name, json.encode(payload), nil, function(result)
		pprint("PUSH RSPC: ".. rpc_name, payload)

		if result.payload then
			result = json.decode(result.payload)
		else
			pprint("ERROR PUSH RPC:", result)
		end
		
		if function_result then
			function_result(self, result)
		end
	end)
end

return M