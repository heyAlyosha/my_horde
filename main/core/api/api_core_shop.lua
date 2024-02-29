-- Функции для работы с магазином через АПИ
local M = {}

local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local storage_gui = require "main.storage.storage_gui"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local game_content_notify_add = require "main.game.content.game_content_notify_add"
local api_player = require "main.game.api.api_player"
local data_handler = require "main.data.data_handler"

-- Получение количества товаров в магазине
function M.get_shop(self, count)
	return storage_player.shop
end

-- Добавление товаров в магазин
function M.add_shop(self, id, count, set)
	nakama.sync(function (self)
		storage_player.shop[id] = storage_player.shop[id] or 0
		storage_player.shop[id] = storage_player.shop[id] + count

		if storage_player.shop[id] < 0 then
			storage_player.shop[id] = 0
		end

		if set then
			data_handler.set_key_userdata(self, "shop", storage_player.shop, callback)
		end
	end, cancellation_token)
	

	return storage_player.shop
end

-- Рандомное добавление товаров в магазин 
function M.random_add_object_to_shop(self, count_object, game_content_artifact)
	local count_object = count_object or game_content_characteristic.get_id(self, "charisma").buff
	local catalog = game_content_artifact.get_catalog(self)

	--Удаляем из массива артефакты, которые не нужны
	for i =  #catalog, 1, -1 do
		local item = catalog[i]
		
		if not item.is_add_random_shop or not item.visible_shop then
			table.remove(catalog, i)
		end

	end

	local types_add_objects = {}

	for i = 1, count_object do
		-- Находим рандомный объект 
		math.randomseed(os.clock() * i)
		local random_object = catalog[math.random(#catalog)]
		-- Добавляем его в магазин
		M.add_shop(self, random_object.id, random_object.add_shop)
		print("add:", random_object.id)
		
		-- Добавляем в типы 
		if not types_add_objects[random_object.type] then
			types_add_objects[random_object.type] = true
		end
	end

	data_handler.set_key_userdata(self, "shop", storage_player.shop, callback)
	game_content_notify_add.update_shop(self, types_add_objects)

	return storage_player.shop
end

-- Получение товара игроком
function M.player_add_object(self, id, type, count)
	storage_player.shop[id] = storage_player.shop[id] or 0

	-- Есть ли в магазине такое количество 
	if storage_player.shop[id] < count then
		return false
	else
		-- Добавляем игроку
		api_player.set_artifacts(self, id, count, "add", false)

		-- Отнимаем из наличия магазина
		M.add_shop(self, id, -count, false)

		local userdata = {shop = storage_player.shop, artifacts = storage_player.artifacts}
		data_handler.set_userdata(self, userdata, function_result)

		return storage_player.artifacts[id] 
	end
end

-- Покупка предмета
function M.buy(self, id, type, count, game_content_artifact)
	local type = "artifact"

	if type == "artifact" then
		local object = game_content_artifact.get_item(id)
		local error = false

		-- Проверяем доступно ли для покупки
		if not object.is_buy or object.disable then
			error = true
		else
			-- Доступно
			-- Оплачиваем
			msg.post("main:/core_player", "balance", {
				operation = "add",
				values = {
					coins = -object.price_buy * count,
				},
				animate = true,
			})

			-- Добавляем объект
			local result = M.player_add_object(self, object.id, type, count)

			-- Получаем приз
			local item_content = game_content_artifact.get_item(id)

			if result then
				--M.random_add_object_to_shop(self, count_object, game_content_artifact)

				-- Отправляем сообщения в компоненты
				if storage_gui.components_visible.inventary_detail then
					msg.post("/loader_gui", "set_status", {
						id = "inventary_detail",
						type = "result_buy",
						value = {
							status = "success",
							type_object = type,
							item_id = id 
						}
					})
				end 

				msg.post("main:/loader_gui", "set_status", {
					id = "catalog_shop",
					type = "result_buy",
					value = {
						status = "success",
						type_object = type,
						item_id = id 
					}
				})

			else 
				error = true
			end
		end

		if error then
			-- Не доступно
			if storage_gui.components_visible.inventary_detail then
				msg.post("/loader_gui", "set_status", {
					id = "inventary_detail",
					type = "result_buy",
					value = {
						status = "error",
						type_object = type,
						item_id = id
					}
				})
			end
			msg.post("main:/loader_gui", "set_status", {
				id = "catalog_shop",
				type = "result_buy",
				value = {
					status = "error",
					type_object = type,
					item_id = id 
				}
			})

			return false
		end
	end
end

-- Завоз в магазин
function M.add_random_shop(self, game_content_artifact)
	local count_object = game_content_characteristic.get_id(self, "charisma").buff
	M.random_add_object_to_shop(self, count_object, game_content_artifact)
end

-- Первый зваоз в магазин при иницииализации игрока
function M.add_start_shop(self, game_content_artifact, function_result)
	local catalog = game_content_artifact.get_catalog(self)
	for i, item in ipairs(catalog) do
		if storage_player.shop[item.id] == nil and item.start_shop then
			storage_player.shop[item.id] = item.start_shop
		end
	end

	data_handler.set_key_userdata(self, "shop", storage_player.shop, callback)
end

return M