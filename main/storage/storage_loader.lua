-- Хранилище для данных загрузчика разделов игры
local M = {
	-- Путь до коллекции стартового экрана
	path_start_main = "/start-main/",
	-- Какой показывается экран сейчас
	active_screen = hash("none"),
	-- Звписываем путь для отправки сообщений
	screen_sender_proxy = false
}

return M