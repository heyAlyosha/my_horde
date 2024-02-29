-- Отрисовка каталога типа инвентарь
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local lang_core = require "main.lang.lang_core"

function M.render_item(self, item, index)
	local nodes = {
		wrap = gui.get_node("item_template_"..index.."/icon_wrap"),
		title = gui.get_node("item_template_"..index.."/title"),
		icon = gui.get_node("item_template_"..index.."/img"),
		count = gui.get_node("item_template_"..index.."/count"),
		reward_icon = gui.get_node("item_template_"..index.."/icon_reward"),
		icon_bg = gui.get_node("item_template_"..index.."/icon_bg"),
		icon_border = gui.get_node("item_template_"..index.."/icon_border"),
	}

	item.nodes = nodes

	-- Отрисовываем количество
	if item.count < 1 and item.is_reward then
		-- Если нет у игрока, но есть за рекламу
		gui_loyouts.set_enabled(self, nodes.reward_icon, true)
		gui_loyouts.set_alpha(self, nodes.icon_bg, 0.25)
		gui_loyouts.set_alpha(self, nodes.icon_border, 0.25)
	else
		-- Если нет за рекламу
		gui_loyouts.set_enabled(self, nodes.reward_icon, false)
		gui_loyouts.set_alpha(self, nodes.icon_bg, 1)
		gui_loyouts.set_alpha(self, nodes.icon_border, 1)
	end

	gui_loyouts.set_enabled(self, nodes.wrap, true)
	--gui.set_text(nodes.title, utf8.lower(item.title))
	local title = lang_core.get_text(self, "_type_"..item.type, before_str, after_str, values)
	self.druid:new_text(nodes.title, utf8.upper(title))
	--gui_loyouts.set_druid_text(self, nodes.title, utf8.upper(title))

	gui_loyouts.set_text(self, nodes.count, item.count)

	gui_loyouts.play_flipbook(self, nodes.icon, item.icon)

	return item
end

-- Старая отрисовка для клона
function M.render_item_clone(self, item, coordinate, catalog_array, params)
	local clone_node = params.node_for_clone
	coordinate.end_x = coordinate.start_x + coordinate.width_card + params.margin
	coordinate.end_y = coordinate.start_y
	coordinate.cols = coordinate.cols

	item.cols = coordinate.cols
	item.nodes = gui.clone_tree(clone_node)

	local nodes = {
		wrap = item.nodes[hash("item_template/icon_wrap")],
		title = item.nodes[hash("item_template/title")],
		icon = item.nodes[hash("item_template/img")],
		count = item.nodes[hash("item_template/count")],
		reward_icon = item.nodes[hash("item_template/icon_reward")],
	}

	-- Отрисовываем количество
	if item.count < 1 and item.is_reward then
		-- Если нет у игрока, но есть за рекламу
		gui.set_enabled(nodes.count, false)
		gui.set_enabled(nodes.reward_icon, true)
	else
		-- Если нет за рекламу
		gui.set_enabled(nodes.count, true)
		gui.set_enabled(nodes.reward_icon, false)
	end

	gui.set_enabled(nodes.wrap, true)
	gui.set_position(nodes.wrap, vmath.vector3(coordinate.start_x, coordinate.start_y, 1))
	--gui.set_text(nodes.title, utf8.lower(item.title))
	local title = lang_core.get_text(self, "_type_"..item.type, before_str, after_str, values)
	gui.set_text(nodes.count, utf8.upper(item.count))

	gui.play_flipbook(nodes.icon, item.icon)

	coordinate.start_x = coordinate.end_x

	return coordinate
end



return M