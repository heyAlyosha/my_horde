-- Храним кнопки для окна настроек
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local color = require("color-lib.color")
local storage_game = require "main.game.storage.storage_game"
local gui_input = require "main.gui.modules.gui_input"

function M.add_btn_close(self)
	-- Кнопка закрытия
	return {
		id = "close", 
		type = "btn", 
		section = "close", 
		node = self.nodes.btn_close, 
		wrap_node = self.nodes.btn_close_icon, 
		node_title = false, 
		icon = "btn_circle_bg_red_", 
		wrap_icon = "btn_icon_close_"
	}
end

-- Кнопка СОхранения
function M.add_btn_save(self)
	return {
		id = "save", 
		type = "btn", 
		section = "play", 
		node = self.nodes.btn_save, 
		node_title = self.nodes.btn_save_title,
		icon = "button_default_green_",
	}
end

-- Изменение типа
function M.add_btns_type(self)
	return {
		{
			id = "prev_type", 
			type = "btn", 
			section = "type", 
			node = gui.get_node('type_template/select_template/left_arrow'),
			node_title = gui.get_node("type_template/select_template/left_arrow"),
			node_wrap_title = gui.get_node("type_template/title"),
			
		},
		{
			id = "next_type", 
			type = "btn", 
			section = "type", 
			node = gui.get_node('type_template/select_template/right_arrow'),
			node_title = gui.get_node("type_template/select_template/right_arrow"),
			node_wrap_title = gui.get_node("type_template/title"),
		},
	}
end

function M.add_btns_player(self)
	self.btns = {
		M.add_btn_close(self),
		-- ТИП ИГРОКА
		M.add_btns_type(self)[1], M.add_btns_type(self)[2],
		-- ИЗМЕНЕНИЕ ИМЯ ИГРОКА
		{
			id = "prev_avatar", 
			type = "btn", 
			section = "color", 
			node = gui.get_node('avatar_template/color_template/left_arrow'),
			node_title = gui.get_node("avatar_template/color_template/left_arrow"),
			node_wrap_title = gui.get_node("avatar_template/title"),
		},
		{
			id = "next_avatar", 
			type = "btn", 
			section = "color", 
			node = gui.get_node('avatar_template/color_template/right_arrow'),
			node_title = gui.get_node("avatar_template/color_template/right_arrow"),
			node_wrap_title = gui.get_node("avatar_template/title"),
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
			on_input_text = function (self, btn, text) 
				self.player.name = text
			end,
			on_input_select = function (self, btn, node)
				--По слову
				msg.post("/loader_gui", "visible", {
					id = "keyboard_ru",
					visible = true,
					value = {
						type = "input", -- Для игры или для ввода текста
						is_player = true,
						keys_disabled = {}
					}
				})
			end,
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
			node_title = gui.get_node("color_template/color_template/right_arrow"),
			node_wrap_title = gui.get_node("color_template/title"),
		},
		M.add_btn_save(self)
	}

	gui_input.init(self)
	self.btns_id.edit_name.input:set_text(self.player.name)
	self.btns_id.edit_name.input:set_max_length(30)

	return self.btns
end

function M.add_btns_bot(self)
	self.btns = {
		M.add_btn_close(self),
		-- ТИП ИГРОКА
		M.add_btns_type(self)[1], M.add_btns_type(self)[2],
		-- ИЗМЕНЕНИЕ ИМЯ ИГРОКА
		{
			id = "prev_bot", 
			type = "btn", 
			section = "color", 
			node = gui.get_node('bot_template/color_template/left_arrow'),
			node_title = gui.get_node("bot_template/color_template/left_arrow"),
			node_wrap_title = gui.get_node("bot_template/title"),
		},
		{
			id = "next_bot", 
			type = "btn", 
			section = "color", 
			node = gui.get_node('bot_template/color_template/right_arrow'),
			node_title = gui.get_node("bot_template/color_template/right_arrow"),
			node_wrap_title = gui.get_node("bot_template/title"),
		},
		M.add_btn_save(self)
	}

	gui_input.init(self)

	return self.btns
end

return M