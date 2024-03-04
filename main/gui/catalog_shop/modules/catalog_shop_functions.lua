-- Функции 
local M = {}

local gui_animate = require "main.gui.modules.gui_animate" 
local gui_catalog = require "main.gui.modules.gui_catalog"
local gui_input = require "main.gui.modules.gui_input"
local gui_loader = require "main.gui.modules.gui_loader"
local game_content_artifact = require "main.game.content.game_content_artifact"
local gui_catalog_type_shop = require "main.gui.modules.gui_catalog.gui_catalog_type_shop"
local storage_player = require "main.storage.storage_player"
local api_core_shop = require "main.core.api.api_core_shop"
local data_handler = require "main.data.data_handler"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"

-- Отрисовка катлаога
function M.render_catalog(self)
	gui_loader.visible(true, node_wrap, node_icon, node_body, self)
	gui_catalog.catalog_empty(self, "shop", false)
	local items = game_content_artifact.get_catalog(self)

	-- Удаляем невидимые для магазина товары

	for i = #items, 1, -1 do
		local item = items[i]

		if not item.visible_shop then
			table.remove(items, i)
		end
	end

	for i, item in ipairs(items) do
		if not item.disable_buy then
			item.sort = item.sort + 10 
		end
	end

	table.sort(items, function (a, b)
		
		--return not a.disable_buy and b.disable_buy

		return a.sort > b.sort

		--return not a.disable_buy and b.disable_buy and a.sort > b.sort
		
		--if (not a.disable_buy and b.disable_buy) then return true end
		--if (a.sort > b.sort) then return false end
	end)

	local params = {
		margin = 5,
		node_for_clone = self.nodes.node_for_clone,
		node_catalog_view = self.nodes.catalog_view,
		node_catalog_content = self.nodes.catalog_content,
		node_catalog_input = self.nodes.catalog_input,
		node_scroll = self.nodes.catalog,
		node_scroll_wrap = self.nodes.scroll_wrap,
		node_scroll_caret = self.nodes.scroll_caret,
	}

	self.cards = self.cards or {}
	for i = #self.cards, 1, -1  do
		local item = self.cards[i]
		gui.delete_node(item.nodes[hash("item_template/wrap")])
		table.remove(self.cards, i)
	end
	self.cards = gui_catalog.create_catalog(self, self.id_catalog, items, self.type, params)

	-- Добавляем кнопки
	self.btns = {}
	self.btns_id = {}
	self.cards_id = {}

	-- Если это модальное окно
	-- Кнопка закрытия
	gui_loyouts.set_enabled(self, self.nodes.btn_close, not (self.btn_close == nil or self.btn_close == false))
	if self.btn_close then
		table.insert(self.btns, {
			id = "close", 
			type = "btn", 
			section = "close", 
			node = self.nodes.btn_close,
			wrap_node = self.nodes.btn_close_icon, 
			node_title = false, 
			icon = "btn_circle_bg_red_", 
			wrap_icon = "btn_icon_close_"
		})
	end

	for i = 1, #self.cards do
		local item = self.cards[i]

		local btn = {
			id = item.id, 
			type = "btn", 
			section = "card_"..item.cols, 
			node = item.nodes[hash("item_template/wrap")],
			node_title = item.nodes[hash("item_template/btn_template/btn_title")],
			wrap_node = item.nodes[hash("item_template/btn_template/btn_wrap")],
			icon = "bg_modal_",
			wrap_icon = "btn_ellipse_green_",
			-- Смотрим заблокирован ли уровень для покупки
			disabled = item.disable_buy,
			--disabled = item.disable_buy,
			id_object = item.id,
			scroll = self["scroll_"..self.id_catalog],
			is_card = true,
			on_set_function = function (self, btn, focus)
				if focus then
					local card = self.cards_id[btn.id]
					gui_catalog_type_shop.render_detail(self, card)
					M.render_upgrade(self, btn.id)
				end
			end,
		}

		self.btns_id[item.id] = btn
		self.cards_id[item.id] = item

		table.insert(self.btns, btn)
		gui_catalog_type_shop.render_item_content(self, item)

		-- Добавляем кнопки улучшений, если есть
		if item and item.upgrade_id then
			-- Добавляем кнопку
			table.insert(self.btns, {
				id = "upgrade_"..item.upgrade_id, 
				upgrade = true, 
				type = "btn", 
				section = "card_"..item.cols, 
				node = self.nodes["btn_upgrade_"..item.upgrade_id],
				node_title = self.nodes["btn_upgrade_"..item.upgrade_id.. "_title"],
				icon = "button_default_green_",
				price = item.upgrade_price,
				id_object = item.id,
				on_set_function = function (self, btn, focus)
					if focus then
						--gui_catalog_type_shop.render_detail(self, item)
						--M.render_upgrade(self, item.id)
					end
				end,
			})
		end

	end

	-- Умная кнопка внизу
	gui_loyouts.set_enabled(self, self.nodes.btn_smart, not (self.btn_smart == nil or self.btn_smart == false))
	if self.btn_smart then
		table.insert(self.btns, {
			id = "btn_smart", 
			type = "btn", 
			section = "close", 
			node = self.nodes.btn_smart,
			node_title = self.nodes.btn_smart_title, 
			icon = "button_default_green_", 
		})
		gui_lang.set_text_upper(self, self.nodes.btn_smart_title, self.btn_smart.title_id, before_str, after_str)
	end

	gui_input.render_btns(self, self.btns)
	gui_catalog.catalog_empty(self, self.type, #self.cards <= 0)
	gui_loader.visible(false, node_wrap, node_icon, node_body, self)
end

-- Отрисовка улучшения
function M.render_upgrade(self, current_product_id)
	
	local item = game_content_artifact.get_item(current_product_id, player_id, is_game, is_reward)

	gui_loyouts.set_enabled(self, self.nodes.wrap_upgrade, false)

	for i, btn in ipairs(self.btns) do
		if btn.upgrade then
			gui_loyouts.set_enabled(self, btn.node, false)
		end
	end

	if item and item.upgrade_id then

		storage_player.upgrades[item.upgrade_id] = storage_player.upgrades[item.upgrade_id] or 1

		local current_upgrade = storage_player.upgrades[item.upgrade_id]
		local next_upgrade = current_upgrade + 1

		local next_item_id = item.type .. "_" .. next_upgrade
		local next_item = game_content_artifact.get_item(next_item_id, player_id, is_game, is_reward)

		if next_item then
			local value_upgrade = next_item.score
			local price_upgrade = item.upgrade_price

			gui_loyouts.set_enabled(self, self.nodes.wrap_upgrade, true)
			gui_loyouts.set_text(self, self.nodes.upgrade_value_value, "+" .. value_upgrade)
			gui_loyouts.set_text(self, self.nodes.upgrade_price_price, price_upgrade)
			

			-- Кнопка улучшения
			local btn = self.btns_id["upgrade_"..item.upgrade_id]
			if btn then
				gui_loyouts.set_enabled(self, btn.node, true)
				gui_input.set_disabled(self, btn, price_upgrade > storage_player.coins)
				btn.upgrade_id = item.upgrade_id
				btn.price = item.upgrade_price
				btn.id = "upgrade_"..item.upgrade_id
				btn.id_object = item.id
				btn.upgrade_id = item.upgrade_id
				btn.next_upgrade = next_upgrade
			end
		end
	end
end

--
function M.buy(self, btn, type)
	local type = "artifact"

	if type == "artifact" then
		local id = btn.id

		-- ОТправляем запрос на покупку
		local object = game_content_artifact.get_item(id, player_id, is_game, is_reward)
		if btn.is_sell_prize then
			-- Показать раздел инвентаря вместе с обёрткой
			msg.post("/loader_gui", "visible", {
				id = "catalog_inventary",
				visible = true,
				modal = false, -- Не открывается обёртка инвентаря
				-- Кнопка внизу
				btn_smart = {
					type = "message",
					title_id = "_to_buy",
					message_url = "main:/loader_gui",
					message_id = "visible",
					message = {
						id = "catalog_shop",
						visible = true,
						-- Кнопка внизу
						btn_smart = self.btn_smart,
					},
				},
			})

		elseif object.buy.buy_type == "buy" then
			msg.post("main:/core_player", "buy", {
				type = "artifact",
				count = 1,
				id = id,
			})
		elseif object.buy.buy_type == "reward" then
			-- ОТправляем запрос на покупку
			msg.post("main:/core_reward", 
				"get_reward", {
					type = "artifact", 
					id = id, 
					player_id = "player", 
					is_game = false
				}
			)
		end
	end
end

-- Результат покупки
function M.result_buy(self, id)
	msg.post("main:/sound", "play", {sound_id = "buy"})

	if id == "delivery" then
		-- Обрабатываем доставку
		storage_player.artifacts[id] = storage_player.artifacts[id] or 0
		if storage_player.artifacts[id] > 0 then
			storage_player.artifacts[id] = storage_player.artifacts[id] - 1
		end

		api_core_shop.add_random_shop(self, game_content_artifact)

	elseif id == "xp_1" then
		-- Обрабатываем покупку очков
		storage_player.artifacts[id] = storage_player.artifacts[id] or 0
		if storage_player.artifacts[id] > 0 then
			storage_player.artifacts[id] = storage_player.artifacts[id] - 1
		end

		storage_player.shop[id] = storage_player.shop[id] or 0
		if storage_player.shop[id] > 0 then
			--storage_player.shop[id] = storage_player.shop[id] - 1
		end

		-- Выпадение кучи монеток и опыта
		local end_position = gui.get_screen_position(self.nodes.detail_gift)
		local gift_random_size =  gui.get_size(self.nodes.detail_gift)
		local object = game_content_artifact.get_item(id, player_id, is_game, is_reward)
		local score = object.value.score

		msg.post("main:/loader_gui", "set_status", {
			id = "add_balance",
			type = "stack", -- Обычный перелёт или куча
			setting_stack ={
				score = score,
				coins = 0,
				end_position = end_position,
				height_flight = 150,
				random_height = gift_random_size.y,
				random_width = gift_random_size.x,
			}, -- Настройки для кучи
			start_position = gui.get_screen_position(self.nodes.detail_icon),
			value = 0
		})

	elseif id == "clear_characteristics" then
		-- Обрабатываем сброс очков
		storage_player.artifacts[id] = storage_player.artifacts[id] or 0
		if storage_player.artifacts[id] > 0 then
			storage_player.artifacts[id] = storage_player.artifacts[id] - 1
		end

		-- Зачисляем очки
		storage_player.characteristic_points = storage_player.characteristic_points or 0
		for k, value in pairs(storage_player.characteristics) do
			storage_player.characteristic_points = storage_player.characteristic_points + value
			storage_player.characteristics[k] = 0
		end

		local userdata = {
			characteristics = storage_player.characteristics,
			characteristic_points = storage_player.characteristic_points
		}

		data_handler.set_userdata(self, userdata, callback)

		msg.post("main:/loader_gui", "visible", {
			id = "catalog_characteristic",
			visible = true,
			type = hash("animated_close"),
		})
	end

	-- Анимация пульсирования смарткнопки
	if self.btn_smart then
		local delay = 2
		gui_animate.pulse_loop(self, self.nodes.btn_smart, delay)
	end

	local object_buy = game_content_artifact.get_item(id, player_id, is_game, is_reward)

	-- События в обучения
	if object_buy.count_shop < 1 then
		--Закончился товар
		msg.post("main:/core_study", "event", {
			id = "shop_no_product",
			item_id = id
		})

	elseif (object_buy.buy.buy_type == "reward" or (object_buy.disable_buy and object_buy.buy.error_id_string == "_no_gold")) and object_buy.buy.sell then
		--Закончились монеты
		msg.post("main:/core_study", "event", {
			id = "shop_no_gold",
			item_id = id
		})
	end

	for key, value in pairs(self.cards_id) do
		local item = self.cards_id[key]

		-- Обновляем каталог
		local object = game_content_artifact.get_item(key, player_id, is_game, is_reward)
		item.count_shop = object.count_shop
		item.count = object.count
		item.buy = object.buy
		item.disable_buy = object.disable_buy

		gui_catalog_type_shop.render_item_content(self, item)

	end

	gui_input.set_focus_id(self, id)
end

-- Покупка улучшения
function M.activate_upgrade(self, btn)
	msg.post("main:/core_player", "upgrade", {
		upgrade_id = btn.upgrade_id,
		upgrade_value = btn.next_upgrade,
		price = btn.price,
	})


	pprint({
		upgrade_id = btn.upgrade_id,
		upgrade_value = btn.next_upgrade,
		price = btn.price,
	})
end

-- Результат улучшения
function M.result_upgrade(self, upgrade_id, upgrade_value)
	msg.post("main:/sound", "play", {sound_id = "buy"})

	local id_item = upgrade_id .. "_" ..upgrade_value
	local id_prev_item = upgrade_id .. "_" ..(upgrade_value - 1)

	if self.cards_id[id_prev_item] then
		-- Меняем карточку на улучшение
		self.cards_id[id_prev_item].id = id_item
		self.cards_id[id_prev_item].id_object = id_item
		self.cards_id[id_item] = self.cards_id[id_prev_item]
		self.cards_id[id_prev_item] = nil

		--
		self.btns_id[id_prev_item].id = id_item
		self.btns_id[id_prev_item].id_object = id_item
		self.btns_id[id_item] = self.btns_id[id_prev_item]
		self.btns_id[id_prev_item] = nil
	end

	for key, value in pairs(self.cards_id) do
		local item = self.cards_id[key]
		local btn = self.btns_id[key]

		-- Обновляем каталог
		local object = game_content_artifact.get_item(key, player_id, is_game, is_reward)
		item.count_shop = object.count_shop
		item.count = object.count
		item.id = object.id
		item.score = object.score
		item.upgrade_price = object.upgrade_price
		item.description_mini_id_string = object.description_mini_id_string
		item.title_id_string = object.title_id_string
		item.description_id_string = object.description_id_string
		item.icon = object.icon
		item.value = object.value
		item.upgrade_price = object.upgrade_price
		item.price_buy = object.price_buy
		item.buy = object.buy
		item.disable_buy = object.disable_buy

		btn.id = item.id

		gui_catalog_type_shop.render_item_content(self, item)

	end

	gui_input.set_focus_id(self, id_item)
end

return M