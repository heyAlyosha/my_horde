-- Модуль авторизации на сервере Накама
local M = {}

local defold = require "nakama.engine.defold"
local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local storage_sdk = require "main.storage.storage_sdk"
local storage_gui = require "main.storage.storage_gui"
local nakama_storage = require "main.online.nakama.modules.nakama_storage"
local json = require "nakama.util.json"
local loader_sdk_rpc = require "main.loaders.loader_sdk.modules.loader_sdk_rpc"
local storage_sdk = require "main.storage.storage_sdk"
local api_player = require "main.game.api.api_player"
local nakama_api_rating = require "main.online.nakama.api.nakama_api_rating"
local online_import_account = require "main.online.online_import_account"

-- Авторизация пользователя по девайсу и получение токена авторизации
function M.device_login(client)
	local body = nakama.create_api_account_device(defold.uuid())

	local result = nakama.authenticate_device(client, body, true)

	if result.token then
		-- store the token and use it when communicating with the server
		storage_player.token = result.token
		nakama.set_bearer_token(client, result.token)

		return true
	end

	return false
end

-- Авторизация по кастомному ID
function M.custom_login(client, custom_id)
	--local body = nakama.create_api_account_custom(custom_id)
	local id = custom_id
	local create_bool = true
	local username_str = custom_id
	local result = client.authenticate_custom(id, vars, create_bool, username_str, callback, retry_policy, cancellation_token)

	if result.token then
		-- store the token and use it when communicating with the server
		storage_player.token = result.token
		nakama.set_bearer_token(client, result.token)

		return true
	end

	return false
end

-- Авторизуемся
function M.login(id, type)
	storage_player.client = nakama.create_client(nakama_storage.config)
	if type == "custom" then
		return M.custom_login(storage_player.client, id)
	else
		return M.device_login(storage_player.client)
	end
end

-- Подключаемся к сокету
function M.create_socket()
	storage_player.socket = storage_player.client.create_socket()
	local ok, err = storage_player.socket.connect()

	if not ok then
		print("Unable to connect: ", err)
		return false
	else
		pprint(ok,err)
		return true
	end
end

-- Получение данных аккаунта
function M.get_account()
	local account = nakama.get_account(storage_player.client)

	if not account.error then
		-- Если всё в порядке
		account.user.metadata = json.decode(account.user.metadata)
		account.wallet = json.decode(account.wallet)

		-- Имя 
		storage_player.id = account.user.id
		storage_player.name = account.user.display_name
		storage_player.user_name = account.user.display_name
		storage_player.avatar_url = account.user.avatar_url
		storage_player.user_nakama_id = account.user.id
		storage_player.lang_tag = account.lang_tag
		storage_player.coins = account.wallet.coins or 0
		storage_player.score = account.wallet.score or 0
		storage_player.user_metadata = account.user.metadata or {}

		-- записывае настройки, инвентарь и тд
		for id, data in pairs(storage_player.user_metadata) do
			storage_player[id] = data
		end

		-- Получаем рейтинг, если нет
		if not storage_player.import_anonym_data then
			local update_inteface = true
			storage_player.rating = api_player.get_rating(self, update_inteface)
		end
		

		-- Если каких то настроек нет - ставим дефолтные
		storage_player.settings = api_player.get_settings(self)

		--pprint(storage_player.user_metadata)

		--[[
		local feedback = nakama.rpc_func(storage_player.client, "feedback", json.encode({
			data = {
				method = "get",
			}
		}), storage_player.token)
		storage_player.feedback = json.decode(feedback.payload)
		storage_player.subscribe = loader_sdk_rpc.get_subscribe(storage_sdk.stats.platform_id)
		--]]

		M.update_interface(self)

		pprint("M.get_account", account)
		return account
	else
		-- Если ошибка с сервера
		storage_player.name = "-"
		storage_player.user_nakama_id = false
		storage_player.coins = 0

		storage_player.user_metadata = {}
		pprint("Get account error:", account.error)
		return false
	end
end

-- Импортируем анонимный аккаунт в обычный
function M.import_anonym_to_account(accoutn_id)
	local anonym_data = {
		score = storage_player.score or 0, coins = storage_player.coins or 0,
		characteristics = storage_player.characteristics,
		prizes = storage_player.prizes,
		shop = storage_player.shop,
		visible_levels = storage_player.visible_levels,
		progress = storage_player.progress,
		achieve = storage_player.achieve,
		stats = storage_player.stats
	}
	local score, coins, metadata = online_import_account.from_anonym(self, player_data, anonym_data)
end

-- Обновляем экраны
function M.update_interface(self)
	-- Интерфейс
	if storage_gui.components_visible.interface then
		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "update_all"
		})
	end
	
	-- Главное меню
	if storage_gui.components_visible.main_menu then
		msg.post("main:/loader_gui", "set_status", {id = "main_menu", type = "update"})

	end

	-- Окно результатов
	if storage_gui.components_visible.modal_result_single then
		msg.post("main:/loader_gui", "set_status", {id = "modal_result_single", type = "login"})

	end
end

return M