-- Управление лоадером
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"

-- Показ или скрытие лоадера загрузки
function M.visible(visible, node_wrap, node_icon, node_body, self)
	self._gui_loader_nodes = self._gui_loader_nodes or {}

	for i = 1, 8 do
		self._gui_loader_nodes[i] = gui.get_node("loader_template/loader_item"..i)
	end

	local node_wrap = node_wrap or gui.get_node("loader_template/loader_wrap")
	local node_icon = node_icon or gui.get_node("loader_template/loader_icon")
	local node_body = node_body
	if node_body == nil then
		node_body = gui.get_node("catalog_content")
	end
	local rotation = gui.get_rotation(node_icon)

	gui_loyouts.set_enabled(self, node_wrap, visible)
	if node_body then
		gui_loyouts.set_enabled(self, node_body, not visible)
	end

	if visible then
		local index_start = 1
		self._gui_loader_timer = timer.delay(0.1, true, function (self)
			gui.set_alpha(self._gui_loader_nodes[index_start], 0.2)
			index_start = index_start + 1

			if index_start > #self._gui_loader_nodes then
				index_start = 1
			end
			gui.set_alpha(self._gui_loader_nodes[index_start], 1)
		end)
		--gui.animate(node_icon, "rotation.z", rotation.z + 360, gui.EASING_LINEAR, 3, 0, nil, gui.PLAYBACK_LOOP_FORWARD)
	end
end

return M