-- Функции для ползунка
local M = {}

local color = require("color-lib.color")
local gui_size = require "main.gui.modules.gui_size"

-- Инициализация
function M.init(self, btn)
	-- находим  максимальную позицию ползунка
	local end_position = gui.get_size(btn.nodes.line)
	end_position.x = end_position.x * gui.get_scale(btn.nodes.line).x
	end_position.y = gui.get_position(btn.nodes.circle).y

	--Ставим ползунок на старт
	gui.set_position(btn.nodes.circle, vmath.vector3(0, end_position.y, 1))

	btn.on = btn.on or function (self, procent) print("Slider", procent) end
	btn.slider = self.druid:new_slider(btn.nodes.circle, end_position, function (self, procent)
		btn.on(self, procent)
	end)

	btn.slider:set_input_node(btn.nodes.line)
	btn.slider:set_steps({0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1})
end

-- Управление влево/вправо
function M.left_or_right(self, btn, action_id)
	local step = 0.1

	--Определяем в какую сторону двигать
	if action_id == hash("left") then
		step = -0.1
	else
		step = 0.1
	end

	btn.slider:set(btn.slider.value + step)
end

return M