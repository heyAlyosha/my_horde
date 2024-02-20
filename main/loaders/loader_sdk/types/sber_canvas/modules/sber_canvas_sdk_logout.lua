-- Модуль для показа главного меню
local M = {}

local storage_loader = require "main.storage.storage_loader" 
local storage_player = require "main.storage.storage_player" 
local storage_sdk = require "main.storage.storage_sdk" 
local defold = require "nakama.engine.defold"
local nakama = require "nakama.nakama"
--local nakama_storage = require "main.online.nakama.modules.nakama_storage"
--local nakama_login = require "main.online.nakama.modules.nakama_login"
--[[local nakama_controller = require "main.online.nakama.modules.nakama_controller"
local loader_sdk_game_result = require "main.loaders.loader_sdk.modules.loader_sdk_game_result"
local loader_sdk_rpc = require "main.loaders.loader_sdk.modules.loader_sdk_rpc"
local sber_canvas_sdk_ads = require "main.loaders.loader_sdk.types.sber_canvas.modules.sber_canvas_sdk_ads"
local screen_content = require "main.content.screen.screen_content"
local content = {}
]]--

-- Получаем данные о пользователе на площадке
local function get_sdk_account()
	if html5 then
		html5.run([=[
		window.assistant_client.sendData(
		{
			action: {action_id: 'GET_GAMER'}
		});]=])
	end
end

-- Авторизация и вход на сервер
function M.logout(id)
	content = {
		btn_err_refresh = screen_content.get(hash("logout"), "btn_err_refresh"),
		btn_err_exit = screen_content.get(hash("logout"), "btn_err_exit"),
		logout = screen_content.get(hash("logout"), "logout"),
		login_err_title = screen_content.get(hash("logout"), "login_err_title"),
		socket = screen_content.get(hash("logout"), "socket"),
		socket_err_title = screen_content.get(hash("logout"), "socket_err_title"),
		load_data = screen_content.get(hash("logout"), "load_data"),
		description_loader = screen_content.get(hash("logout"), "description_loader"),
		err_description = screen_content.get(hash("logout"), "err_description"),
	}

	nakama.sync(function()
		--Если нет токена для авторизации, создаём его
		--if not storage_player.token then
		if true then
			M.get_account = nakama_login.login("sber-" .. MD5.calculate(id), "custom")
			
			if not M.get_account then
				-- Показываем ошибку
				msg.post("main:/loader_gui", "set_content", {
					id = "preloader_default",
					title = content.login_err_title,
					description = content.err_description,
					icon = "Eror_icon",
					btn_action = "error_logout",
					btn_color = "green",
					btn_title = content.btn_err_refresh,
					btn_focus = false,
					btns = {
						{title = content.btn_err_exit, color = "orange", action = "exit_game"},
					}
				})
				msg.post("main:/loader", "event", {id = "error_logout", step = "login"})

				return false
			end
		end

		--Если нет подключенного сокет сервера, подключаемся к нему
		--if not storage_player.socket then
		if true then
			msg.post("main:/loader_gui", "set_content", {
				id = "preloader_default",
				title = content.socket,
			})

			if not nakama_login.create_socket() then
				-- Показываем ошибку
				msg.post("main:/loader_gui", "set_content", {
					id = "preloader_default",
					title = content.socket_err,
					description = content.err_description,
					icon = "Eror_icon",
					btn_action = "error_logout",
					btn_color = "green",
					btn_title = content.btn_err_refresh,
					btn_focus = false,
					btns = {
						{title = content.btn_err_exit, color = "orange", action = "exit_game"},
					}
				})
				msg.post("main:/loader", "event", {id = "error_logout", step = "create_socket"})
				return false
			end
		end

		msg.post("main:/loader_gui", "set_content", {
			id = "preloader_default",
			title = content.load_data,
		})
	
		if nakama_login.get_account() then
			-- Умпешный вход, отправляем ивент в лоадер
			msg.post("main:/loader", "event", {id = "logout_success"})
			nakama.on_notification(storage_player.socket, nakama_controller.notification)
		else
			-- Показываем ошибку
			msg.post("main:/loader_gui", "set_content", {
				id = "preloader_default",
				title = content.account_err,
				description = content.err_description,
				icon = "Eror_icon",
				btn_action = "error_logout",
				btn_color = "green",
				btn_title = content.btn_err_refresh,
				btn_focus = false,
				btns = {
					{title = content.btn_err_exit, color = "orange", action = "exit_game"},
				}
			})
			msg.post("main:/loader", "event", {id = "error_logout", step = "account_err"})
		end
	end)
end

-- Посылаем запросы на полдучение данных об игроке
function M.start()
	-- Показываем прелоадер
	msg.post("main:/loader_gui", "set_content", {
		id = "preloader_default",
		title = screen_content.get(hash("logout"), "login_sdk"),
		description = screen_content.get(hash("logout"), "description_loader"),
		icon = "loader",
		btn_action = false,
		btns = {}
	})

	M.max_count_get_sdk_account = 3
	M.count_get_sdk_account = 1

	if M.start_timer then
		timer.cancel(M.start_timer)
		M.start_timer = nil
	end

	M.start_timer = timer.delay(3, true, function ()
		if M.get_account then
			-- Если id игрока получено, просто удаляем таймер
			timer.cancel(M.start_timer)
			M.start_timer = nil
			M.get_account = nil

		elseif M.count_get_sdk_account > M.max_count_get_sdk_account  then
			-- Если колличество запросов перевалило лимит, показываем ошибку
			timer.cancel(M.start_timer)
			M.start_timer = nil
			M.get_account = nil

			msg.post("main:/loader_gui", "set_content", {
				id = "preloader_default",
				title = screen_content.get(hash("logout"), "err").login_sdk,
				description = screen_content.get(hash("logout"), "err_description"),
				icon = "Eror_icon",
				btn_action = "error_logout",
				btn_color = "green",
				btn_title = screen_content.get(hash("logout"), "btn_err_refresh"),
				btn_focus = false,
				btns = {
					{title = screen_content.get(hash("logout"), "btn_err_exit"), color = "orange", action = "exit_game"},
				}
			})

		else
			-- Отправляем запрос на получение ID сдк
			M.count_get_sdk_account = M.count_get_sdk_account + 1
			get_sdk_account()
		end
	end)

	-- Для теста авторизуемся
	if sys.get_config("developers.is_logout_pip") == "1" then
		
		M.logout("pip")
	end
end

return M