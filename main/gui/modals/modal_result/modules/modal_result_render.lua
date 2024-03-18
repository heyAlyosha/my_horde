-- Отрисовка победы в окне результатов игры
local M = {}

local druid = require("druid.druid")
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local gui_animate = require "main.gui.modules.gui_animate"
local modal_result_single_animations = require "main.gui.modals.modal_result.animations.modal_result_single_animations"
local modal_result_single_animate_win = require "main.gui.modals.modal_result.animations.modal_result_single_animate_win"
local gui_manager = require "main.gui.modules.gui_manager"
local game_content_levels = require "main.game.content.game_content_levels"
local game_content_company = require "main.game.content.game_content_company"
local game_content_text = require "main.game.content.game_content_text"
local gui_render = require "main.gui.modules.gui_render"
local gui_size = require 'main.gui.modules.gui_size'
local modal_result_single_btns = require "main.gui.modals.modal_result.modules.modal_result_single_btns"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"

function M.visible(self, data)
	-- Показываем или скрываем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes.wrap_btns_win, self.data.type_result == "win")
	gui_loyouts.set_enabled(self, self.nodes.wrap_btns_fail, self.data.type_result == "fail")
	gui_loyouts.set_enabled(self, self.nodes.wrap_trophy, self.data.type_result == "win")

	-- Отрисовываем Поражение или победу
	if self.data.type_result == "win" then
		-- 
		gui_loyouts.set_color(self, self.nodes.title, color.lime)
		gui_lang.set_text_upper(self, self.nodes.title, "_victory")
		gui_lang.set_text_upper(self, self.nodes.prize_title, "_prizes", before_str, ":")

		-- Добавляем кнопки
		self.btns = {
			{id = "back", type = "btn", section = "body",  icon = "btn_interface_"},
			{id = "continue", type = "btn", section = "body",  icon = "btn_interface_"},
			{id = "shop", type = "btn", section = "body", icon = "btn_interface_"},
		}
	else
		-- 
		gui_loyouts.set_color(self, self.nodes.title, color.red)
		gui_lang.set_text_upper(self, self.nodes.title, "_fail")

		--
		self.btns = {
			{id = "back", type = "btn", section = "body", icon = "btn_interface_"},
			{id = "refresh", type = "btn", section = "body", icon = "btn_interface_"},
			{id = "shop", type = "btn", section = "body", icon = "btn_interface_"},
		}
	end

	--подставляем ноды в кнопки
	for i, btn in ipairs(self.btns) do
		self.btns[i].node = gui.get_node("btn_"..self.data.type_result.."_"..i.."_template/btn")
		if btn.id ~= "shop" then
			self.btns[i].node_title = gui.get_node("btn_"..self.data.type_result.."_"..i.."_template/btn_icon")
		end
	end

	-- АНИМАЦИЯ ПОЯВЛЕНИЯ ЭЛЕМЕНТОВ ПОБЕДЫ
	--[[
	modal_result_single_animate_win.start(self, data, nil, function (self)
		--modal_result_single_btns.render_login_btn(self)
		self.druid = druid.new(self)
		--gui_input.set_focus(self, 2)
		--msg.post("game-room:/core_game", "event", {id = "visible_game_result"})
	end)
	--]]

	-- Отрисовываем кнопки
	gui_input.render_btns(self)

	return true
end

return M