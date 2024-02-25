-- Храним кнопки для окна настроек
local M = {}

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
			node_bg = gui.get_node('color_template/color_template/left_arrow'),
			node_wrap_title = gui.get_node("color_template/title"),
			icon = "btn_icon_play_", 
		},
		-- Кнопка предыдущего цвета
		{
			id = "next_color", 
			type = "btn", 
			section = "color", 
			node_bg = gui.get_node('color_template/color_template/right_arrow'),
			node_wrap_title = gui.get_node("color_template/title"),
			icon = "btn_icon_play_", 
		},
		-- Кнопка
		{
			id = "next_color",
			type = "btn", 
			section = "color", 
			node_bg = gui.get_node('color_template/color_template/right_arrow'),
			node_wrap_title = gui.get_node("color_template/title"),
			icon = "btn_icon_play_", 
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
		}
	}

	return self.btns
end

return M