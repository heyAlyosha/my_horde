-- Функции
local M = {}

local gui_catalog = require "main.gui.modules.gui_catalog"
local gui_input = require "main.gui.modules.gui_input"
local gui_loader = require "main.gui.modules.gui_loader"
local game_content_artifact = require "main.game.content.game_content_artifact"
local gui_animate = require "main.gui.modules.gui_animate"

function M.visible(self, player_id)
	self.player_id = player_id
	gui_animate.show_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = "keyboard_ru",
			visible = true,
			value = {
				type = "input", -- Для игры или для ввода текста
				is_player = true,
				keys_disabled = {}
			}
		})
	end)

	self.focus_btn_id = nil
	self.btns = {}

	-- Добавляем кнопки внизу
	self.btns[#self.btns + 1] = {
		id = "word",
		type = "input",
		section = "body",  -- Секция, если одинаоквая, то можно переключаться вправо-влево
		nodes = {
			title = gui.get_node("name_template/title"), -- заголовок
			status = gui.get_node("name_template/status"), -- нода для сообщений со статусом
			input_wrap = gui.get_node("name_template/input_template/input_wrap"),
			input_text = gui.get_node("name_template/input_template/input_text"),
			caret = gui.get_node("name_template/input_template/caret"),
		},
		input_bg_image = "bg_modal_",
		on_input_text = function (self, btn, text)
			self.word = text

			gui_input.set_disabled(self, self.btns[2], text == "")
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
	}
	
	self.btns[#self.btns + 1] = {
		id = "confirm", 
		type = "btn", 
		section = "footer", 
		node = self.nodes.btn_confirm,
		node_title = self.nodes.btn_confirm_title, 
		icon = "btn_ellipse_green_"
	}
	self.btns[#self.btns + 1] = {
		id = "close", 
		type = "btn", 
		section = "footer", 
		node = self.nodes.btn_close,
		node_title = self.nodes.btn_close_title, 
		icon = "btn_ellipse_red_"
	}

	self.btns_id = {}

	for i, btn in ipairs(self.btns) do
		self.btns_id[btn.id] = btn
	end

	gui_input.init(self)

	timer.delay(0.8, false, function(self)
		if #self.btns > 0 then
			gui_input.set_focus(self, 1)
		end
	end)

	gui_input.set_disabled(self, self.btns[2], true)
end

-- Закрытие формы
function M.hidden(self, callback)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		if callback then
			callback(self)
		end
		msg.post("/loader_gui", "visible", {
			id = "game_word",
			visible = false,
		})

		
	end)
end

-- Закрывают форму
function M.close(self)
	msg.post("/loader_gui", "visible", {
		id = "keyboard_ru",
		visible = false,
	})

	M.hidden(self, function (self)
		msg.post("game-room:/core_game", "event", {id = "close_game_word"})
	end)
	
end


-- Нажатие на кнопку
function M.activate_btn(self, focus_btn_id)
	local btn = self.btns[focus_btn_id]

	if btn.disabled then
		return false
	end

	gui_animate.activate(self, btn.node, function_after)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	if btn.id == "confirm" then
		-- Слово целиком
		self.word = utf8.lower(self.word)
		msg.post("game-room:/core_game", "full_word", {word = self.word})
		msg.post("/loader_gui", "visible", {
			id = "keyboard_ru",
			visible = false,
		})
		M.hidden(self)

	elseif btn.id == "close" then
		-- Закрытие
		M.close(self)

	end
end



return M