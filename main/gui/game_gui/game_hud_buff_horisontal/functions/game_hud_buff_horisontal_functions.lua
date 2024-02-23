-- Функции
local M = {}

local gui_catalog = require "main.gui.modules.gui_catalog"
local gui_input = require "main.gui.modules.gui_input"
local gui_loader = require "main.gui.modules.gui_loader"
local game_content_artifact = require "main.game.content.game_content_artifact"
local gui_animate = require "main.gui.modules.gui_animate"
local storage_player = require "main.storage.storage_player"
local gui_catalog_type_buff_horisontal = require "main.gui.modules.gui_catalog.gui_catalog_type_buff_horisontal"
local lang_core = require "main.lang.lang_core"
local storage_game = require "main.game.storage.storage_game"
local color = require("color-lib.color")
local gui_loyouts = require "main.gui.modules.gui_loyouts"

function M.visible(self, data, is_update)
	local data = data or {}
	self.is_game = self.is_game or data.is_game
	self.is_reward = self.is_reward or data.is_reward
	self.sector_id = self.sector_id or data.sector_id
	self.player_id = self.player_id or data.player_id
	self.disabled = false

	M.render_detail(self, false)

	if not is_update then
		gui_animate.show_bottom(self, self.nodes.wrap , nil)
	end

	self.focus_btn_id = nil

	self.btns = self.btns or {}
	M.render_catalog(self)
	
	-- Добавляем кнопки внизу
	self.btns[#self.btns + 1] = {
		id = "close", 
		type = "btn", 
		section = "body", 
		node = self.nodes.btn_close,
		node_title = self.nodes.btn_close_title, 
		icon = "btn_ellipse_red_"
	}

	self.btns_id = {}

	for i, btn in ipairs(self.btns) do
		self.btns_id[btn.id] = btn
	end

	-- Фокус если управляет через кнопки
	if not storage_player.input.touch and not storage_player.input.mouse then
		timer.delay(0.2, false, function(self)
			if is_update then
				gui_input.set_focus(self, #self.btns - 1)
			else
				if #self.btns > 0 then
					gui_input.set_focus(self, 1)
				end
			end
		end)
	else
		--gui_input.set_focus(self, 1)
		--gui_input.set_focus(self, nil)
	end

	self.visible = true
end

-- Отрисовка каталога
function M.render_catalog(self)
	local items = game_content_artifact.get_catalog(self, self.player_id, self.is_game, self.is_reward)
	
	local items_type = {}
	for i, item in ipairs(items) do
		if (item.is_use or not items_type[1]) and item.type == "trap" then
			items_type[1] = item

		elseif (item.is_use or not items_type[2]) and item.type == "catch" then
			items_type[2] = item

		elseif (item.is_use or not items_type[3]) and item.type == "bank" then
			items_type[3] = item

		elseif (item.is_use or not items_type[4]) and item.type == "accuracy" then
			items_type[4] = item

		elseif (item.is_use or not items_type[5]) and item.type == "speed_caret" then
			items_type[5] = item

		end
	end

	items = items_type

	self.cards = {}

	for index, item in ipairs(items) do
		gui_catalog_type_buff_horisontal.render_item(self, item, index)

		item.cols = 1

		self.cards[index] = item
	end

	-- Добавляем кнопки
	self.btns = {}
	self.btns_id = {}
	self.cards_id = {}

	for i = 1, #self.cards do
		local item = self.cards[i]

		local btn = {
			id = item.id, 
			type = "btn", 
			section = "card_"..item.cols, 
			node = item.nodes.wrap,
			node_title = item.nodes.count,
			node_wrap_title = item.nodes.title,
			name_areol = "item_template_"..i.."/aureola-template",
			node_info = gui.get_node("item_template_"..i.."/info_btn_template/btn_wrap"),
			-- Смотрим заблокирован ли объект для покупки
			disabled = not item.is_use,
			id_object = item.id,
			is_card = true,
			count = item.count,
			item = item,
			on_set_function = function (self, btn, focus)
				if focus then
					btn.areol_animate = gui_animate.areol(self, btn.name_areol, speed_to_second, "loop", function_end, 0.4)

					M.render_detail(self, btn.id)

				else
					M.render_detail(self, false)
					gui_loyouts.set_color(self, item.nodes.title,  color[item.color])
					btn.areol_animate.stop(self)
				end
			end,
		}

		self.btns_id[item.id] = btn
		self.cards_id[item.id] = item

		if item.type == "trap" then
			--pprint(item)
		end

		table.insert(self.btns, btn)
	end

	gui_input.render_btns(self, self.btns)

	for i = 1, #self.cards do
		local item = self.cards[i]
		gui_loyouts.set_color(self, item.nodes.title,  color[item.color])
	end
end

-- Закрытие формы
function M.hidden(self)
	msg.post("/loader_gui", "visible", {
		id = "game_hud_buff_horisontal",
		visible = false,
		type = hash("animated_close"),
	})
end

-- Выбор баффа
function M.activate_card(self, btn)
	-- Удаляем активационный ареол со старой кнопки
	--if self.activate_btn and self.activate_btn.id == btn.id then
	if self.activate_btn and self.activate_btn.id == btn.id then
		-- Если 2 раза на 1 кнопку
		return M.activate_buff(self, self.activate_btn)
		
	elseif self.activate_btn then
		self.activate_btn.areol.stop()
	end

	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	-- Ставим на новую кнопку
	self.activate_btn = btn
	self.activate_btn.areol = gui_animate.areol(self, btn.name_areol, speed_to_second, "loop", function_end, 0.4)

	-- Если не досутпен для покупки
	if (self.activate_btn.item.count < 1 and not self.activate_btn.item.is_reward) or self.activate_btn.item.type == "try" then
		gui_input.set_disabled(self, self.btns_id.confirm, true)
	else
		self.disabled = nil

		gui_input.set_focus(self, #self.btns - 1)
	end
	
end

-- активация
function M.activate_buff(self, card)
	if not card.is_card then
		card = self.activate_btn
	end

	self.last_activate_btn = card

	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	if card.item.count < 1 and card.item.is_reward then

		-- Просмотр рекламы за артефакт
		msg.post("main:/core_reward", "get_reward", {type = "artifact", id = card.item.id, player_id = "player", is_game = true})

	elseif card.item.count > 0 then

		msg.post("game-room:/core_game", "event", {
			id = "catch_sector",
			value = {
				type = "confirm",
				sector_id = self.sector_id,
				player_id = self.player_id,
				artifact_id = card.item.id,
			}
		})

		M.hidden(self)

	end
end

-- Отказ или закрытие
function M.close(self)
	msg.post("game-room:/core_game", "event", {
		id = "catch_sector",
		value = {
			type = "close",
		}
	})
	M.hidden(self)
end

function M.render_detail(self, id)
	-- Превью артефакта 

	gui_loyouts.set_enabled(self, self.nodes.wrap_description, false)

	if not self._druid_description then
		self._druid_description = self.druid:new_text(self.nodes.description)
	end

	if id then
		msg.post("game-room:/loader_gui", "set_status", {
			id = "game_wheel",
			type = "preview_artifact",
			visible = true,
			value = {
				artifact_id = id,
				player_id = self.player_id,
				sector_id = self.sector_id,
			}
		})

		gui_animate.show_elem_popping(self, self.nodes.wrap_description, duration, delay, function_end_animation)
		local item = game_content_artifact.get_item(id)

		local description = lang_core.get_text(self, item.description_mini_id_string, before_str, after_str, values)
		self._druid_description:set_to(utf8.upper(description))
	else
		msg.post("game-room:/loader_gui", "set_status", {
			id = "game_wheel",
			type = "preview_artifact",
			visible = false,
		})
	end
end

return M