-- Кнопки
local M = {}

local druid = require("druid.druid")
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local gui_animate = require "main.gui.modules.gui_animate"

function M.function_back(self)
	M.function_activate(self, 1)
end

-- Нажатие на кнопки
function M.function_activate(self, focus_btn_id)
	local btn = self.btns[focus_btn_id]

	gui_animate.activate(self, btn.node)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = "modal_result_family",
			visible = false
		})
	end)

	if btn.id == "close" or btn.id == "back" then
		-- Закрытие/возврат назад
		msg.post("main:/core_screens", "constructor_family", {})

	elseif btn.id == "continue_family" then
		-- Продолжают играть
		msg.post("main:/core_family", "event", {id = "continue_family_play"})

	elseif btn.id == "home" then
		-- В главное меню
		msg.post("main:/core_screens", "main_menu", {})
		
	end
end

return M