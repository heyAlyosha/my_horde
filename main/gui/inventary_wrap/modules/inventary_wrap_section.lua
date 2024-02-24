-- Отрисовываем разные разделы инвентаря
local M = {}

local color = require("color-lib.color")

-- Открытие раздела инвентаря
function M.open(self, id)
	msg.post("/loader_gui", "visible", {
		id = "inventary_detail",
		visible = false,
	})
	self.open_section_id = id
	for i = 1, #self.sections do
		local section = self.sections[i]
		-- Открываем указанный раздел и скрываем остальные
		section.visible = section.id == id
		msg.post("/loader_gui", "visible", {
			id = section.id_loader_gui,
			visible = section.visible,
		})

		-- Окрашиваем активную вкладку
		local btn = section.btn
		if section.visible then
			gui.set_color(btn.node_title_section , color.lime)
		else
			gui.set_color(btn.node_title_section , color.white)
		end
	end
end

-- получить открытый раздел
function M.get_open_section(self)
	self.open_section_id = self.open_section_id or 0
	return self.sections_id[self.open_section_id]
end

return M