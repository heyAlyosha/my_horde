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
				dialog_id = "_study_inventary_1", 
				text = lang_core.get_text(self, "_study_inventary_1"),
			},
			{
				dialog_id = "_study_inventary_2", 
				text = lang_core.get_text(self, "_study_inventary_2"),
			},
		}
	})

	
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and ((message.type == "close_character_dialog" and message.value.dialog_id == "_study_inventary_1")) then
		storage_player.prizes = storage_player.prizes or {}
		storage_player.prizes.akum = storage_player.prizes.akum or 0
		storage_player.prizes.duhi = storage_player.prizes.duhi or 0
		storage_player.prizes.naushniki = storage_player.prizes.naushniki or 0
		storage_player.prizes.microphone = storage_player.prizes.microphone or 0

		storage_player.prizes.akum = storage_player.prizes.akum + 2
		storage_player.prizes.duhi = storage_player.prizes.duhi + 2
		storage_player.prizes.microphone = storage_player.prizes.microphone + 1
		storage_player.prizes.naushniki = storage_player.prizes.naushniki + 1

		msg.post("main:/sound", "play", {sound_id = "inventary_category_listen"})

		msg.post("main:/loader_gui", "set_status", {
			id = "catalog_inventary",
			type = "update",
		})

	elseif message and ((message.type == "close_character_dialog" and message.value.dialog_id == "_study_inventary_2") or (self.cursor_visible and ((message.type == "activate_btn") or (message.type == "scroll")))) then
		-- Курсор на кнопку покупки или выхода
		if self.cursor_timer then
			timer.cancel(self.cursor_timer)
		end
		self.cursor_timer = nil
		if self.cursor_visible then
			self.cursor_visible = nil
			msg.post("main:/loader_gui", "visible", {
				id = "study",
				visible = false
			})
		end

		self.cursor_visible = true
		self.cursor_timer = timer.delay(0.5, false, function (self)
			--Смотрим какие кнопки есть
			storage_gui.positions.catalog_inventary = storage_gui.positions.catalog_inventary or {}

			local btn_cursor = #storage_gui.positions.catalog_inventary
			if btn_cursor > 0 then
				btn_cursor = 1
			end

			msg.post("main:/loader_gui", "set_status", {
				id = "study",
				type = "set_items",
				timeline = {
					{
						type = "touch",
						gui_object_end = {
							id_comonent = "catalog_inventary", node_name = btn_cursor -- ключи в storage_gui.positions
						},
					}
				}
			})
		end)

	elseif message and message.id == "close_gui" and message.component_id == "catalog_inventary" then
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