-- Функции для ачивок
local M = {}

local storage_player = require "main.storage.storage_player"
local game_content_achieve = require "main.game.content.game_content_achieve"
local game_content_notify_add = require "main.game.content.game_content_notify_add"
local core_achieve_types_default = require "main.core.core_achieve.modules.core_achieve_types_default"
local core_achieve_types_custom = require "main.game.core.core_achieve_types_custom.core_achieve_types_custom"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local data_handler = require "main.data.data_handler"

-- Обновить данные по ачивкам
function M.update(self)
	local items = {}
	local achieves = game_content_achieve.get_catalog(self, M)
	local items_values = {}
	core_achieve_types_default.cache = {}

	-- Начинаем перебирать все ачивки, которые не получил игрок
	for i, achieve in ipairs(achieves) do
	
		if not achieve.success then
			if achieve.type == "stars" then
				-- Получить определённое кол-во звёзд за миссии
				core_achieve_types_default.stars(self, items, achieve, value)
			elseif achieve.type == "win" then
				-- Победить
				core_achieve_types_default.wins(self, items, achieve, value)

			elseif achieve.type == "coins" then
				-- Накопить монет
				core_achieve_types_default.coins(self, items, achieve, value)

			elseif achieve.type == "score" then
				-- Накопить опыта
				core_achieve_types_default.score(self, items, achieve, value)

			elseif achieve.type == "characteristic" then
				-- Прокачать харктеристику
				core_achieve_types_default.characteristics(self, items, achieve, value)

			elseif achieve.type == "full_company" then
				-- Прохождение компании
				core_achieve_types_default.company(self, items, achieve, value)
			else
				-- Кастомные 
				local type = achieve.type 
				core_achieve_types_custom.update(self, type, items, achieve, value)

			end
		end
	end

	local set_nakama = true
	local success_achieve = M.set_progress(self, items, set_nakama)
end

-- Получить прогресс по ачивке
function M.get_progress(id)
	return {
		status = storage_player.achieve[id],
		achieve_progress = storage_player.achieve_progress[id] or 0
	}
end

-- Запись прогресса
local items = {
	{id = "test", operation = "add/set", value = 0}
}
function M.set_progress(self, items, set)
	local success_achieve = {}

	for i, item in ipairs(items) do
		item.operation = item.operation or "set"
		local id = item.id
		local value = item.value

		-- Свершаем операцию над прогрессом ачивки
		if item.operation == "set" then
			storage_player.achieve_progress[id] = value

		elseif item.operation == "add" then
			storage_player.achieve_progress[id] = storage_player.achieve_progress[id] or 0
			storage_player.achieve_progress[id] = storage_player.achieve_progress[id] + value
		end

		local achieve = game_content_achieve.get_item(id)
		if achieve and storage_player.achieve_progress[id] >= achieve.max_count then
			storage_player.achieve[id] = true
			success_achieve[id] = true
			game_content_notify_add.add_achieve(self, id)
		end
	end

	if set then
		local userdata = {
			achieve = storage_player.achieve,
			achieve_progress = storage_player.achieve_progress
		}
		data_handler.set_userdata(self, userdata, callback)
	end

	return success_achieve
end

return M