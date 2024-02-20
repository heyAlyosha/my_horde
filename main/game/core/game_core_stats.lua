-- Работы со статистикой в игре
local M = {}

local storage_player = require "main.storage.storage_player"
local game_content_company = require "main.game.content.game_content_company"

-- Обновление статистики игрока
function M.update(self)
	local companies = game_content_company.get_all(user_lang)

	local missions_all = 0
	local mission_complete = 0
	local company_all = #companies 
	local company_complete = 0

	for i, company in ipairs(companies) do
		company.progress_count = company.progress_count or 0
		company.progress_all = company.progress_all or 0

		-- Сколько уровней всего
		missions_all = missions_all + company.progress_all
		-- Пройденный уровней
		mission_complete = mission_complete + company.progress_count

		--Пройденный компаний
		if status == "success" then
			company_complete = company_complete + company.progress_count
		end
	end

	-- Начинаем рисваивать
	storage_player.stats = storage_player.stats or  {}
	storage_player.stats.missions_all = missions_all
	storage_player.stats.mission_complete = mission_complete
	storage_player.stats.company_all = company_all
	storage_player.stats.company_complete = company_complete

	return storage_player.stats
end

-- Добавление данны в статистику по игре
function M.add(self, id)
	storage_player.stats = storage_player.stats or {}
	storage_player.stats[id] = storage_player.stats[id] or 0

	return storage_player.stats[id]
end

return M