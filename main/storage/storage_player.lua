local storage_gui = require "main.storage.storage_gui"

-- Модуль для хранения данных для пользователя
local M = {}

M.lang_tag = "ru"
M.user_id = false
M.user_object = false
M.user_go_url = false
M.user_go_id = false
M.name = 'Анонимный игрок'
M.avatar_url = nil -- "icon-anonim"
M.coins = 0
M.xp = 0
M.resource = 0
M.score = 0
M.rating = 0
M.level = 1
M.add_reward_visit = nil
M.characteristics = {
	--[[
	mind = 10,
	charisma = 10,
	accuracy = 1,
	]]--
}
M.prizes = {}
M.shop = {
	--[[
	catch_1 = 2,
	catch_2 = 10,
	try = 2,
	--]]
}
M.visible_levels = {
	--category_id_level_id = 2,
}
M.artifacts = {
	--[[
	try_1 = 0,
	catch_1 = 10
	]]--
}
M.view_rewards = {
	--[[
	try_1 = 2,
	catch_1 = 10
	]]--
}
-- Прогресс в уровнях игрока
M.progress = {}

M.achieve_progress = {
	--[[
	full_stars_50 = 20,
	win_1 = 0,
	coins_50000 = 5000,
	full_mind = 5,
	--]]
}
M.achieve = {
	--[[
	full_trade = true,
	full_mind = true,
	score_100000 = true
	--]]
}


M.characteristic_points = 0
-- Хрпанилище для статистики
M.stats = {
	--[[
	wins = 0, fail = 0
	--]]
}

-- Части обучения
M.study = {
	--[[
	hello = true,
	aim = true,
	catch = true,
	accuracy = true,
	speed_caret = true,
	bank = true,
	artifact_trap = true,
	artifact_catch = true,
	obereg = true,
	level_up = true,
	shop_prizes = true,
	shop = true,
	stars = true,
	--inventary = true,
	keyboard = true,
	company = true,
	--]]
}

-- Типы управления игрока
M.input = {
	--touch = true,
	--mouse = true,
	--keyboard = true,
}

-- Улучшения
M.upgrades = {
	--trap = 1
}

M.user_nakama_id = false -- 
M.rewarde_view = 3 -- Максимальное кол-во просмотра рекламы
M.platform = "yandex-games" -- Платформа на которой игрок играет
M.valute = "ruble" -- Валюта для покупок
M.open_level = nil
-- Варианты управления
M.controlls = {
	--hash("voice"), 
	hash("remote"), 
	--hash("keyboard"), 
	--hash("mouse"), 
	--hash("sensor")
}

-- Камера
M.camera_position = vmath.vector3(0)
M.camera_projected_width = 560
M.camera_projected_height = 315
M.camera_xoffset = 0
M.camera_yoffset = 0
M.camera_zoom = 0
M.map_max_size = vmath.vector3(2000, 2000, 0)
M.camera_zoom_buff = vmath.vector3(0, 0, 0)
M.user_metadata = {}
M.data_rating = nil
M.window_width = 0
M.window_height = 0

-- Способ отрисовки движения орды
M.zombie_row_render_type = hash("animate")
M.develop_mode = false
M.nakama_localhost = sys.get_config("developers.nakama_localhost") == "1"
M.show_opening = false

if true or not M.nakama_localhost then
	M.config_nakama = {
		host = "nakama.heyalyosha.ru",
		port = 7350,
		use_ssl = true,
		username = "",
		password = "",
		engine = defold,
		timeout = 10, -- connection timeout in seconds
	}
else
	-- Для отладки
	M.config_nakama = {
		host = "127.0.0.1",
		port = 7350,
		use_ssl = false,
		username = "defaultkey",
		password = "",
		engine = defold,
		timeout = 10, -- connection timeout in seconds
	}
end
M.subscribe = false
M.client = false
M.token = false
M.socket = false
M.match_id = false
M.path_factories_online = "/"
M.frame_rate = 0.15
M.status_top = hash("none")
M.virtual_gamepad = {}

-- Параметры настроек
M.settings = {
	lang = 'ru',
	color = "aqua",
	volume_music = 0.5,
	volume_effects = 0.5,
	volume_effects = 0.5,
}

return M