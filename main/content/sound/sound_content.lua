-- Модуль для хранения контента для звуков
local M = {}

M.sounds = {
	focus_main_menu = "nav_click_1", -- Звук фокусирования на элемент меню
	animate_rating_change_place = "game_result_trophys_1", -- Звук изменения позиции игркоа в рейтинге
	block_nav = "nav_block_2", -- Звук недоступной вкладки
	rating_animate_changed_success = "modal_top_2_2", -- Звук завершения анимации изменения рейтинга игрока
	level_up = "modal_top_1_2", -- Звук завершения анимации изменения рейтинга игрока
	open_modal = "popup_hide_2", -- Звук открытия модального окна
	close_modal = "popup_hide_2", -- Звук закрытия модального окна
	activate_btn = "active_btns_short_1", -- Звук закрытия модального окна
	activate_switch = "switch_1", -- Звук переключателя
	listen_category_inventary = "listen_category_4", -- Звук смены категории
	popup_hidden = "popup_hide_2", -- Скрытие модального окна
	sell = "sold_bulb_1", -- Продажа
	add_gold = {
		"add_gold_1", "add_gold_2", "add_gold_3", "add_gold_4", "add_gold_5", -- Добавление золота
	},
	add_score = {
		"game_result_leaders_1"
	},
	update_rating = {
		"game_result_leaderboard"
	},
	inventary_category_listen = "listen_category_4",
	open_shop = "open_shop",
	buy = "buy_1",
	notify_open = "modal_help_4",
	notify_show_item = "switch_1",
	improve = "modal_top_3_2",
}

-- Получаем звуки 
function M.get(id)
	return M.sounds[id] or id
end

-- Получаем получаем рандомный звук 
function M.get_random(id)
	local item = M.sounds[id] or id
	if type(item) == "table" then
		return M.sounds[id][math.random(1, #M.sounds[id])]
	else
		return item
	end
end

return M