-- Анимация для победы
local M = {}

local gui_animate = require "main.gui.modules.gui_animate"
local modal_result_single_animations = require "main.gui.modals.modal_result_single.animations.modal_result_single_animations"
local game_content_stars = require "main.game.content.game_content_stars"
local gui_manager = require "main.gui.modules.gui_manager"
local game_content_levels = require "main.game.content.game_content_levels"
local gui_render = require "main.gui.modules.gui_render"
local gui_size = require 'main.gui.modules.gui_size'
local gui_input = require "main.gui.modules.gui_input"
local timer_linear = require "main.modules.timer_linear"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

function M.start(self, data, function_start, function_end)
	-- АНИМАЦИЯ ПОЯВЛЕНИЯ ЭЛЕМЕНТОВ ПОБЕДЫ
	self.delay = 0
	self.animate = true

	-- Заупскаем функцию перед началом анимации, если есть
	if function_start then
		function_start(self)
	end

	-- Анимация появления списка призов
	local node_wrap = gui.get_node('prize_icons_wrap')
	local node_more = gui.get_node('prize_more')
	local max_prizes = 9

	modal_result_single_animations.animate_prizes(self, node_prize, node_wrap, node_more, max_prizes, self.delay, params, data)

	-- Анимируем появление плашки текущего уровня
	gui_loyouts.set_enabled(self, gui.get_node("current_level_template/wrap"), false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, gui.get_node("current_level_template/wrap"), duration, self.delay, function_end_animation)
	end)

	-- Анимация установки звёзд в уровне
	timer_linear.add(self, "result_single", 0.25, function (self)
	end)
	local stars = data.current_level.stars or 0
	local duration_star = 0.15
	local level = game_content_levels.get(data.current_level.id, data.current_level.category_id, user_lang)
	for i = 1, 3 do
		if i <= stars then
			timer_linear.add(self, "result_single", 0.35, function (self)
				msg.post("main:/sound", "play", {sound_id = "not_enouth_beep"})
				self.animate_star = gui_animate.set_star(self, gui.get_node("current_level_template/star_"..i), duration_star, 0)

				-- Награда за звёздочки
				-- Выпадение кучи монеток и опыта
				local stars_score, stars_coins = game_content_stars.get_prize(self, i, level.complexity)

				local end_position = gui.get_screen_position(gui.get_node("gift_star_prize"))
				local gift_random_size =  gui.get_size(gui.get_node("gift_star_prize"))
				msg.post("main:/loader_gui", "set_status", {
					id = "add_balance",
					type = "stack", -- Обычный перелёт или куча
					setting_stack ={
						score = stars_score,
						coins = stars_coins,
						end_position = end_position,
						height_flight = 100,
						random_height = gift_random_size.y,
						random_width = gift_random_size.x,
					}, -- Настройки для кучи
					start_position = gui.get_screen_position(gui.get_node("current_level_template/star_"..i)),
					value = 0
				})
			end)
		else
			break
		end
	end

	-- Анимируем появление галочки пройденного уровня
	gui_loyouts.set_enabled(self, self.nodes.success_icon, false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, self.nodes.success_icon, duration, self.delay, function_end_animation)
	end)

	if data.next_level then
		-- Если есть следующий уровень, анимируем продолжение
		-- Анимация появления стрелки
		gui_loyouts.set_enabled(self, self.nodes.arrow_wrap, false)
		timer_linear.add(self, "result_single", 0.5, function (self)
			msg.post("main:/sound", "play", {sound_id = "game_result_leaderboard"})
			gui_animate.show_elem_popping(self, self.nodes.arrow_wrap, 0.15, self.delay)
		end)

		-- Анимация появления плашки следующего уровня
		gui_loyouts.set_enabled(self, self.nodes.next_level_card_wrap, false)
		timer_linear.add(self, "result_single", 0.5, function (self)
			msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
			gui_animate.show_elem_popping(self, self.nodes.next_level_card_wrap, duration, self.delay, function_end_animation)
		end)

		if not data.next_level.unlock then
			-- Анимация замка
			timer_linear.add(self, "result_single", 0.5, function (self)
				self.delay = self.delay + gui_animate.unlock(self, 'next_level_template/lock_wrap_template', nil, function (self)
					gui_loyouts.set_enabled(self, gui.get_node("next_level_template/lock_wrap_template/lock_wrap"), false)
				end)
			end)
		end

	else
		-- Если нет следующего уровня, сообщаем о завершении игры
		-- Анимация появления плашки компании
		local template_name_company = 'company_success_template'
		local template_name_aureol = 'areol_company_template'
		-- Анимация появления плашки следующего уровня
		modal_result_single_animations.animate_company_success(self, template_name_company, template_name_aureol, duration)

		-- Анимация появления стрелки
		gui_loyouts.set_enabled(self, self.nodes.arrow_wrap, false)
		timer_linear.add(self, "result_single", 0.5, function (self)
			msg.post("main:/sound", "play", {sound_id = "game_result_leaderboard"})
			gui_animate.show_elem_popping(self, self.nodes.arrow_wrap, 0.15, self.delay)
		end)
		
	end

	-- Показываем кнопки
	gui_loyouts.set_enabled(self, self.nodes.btns_win, false)
	timer_linear.add(self, "result_single", 1, function (self)
		gui_animate.show_elem_popping(self, self.nodes.btns_win, 0.15, self.delay, function (self)
			msg.post("main:/sound", "play", {sound_id = "game_result_leaderboard"})
			-- ОКОНЧАНИЕ АНИМАЦИИ
			self.animate = nil
			-- Заупскаем функцию перед началом анимации, если есть
			if function_end then
				function_end(self)
			end
		end)
	end)

	-- Пульсация кнопки
	gui_loyouts.set_enabled(self, self.nodes.btns_win, false)
	timer_linear.add(self, "result_single", 1.5, function (self)
		gui_animate.pulse_loop(self, self.nodes.btn_win_continue, 1.5)
	end)
end

-- Пролистнуть к концу анимации
function M.to_end(self)
	self.to_end_animate_win = 0.1
end

return M