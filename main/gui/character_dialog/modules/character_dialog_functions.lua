-- Персонаж
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local printer = require "printer.printer"
local gui_animate = require "main.gui.modules.gui_animate"

-- Пролистывание текста
function M.next(self)
	-- Очищаем старый текст, если есть
	if self.index_items >= 1 then
		local last_item = self.items[self.index_items]
		self.printer:clear()

		if last_item.timer then
			timer.cancel(last_item.timer)
		end

		msg.post("/loader_gui", "set_status", {
			id = "all",
			from_id = self.id, 
			is_from_msg = false,
			type = "close_character_dialog",
			value = {
				dialog_id = last_item.dialog_id,
				character_id = last_item.character_id,
			}
		})
	end

	self.index_items = self.index_items + 1
	local item = self.items[self.index_items]
	if not item then
		--Если нет
		M.close(self)
	else
		self.block_input = true
		timer.delay(0.25, false, function (self)
			self.block_input = false
		end)

		self.item = item
		self.printer:print(item.text)

		-- Затемнение фона
		gui_loyouts.set_enabled(self, self.nodes.bg, self.item.bg == nil or self.item.bg == true)
	end
end

-- Закртыие диалога
function M.close(self)
	gui_animate.hidden_bottom(self, self.nodes.character_study_wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = self.id,
			visible = false,
		})
	end)

end

return M