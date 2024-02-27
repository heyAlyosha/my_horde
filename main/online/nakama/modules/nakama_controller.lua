-- Модуль для распределения сообщений от сервера во время игры
local M = {}

local defold = require "nakama.engine.defold"
local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local nakama_storage = require "main.online.nakama.modules.nakama_storage"
--local screen_content = require "main.content.screen.screen_content"
--local notification_online_core = require "main.online.render.notification.notification_online_core"
--local nakama_render_array = require "main.nakama.nakama_render.modules.nakama_render_array"
--local ProFi = require "main.global.ProFi"
--local match_codes = require "main.content.codes.match_codes"
--local op_codes = require "main.content.codes.op_codes"
--local buff_codes =  require "main.content.codes.buff_codes"
--local game_screen_rating = require "main.gui.game_screen.modules.game_screen_rating"

-- Разъединение с сервером во время игры
function M.disconnect(message)
	print("Disconnected!")

	msg.post("main:/loader", "event", {id = "error_disconect_nakama"})

	-- Показываем ошибку с дисконектом
	msg.post("main:/loader_gui", "set_content", {
		id = "preloader_default",
		title = screen_content.get(hash("errors"), "disconect_nakama_title"),
		description = screen_content.get(hash("errors"), "disconect_nakama_description"),
		icon = "Eror_icon",
		btn_action = "error_join_room_back",
		btn_title = screen_content.get(hash("errors"), "disconect_nakama_btn"),
		btn_color = "green",
		btn_focus = true,
		sound = "error"
	})
end

-- Ошибка во время работы с сервером
function M.error(message)
	print("Error:")
	pprint(message)

	msg.post("main:/loader", "event", {id = "error_room_nakama"})

	-- Показываем ошибку с дисконектом
	msg.post("main:/loader_gui", "set_content", {
		id = "preloader_default",
		title = screen_content.get(hash("errors"), "error_nakama_title"),
		description = screen_content.get(hash("errors"), "error_nakama_description"),
		icon = "Eror_icon",
		btn_action = "error_join_room_back",
		btn_title = screen_content.get(hash("errors"), "error_nakama_btn"),
		btn_color = "green",
		btn_focus = true,
		sound = "error"
	})
end

-- Уведомления с сервера во время игры
function M.notification(message)
	pprint("------------------------------")

	nakama.sync(function ()
		local data = message.notifications.notifications
		--print("Notification:")
		local ids = {}

		for i = 1, #data do
			local item = data[i]
			item.content = json.decode(item.content)
			notification_online_core.core(item)
			if item.content.persistent then
				table.insert(ids, item.id)
				--pprint("DELETE notification", item)
			end
		end

		-- Удаляем прочитанные сообщения
		if #ids > 0 then
			nakama.delete_notifications(storage_player.client, ids)
		end
	end)
end

-- Сообщения в канале
function M.channelmessage(message)
	print("Chanelmessage:")
	pprint(message)
end

-- Сообщение при входе в игру
function M.matchpresence(message)
	--print("Matchpresence:")
	--pprint(message)
end

-- Сообщения с данными при игре
function M.matchdata(data)
	--Проверяем, что оп код имеет значение установки позиций игровых объектов
	--print(data.match_data.op_code, ' - ', match_codes.game_data)
	if data.match_data.op_code == match_codes.game_data then
		--pprint("ЕСть")
		--data = cjson.decode(data.match_data.data)
		--pprint("Длина массива:", data.match_data.data:len())
		--online_core_render.render(s, data, go)
		
		nakama_render_array.add_data(data.match_data.data)
	elseif data.match_data.op_code == match_codes.buff_data then 
		local data = cjson.decode(data.match_data.data)

		if storage_player.user_object_path then
			storage_player.buffs = data
			-- Отправляем обновление улучшения обзора
			for i, item in ipairs(storage_player.buffs) do
				if buff_codes.scale_view == item.i then
					msg.post(storage_player.user_object_path, "update_scale", 
					{
						x = storage_player.camera_projected_width * (item.v / 100), 
						y = storage_player.camera_projected_height * (item.v / 100)
					})
					break
				end
			end
			msg.post(storage_player.user_object_path, "update_rating", {"update"})
		end

	elseif data.match_data.op_code == match_codes.stats_data then 
		local data = cjson.decode(data.match_data.data)
		if storage_player.user_object_path then
			msg.post(storage_player.user_object_path, "update_stats", {
				horde = data.z,
				humans = data.h,
				coins = data.c,
			})
		end

	elseif data.match_data.op_code == match_codes.add_coins then 
		local data = cjson.decode(data.match_data.data)
		storage_player.add_wallet({
			coins = data.balance
		})

		if storage_player.user_object_path then
			msg.post(storage_player.user_object_path, "add_gold", {
				count = data.count, 
				balance = data.balance, 
				id_player = storage_player.user_object
			})
		end

	elseif data.match_data.op_code == match_codes.rating_data then 
		local data = cjson.decode(data.match_data.data)
		game_screen_rating.storage = data
	end
end

-- Прочитать устаревшие уведомления
function M.read_old_notification(self)
	nakama.sync(function ()
		local data = nakama.list_notifications(storage_player.client, 10)
		local notifications = data.notifications
		local ids = {}

		if notifications then
			for i = 1, #notifications do
				local item = notifications[i]
				item.content = json.decode(item.content)
				notification_online_core.core(item)
				if item.content.persistent then
					table.insert(ids, item.id)
					--pprint("DELETE notification", item)
				end
			end

			-- Удаляем прочитанные сообщения
			if #ids > 0 then
				nakama.delete_notifications(storage_player.client, ids)
			end
		end
	end)
end



return M