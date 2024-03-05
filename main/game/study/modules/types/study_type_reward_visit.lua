-- Знакомство с обучением
local M = {}

local lang_core = require "main.lang.lang_core"
local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"

-- Запуск
function M.start(self)
	msg.post("/loader_gui", "visible", {
		id = "character_dialog",
		visible = false,
	})

	msg.post("/loader_gui", "set_content", {
		id = "character_dialog",
		type = "add_dialog",
		items = {
			{
				dialog_id = "_study_reward_visit_1", 
				text = lang_core.get_text(self, "_study_reward_visit_1"),
				bg = true
			},
		}
	})
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and message.id == "close_gui" and message.component_id == "modal_reward_visit" then
		msg.post("/loader_gui", "visible", {
			id = "character_dialog",
			visible = false,
		})

		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "study",
			value = {
				id = false
			}
		})
		-- Скрываем курсор после окончания
		if self.cursor_timer then
			timer.cancel(self.cursor_timer)
		end
		self.cursor_timer = nil
		self.cursor_visible = nil
		msg.post("main:/loader_gui", "visible", {
			id = "study",
			visible = false
		})

		-- Закончилась
		self.current_study_id = nil

		if storage_gui.components_visible.modal_result_single then
			msg.post("main:/core_study", "event", {id = "result_all_showing", type = nil})
		end
	end

end

return M