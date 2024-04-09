-- Ядро для работы с данными игрока
local M = {}

local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"

local api_core_shop = require "main.core.api.api_core_shop"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local data_handler = require "main.data.data_handler"
local storage_gui = require "main.storage.storage_gui"

-- Записываем или добавляем очки в характеристики
function M.set_characteristic(self, id, operation, value, set, callback)
	local operation = operation or 'add'
	
	storage_player.characteristics[id] = storage_player.characteristics[id] or 0

	if operation == "add" then
		storage_player.characteristics[id] = storage_player.characteristics[id] + 1
	elseif operation == "set" then
		storage_player.characteristics[id] = value
	else
		return false
	end

	if set then
		local userdata = {
			characteristics = storage_player.characteristics,
			characteristic_points = storage_player.characteristic_points
		}

		data_handler.set_userdata(self, userdata, callback)
	end

	return storage_player.characteristics
end

-- Продажа предметов
function M.sell(self, id, type, count)
	local prizes = api_player.get_prizes()

	-- Смотрим доступна ли покупка
	if not prizes[id] or prizes[id] < count then
		
		msg.post("/loader_gui", "set_status", {
			id = "inventary_detail",
			type = "result_sell",
			value = {
				status = "error",
				type_object = "prize",
			}
		})
		msg.post("main:/loader_gui", "set_status", {
			id = "catalog_inventary",
			type = "result_sell",
			value = {
				status = "error",
				type_object = "prize",
			}
		})
		return false
	else
		local set_nakama = true
		api_player.set_prizes(self, id, -count, "add", set_nakama)

		-- Получаем приз
		local prize = game_content_prize.get_prize(id)

		local result = {
			coins = count * prize.price_sell,
			score = count * prize.score_sell,
			prize = prize
		}

		-- Отправляем сообщения в компоненты
		if storage_gui.components_visible.inventary_detail then
			msg.post("/loader_gui", "set_status", {
				id = "inventary_detail",
				type = "result_sell",
				value = {
					status = "success",
					type_object = "prize",
					coins = result.coins,
					score = result.score,
					prize = result.prize -- Приз
				}
			})
		end
		if storage_gui.components_visible.catalog_inventary then
			msg.post("main:/loader_gui", "set_status", {
				id = "catalog_inventary",
				type = "result_sell",
				value = {
					status = "success",
					type_object = "prize",
					coins = result.coins,
					score = result.score,
					prize = result.prize -- Приз
				}
			})
		end
	end
end



-- Улучшение
function M.upgrade(self, operation, upgrade_id, upgrade_value, price, sender)
	local price = price or 0

	if price > storage_player.coins then
		return
	end

	-- Оплачиваем
	msg.post("main:/core_player", "balance", {
		operation = "add",
		values = {
			coins = -price,
		},
		animate = true,
	})

	storage_player.upgrades = storage_player.upgrades or {}

	if operation == "set" then
		storage_player.upgrades[upgrade_id] = upgrade_value
	elseif operation == "add" then
		storage_player.upgrades[upgrade_id] = storage_player.upgrades[upgrade_id] or 0
		storage_player.upgrades[upgrade_id] = storage_player.upgrades[upgrade_id] + upgrade_value
	end

	data_handler.set_key_userdata(self, "upgrades", storage_player.upgrades, callback)

	if sender then
		msg.post(sender, "result_upgrade", {
			status = "success",
			upgrade_id = upgrade_id,
			upgrade_value = upgrade_value
		})
	end
end


return M