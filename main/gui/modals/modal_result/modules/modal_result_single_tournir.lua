-- Отрисовка победы в окне результатов игры
local M = {}

local druid = require("druid.druid")
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local storage_game = require "main.game.storage.storage_game"
local gui_animate = require "main.gui.modules.gui_animate"
local modal_result_single_animations = require "main.gui.modals.modal_result.animations.modal_result_single_animations"
local modal_result_single_animate_win = require "main.gui.modals.modal_result.animations.modal_result_single_animate_win"
local gui_manager = require "main.gui.modules.gui_manager"
local game_content_levels = require "main.game.content.game_content_levels"
local game_content_company = require "main.game.content.game_content_company"
local game_content_text = require "main.game.content.game_content_text"
local gui_render = require "main.gui.modules.gui_render"
local gui_text = require "main.gui.modules.gui_text"
local gui_size = require 'main.gui.modules.gui_size'
local color = require("color-lib.color")
local modal_result_single_animations = require "main.gui.modals.modal_result.animations.modal_result_single_animations"
local timer_linear = require "main.modules.timer_linear"
local modal_result_single_btns = require "main.gui.modals.modal_result.modules.modal_result_single_btns"
local storage_sdk = require "main.storage.storage_sdk"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

function M.start(self, data)
	self.type_result = data.type_result

	gui_lang.set_text_upper(self, gui.get_node("opponents_title"), "_opponents", before_str, after_str)

	-- Скрываем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes.wrap_fail, true)
	gui_loyouts.set_enabled(self, self.nodes.wrap_win, true)
	gui_loyouts.set_enabled(self, self.nodes.wrap_tournir, true)

	gui_loyouts.set_alpha(self, self.nodes.fail_bg, 0)
	gui_loyouts.set_alpha(self, self.nodes.win_bg, 0)

	gui_loyouts.set_enabled(self, self.nodes.company_card_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.current_level_card_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.next_level_card_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.arrow_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.btns_fail, false)
	gui_loyouts.set_enabled(self, self.nodes.fail_level_card_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.fail_next_level_card_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.arrow_wrap_fail, false)
	gui_loyouts.set_enabled(self, self.nodes.arrow_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.win_level_card_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.win_next_level_card_wrap, false)

	gui_loyouts.set_enabled(self, gui.get_node("title_wrap"), false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		gui_animate.show_elem_popping(self, gui.get_node("title_wrap"), duration, delay, function_end_animation)
	end)


	-- Если это проигрышь
	if self.type_result == "fail" then
		-- Отключаю ненужные элементы в блоке победды
		gui_loyouts.set_enabled(self, self.nodes.prize_wrap, false)

		-- Отключаю ненужные элементы в блоке поражения
		gui_loyouts.set_enabled(self, self.nodes.wrap_fail, true)
		gui_lang.set_text_upper(self, gui.get_node("title"), "_you_fail", before_str, after_str)
		gui_loyouts.play_flipbook(self, gui.get_node("title_wrap"), "title_bg_red")

		-- Ставим описание
		local fail_description = utf8.upper(lang_core.get_text(self, "_you_game_other_opponents", before_str, after_str, values))
		local type_fail_text = utf8.upper(lang_core.get_text(self, "_type_fail_"..data.type_fail, before_str, after_str, values))
		gui_loyouts.set_text(self, self.nodes.fail_description, "")
		if type_fail_text ~= '-' then
			gui_text.set_text_formatted(self, self.nodes.fail_description, type_fail_text.." <br/>"..fail_description)
		else
			gui_text.set_text_formatted(self, self.nodes.fail_description, fail_description)
		end


		gui_loyouts.set_enabled(self, self.nodes.fail_description_wrap, false)
		timer_linear.add(self, "result_single", 0.5, function (self)
			gui_animate.show_elem_popping(self, self.nodes.fail_description_wrap, duration, delay, function_end_animation)
		end)

	-- Если это проигрышь
	elseif self.type_result == "win" then
		-- Отключаю ненужные элементы в блоке победы
		gui_loyouts.set_enabled(self, self.nodes.wrap_win, true)
		gui_loyouts.set_enabled(self, self.nodes.fail_description_wrap, false)
		gui_loyouts.play_flipbook(self, gui.get_node("title_wrap"), "title_bg_green")

		-- Анимация появления списка призов
		local node_wrap = gui.get_node('prize_icons_wrap')
		local node_more = gui.get_node('prize_more')
		local max_prizes = 9

		modal_result_single_animations.animate_prizes(self, node_prize, node_wrap, node_more, max_prizes, delay, params, data)

	end

	-- Отрисовываем игроков
	local index_opponent = 0
	for i, player in ipairs(storage_game.game.players) do
		if player and player.player_id ~= "player" then
			index_opponent = index_opponent + 1

			if index_opponent <= 3 then
				gui_loyouts.set_text(self, self.nodes['opponent_tournir_'..index_opponent..'_name'], player.name)
				gui_loyouts.play_flipbook(self, self.nodes['opponent_tournir_'..index_opponent..'_avatar'], player.avatar)
			end
		end
	end

	-- Анимация появления противников
	gui_loyouts.set_enabled(self, self.nodes.wrap_opponents, false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, self.nodes.wrap_opponents, duration, delay, function_end_animation)
	end)
	

	if self.type_result == "win" then
		-- Аанимация зачёркивания
		timer_linear.add(self, "result_single", 0.5, function (self)
			gui_animate.strikethrough(self, "strike_1_template", duration)
		end)
		timer_linear.add(self, "result_single", 0.5, function (self)
			gui_animate.strikethrough(self, "strike_2_template", duration)
		end)

		timer_linear.add(self, "result_single", 0.25, function (self)
			msg.post("main:/sound", "play", {sound_id = "modal_top_3_2"})
		end)
	end

	-- Добавляем кнопки
	self.btns[2] = {id = "back", type = "btn", section = "body", node = self.nodes.btn_win_back, wrap_node = self.nodes.btn_win_back_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_back_"}
	self.btns[3] = {id = "refresh", type = "btn", section = "body", node = self.nodes.btn_win_continue, wrap_node = self.nodes.btn_win_continue_icon, node_title = false, icon = "btn_circle_bg_green_", wrap_icon = "btn_icon_play_"}
	self.btns[4] = {id = "home", type = "btn", section = "body", node = self.nodes.btn_win_refresh, wrap_node = self.nodes.btn_win_refresh_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_refresh_"}
	self.btns[5] = {id = "login", type = "btn", section = "logi", node = self.nodes.btn_login_wrap,  node_title = self.nodes.btn_login_title, icon = "button_default_blue_"}

	gui_loyouts.set_enabled(self, self.nodes.btns_win, false)
	timer_linear.add(self, "result_single", 0.5, function (self)
		modal_result_single_btns.render_login_btn(self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, self.nodes.btns_win, duration, delay, function_end_animation)
	end)

	-- Фокус на кнопке
	timer_linear.add(self, "result_single", 0.5, function (self)
		gui_input.set_focus(self, 3)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		msg.post("game-room:/core_game", "event", {id = "visible_game_result"})
	end)

	gui_animate.pulse_loop(self, self.btns[3].node)

	if storage_game.game.study_level and storage_game.game.study_level > 0 then
		for i, btn in ipairs(self.btns) do
			if btn.id == "home" then
				gui_input.set_disabled(self, self.btns[i], true)
			end
		end
	end
	
	gui_input.render_btns(self)

	return delay
end

return M