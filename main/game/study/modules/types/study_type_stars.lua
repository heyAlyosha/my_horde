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

	timer.delay(0.3, false, function (self)
		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "study",
			value = {
				id = "stars"
			}
		})
	end)

	msg.post("/loader_gui", "set_content", {
		id = "character_dialog",
		type = "add_dialog",
		items = {
			{
				dialog_id = "_study_stars_1", 
				text = lang_core.get_text(self, "_study_stars_1"),
				bg = false
			},
			{
				dialog_id = "_study_stars_2", 
				text = lang_core.get_text(self, "_study_stars_2"),
				bg = false
			},
			--[[
			{
				dialog_id = "_study_stars_4", 
				text = lang_core.get_text(self, "_study_stars_4"),
				bg = false
			},
			--]]
		}
	})
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_stars_2" then
		timer.delay(0.3, false, function (self)
			msg.post("/loader_gui", "set_status", {
				id = "interface",
				type = "study",
				value = {
					id = false
				}
			})
		end)
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