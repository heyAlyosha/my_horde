-- Продолжение игры
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

	pprint("character_dialog")

	self.cursor_visible = true
	self.cursor_timer = timer.delay(0.5, false, function (self)
		msg.post("main:/loader_gui", "set_status", {
			id = "study",
			type = "set_items",
			timeline = {
				{
					type = "touch",
					gui_object_end = {
						id_comonent = "modal_result_single", node_name = "btn_3" -- ключи в storage_gui.positions
					},
					set_order = 10
				}
			}
		})
	end)
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	pprint(message_id, message)
	if message and (message.id == "close_gui" and message.component_id == "modal_result_single") or (message.id == "visible_gui" and message.component_id == "catalog_shop") then
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