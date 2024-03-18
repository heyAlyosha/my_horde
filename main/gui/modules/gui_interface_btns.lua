-- Функции работы с кнопками вверху
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local game_content_interface_btns_set = require "main.game.content.game_content_interface_btns_set"
local storage_gui = require "main.storage.storage_gui"
local gui_size = require "main.gui.modules.gui_size"

-- Отрисовка сета кнопок
function M.render_btns_set(self, set_id)
	if not set_id or not game_content_interface_btns_set[set_id] then
		set_id = "default"
	end

	local set_btn = game_content_interface_btns_set[set_id]
	if set_id ~= storage_gui.iterface_btns_set_current then
		local btns = {}

		-- Если сет кнопок изменился 
		for i = 1, 3 do
			local btn_id = set_btn[i]

			local node_btn = self.nodes["btn_"..i.."_wrap"]
			local node_btn_icon_wrap = self.nodes["btn_"..i.."_icon_wrap"]
			local node_icon
			if i ~= 3 then
				node_icon = self.nodes["btn_"..i.."_icon"]
			end
			local btn_content = self.btns_content[btn_id]

			if not btn_id then
				-- Если кнопки нет, то выключаем ноду под неё
				gui_loyouts.set_enabled(self, node_btn, false)
			else
				gui_loyouts.set_enabled(self, node_btn, true)
				--gui_size.play_flipbook_ratio(self, node_icon, node_btn_icon_wrap, btn_content.icon.."_default", 70, 70)

				table.insert(btns, 1, {
					id = btn_content.id, 
					type = "btn", 
					section = "interface_right", 
					node = node_btn, 
					--wrap_node = node_icon,
					node_title = node_icon, 
					icon = "btn_interface_",
					wrap_icon = btn_content.icon.."_"
				})
			end
		end

		storage_gui.iterface_btns_set_current = set_id

		return btns
	else
		return false
	end
end

return M