local storage_player = require "main.storage.storage_player"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local api_player = require "main.game.api.api_player"
local api_core_shop = require "main.core.api.api_core_shop"
local storage_sdk = require "main.storage.storage_sdk"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_content_functions = require "main.game.content.modules.game_content_functions"

-- Информация про артефакты
local M = {}
M.catalog_keys = {}
M.catalog = {}

function M.init(self)
	--[[
	local group_columns = {
		score = "value",
		skipping = "value",
		sectors = "value",
		accuracy = "value",
		speed_caret = "value",
		reward = "value",
	}
	--]]
	--M.catalog_keys = game_content_functions.load_content(self, "artifact", group_columns)
	local is_replace_placeholder = false
	M.catalog_keys = game_content_functions.load_content(self, "artifact", group_columns, function (self, row_id, item)
		item.value = {
			score = item.score,
			skipping = item.skipping,
			sectors = item.sectors,
			accuracy = item.accuracy,
			speed_caret = item.speed_caret,
			reward = item.reward,
			color = item.color,
		}

		item.title_id_string = string.gsub(item.title_id_string, "{{id}}", row_id)
		item.description_id_string = string.gsub(item.description_id_string, "{{id}}", row_id)
		item.description_mini_id_string = string.gsub(item.description_mini_id_string, "{{id}}", row_id)

	end, is_replace_placeholder)

	M.catalog = game_content_functions.create_catalog(self, "sort", M.catalog_keys, sort_function)
end

-- Получение данных для артефактов
local is_get_not_player = nil -- Надо ли получать призы, которых нет у игрока
function M.get_catalog(self, player_id, is_game, is_reward)
	if is_reward == nil then is_reward = true end
	if is_game == nil then is_game = false end
	local player_id = player_id or "player"
	local result = {}

	for i, item in ipairs(M.catalog) do
		local item =  M.get_item(item.id, player_id, is_game, is_reward)

		if is_game then
			if item.type ~= "shop" then
				result[#result + 1] = item
			end
		else
			result[#result + 1] = item
		end
	end

	return result
end

function M.get_item(id, player_id, is_game, is_reward)
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
		-- Находим кол-во артефактов у игрока
		local player_items, player_rewards

		local player_rewards = api_player.get_view_rewards(self)
		local shop = api_core_shop.get_shop()

		-- если это игра, то находим предметы внутри игры, а не игрока
		if is_game then
			player_items = game_core_gamers.get_player(self, player_id).artifacts
		else
			player_items = api_player.get_artifacts(self)
		end

		local count = player_items[item.id] or 0
		local count_shop = shop[item.id] or 0
		local reward_view = player_rewards[item.id] or 0
		local reward = item.value.reward or 0

		-- Нужно ли добавлять товары при завовзе в магазин
		local is_add_random_shop = true
		storage_player.characteristics.trade = storage_player.characteristics.trade or 0

		if item.add_shop  == 0 then
			is_add_random_shop = false

		elseif storage_player.characteristics.trade < item.level and item.id ~= "try_1" then
			is_add_random_shop = false
		end

		if item.shop_infinite then
			count_shop = 1

		elseif shop[item.id] == nil then
			count_shop = item.start_shop

		end

		-- Если нет рекламы с вознаграждением ставим 0
		if not storage_sdk.stats.is_ads_reward or is_reward == false then
			reward_view = 0
			reward = 0
		end

		-- Формируем стоимость в зависимости от улучшения магазина
		storage_player.characteristics.charisma = storage_player.characteristics.charisma or  0
		item.level_shop = item.level_shop or 0
		item.original_price = item.original_price or item.price_buy
		item.price_buy = item.original_price - item.level_shop * storage_player.characteristics.charisma

		if item.price_buy <= 0 then
			item.price_buy = 1
		end

		-- Стоит ли показывать в магазине
		if item.upgrade_id then
			storage_player.upgrades = storage_player.upgrades or {}
			storage_player.upgrades[item.type] = storage_player.upgrades[item.type] or 1

			local current_upgrade_product_id = item.type .. "_" .. storage_player.upgrades[item.type]

			item.visible_shop = current_upgrade_product_id == item.id
		else
			item.visible_shop = true
		end

		-- Вычисляем доступно ли для покупки
		local is_buy = storage_player.coins >= item.price_buy
		-- Смотрим подходит ли по уровню
		local disable = game_content_characteristic.get_id(self, "charisma").level < item.level
		-- Смотрим дотупно ли за рекламу
		local is_reward = reward - reward_view
		if is_reward < 1 then is_reward = false end

		local result = {}
		for k, v in pairs(item) do
			result[k] = v
		end

		result.is_use = count > 0 or is_reward
		result.count = count
		result.is_buy = is_buy
		result.disable = disable
		result.disable_buy = disable_buy
		result.is_reward = is_reward
		result.reward = reward
		result.count_shop = count_shop
		result.catch = catch
		result.scale = result.scale / 100
		result.is_add_random_shop = is_add_random_shop

		result.buy = {
			buy_type = "buy",
			error_id_string = ""
		}

		-- Определяем доступен ли для покупки
		if not result.disable and result.is_buy and result.count_shop > 0 then
			-- Доступен для покупки
			result.buy.buy_type = "buy"
			result.buy.error_id_string = ""
			result.disable_buy = false

		elseif result.count_shop  < 1 then
			-- если не осталось товара в магазине
			result.buy.buy_type = result.buy.buy_type
			result.buy.error_id_string = "_product_over"
			result.disable_buy = true

		elseif result.is_reward and result.count_shop > 0  then
			-- Доступен для просмотра рекламы
			result.buy.buy_type = "reward"
			result.buy.error_id_string = ""
			result.disable_buy = false

		elseif result.disable then
			-- Заблокирован из-за уровня
			result.buy.buy_type = "buy"
			result.buy.error_id_string = "_required_level_charisma"
			result.disable_buy = true

		elseif not result.is_buy then
			-- Обработка случаев, когда не хватает денег
			if not result.is_reward and result.reward > 0 then
				-- если не хватает денег у игрока и закончились просмотры рекламы
				result.buy.buy_type = result.buy.buy_type
				result.buy.error_id_string = "_reward__video_over_come_to_back"
				result.disable_buy = true

			elseif not result.is_reward and result.reward == 0 then
				-- если не хватает денег у игрока и недоступны просмотры рекламы
				result.buy.buy_type = result.buy.buy_type
				result.buy.error_id_string = "_no_gold"
				result.disable_buy = true

			elseif result.is_reward then
				-- если не хватает денег у игрока , но доступна реклама
				result.buy.buy_type = "reward"
				result.buy.error_id_string = "_no_gold"
				result.disable_buy = false

			else
				result.buy.buy_type = false
				result.buy.error_id_string = "_no_gold"
				result.disable_buy = true

			end

		else
			-- Доступен для покупки
			result.buy.buy_type = "buy"
			result.buy.error_id_string = ""
			result.disable_buy = false
		end

		-- Смотрим можно ли продать призы для покупки
		if result.disable_buy or result.buy.buy_type == "reward" then
			if not storage_player.study.inventary then
				result.buy.sell = true
			else
				for prize_id, count in pairs(storage_player.prizes) do
					if count > 0 then
						result.buy.sell = true
						break
					end
				end
			end
		end

		return result
	end
end

return M