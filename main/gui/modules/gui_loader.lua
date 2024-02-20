-- Управление лоадером
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"

-- Показ или скрытие лоадера загрузки
function M.visible(visible, node_wrap, node_icon, node_body, self)
	local node_wrap = node_wrap or gui.get_node("loader_template/loader_wrap")
	local node_icon = node_icon or gui.get_node("loader_template/loader_icon")
	local node_body = node_body or gui.get_node("catalog_content")
	local rotation = gui.get_rotation(node_icon)

	gui_loyouts.set_enabled(self, node_wrap, visible)
	gui_loyouts.set_enabled(self, node_body, not visible)
	gui_loyouts.set_rotation(self, node_icon, 0, "z")
	gui.cancel_animation(node_icon, "rotation.z")

	if visible then
		gui.animate(node_icon, "rotation.z", rotation.z + 360, gui.EASING_LINEAR, 3, 0, nil, gui.PLAYBACK_LOOP_FORWARD)
	end
end

return M