-- Обработка дефолтных типов ачивок
local M = {}

local core_prorgress = require "main.core.core_progress.core_prorgress"
local storage_player = require "main.storage.storage_player"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local game_content_company = require "main.game.content.game_content_company"

M.cache = {}

function M.clear_cache()
	M.cache = {}
end

-- Звёзды за уровни
function M.stars(self, items, achieve, value)
	-- Смотрим на все пройденные 
	local stars_count = 0
	for category_id, category in pairs(storage_player.progress) do
		for level_id, stars in pairs(category) do
			if stars >= 3 then
				stars_count = stars_count + 1
			end
		end
	end

	table.insert(items, {id = achieve.id, operation = "set", value = stars_count})
end

-- Победы
function M.wins(self, items, achieve, value)
	local wins = core_prorgress.get_stats().wins or 0
	table.insert(items, {id = achieve.id, operation = "set", value = wins})
end

-- Монеты
function M.coins(self, items, achieve, value)
	local coins = storage_player.coins or 0
	table.insert(items, {id = achieve.id, operation = "set", value = coins})
end

-- Опыт
function M.score(self, items, achieve, value)
	local score = storage_player.score or 0
	table.insert(items, {id = achieve.id, operation = "set", value = score})
end

-- Прокаченные характеристики
function M.characteristics(self, items, achieve, value)
	local characteristic_id = achieve.value.dop_id
	local characteristic = game_content_characteristic.get_id(self, characteristic_id)
	local level = characteristic.level
	table.insert(items, {id = achieve.id, operation = "set", value = level})
end

-- Выполненные задания
function M.company(self, items, achieve, value)
	if not M.cache.levels then
		M.cache.levels = {}
		M.cache.levels = core_prorgress.get_progress_all()
	end

	local company_id = achieve.value.dop_id
	local company = game_content_company.get_id(company_id)
	local levels = company.progress_all
	local levels_count = company.progress_count
	table.insert(items, {id = achieve.id, operation = "set", value = levels_count})
end


return M