-- Знакомство с обучением
local M = {}

local lang_core = require "main.lang.lang_core"
local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"
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
				dialog_id = "_study_accuracy_1", 
				text = lang_core.get_text(self, "_study_accuracy_1"),
				bg = false
			},
		}
	})

	-- Добавляю новую гирю
	local player_id = core_layouts.get_data().data.player.player_id
	local artifact_id = "accuracy_1"
	local count = 1
	game_core_gamers.add_artifact_count(self, artifact_id, player_id, count)

	msg.post("/loader_gui", "set_status", {
		id = "game_hud_buff_horisontal",
		type = "update",
	})

	timer.delay(0.3, false, function (self)
		msg.post("/loader_gui", "focus", {
			id = "game_hud_buff_horisontal",
			focus = 4,
		})
	end)
	
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and message.type == "close_character_dialog" and (message.value.dialog_id == "_study_accuracy_1" or message.value.dialog_id == "_study_accuracy_2") then
		-- Про прицел
		self.cursor_visible = true
		self.cursor_timer = timer.delay(0.5, false, function (self)
			msg.post("main:/loader_gui", "set_status", {
				id = "study",
				type = "set_items",
				timeline = {
					{
						type = "touch",
						gui_object_end = {
							id_comonent = "game_hud_buff_horisontal", node_name = "buff_4" -- ключи в storage_gui.positions
						},
					}
				}
			})
		end)

	elseif message and message.id == "close_gui" and message.component_id == "game_hud_buff_horisontal" then
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