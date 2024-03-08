-- работа с текстом в гуи
local M = {}

local richtext = require "richtext.richtext"
local color = require "richtext.color"

function M.set_text_formatted(self, node, text)
	local node_id = gui.get_id(node)
	local pivot = gui.get_pivot(node)
	self._storage_set_text_formatted = self._storage_set_text_formatted or {}
	local align = 0
	local valign = 0
	if pivot == gui.PIVOT_CENTER then
		align = richtext.ALIGN_CENTER
		valign = richtext.VALIGN_MIDDLE
		
	elseif pivot == gui.PIVOT_N then
		align = richtext.ALIGN_CENTER
		valign = richtext.VALIGN_TOP
		
	elseif pivot == gui.PIVOT_NE then
		align = richtext.ALIGN_RIGHT
		valign = richtext.VALIGN_TOP
		
	elseif pivot == gui.PIVOT_E then
		align = richtext.ALIGN_RIGHT
		valign = richtext.VALIGN_MIDDLE
		
	elseif pivot == gui.PIVOT_SE then
		align = richtext.ALIGN_RIGHT
		valign = richtext.VALIGN_BOTTOM
	elseif pivot == gui.PIVOT_S then
		align = richtext.ALIGN_CENTER
		valign = richtext.VALIGN_BOTTOM
	elseif pivot == gui.PIVOT_SW then
		align = richtext.ALIGN_LEFT
		valign = richtext.VALIGN_BOTTOM
	elseif pivot == gui.PIVOT_W then
		align = richtext.ALIGN_LEFT
		valign = richtext.VALIGN_MIDDLE
	elseif pivot == gui.PIVOT_NW then
		align = richtext.ALIGN_LEFT
		valign = richtext.VALIGN_TOP
	end

	local settings = {
		width = gui.get_size(node).x,
		parent = node,
		color = gui.get_color(node),
		shadow = gui.get_shadow(node),
		outline = gui.get_outline(node),
		align = align,
		valign = valign,
	}

	-- Скрываем родительский блок
	gui.set_text(node, "")

	-- Если уже были отрисованы ноды для текста, удаляем их
	if self._storage_set_text_formatted[node_id] then
		richtext.remove(self._storage_set_text_formatted[node_id])
		self._storage_set_text_formatted[node_id] = nil
	end

	local font = gui.get_font(node)
	local nodes = richtext.create(text, font, settings)
	self._storage_set_text_formatted[node_id] = nodes

	return nodes
end

-- Замена плейсхолдеров на значение
function M.set_placeholder(string, placeholders)
	local result = string
	for name, value in pairs(placeholders) do
		result = string.gsub(result, "{{" .. name .. "}}", value)
	end

	return result
end

return M