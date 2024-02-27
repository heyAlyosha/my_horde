-- Работа с размерами 
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"

-- Получение размеров текстового блока gui
function M.get_size_gui_text(node_text)
	return resource.get_text_metrics(
	gui.get_font_resource(gui.get_font(node_text)),
	gui.get_text(node_text),
	{
		width = gui.get_size(node_text).x,
		line_break = gui.get_line_break(node_text)
	}
)
end

-- Установка размера контейнеру по тектсу в нём
function M.set_gui_wrap_from_text(node_text, node_wrap, type, margin, self)
	local margin = margin or 0
	local type = type or 'height'
	local text_size = M.get_size_gui_text(node_text)
	local node_text_size = gui.get_size(node_text)
	local scale_text = gui.get_scale(node_text)
	local size_wrap = gui.get_size(node_wrap)

	if type == "height" then
		--находим разницу в высотах дефолтной строки в редакторе и прибавляем её к высоте обёртки
		--[[
		local add_height = text_size.height - node_text_size.y
		size_wrap.y = size_wrap.y + add_height
		--]]
		size_wrap.y = text_size.height * scale_text.x + margin * 2

	elseif type == "width" then
		--size_wrap.x = node_text_size.x + margin
		size_wrap.x = (text_size.width * scale_text.x)  + margin
	end

	gui_loyouts.set_size(self, node_wrap, size_wrap)
	return size_wrap
end

-- Установка кнопок в горизонтальный ряд
function M.set_btn_list_horisontal(node_wrap, btn_nodes, margin, self)
	local margin = margin or 0
	local start_x = 0
	for i, node in ipairs(btn_nodes) do
		
		local position = gui.get_position(node)
		local width = gui.get_size(node).x * gui.get_scale(node).x

		-- Ставим по центру
		position.x = start_x + width/2
		gui_loyouts.set_position(self, node, position.x, "x")

		start_x = start_x + width + margin
	end
end

-- Получение центра для горизонтального блока с элементами внутри
function M.get_center_horisontal_list(self, node_wrap, node_item, margin)
	if not self.get_center_horisontal_list then
		self.get_center_horisontal_list = {}
	end

	if not self.get_center_horisontal_list[gui.get_id(node_wrap)] then
		self.get_center_horisontal_list[gui.get_id(node_wrap)] = {
			position_wrap = vmath.vector3(0, gui.get_position(node_wrap).y, gui.get_position(node_wrap).z),
			size_wrap = vmath.vector3(0, 0, 0),
			position_item = vmath.vector3(0, 0, 0),
		}
	end

	local storage = self.get_center_horisontal_list[gui.get_id(node_wrap)];
	local result = {}

	--Начинаем высчитывать ncартовую позицию элемента
	storage.position_item.x = storage.position_item.x + margin

	-- Стартовая позиция элемента
	result.start_position = vmath.vector3(storage.position_item.x, 0, 0)

	-- Начало позиции для следующего элемента 
	local width_elem = gui.get_size(node_item).x * gui.get_scale(node_item).x
	storage.position_item.x = storage.position_item.x + width_elem + margin;

	-- Увеличиваем размер обложки
	storage.size_wrap.x = storage.position_item.x

	storage.position_wrap.x = - storage.size_wrap.x / 2 + width_elem - margin

	result['size_wrap'] = storage.position_item
	result['position_wrap'] = storage.position_wrap

	return result
end

-- Получение размеров текстового блока gui
function M.get_size_gui_text(node_text)
	return resource.get_text_metrics(
	gui.get_font_resource(gui.get_font(node_text)),
	gui.get_text(node_text),
	{
		width = gui.get_size(node_text).x,
		line_break = gui.get_line_break(node_text)
	}
)
end

-- Установка изображения в заданные рамки
function M.play_flipbook_ratio(self, node, node_wrap, animation, width, height, not_loyouts)
	local size_wrap = gui.get_size(node_wrap)
	local width = width or size_wrap.x
	local height = height or size_wrap.y

	if not_loyouts then
		gui.play_flipbook(node, animation)
	else
		gui_loyouts.play_flipbook(self, node, animation)
	end

	local size = gui.get_size(node)
	local orientation = "vertical"
	if size.x > size.y then
		orientation = "horisontal"
	end

	if orientation == "horisontal" then
		if not_loyouts then
			gui.set_scale(node, vmath.vector3(width / size.x))
		else
			gui_loyouts.set_scale(self, node, vmath.vector3(width / size.x))
		end
	elseif orientation == "vertical" then
		if not_loyouts then
			gui.set_scale(node, vmath.vector3(height / size.y))
		else
			gui_loyouts.set_scale(self, node, vmath.vector3(height / size.y))
		end
	end

	return true
end

return M