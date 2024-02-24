-- Знакомство с обучением
local M = {}

local lang_core = require "main.lang.lang_core"
local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"
local game_core_gamers = require "main.game.core.game_core_gamers"
local core_layouts = require "main.core.core_layouts"

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
				dialog_id = "_study_level_up_1", 
				text = lang_core.get_text(self, "_study_level_up_1"),
				bg = false
			},
			{
				dialog_id = "_study_level_up_2", 
				text = lang_core.get_text(self, "_study_level_up_2"),
				bg = false
			},
		}
	})

	timer.delay(0.3, false, function (self)
		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "study",
			value = {
				id = "xp_and_line"
			}
		})
	end)
	
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_level_up_1" then
		-- Левел
		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "study",
			value = {
				id = "level_up"
			}
		})

	elseif message and ((message.type == "close_character_dialog" and message.value.dialog_id == "_study_level_up_2") or (message.id == "activate_characteristic")) then
		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "study",
			value = {
				id = false
			}
		})

		if self.cursor_timer then
			timer.cancel(self.cursor_timer)
		end
		self.cursor_timer = nil
		self.cursor_visible = nil
		msg.post("main:/loader_gui", "visible", {
			id = "study",
			visible = false
		})

		self.cursor_visible = true
		self.cursor_timer = timer.delay(0.5, false, function (self)
			--Смотрим какеи кнопки есть
			storage_gui.positions.modal_characteristics = storage_gui.positions.modal_characteristics or {}

			local btn_cursor = 1
			if #storage_gui.positions.modal_characteristics >= 5 then
				btn_cursor = 5

			elseif #storage_gui.positions.modal_characteristics > 1 then
				btn_cursor = 2

			end

			msg.post("main:/loader_gui", "set_status", {
				id = "study",
				type = "set_items",
				timeline = {
					{
						type = "touch",
						gui_object_end = {
							id_comonent = "modal_characteristics", node_name = btn_cursor -- ключи в storage_gui.positions
						},
					}
				}
			})
		end)

	elseif message and message.id == "close_gui" and message.component_id == "modal_characteristics" then
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
	end

end

return M