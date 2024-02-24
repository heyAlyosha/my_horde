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
				dialog_id = "_study_aim_1", 
				text = lang_core.get_text(self, "_study_aim_1"),
				bg = false
			},
			{
				dialog_id = "_study_aim_2", 
				text = lang_core.get_text(self, "_study_aim_2"),
				bg = false
			},
			{
				dialog_id = "_study_aim_3", 
				text = lang_core.get_text(self, "_study_aim_3"),
				bg = false
			},
			{
				dialog_id = "_study_aim_4", 
				text = lang_core.get_text(self, "_study_aim_4"),
				bg = false
			},
		}
	})

	-- Про прицел
	msg.post("/loader_gui", "set_status", {
		id = "game_wheel",
		type = "study",
		value = {
			id = "aim"
		}
	})
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_aim_1" then
		-- Про сектора с очками
		msg.post("/loader_gui", "set_status", {
			id = "game_wheel",
			type = "study",
			value = {
				id = "sector_many_score"
			}
		})

	elseif message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_aim_2" then
		-- Про зелёные
		msg.post("/loader_gui", "set_status", {
			id = "game_wheel",
			type = "study",
			value = {
				id = "sector_green"
			}
		})

	elseif message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_aim_3" then
		-- Про красные
		msg.post("/loader_gui", "set_status", {
			id = "game_wheel",
			type = "study",
			value = {
				id = "sector_red"
			}
		})

	elseif message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_aim_4" then
		-- Про красные
		msg.post("/loader_gui", "set_status", {
			id = "game_wheel",
			type = "study",
			value = {
				id = false
			}
		})

		self.cursor_visible = true
		self.cursor_timer = timer.delay(0.5, false, function (self)
			msg.post("main:/loader_gui", "set_status", {
				id = "study",
				type = "set_items",
				timeline = {
					{
						type = "touch",
						gui_object_end = {
							id_comonent = "scale_power", node_name = "btn" -- ключи в storage_gui.positions
						},
					}
				}
			})
		end)

	elseif message and message.id == "close_gui" and message.component_id == "scale_power" then
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

		msg.post("/loader_gui", "set_status", {
			id = "game_wheel",
			type = "study",
			value = {
				id = false
			}
		})

		-- Закончилась
		self.current_study_id = nil
	end

end

return M