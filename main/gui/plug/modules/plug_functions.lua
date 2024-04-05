-- 
local M = {}

local gui_input = require "main.gui.modules.gui_input"
local gui_size = require "main.gui.modules.gui_size"

function M.render_btns(self, btns)
	if btns and #btns > 0 then
		self.btns = self.btns or {}
		-- Удаляем старые кнопки
		for i = #self.btns, 1, -1 do
			if self.btns.nodes then
				for i, node_clone in pairs(self.btns.nodes) do
					gui.delete_node(node_clone)
				end
			end
		end

		local result
		for i, item in ipairs(btns) do
			local nodes = gui.clone_tree(self.nodes.wrap_btn)

			gui.set_enabled(nodes[hash("btn_template/btn_wrap")], true)
			gui.set_text(nodes[hash("btn_template/btn_title")], item.title)
			
			self.btns[i] = {
				nodes = nodes,
				title = item.title,
				id = item.id, -- айдишник для активации кнопки
				value = item.value,
				type = "btn", 
				section = "loader",
				node = nodes[hash("btn_template/btn_wrap")],
				node_title = nodes[hash("btn_template/btn_title")],
				icon = item.bg or "button_default_violet_",
			}

			local type_size = "width"
			local margin = 50
			gui_size.set_gui_wrap_from_text(self.btns[i].node_title, self.btns[i].node, type_size, margin, self)
			gui.set_size(nodes[hash("wrap_btn")], gui.get_size(self.btns[i].node))

			result = gui_size.get_center_horisontal_list(self, self.nodes.center_btns, nodes[hash("wrap_btn")], 5)
			result.position_wrap.x = result.position_wrap.x - result.size_wrap.x / 4

			gui.set_position(nodes[hash("wrap_btn")], result.start_position)
			gui.set_size(self.nodes.center_btns, result.size_wrap)
			gui.set_position(self.nodes.center_btns, result.position_wrap)
		end

		result.position_wrap.x = result.position_wrap.x - result.size_wrap.x / 4
		gui.set_position(self.nodes.center_btns, result.position_wrap)

		gui_input.render_btns(self, self.btns)

		if #self.btns > 0 then
			timer.delay(0.1, false, function(self)
				gui_input.set_focus(self, 1)
			end)
		end
	end
end
return M