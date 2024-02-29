-- Функция для импортирвоания аккаунта
local M = {}

M.images = {}

-- Импорт данных анонимного игрока
function M.from_anonym(self, player_data, anonym_data)
	local result = {
		score = 0, coins = 0,
		characteristics = player_data.characteristics or {},
		prizes = player_data.prizes or {},
		shop = player_data.shop or {},
		visible_levels = player_data.visible_levels or {},
		progress = player_data.progress or {},
		achieve = player_data.achieve or {},
		stats = player_data.stats or {}
	}
	local player_data = {
		score = player_data.score or 0, coins = player_data.coins or 0,
		characteristics = player_data.characteristics or {},
		prizes = player_data.prizes or {},
		shop = player_data.shop or {},
		visible_levels = player_data.visible_levels or {},
		progress = player_data.progress or {},
		achieve = player_data.achieve or {},
		stats = player_data.stats or {}
	}
	local anonym_data = {
		score = anonym_data.score or 0, coins = anonym_data.coins or 0,
		characteristics = anonym_data.characteristics or {},
		prizes = anonym_data.prizes or {},
		shop = anonym_data.shop or {},
		visible_levels = anonym_data.visible_levels or {},
		progress = anonym_data.progress or {},
		achieve = anonym_data.achieve or {},
		stats = anonym_data.stats or {}
	}

	-- Импорт очков и золота
	result.score = player_data.score + anonym_data.score
	result.coins = player_data.coins + anonym_data.coins

	-- Импорт характеристик
	for id, anonym_value in pairs(anonym_data.characteristics) do
		local player_value = player_data.characteristics[id] or 0

		if anonym_value > player_value then
			result.characteristics[id] = anonym_value
		end
	end

	-- Импорт призов
	for id, anonym_value in pairs(anonym_data.prizes) do
		local player_value = player_data.prizes[id] or 0
		result.prizes[id] = player_value + anonym_value 
	end

	-- Импорт товаров в магазине
	for id, anonym_value in pairs(anonym_data.shop) do
		local player_value = player_data.shop[id] or 0
		result.shop[id] = player_value + anonym_value 
	end

	-- Импорт просмотренных вопросов
	for category_id, anonym_group in pairs(anonym_data.visible_levels) do
		local player_value = player_data.visible_levels[category_id] or {}
		
		for id, anonym_value in pairs(anonym_group) do
			result.visible_levels[category_id] = result.visible_levels[category_id] or {}
			result.visible_levels[category_id][id] = anonym_value
		end
	end


	-- Импорт Прогресса по прохождению
	for category_id, anonym_group in pairs(anonym_data.progress) do
		local player_value = player_data.progress[category_id] or {}

		for id, anonym_value in pairs(anonym_group) do
			player_data.progress[category_id] = player_data.progress[category_id] or  {}
			player_data.progress[category_id][id] = player_data.progress[category_id][id] or 0

			if anonym_data.progress[category_id][id] > player_data.progress[category_id][id] then
				result.progress[category_id] = result.progress[category_id] or {}
				result.progress[category_id][id] = anonym_data.progress[category_id][id]
			end
		end
	end

	-- Импорт ачивок
	for id, anonym_value in pairs(anonym_data.achieve) do
		result.achieve[id] = anonym_value 
	end

	-- Импорт статистики
	for id, anonym_value in pairs(anonym_data.stats) do
		local player_value = player_data.stats[id] or 0
		result.stats[id] = player_value + anonym_value 
	end

	-- Формриуем метадату
	local metadata = {}
	for key, item in pairs(result) do
		if key ~= "score" and key ~= "coins" then
			metadata[key] = item
		end
	end

	local score = result.score
	local coins = result.coins

	return score, coins, metadata
end

return M