-- Функции для выбора цвета игрока
local M = {}

local color = require("color-lib.color")

local gui_loyouts = require "main.gui.modules.gui_loyouts"

-- Цвета для выбора цвета
M.colors = {
	"aqua", 
	"aquamarine", 
	"chartreuse", 
	"coral", 
	"deeppink", 
	"deepskyblue", 
	"fuchsia", 
	"gold", 
	"greenyellow", 
	"orangered"
}

-- Пролистываем цвета
function M.listen(self, id)
	local add_index = 1
	local current_color_name =  self.current_color_name or "deepskyblue"

	-- Смотрим в какую сторону листать массив
	if id == "left" then
		add_index = -1
	elseif id == "right" then
		add_index = 1
	else
		add_index = 0
	end

	-- ищем текущую позицию цвета
	local current_index = 0
	for i = 1, #M.colors do
		local item = M.colors[i]

		if item == current_color_name then
			current_index = i
			break
		end
	end

	-- ищем следующую позицию
	local next_index = current_index + add_index

	-- смотрим есть ли она
	if next_index > #M.colors then
		next_index = 1
	elseif next_index < 1 then
		next_index = #M.colors
	end

	self.current_color_name = M.colors[next_index]

	gui_loyouts.set_color(self, self.nodes.color_box, color[self.current_color_name])

	return true
end

return M