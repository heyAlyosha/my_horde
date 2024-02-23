-- Функции для ползунка
local M = {}

local color = require("color-lib.color")
local gui_size = require "main.gui.modules.gui_size"
local storage_gui = require "main.storage.storage_gui"

-- Инициализация
function M.focus_input_component(self, id_component, index)
	-- Было ли уже такое окно в фокусе
	local modal_focus = false
	for i = 1, #storage_gui.modals do
		local modal = storage_gui.modals[i]
		if modal.id == id_component then
			storage_gui.modals[i].focus_input_index_btn = index
			table.insert( storage_gui.modals, #storage_gui.modals, table.remove(storage_gui.modals, i ) )
			modal_focus = modal
			break
		end
	end

	-- Его нет, добавляем
	if not modal_focus then
		if self.is_modal then
			self.type_gui = "modal"
		end
		table.insert(storage_gui.modals, {
			id =  id_component, 
			focus_input_component = id_component,
			url = msg.url(),
			focus_input_index_btn = index,
			type_gui = self.type_gui,
		})
	end

	if not self.is_modal and not self.not_remove_other_focus then
		for key, url in pairs(storage_gui.components_visible) do
			if hash(key) ~= id_component then
				msg.post(url, "focus", {focus = nil})
			end
		end
	end

	-- если элемент изменился 
	if not self.not_set_blocking_focus_component then
		storage_gui.focus_input_component = id_component
		storage_gui.focus_input_index_btn = index
	end
end



return M