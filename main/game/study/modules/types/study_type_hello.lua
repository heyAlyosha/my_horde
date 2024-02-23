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
				dialog_id = "_study_hello_1", 
				text = lang_core.get_text(self, "_study_hello_1"),
			},
		}
	})
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and message.type == "is_print" and message.value.dialog_id == "_study_hello_1" then
		-- Если закончилась анимация приветствия 
		self.cursor_visible = true
		self.cursor_timer = timer.delay(0.5, false, function (self)
			msg.post("main:/loader_gui", "set_status", {
				id = "study",
				type = "set_items",
				timeline = {
					{
						type = "touch",
						gui_object_end = {
							id_comonent = "character_dialog", node_name = "bubble" -- ключи в storage_gui.positions
						},
					}
				}
			})
		end)

	--[[
	elseif message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_hello_1" and self.cursor_visible then
		-- Скрываем курсор после закрытия первой части приветсвия
		timer.cancel(self.cursor_timer)
		self.cursor_timer = nil
		self.cursor_visible = nil
		msg.post("main:/loader_gui", "visible", {
			id = "study",
			visible = false
		})
	--]]

	elseif message and message.type == "close_character_dialog" and message.value.dialog_id == "_study_hello_1" then
		-- Приветсвие закончилось
		msg.post("main:/loader_gui", "visible", {
			id = "study",
			visible = false
		})

		self.current_study_id = nil
		msg.post(".", "play_first_item")
	end
end

return M