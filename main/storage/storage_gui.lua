
-- Модуль для хранения данных для интерфейса
local M = {}

--Храним переменные для работы с всплывающими окнами
M.modal = false
M.modals = {}
M.visible_virtual_gamepad = nil
-- Данные для инвентаря
M.inventary_wrap = {
	visible = false,
	last_sound = nil,
	last_focus = nil, -- {id_component = "test", index_btn = 1}
}
-- Настройки для ядра экранов
M.core_screens = {
	visible_shop = true
}
M.down_popup_main = {s = {}, api = {}}
M.down_popup_nav = {s = {}, api = {}}
M.components_visible_hash_to_id = {} -- Хранить id по хэшам
M.components_visible_sender_to_id = {}
M.components_history_msg = {} -- История сообщений в компонент
M.components_visible_sender_fragment_to_id = {}
M.screen = hash("none")
M.url = {}
M.nodes = {}
M.focus_input_component = nil
M.focus_input_id_component = nil
M.open_company_id = nil -- Какая компания открыта
M.is_user_top = false -- Показывать топ игрока 
-- Данные для плашек помощи
M.help_items = {}

-- Ссылки на видимые компоненты гуишек
M.components_visible = {
	debug_block = nil,
	virtual_gamepad = nil,
}
-- Компоненты затемнённых фонов
M.components_bg = {
	debug_block = nil,
	virtual_gamepad = nil,
}
-- Храним статусы и контент
M.components_status = {}
M.components_content = {}

-- Компоненты gui
M.components_gui = {}
-- Хранение уведомлений
M.notify = {}

M.data = {
	-- Данные для компонента интерфейса игрока
	interface = {
		position_coin_screen = false,
		position_score_screen = false,
	},
	-- Данные для правой верхней панели на игровом экране
	game_screen_panel_right = {
		humans = 0,
		horde = 0,
		gold = 0
	},
	-- Данные для доната 
	modal_donate = {
		no_coins = nil,
		coins = nil
	},
	--
	game = {
		position_wheel = nil
	}
	
}

M.iterface_btns_set_current = nil

M.catalog_rating = {
	is_user_top = false
}

-- Результат игры
--[[
M.game_result = {
	type_result = "win/fail",
	type_game = "single/coop",
	level_id = 2,
	category_id = 0,
	current_star = 0
}
--]]
M.game_result = {
	type_result = "win",
	type_game = "single",
	level_id = 2,
	category_id = hash("sport"),
	current_star = 3,
	score = 3000,
	prizes = {
		{id = 1, count = 5},
		{id = 3, count = 14},
		{id = 4, count = 2},
		{id = 6, count = 5},
		{id = 8, count = 1},
		{id = 10, count = 1},
		{id = 12, count = 7},
		{id = 13, count = 3},
		{id = 15, count = 9},
		{id = 16, count = 9},
	}
}

-- Порядок отрисовки компонентов
M.orders = {
	inventary_component = 6, -- Компоненты внутри инвентаря
	inventary_wrap = 8,
	default_screen = 5,
	interface = 9,
	modal = 10,
	pause = 12,
	keyboard = 11,
	main_title = 12,
	default_bg = 1,
	transfer = 4,
	notify = 11,
	plug = 12,
	modal_exit = 13,
}
-- Позиции гуи элементов откосительно экрана
M.positions = {}

return M