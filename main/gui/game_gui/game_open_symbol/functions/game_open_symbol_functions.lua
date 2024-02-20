-- Функции
local M = {}

local gui_scale = require "main.gui.modules.gui_scale"
local color = require("color-lib.color")
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local game_core_gamers = require "main.game.core.game_core_gamers" 
local game_content_wheel = require "main.game.content.game_content_wheel"
local gui_size = require "main.gui.modules.gui_size"

-- Показываем
function M.visible(self, data)
	local data = data or {}
	local word = data.word or "для тестирования"
	local open_symbols = data.open_symbols or {"а","б","в","д"}

	gui_animate.show_bottom(self, self.nodes.wrap, function_after)

	word = utf8.lower(word)

	-- Удаляем старые данные, если есть
	self.get_center_horisontal_list = self.get_center_horisontal_list or {}
	self.get_center_horisontal_list[gui.get_id(self.nodes.wrap_btns)] = nil

	for i = #self.btns, 1, -1 do
		-- Удаляем старые ноды, если есть
		if self.btns[i] then
			if self.btns[i].node then
				gui.delete_node(self.btns[i].node)
			end
			self.btns[i] = nil
		end
	end
	for i, btn in ipairs(self.btns) do
		
	end

	-- Перебираем все буквы в слове
	local index = 0
	local btn_nodes = {}
	local center_horisontal_list = {}
	for symbol in utf8.gmatch(word, ".") do
		index = index + 1

		local nodes = gui.clone_tree(self.nodes.btn)

		gui.set_enabled(nodes[hash("btn_template/btn_wrap")], true)
		local open = false

		for i = 1, #open_symbols do
			if utf8.lower(open_symbols[i]) == symbol then
				open = true
				break
			end
		end

		if symbol ~= " " then
			if open then
				gui.set_text(nodes[hash("btn_template/btn_title")], utf8.upper(symbol))
			else
				gui.set_text(nodes[hash("btn_template/btn_title")], "")
			end

		else
			gui.set_text(nodes[hash("btn_template/btn_title")], "_")

		end

		-- Формируем кнопки
		self.btns[#self.btns + 1] = {
			id = index, 
			symbol = symbol,
			index = index,
			type = "btn",
			section = "wheel",
			node = nodes[hash("btn_template/btn_wrap")],
			node_title = nodes[hash("btn_template/btn_title")],
			icon = "button_default_blue_"
		}
		if symbol == " " or symbol == "-" or open then
			gui_input.set_disabled(self, self.btns[#self.btns], true)
		end
		btn_nodes[#btn_nodes + 1] =  nodes[hash("btn_template/btn_wrap")]

		center_horisontal_list = gui_size.get_center_horisontal_list(self, self.nodes.wrap_btns, nodes[hash("btn_template/btn_wrap")], 5)
	end

	gui_size.set_btn_list_horisontal(self.nodes.wrap_btns, btn_nodes, 5, self)
	gui.set_position(self.nodes.wrap_btns, center_horisontal_list.position_wrap)

	-- Если размер больше блока - уменьшаем его
	if center_horisontal_list.size_wrap.x > gui.get_size(self.nodes.wrap_bg).x then
		center_horisontal_list.size_wrap.x = center_horisontal_list.size_wrap.x - 75
		local diferent = center_horisontal_list.size_wrap.x - gui.get_size(self.nodes.wrap_bg).x
		local scale = 1 - diferent / center_horisontal_list.size_wrap.x
		gui.set_scale(self.nodes.wrap_btns, vmath.vector3(scale))

		-- Ставим по центру
		center_horisontal_list.position_wrap.x = center_horisontal_list.position_wrap.x * scale - 10
		gui.set_position(self.nodes.wrap_btns, center_horisontal_list.position_wrap)
	end


	self.focus_btn_id = nil

	timer.delay(0.2, false, function(self)
		for i, btn in ipairs(self.btns) do
			if not btn.disabled then
				gui_input.set_focus(self, i)
				break
			end
		end
		
	end)
end

-- Функция закрытия
function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = self.id,
			visible = false,
		})
	end)
end

-- Функция активации
function M.activate(self, btn)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	msg.post("game-room:/core_game", "event", {
		id = "open_symbol",value = {symbol = btn.symbol, index = btn.index}
	})
	M.hidden(self)
end
	
return M