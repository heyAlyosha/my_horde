-- Знакомство с обучением
local M = {}

local lang_core = require "main.lang.lang_core"
local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"
local core_layouts = require "main.core.core_layouts"

-- Запуск
function M.start(self)
	self.step_study = nil

	msg.post("/loader_gui", "visible", {
		id = "character_dialog",
		visible = false,
	})

	msg.post("/loader_gui", "set_content", {
		id = "character_dialog",
		type = "add_dialog",
		items = {
			{
				dialog_id = "_study_shop_1", 
				text = lang_core.get_text(self, "_study_shop_1"),
			},
			{
				dialog_id = "_study_shop_2", 
				text = lang_core.get_text(self, "_study_shop_2"),
			},
		}
	})

end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message and ((message.type == "close_character_dialog" and message.value.dialog_id == "_study_shop_1")) then
		msg.post("main:/loader_gui", "set_status", {
			id = "add_balance",
			type = "coins",
			start_position = storage_gui.positions.character_dialog.bubble,
			value = 150
		})

		-- Если нет точности в магазине
		if not storage_player.shop.accuracy_1 or storage_player.shop.accuracy_1 < 1 then
			storage_player.shop.accuracy_1 = 1
		end

	elseif message and (message.type == "close_character_dialog" and message.value.dialog_id == "_study_shop_2") then
		timer.delay(0.25, false, function (self)
			self.step_study = "test_buy"
			msg.post("main:/loader_gui", "set_status", {
				id = "catalog_shop",
				type = "update",
			})

			msg.post("main:/loader_gui", "set_status", {
				id = "catalog_shop",
				type = "scroll_to_btn",
				btn_id = "accuracy_1"
			})

			
			self.cursor_timer = timer.delay(0.5, false, function (self)
				--Смотрим какие кнопки есть
				self.cursor_visible = true
				msg.post("main:/loader_gui", "set_status", {
					id = "study",
					type = "set_items",
					timeline = {
						{
							type = "touch",
							gui_object_end = {
								id_comonent = "catalog_shop", node_name = "accuracy_1" -- ключи в storage_gui.positions
							},
						}
					}
				})
			end)
		end)

	elseif self.step_study ==  "test_buy"  and (self.cursor_visible and ((message.type == "scroll"))) then
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
			storage_gui.positions.catalog_shop = storage_gui.positions.catalog_shop or {}

			if storage_gui.positions.catalog_shop.accuracy_1 then
				msg.post("main:/loader_gui", "set_status", {
					id = "study",
					type = "set_items",
					timeline = {
						{
							type = "touch",
							gui_object_end = {
								id_comonent = "catalog_shop", node_name = "accuracy_1" -- ключи в storage_gui.positions
							},
						}
					}
				})
			end
		end)

	elseif message.type == "activate_btn" and message.btn_id then
		self.step_study = "close_shop"
		msg.post("main:/loader_gui", "set_status", {
			id = "study",
			type = "set_items",
			timeline = {
				{
					type = "touch",
					gui_object_end = {
						id_comonent = "inventary_wrap", node_name = "close" -- ключи в storage_gui.positions
					},
				}
			}
		})

	elseif message and message.id == "close_gui" and message.component_id == "catalog_shop" then
		-- Скрываем курсор после окончания
		if self.cursor_timer then
			timer.cancel(self.cursor_timer)
		end
		self.step_study = nil
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