-- Отрисовка победы в окне результатов игры
local M = {}

local modal_result_single_btns = require "main.gui.modals.modal_result.modules.modal_result_single_btns"
local druid = require("druid.druid")
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local gui_animate = require "main.gui.modules.gui_animate"
local modal_result_single_animations = require "main.gui.modals.modal_result.animations.modal_result_single_animations"
local modal_result_single_animate_win = require "main.gui.modals.modal_result.animations.modal_result_single_animate_win"
local gui_manager = require "main.gui.modules.gui_manager"
local game_content_levels = require "main.game.content.game_content_levels"
local game_content_company = require "main.game.content.game_content_company"

local gui_render = require "main.gui.modules.gui_render"
local gui_size = require 'main.gui.modules.gui_size'
local gui_text = require "main.gui.modules.gui_text"
local color = require("color-lib.color")
local timer_linear = require "main.modules.timer_linear"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

function M.start(self, data)
	local delay = 0
	-- Скрываем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes.wrap_fail, true)
	gui_loyouts.set_enabled(self, self.nodes.wrap_win, false)
	gui_loyouts.set_enabled(self, self.nodes.wrap_tournir, false)

	-- ставим заголовок поражения
	gui_lang.set_text(self, gui.get_node("title"), "_you_fail")
	gui_loyouts.play_flipbook(self, gui.get_node("title_wrap"), "title_bg_red")

	gui_loyouts.set_enabled(self, gui.get_node("title_wrap"), false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, gui.get_node("title_wrap"), duration, delay, function_end_animation)
	end)

	-- Ставим описание
	local fail_description = utf8.upper(lang_core.get_text(self, "_you_game_refresh", before_str, after_str, values))
	local type_fail_text = utf8.upper(lang_core.get_text(self, "_type_fail_"..data.type_fail, before_str, after_str, values))
	gui_loyouts.set_text(self, self.nodes.fail_description, "")
	if type_fail_text ~= '-' then
		gui_text.set_text_formatted(self, self.nodes.fail_description, type_fail_text.." <br/>"..fail_description)
	else
		gui_text.set_text_formatted(self, self.nodes.fail_description, fail_description)
	end

	gui_loyouts.set_enabled(self, self.nodes.fail_description_wrap, false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, self.nodes.fail_description_wrap, duration, delay, function_end_animation)
	end)

	-- Отрисовываем карточку текущего уровня
	local content_level_card = game_content_levels.get(data.current_level.id, data.current_level.category_id, user_lang)
	gui_render.render_card_level(self, "fail_level_template", content_level_card, data.current_level.stars)

	gui_loyouts.set_enabled(self, self.nodes.fail_level_card_wrap, false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, self.nodes.fail_level_card_wrap, duration, delay, function_end_animation)
	end)

	if data.next_level then
		-- Если есть следующий уровень, отрисовываем его
		local content_next_level_card = game_content_levels.get(data.next_level.id, data.next_level.category_id, user_lang)
		gui_render.render_card_level(self, "fail_next_level_template", content_next_level_card, data.next_level.stars)

		gui_loyouts.set_enabled(self, self.nodes.arrow_wrap_fail, false)
		gui_loyouts.set_enabled(self, self.nodes.fail_next_level_card_wrap, false)
		timer_linear.add(self, "result_single", 0.25, function (self)
			msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
			gui_animate.show_elem_popping(self, self.nodes.arrow_wrap_fail, duration, delay, function_end_animation)
			gui_animate.show_elem_popping(self, self.nodes.fail_next_level_card_wrap, duration, delay, function_end_animation)
		end)
		
	else
		-- если нет следующего уровня
		-- выключаем стрелочку и плашку
		gui_loyouts.set_enabled(self, self.nodes.arrow_wrap_fail, false)
		gui_loyouts.set_enabled(self, self.nodes.fail_next_level_card_wrap, false)
	end

	-- Добавляем кнопки
	self.btns[2] = {id = "back", type = "btn", section = "body", node = self.nodes.btn_fail_back, wrap_node = self.nodes.btn_fail_back_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_back_"}
	self.btns[3] = {id = "refresh", type = "btn", section = "body", node = self.nodes.btn_fail_refresh, wrap_node = self.nodes.btn_fail_refresh_icon, node_title = false, icon = "btn_circle_bg_green_", wrap_icon = "btn_icon_refresh_"}
	self.btns[4] = {id = "home", type = "btn", section = "body", node = self.nodes.btn_fail_home, wrap_node = self.nodes.btn_fail_home_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_home_"}
	self.btns[5] = {id = "login", type = "btn", section = "login", node = self.nodes.btn_login_wrap,  node_title = self.nodes.btn_login_title, icon = "button_default_blue_"}

	timer_linear.add(self, "result_single", 0.5, function (self)
		modal_result_single_btns.render_login_btn(self)
		gui_input.set_focus(self, 3)
		msg.post("game-room:/core_game", "event", {id = "visible_game_result"})
	end)

	gui_animate.pulse_loop(self, self.btns[3].node)
	gui_input.render_btns(self)

	return true
end

return M