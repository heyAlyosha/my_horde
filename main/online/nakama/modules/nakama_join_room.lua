-- Модуль поиска игры и входа в неё
local M = {}

local defold = require "nakama.engine.defold"
local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local nakama_storage = require "main.online.nakama.modules.nakama_storage"
local nakama_controller = require "main.online.nakama.modules.nakama_controller"

-- Подключаемся к комнате игры
function M.join()
	-- Если пользователь уже в комнате
	if storage_player.match_id then
		local message = nakama.create_match_leave_message(storage_player.match_id)
		local result = nakama.socket_send(storage_player.socket, message)

		if result.error then
			--print(result.error.message)
			return
		else
			storage_player.match_id = nil
		end
	end

	-- Подключаемся к комнате
	local match = nakama.rpc_func(storage_player.client, "get_world_id", "", storage_player.token)

	-- Заходим в комнату
	local message = nakama.create_match_join_message(match.payload)
	local result = nakama.socket_send(storage_player.socket, message)

	if result.match then
		--Уcпешно  вошли в матч
		pprint(result)
		print("Match joined!")

		storage_player.user_id = result.match.self.user_id
		storage_player.user_name = result.match.self.username
		storage_player.match_id = result.match.match_id


	elseif result.error then
		print(result.error.message)
		pprint(result)
		match = nil
		match_callback(false)
	end

	nakama.on_disconnect(storage_player.socket, nakama_controller.disconnect)
	--nakama.on_error(socket, nakama_controller.error)
	--nakama.on_notification(storage_player.socket, nakama_controller.notification)
	nakama.on_channelmessage(storage_player.socket, nakama_controller.channelmessage)
	nakama.on_matchpresence(storage_player.socket, nakama_controller.matchpresence)
	nakama.on_matchdata(storage_player.socket, nakama_controller.matchdata)
end

return M