-- Храним кнопки для окна настроек
local M = {}

local color = require("color-lib.color")
local storage_sdk = require "main.storage.storage_sdk"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local storage_game = require "main.game.storage.storage_game"
local gui_input = require "main.gui.modules.gui_input"

function M.add_btns(self)
	self.btns = {
		-- Кнопка закрытия
		{
			id = "close", 
			type = "btn", 
			section = "close", 
			node = self.nodes.btn_close, 
			wrap_node = self.nodes.btn_close_icon, 
			node_title = false, 
			icon = "btn_circle_bg_red_", 
			wrap_icon = "btn_icon_close_"
		},
		-- Блок с id
		{
			id = "id",
			type = "text", 
			section = "id",  -- Секция, если одинаоквая, то можно переключаться вправо-влево
			nodes = {
				gui.get_node("id_template/title"), gui.get_node("id_template/value"),
			} --массив нод с текстом
		},
		-- СЕКЦИЯ ИЗМЕНЕНИЯ ИМЕНИ
		-- Блок с вводом текста
		{
			id = "edit_name",
			type = "input",
			section = "edit_name",  -- Секция, если одинаоквая, то можно переключаться вправо-влево
			nodes = {
				title = gui.get_node("name_template/title"), -- заголовок
				status = gui.get_node("name_template/status"), -- нода для сообщений со статусом
				input_wrap = gui.get_node("name_template/input_template/input_wrap"),
				input_text = gui.get_node("name_template/input_template/input_text"),
				caret = gui.get_node("name_template/input_template/caret"),
			},
			input_bg_image = "bg_modal_",
		},
		-- Кнопка сохранения имени
		{
			id = "save_name", 
			type = "btn", 
			section = "edit_name", 
			node_bg = self.nodes.btn_save_name,  
			node_title = self.nodes.btn_save_name_title, 
			node_wrap_title = gui.get_node("name_template/title"),
			icon = "btn_ellipse_green_", 
		},

		-- ИЗМЕНЕНИЕ ЦВЕТА ИГРОКА
		-- Кнопка предыдущего цвета
		{
			id = "prev_color", 
			type = "btn", 
			section = "color", 
			node = gui.get_node('color_template/color_template/left_arrow'),
			node_title = gui.get_node("color_template/color_template/left_arrow"),
			node_wrap_title = gui.get_node("color_template/title"),
		},
		-- Кнопка предыдущего цвета
		{
			id = "next_color", 
			type = "btn", 
			section = "color", 
			node = gui.get_node('color_template/color_template/right_arrow'),
			node_wrap_title = gui.get_node("color_template/title"),
			node_title = gui.get_node("color_template/color_template/right_arrow"),
		},
		-- Громкость музыки
		{
			id = "music",
			type = "slider", 
			section = "music",  -- Секция, если одинаоквая, то можно переключаться вправо-влево
			nodes = {
				title = gui.get_node("volume_music_template/title"), -- заголовок
				line = gui.get_node("volume_music_template/slider_template/bg_line"), -- 
				circle = gui.get_node("volume_music_template/slider_template/circle"), -- качелька
			},
			bg_image = "btn_circle_bg_green_",

		},
		-- Громкость эффектов
		{
			id = "effects",
			type = "slider", 
			section = "effects",  -- Секция, если одинаоквая, то можно переключаться вправо-влево
			nodes = {
				title = gui.get_node("volume_effects_template/title"), -- заголовок
				line = gui.get_node("volume_effects_template/slider_template/bg_line"), -- 
				circle = gui.get_node("volume_effects_template/slider_template/circle"), -- качелька
			},
			bg_image = "btn_circle_bg_green_"
		},
		-- переключатель
		{
			id = "study",
			type = "switch", 
			section = "study",  
			nodes = {
				title = gui.get_node("study_template/title"), -- заголовок
				line = gui.get_node("study_template/switch_template/bg_line"), -- 
				circle = gui.get_node("study_template/switch_template/circle"), -- качелька
			},
		},
		-- переключатель
		{
			id = "help_shop",
			type = "switch", 
			section = "help_shop",  
			nodes = {
				title = gui.get_node("shop_template/title"), -- заголовок
				line = gui.get_node("shop_template/switch_template/bg_line"), -- 
				circle = gui.get_node("shop_template/switch_template/circle"), -- качелька
			},
			on = function (self, value)
				-- do things
			end
		},
		-- СБрос прогресса
		{
			id = "reset",
			type = "btn", 
			node = self.nodes.btn_reset,
			node_title = self.nodes.btn_reset_title,
			disabled = storage_game.is_game,
			icon = "button_default_red_"
		}
	}

	-- Блокируем кнопку сброса прогресса во время игры
	gui_input.set_disabled(self, self.btns[#self.btns], storage_game.is_game)

	if not storage_sdk.edit_name then
		for i, btn in ipairs(self.btns) do
			if btn.id == "save_name" then
				gui_loyouts.set_enabled(self, btn.node_bg, false)
				table.remove(self.btns, i)
			end
			
		end
	end

	return self.btns
end

return M