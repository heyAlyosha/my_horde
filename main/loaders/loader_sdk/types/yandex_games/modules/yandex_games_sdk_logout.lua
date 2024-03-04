-- Модуль для показа главного меню
local M = {}

local storage_loader = require "main.storage.storage_loader" 
local storage_player = require "main.storage.storage_player"
local storage_sdk = require "main.storage.storage_sdk" 
local storage_gui = require "main.storage.storage_gui"
local defold = require "nakama.engine.defold"
local nakama = require "nakama.nakama"
local nakama_storage = require "main.online.nakama.modules.nakama_storage"
local nakama_login = require "main.online.nakama.modules.nakama_login"
local nakama_controller = require "main.online.nakama.modules.nakama_controller"
local log = require "nakama.util.log"
local yagames = require("yagames.yagames")
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local defsave = require("defsave.defsave")
local api_player = require "main.game.api.api_player"
local online_import_account = require "main.online.online_import_account"
local data_handler = require "main.data.data_handler"

--[[local nakama_controller = require "main.online.nakama.modules.nakama_controller"
local loader_sdk_game_result = require "main.loaders.loader_sdk.modules.loader_sdk_game_result"
local loader_sdk_rpc = require "main.loaders.loader_sdk.modules.loader_sdk_rpc"
local sber_canvas_sdk_ads = require "main.loaders.loader_sdk.types.sber_canvas.modules.sber_canvas_sdk_ads"
local screen_content = require "main.content.screen.screen_content"
local content = {}
]]--

-- Авторизация и вход на сервер
function M.logout(is_anonym)
	local id = id or "test_id"

	-- Включаем логи
	log.print()

	if is_anonym then
		return

	else
		storage_sdk.handler = "yandex"
		local account = data_handler.init_player(self, storage_sdk.handler)

		-- Отправляем ивент в лоадер
		if not storage_player.import_anonym_data then
			-- Если нет импорта
			-- Отправляем ивент в лоадер
			msg.post("main:/loader_main", "event", {id = "logout", success = true})

		else
			-- Был анонимным игроком
			M.import(self)

		end
	end
end

function init(self)
	
end

-- Старт авторизации
function M.start()
	msg.post("/loader_gui", "visible", {
		id = "plug", visible = true, value = {
			title = "ПОЛУЧЕНИЕ ДАННЫХ ИГРОКА...",
			icon = false,
			btns = {},
		}
	})

	-- Инициализация
	yagames.init(function (self, err, result)
		-- ТВ или нет
		if false then
			storage_sdk.stats.device_type = "tv"
		else
			storage_sdk.stats.device_type = yagames.device_info_type()
		end

		if storage_sdk.stats.device_type == "tv" then
			storage_sdk.stats.is_exit = true
			storage_sdk.stats.is_ads_reward = false
			storage_sdk.stats.is_ads_fullscreen = false
			storage_sdk.stats.is_ads_horisontal_block = false
		else

			storage_sdk.stats.is_exit = false
			storage_sdk.stats.is_ads_reward = true
			storage_sdk.stats.is_ads_fullscreen = true
			storage_sdk.stats.is_ads_horisontal_block = true
		end

		if err then
			print("Something bad happened :(", err)
		else
			-- Отправляем, что загружены ресурсы
			yagames.features_loadingapi_ready()

			--local local_handler = true
			if local_handler or not html5 then
				-- Обычный билд
				storage_sdk.handler = "local"
				storage_sdk.player.is_anonime = true
				data_handler.init_player(self, storage_sdk.handler, function (self, err, data)
					if storage_player.import_anonym_data then
						-- Игрок был анонимом
						M.import(self)
					else
						msg.post("main:/loader_main", "event", {id = "logout", success = true})
					end

				end)
				--msg.post("main:/loader_main", "event", {id = "logout", success = true})
				return
			else
				-- Лидерборды
				yagames.leaderboards_init(function (self)
					storage_sdk.leaderboard_top = true
				end)
				-- Игрок
				M.init_player(self)
			end

		end
	end)

end

-- Инициализация игрока
function M.init_player(self)
	-- Иницииализируме игрока
	local options = {
		scopes = true
	}
	yagames.player_init(options, function (self, err, result) 
		if err then
			pprint("ERROR PLAYER INIT", err)

			--Игрок неавторизован на яндексе
			storage_sdk.handler = "local"
			storage_sdk.player.is_anonime = true
			local account = data_handler.init_player(self, storage_sdk.handler)
			msg.post("main:/loader_main", "event", {id = "logout", success = true})
			
			return

		else
			pprint("SUCCESS PLAYER INIT")
			-- Сырой массив с данными
			local player = yagames.player_get_personal_info()

			-- Управление для пульта
			yagames.event_on("HISTORY_BACK", function (self)
				input_remote_tv.activate_back(self)
				--print("yagames.event_on(\"HISTORY_BACK\")")
				return 
			end)

			if yagames.player_get_mode() == "lite" then
				--Игрок неавторизован на яндексе
				storage_sdk.handler = "local"
				storage_sdk.player.is_anonime = true
				local account = data_handler.init_player(self, storage_sdk.handler)
				msg.post("main:/loader_main", "event", {id = "logout", success = true})
				return

			else
				-- Игрок авторизован на яндексе
				-- Записываем его данные
				storage_sdk.handler = "yandex"
				storage_sdk.player = {
					id = yagames.player_get_unique_id(),
					name = yagames.player_get_name(),
					avatar_url = yagames.player_get_photo("medium"),
					avatar_urls = {
						small = yagames.player_get_photo("small"),
						medium = yagames.player_get_photo("medium"),
						large = yagames.player_get_photo("large"),
					},
					is_anonime = nil
				}
				storage_sdk.leaderboard_personal = true
				data_handler.init_player(self, storage_sdk.handler, function (self, err, data)
					if storage_player.import_anonym_data then
						-- Игрок был анонимом
						M.import(self)
					else
						local update_inteface = true
						storage_player.rating = api_player.get_rating(self, update_inteface)

						msg.post("main:/loader_main", "event", {id = "logout", success = true})
					end
					
				end)

			end
		end
	end)
end

-- Показ окна для авторизации
function M.open_auth_window(self)
	yagames.auth_open_auth_dialog(function (self, err, result)
		if err then
			pprint("ERROR AUTH DIALOG", err)
			return

		else
			-- Сохраняем данные для импорта
			storage_player.import_anonym_data = {
				score = storage_player.score or 0, 
				coins = storage_player.coins or 0,
				characteristics = storage_player.characteristics,
				prizes = storage_player.prizes,
				shop = storage_player.shop,
				visible_levels = storage_player.visible_levels,
				progress = storage_player.progress,
				achieve = storage_player.achieve,
				stats = storage_player.stats
			}

			M.init_player(self)
		end
	end)
end

-- Импорт аккаунта
function M.import(self)
	-- Импортируем его
	local anonym_data = storage_player.import_anonym_data
	local player_data = {
		coins = storage_player.coins, score = storage_player.score,
	}
	for k, item in pairs(storage_player.userdata) do
		player_data[k] = item
	end

	local score, coins, userdata = online_import_account.from_anonym(self, player_data, anonym_data)

	local wallet = {score = score, coins = coins}

	data_handler.set_wallet(self, wallet, operation, metadata, function (self, err, result)
		data_handler.set_userdata(self, userdata, function (self, err, result)
			--pprint("player_data", player_data)
			--pprint("anonym_data", anonym_data)
			--pprint("metadata", userdata)
			--print("print_wallet", storage_player.coins,storage_player.score)

			if not html5 then
				-- Для теста
				storage_sdk.player.is_anonime = nil
			end

			pprint("storage_gui.components_visible.interface", storage_gui.components_visible.interface)
			if storage_gui.components_visible.interface then
				msg.post("main:/loader_gui", "set_status", {
					id = "interface",
					type = "update_all"
				})
			end

			-- Главное меню
			if storage_gui.components_visible.main_menu then
				msg.post("main:/loader_gui", "set_status", {id = "main_menu", type = "update"})
			end

			if storage_gui.components_visible.modal_result_single then
				msg.post(storage_gui.components_visible.modal_result_single, "set_status", {id = "modal_result_single" , type = "login"})
			end

			data_handler.clear(self, "local")

			local update_inteface = true
			storage_player.rating = api_player.get_rating(self, update_inteface)

			msg.post("main:/loader_main", "event", {id = "logout", success = true, import = true})

			--[[
			nakama.sync(function()
				local update_inteface = true
				storage_player.rating = api_player.get_rating(self, update_inteface)

			end)
			--]]
		end)
	end)
end



return M