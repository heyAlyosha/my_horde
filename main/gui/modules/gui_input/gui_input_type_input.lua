-- Функции для поля ввода
local M = {}

local color = require("color-lib.color")
local gui_size = require "main.gui.modules.gui_size"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"

-- Инициализация
function M.init(self, btn)
	btn.input = self.druid:new_input(btn.nodes.input_wrap, btn.nodes.input_text)

	-- Подписываемся на события ввода текста
	btn.on_input_text = btn.on_input_text or function (self, btn, text) pprint("on_input_text", text) end
	btn.input.on_input_text:subscribe(function (self, text)
		M.update_caret(self, btn)
		btn.on_input_text(self, btn, text)
	end)

	-- Подписываемся на события фокуса на поле ввода
	btn.on_input_select = btn.on_input_select or function (self, btn, node) end
	btn.input.on_input_select:subscribe(function (self, node)
		M.animate_caret(self, btn, true)
		btn.on_input_select(self, btn, node)
	end)

	-- Снятие фокуса на поле ввода
	btn.on_input_unselect = function (self, btn, node) end
	btn.input.on_input_unselect:subscribe(function (self, node)
		M.animate_caret(self, btn, false)
		btn.on_input_unselect(self, btn, node)
	end)

	-- Скрываем статус
	gui_loyouts.set_enabled(self, btn.nodes.status, false)

	-- Функция записи статуса
	btn.set_status = function (self, _id_text_lang, color_name)
		local node_status = btn.nodes.status
		local color_name = color_name or "white"
		local color = color[color_name]
		local delay = 3

		gui_lang.set_text_upper(self, node_status, _id_text_lang)
		gui_loyouts.set_color(self, node_status, color)
		gui_loyouts.set_enabled(self, node_status, true)

		if btn._timer_set_status then
			timer.cancel(btn._timer_set_status)
		end

		btn._timer_set_status = timer.delay(delay, false, function (self)
			gui_loyouts.set_enabled(self, node_status, false)
			btn._timer_set_status = nil
		end)
	end 
end

-- Запуск/остановка анимации каретки
function M.animate_caret(self, btn, animation)
	local node_caret = btn.nodes.caret
	local node_wrap = btn.nodes.input_wrap

	-- Если нет ноды каретки или анимация каретки уже запущена, то 
	if not node_caret or (animation and btn._animate_caret) then
		return false
	end

	-- запускаем анимацию картеки
	if animation then
		gui_loyouts.set_enabled(self, node_caret, true)

		btn._animate_caret = timer.delay(0.5, true, function (self)
			gui_loyouts.set_enabled(self, node_caret, not gui.is_enabled(node_caret))
		end)

		return true
	else
		gui_loyouts.set_enabled(self, node_caret, false)
		if btn._animate_caret then
			timer.cancel(btn._animate_caret)
		end
		btn._animate_caret = nil

		return true
	end
end

-- Обновление каретки под текст
function M.update_caret(self, btn)
	local node_caret = btn.nodes.caret
	
	local node_text = btn.nodes.input_text

	if not node_caret then
		return false
	end

	local position_caret = gui.get_position(node_caret)
	local size_text = gui_size.get_size_gui_text(node_text)
	position_caret.x = size_text.width + 0

	gui_loyouts.set_position(self, node_caret, position_caret)

	return true
end

return M