local storage_player = require "main.storage.storage_player"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local api_player = require "main.game.api.api_player"
local game_content_functions = require "main.game.content.modules.game_content_functions"

-- Информация про ботов
local M = {}
M.catalog_keys = {}
M.catalog = {}

function M.init(self)
	M.catalog_keys = game_content_functions.load_content(self, "prizes")
	M.catalog = game_content_functions.create_catalog(self, "price_buy", M.catalog_keys)
end

-- Получение данных для каталога призов
local is_magazine = nil -- если это магазин
local is_get_not_player = nil -- Надо ли получать призы, которых нет у игрока
function M.get_catalog_prizes(self, is_magazine, is_get_disabled)
	local result = {}

	for i, item in ipairs(M.catalog) do
		local item =  M.get_prize(item.id)

		if is_get_disabled or item.count > 0 then
			item.index = i
			result[#result + 1] = item
		end
	end

	return result
end

function M.get_prize(id)
	-- кешируем по ключу
	if #M.catalog_keys < 1 then
		for k, item in ipairs(M.catalog) do
			M.catalog_keys[item.id] = item
		end
	end

	local item = M.catalog_keys[id]
	if not item then
		return false
	else
		-- Находим кол-во призов у игрока
		local player_prizes = api_player.get_prizes(self)
		local count = player_prizes[item.id] or 0

		-- Вычисляем стоимость продажи
		local price_sell = item.price_buy * (game_content_characteristic.get_id(self, "trade").buff / 100)
		local score_sell = game_content_characteristic.get_id(self, "mind").buff

		return {
			id = item.id,
			type = "prize",
			title_id_string = item.title_id_string,
			description_id_string = item.description_id_string,
			icon = item.icon,
			price_buy = math.floor(item.price_buy),
			price_sell = math.floor(price_sell),
			score_sell = math.floor(score_sell),
			count = count
		}	
	end
end

return M