-- Функции 
local M = {}

local gui_animate = require "main.gui.modules.gui_animate" 
local gui_catalog = require "main.gui.modules.gui_catalog"
local gui_input = require "main.gui.modules.gui_input"
local gui_loader = require "main.gui.modules.gui_loader"
local game_content_prize = require "main.game.content.game_content_prize"
local gui_catalog_type_inventary = require "main.gui.modules.gui_catalog.gui_catalog_type_inventary"
local sound_render = require "main.sound.modules.sound_render"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"

-- Отрисовка катлаога
function M.render_catalog(self)
	gui_loader.visible(true, node_wrap, node_icon, node_body, self)
	gui_catalog.catalog_empty(self, "inventary", false)

	local items = game_content_prize.get_catalog_prizes(self, is_magazine)
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
		for i, node in pairs(item.nodes) do
			gui.delete_node(node)
		end
		
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
			id_object = item.id,
			is_card = true,
			scroll = self["scroll_"..self.id_catalog],
			on_set_function = function (self, btn, focus)
				if focus then
					local card = self.cards_id[btn.id]
					gui_catalog_type_inventary.render_detail(self, card)
				end
				
				--[[
				if focus then
					msg.post("/loader_gui", "set_status", {
						id = "inventary_detail",
						type_object = "prize",
						type = "set_object",
						id_object = btn.id_object
					})
					local card = self.cards_id[btn.id]

					local node_wrap = card.nodes[hash("item_template/wrap")]
					--self["scroll_"..self.id_catalog]:scroll_to(vmath.vector3(0, gui.get_position(node_wrap).y, 0))
				end
				--]]
			end,
		}

		self.btns_id[item.id] = btn
		self.cards_id[item.id] = item

		table.insert(self.btns, btn)
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

	if #self.cards <= 0 then
		gui_catalog_type_inventary.render_detail(self, false)
	end
	gui_catalog.catalog_empty(self, self.type, #self.cards <= 0)
	gui_loader.visible(false, node_wrap, node_icon, node_body, self)
end

function M.result_sell(self, prize)
	-- Если только изменилось количество
	local card = self.cards_id[prize.id]
	gui.set_text(card.nodes[hash("item_template/title_purchased")], prize.count)

	-- Анимация пульсирования смарткнопки
	if self.btn_smart then
		local delay = 2
		gui_animate.pulse_loop(self, self.nodes.btn_smart, delay)
	end

	if prize.count <= 0 then
		-- Если этот приз закончился
		local btn = self.btns_id[prize.id]
		local disable = true
		gui_input.set_disabled(self, btn, disable)

		-- Находим слудующуую кнопку
		local next_focus_btn_i 
		for i, btn in ipairs(self.btns) do
			if btn.id == prize.id then
				next_focus_btn_i = i + 1
				break
			end
		end

		if next_focus_btn_i and self.btns[next_focus_btn_i] then
			-- Если есть следующий, наводим фокус на него
			gui_input.set_focus(self, next_focus_btn_i)
			local node = self.btns[next_focus_btn_i].node_wrap or self.btns[next_focus_btn_i].node
			self["scroll_"..self.id_catalog]:scroll_to(vmath.vector3(0, gui.get_position(node).y, 0))

		elseif next_focus_btn_i and not self.btns[next_focus_btn_i] then
			-- Если нет следующего , наводим фокус на предыдущий
			next_focus_btn_i = next_focus_btn_i - 1
			gui_input.set_focus(self, next_focus_btn_i)
			local node = self.btns[next_focus_btn_i].node_wrap or self.btns[next_focus_btn_i].node
			self["scroll_"..self.id_catalog]:scroll_to(vmath.vector3(0, gui.get_position(node).y, 0))

		end
	end
end

-- Функция продажи
function M.sell(self, id, type)
	local type = "prize"

	msg.post("main:/core_study", "event", {
		type = "activate_btn",
		from_id = self.id
	})

	if type == "prize" then
		self.content = game_content_prize.get_prize(id)

		-- Анимация уменьшения
		self.scale_prize = gui.get_scale(self.nodes.detail_icon)
		gui.animate(self.nodes.detail_icon, "scale", vmath.vector3(0), gui.EASING_INOUTBACK, 0.25, 0, function (self)
			sound_render.play("sell")
			msg.post("main:/core_player", "sell", {
				type = "prize",
				count = 1,
				id = id,
			})
		end)
	end
end

-- Успешная продажа в подробном описании приза
function M.result_sell_detail(self, status, object, type_object, coins, score, inventary_detail_function)
	if status == "error" then
		-- Если ошибка при продаже
		inventary_detail_function.render(self, "prize", self.content.id)

		return false

	elseif status == "success" then
		-- Выпадение кучи монеток и опыта
		local end_position = gui.get_screen_position(self.nodes.detail_gift)
		local gift_random_size =  gui.get_size(self.nodes.detail_gift)

		msg.post("main:/loader_gui", "set_status", {
			id = "add_balance",
			type = "stack", -- Обычный перелёт или куча
			setting_stack ={
				score = score,
				coins = coins,
				end_position = end_position,
				height_flight = 150,
				random_height = gift_random_size.y,
				random_width = gift_random_size.x,
			}, -- Настройки для кучи
			start_position = gui.get_screen_position(self.nodes.detail_icon),
			value = 0
		})

		gui.set_scale(self.nodes.detail_icon, self.scale_prize)

	end
end



return M