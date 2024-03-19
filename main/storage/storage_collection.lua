-- Хранилище для данных загрузчика разделов игры
local M = {
	path_proxy_game = nil,
	-- Путь до коллекции стартового экрана
	path_start_main = "/start-main/",
	-- Какой показывается экран сейчас
	active_screen = hash("none"),
	-- Звписываем путь для отправки сообщений
	screen_sender_proxy = false,
	offline_win_controller_url = nil,
}

return M