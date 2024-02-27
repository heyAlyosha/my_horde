-- Дисконект от комнаты сетевой игры
local storage_player = require "main.storage.storage_player"
local storage_loader = require "main.storage.storage_loader"
local online_object_storage = require "main.online.online_object_storage"
local nakama = require "nakama.nakama"

local M = {}

-- Очистка старых данных игры
function M.clear_old_data_game(self)
	for k, item in pairs(online_object_storage) do
		online_object_storage[k] = nil
	end

	-- обнуляем массив бафов
	if storage_player.buffs then
		for i, buff_data in ipairs(storage_player.buffs) do
			table.remove(storage_player.buffs, i)
		end
	end

	storage_player.result_round = nil
	storage_player.win_round = nil
	game_screen_rating.storage = {}
	storage_nakama.data = {}
end

--Функция отключение игрока от сервера с удалением всех данных
function M.disconect(end_function, type)
	-- Обнуляем массив
	if type ~= "no_delete_online_objects" then
		for k, item in pairs(online_object_storage) do
			online_object_storage[k] = nil
		end
	end

	-- обнуляем массив бафов
	if storage_player.buffs then
		for i, buff_data in ipairs(storage_player.buffs) do
			table.remove(storage_player.buffs, i)
		end
	end

	-- Отключаемся от сервера
	if storage_player.match_id then
		nakama.sync(function()
			local match_id = storage_player.match_id
			local message = nakama.create_match_leave_message(match_id)
			local result = nakama.socket_send(storage_player.socket, message)

			if result.error then
				--print(result.error.message)
				return
			else
				storage_player.match_id = nil

				if end_function then
					end_function(self)
				end
			end
		end)
	elseif end_function then
		end_function(self)
	end
end

return M