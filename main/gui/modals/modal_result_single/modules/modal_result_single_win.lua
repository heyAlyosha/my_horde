-- Отрисовка победы в окне результатов игры
local M = {}

local druid = require("druid.druid")
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local gui_animate = require "main.gui.modules.gui_animate"
local modal_result_single_animations = require "main.gui.modals.modal_result_single.animations.modal_result_single_animations"
local modal_result_single_animate_win = require "main.gui.modals.modal_result_single.animations.modal_result_single_animate_win"
local gui_manager = require "main.gui.modules.gui_manager"
local game_content_levels = require "main.game.content.game_content_levels"
local game_content_company = require "main.game.content.game_content_company"
local game_content_text = require "main.game.content.game_content_text"
local gui_render = require "main.gui.modules.gui_render"
local gui_size = require 'main.gui.modules.gui_size'
local color = require("color-lib.color")
local modal_result_single_btns = require "main.gui.modals.modal_result_single.modules.modal_result_single_btns"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"

function M.start(self, data)
	-- Скрываем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes.wrap_fail, false)
	gui_loyouts.set_enabled(self, self.nodes.wrap_win, true)
	gui_loyouts.set_enabled(self, self.nodes.wrap_tournir, false)

	-- Отрисовываем текст
	gui_lang.set_text_upper(self, self.nodes.title, "_victory")
	gui_lang.set_text_upper(self, self.nodes.prize_title, "_prizes", before_str, ":")
	gui_loyouts.play_flipbook(self, self.nodes.title_wrap, "title_bg_green")

	-- Отрисовка текущего уровня
	local current_level = data.current_level
	local content_current_level_card = game_content_levels.get(current_level.id, current_level.category_id, user_lang)
	gui_render.render_card_level(self, "current_level_template", content_current_level_card, 0)

	-- Отрисовка следующего уровня уровня
	local next_level = data.next_level
	if next_level then
		-- Если следующий уровень есть  - отрисовываем его
		local content_next_level_card = game_content_levels.get(next_level.id, next_level.category_id, user_lang)
		gui_render.render_card_level(self, "next_level_template", content_next_level_card, next_level.stars)
		gui_lang.set_text_upper(self, self.nodes.arrow_title, "_next_level", nil, "!")
		gui_loyouts.set_enabled(self, self.nodes.company_card_wrap, false)
		gui_loyouts.set_enabled(self, self.nodes.next_level_card_wrap, true)

		-- Если уровень уже разблокирован, отключаем замок
		if data.next_level.unlock then
			gui_loyouts.set_enabled(self, self.nodes.lock_wrap, false)
		end

		-- Добавляем кнопки
		self.btns[2] = {id = "back", type = "btn", section = "body", node = self.nodes.btn_win_back, wrap_node = self.nodes.btn_win_back_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_back_"}
		self.btns[3] = {id = "continue_level", level_id = next_level.id, category_id = next_level.category_id, type = "btn", section = "body", node = self.nodes.btn_win_continue, wrap_node = self.nodes.btn_win_continue_icon, node_title = false, icon = "btn_circle_bg_green_", wrap_icon = "btn_icon_play_"}
		self.btns[4] = {id = "refresh", type = "btn", section = "body", node = self.nodes.btn_win_refresh, wrap_node = self.nodes.btn_win_refresh_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_refresh_"}
		self.btns[5] = {id = "login", type = "btn", section = "login", node = self.nodes.btn_login_wrap,  node_title = self.nodes.btn_login_title, icon = "button_default_blue_"}
	else
		-- Если уровня нет, значит игрок прошёл категорию
		-- Отрисовываем прошедшую компанию
		local content_company = game_content_company.get_id(current_level.category_id, user_lang)
		gui_render.render_card_company(self, 'company_success_template', content_company)
		-- Скрываем карточку следующего уровня
		gui_loyouts.set_enabled(self, self.nodes.company_card_wrap, true)
		gui_loyouts.set_enabled(self, self.nodes.next_level_card_wrap, false)

		--Изменяем стрелку следующего уровня на звершение компании
		gui_lang.set_text_upper(self, self.nodes.arrow_title, "_company_passed", nil, "!")
		gui_loyouts.set_color(self, self.nodes.arrow_title, color.lime)
		gui_loyouts.set_enabled(self, self.nodes.arrow, false)

		-- Добавляем кнопки
		self.btns[2] = {id = "home", type = "btn", section = "body", node = self.nodes.btn_win_back, wrap_node = self.nodes.btn_win_back_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_home_"}
		self.btns[3] = {id = "back", type = "btn", section = "body", node = self.nodes.btn_win_continue, wrap_node = self.nodes.btn_win_continue_icon, node_title = false, icon = "btn_circle_bg_green_", wrap_icon = "btn_icon_back_"}
		self.btns[4] = {id = "refresh", type = "btn", section = "body", node = self.nodes.btn_win_refresh, wrap_node = self.nodes.btn_win_refresh_icon, node_title = false, icon = "btn_circle_bg_orange_", wrap_icon = "btn_icon_refresh_"}
		self.btns[5] = {id = "login", type = "btn", section = "login", node = self.nodes.btn_login_wrap,  node_title = self.nodes.btn_login_title, icon = "button_default_blue_"}
	end

	-- Скрываем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes.wrap_fail, false)
	gui_loyouts.set_enabled(self, self.nodes.wrap_win, true)

	-- АНИМАЦИЯ ПОЯВЛЕНИЯ ЭЛЕМЕНТОВ ПОБЕДЫ
	modal_result_single_animate_win.start(self, data, nil, function (self)
		modal_result_single_btns.render_login_btn(self)
		self.druid = druid.new(self)
		gui_input.set_focus(self, 3)
		msg.post("game-room:/core_game", "event", {id = "visible_game_result"})
	end)

	-- Отрисовываем кнопки
	gui_input.render_btns(self)

	return true
end

return M