-- Изменение и хранение статистики и прогресса
local M = {}

local storage_player = require "main.storage.storage_player"

-- Получение прогресса уровння
function M.get_progress_level(category_id, level_id)
	local id = "level_"..level_id

	if storage_player.progress[category_id] and storage_player.progress[category_id][id] then
		return storage_player.progress[category_id][id]
	else
		return nil

	end
end

-- Получение прогресса категории
function M.get_progress_category(category_id)
	return storage_player.progress[category_id] or  {}
end

-- Получение прогресса всех уровней всех категорий
function M.get_progress_all(game_content_company)
	local result = {}

	if game_content_company then
		for i, category in ipairs(game_content_company.get_all()) do
			local category_id = category.id

			result[category_id] = M.get_progress_category(category_id)
		end
	end

	return result
end

-- Записываем прогресса уровня
function M.set_progress_level(category_id, level_id, value)
	local id = "level_"..level_id
	storage_player.progress = storage_player.progress or {}
	storage_player.progress[category_id] = storage_player.progress[category_id] or {}
	storage_player.progress[category_id][id] = value
end

-- Получение статистики
function M.get_stats()
	return storage_player.stats
end

-- Запись статистики
local items = {
	{id = "test", operation = "add/set", value = 0}
}
function M.set_stats(items)
	for i, item in ipairs(items) do
		item.operation = item.operation or "set"

		if item.operation == "set" then
			storage_player.stats[item.id] = item.value

		elseif item.operation == "add" then
			storage_player.stats[item.id] = storage_player.stats[item.id] or 0
			storage_player.stats[item.id] = storage_player.stats[item.id] + item.value

		end

	end

	return storage_player.stats
end

-- Поражения в уровнях
function M.get_visible_level(category_id, level_id)
	storage_player.visible_levels = storage_player.visible_levels or {}
	storage_player.visible_levels[category_id] = storage_player.visible_levels[category_id] or {}
	return storage_player.visible_levels[category_id]["level_"..level_id] or 0
end

-- Поражения в уровнях
function M.set_visible_level(category_id, level_id, count, operation)
	local level = M.get_visible_level(category_id, level_id)
	local id = "level_"..level_id
	local operation = operation or "set"

	if operation == "set" then
		storage_player.visible_levels[category_id][id] = count

	elseif operation == "add" then
		storage_player.visible_levels[category_id][id] = storage_player.visible_levels[category_id][id] or 0
		storage_player.visible_levels[category_id][id] = storage_player.visible_levels[category_id][id] + count
	end

	return storage_player.visible_levels
end

return M