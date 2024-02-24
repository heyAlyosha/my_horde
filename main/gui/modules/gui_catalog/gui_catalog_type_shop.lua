-- Отрисовка каталога типа инвентарь
local M = {}

local color = require("color-lib.color")
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local gui_input = require "main.gui.modules.gui_input"
local gui_size = require "main.gui.modules.gui_size"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"
local lang_core = require "main.lang.lang_core"
local storage_player = require "main.storage.storage_player"

-- Отрисовка контента в элементе
function M.render_item_content(self, item)
	local nodes = {
		wrap = item.nodes[hash("item_template/wrap")],
		title = item.nodes[hash("item_template/title")],
		description = item.nodes[hash("item_template/description")],
		icon = item.nodes[hash("item_template/icon")],
		purchased = item.nodes[hash("item_template/title_purchased")],
		count_shop = item.nodes[hash("item_template/count_shop")],
		price = item.nodes[hash("item_template/title_price")],
		icon_price = item.nodes[hash("item_template/icon_price")],
		btn_wrap = item.nodes[hash("item_template/btn_template/btn_wrap")],
		btn_title = item.nodes[hash("item_template/btn_template/btn_title")],
		count = item.nodes[hash("item_template/btn_template/btn_title")],
		error = item.nodes[hash("item_template/error")],
	}

	gui_lang.set_text_upper(self, nodes.title, item.title_id_string)
	gui_lang.set_text(self, nodes.count_shop, "_to_shop", before_str, ": "..item.count_shop)
	gui_loyouts.set_enabled(self, nodes.count_shop, not item.shop_infinite)
	--gui_loyouts.set_text(self, nodes.count_shop, item.count_shop)
	--gui_lang.set_text_formated(self, nodes.description, item.description_mini_id_string, before_str, after_str)
	gui_lang.set_text_upper(self, nodes.description, item.description_mini_id_string)
	gui_loyouts.play_flipbook(self, nodes.icon, item.icon)
	gui_loyouts.set_text(self, nodes.price, item.price_buy)
	gui_loyouts.play_flipbook(self, nodes.icon_price, "icon_gold")
	gui_loyouts.set_text(self, nodes.purchased, item.count)
	gui_loyouts.set_enabled(self, nodes.purchased, item.visible_count)
	gui_loyouts.set_color(self, nodes.price, color.white)

	if item.buy.buy_type == "buy" then
		gui_lang.set_text_upper(self, nodes.btn_title, "_buy", before_str, after_str)

	elseif item.buy.buy_type == "reward" then
		gui_loyouts.set_text(self, nodes.price, "1")
		gui_loyouts.play_flipbook(self, nodes.icon_price, "icon_reward")
		gui_lang.set_text_upper(self, nodes.btn_title, "_buy_reward", before_str, after_str)

	else
		gui_lang.set_text_upper(self, nodes.btn_title, "_buy", before_str, after_str)
	end

	-- Отрисовваем состояния
	local error_id_string = item.buy.error_id_string
	local disabled = item.disable_buy
	local btn_type = item.buy.buy_type
	

	--gui_loyouts.set_enabled(self, nodes.error, not item.disable_buy)
	if error_id_string == "_required_level_charisma" then
		gui_lang.set_text(self, nodes.error, error_id_string, before_str, " " .. item.level)
	else
		gui_lang.set_text(self, nodes.error, error_id_string, before_str, after_str)
	end

	if self.btns_id and self.btns_id[item.id]  then
		self.btns_id[item.id].is_sell_prize = false
		-- Если можно продать призы
		if (item.buy.buy_type == "reward" or (item.disable_buy and item.buy.error_id_string == "_no_gold")) and item.buy.sell then
			gui_lang.set_text(self, nodes.error, "_no_gold_sell_prizes")
			gui_loyouts.set_text(self, nodes.price, item.price_buy)
			gui_loyouts.set_color(self, nodes.price, color.red)
			gui_loyouts.play_flipbook(self, nodes.icon_price, "icon_gold")
			gui_input.set_disabled(self, self.btns_id[item.id], false)
			gui_lang.set_text_upper(self, nodes.btn_title, "ПРОДАТЬ", before_str, after_str)

			self.btns_id[item.id].is_sell_prize = true
			self.btns_id[item.id].is_buy = false
			return
		elseif item.disable_buy and item.buy.error_id_string == "_no_gold" then 
			gui_loyouts.set_color(self, nodes.price, color.red)
		end

		gui_input.set_disabled(self, self.btns_id[item.id], item.disable_buy)
	end
end

-- Отрисовка элемента
function M.render_item(self, item, coordinate, catalog_array, params)
	local clone_node = params.node_for_clone
	coordinate.end_x = coordinate.start_x + coordinate.width_card
	coordinate.end_y = coordinate.start_y

	if coordinate.end_x > coordinate.width_wrap then
		coordinate.start_x = 0
		coordinate.start_y = coordinate.start_y + coordinate.height_card
		coordinate.end_x = coordinate.width_card
		coordinate.cols = coordinate.cols + 1
	end

	item.cols = coordinate.cols
	item.nodes = gui.clone_tree(clone_node)

	local nodes = {
		wrap = item.nodes[hash("item_template/wrap")],
		title = item.nodes[hash("item_template/title")],
		description = item.nodes[hash("item_template/description")],
		icon = item.nodes[hash("item_template/icon")],
		purchased = item.nodes[hash("item_template/title_purchased")],
		count_shop = item.nodes[hash("item_template/count_shop")],
		price = item.nodes[hash("item_template/title_price")],
		btn_wrap = item.nodes[hash("item_template/btn_template/btn_wrap")],
		btn_title = item.nodes[hash("item_template/btn_template/btn_title")],
		count = item.nodes[hash("item_template/btn_template/btn_title")]
	}

	gui_loyouts.set_enabled(self, nodes.wrap, true)
	gui_loyouts.set_enabled(self, nodes.count_shop, true)
	gui_loyouts.set_position(self, nodes.wrap, vmath.vector3(coordinate.start_x, -coordinate.start_y, 1))

	M.render_item_content(self, item)

	coordinate.start_x = coordinate.end_x

	return coordinate
end

-- Отрисовка подробностей про предмет
function M.render_detail(self, item)
	if not item then
		gui_loyouts.set_enabled(self, self.nodes.wrap_detail, false)
	else
		gui_loyouts.set_enabled(self, self.nodes.wrap_detail, true)

		gui_lang.set_text_upper(self, self.nodes.detail_title, item.title_id_string, before_str, after_str)
		--gui_lang.set_text(self, self.nodes.detail_description, item.description_id_string, before_str, after_str)

		local text = lang_core.get_text(self, item.description_id_string, before_str, after_str, values) .. " " .. lang_core.get_text(self, item.description_mini_id_string, before_str, after_str, values)
		self.druid:new_text(self.nodes.detail_description, utf8.upper(text))
		--gui_loyouts.set_druid_text(self, self.nodes.detail_description, text)

		-- Ставим картинку
		gui_size.play_flipbook_ratio(self, self.nodes.detail_icon, self.nodes.detail_icon_size, item.icon, 150, 150)

		live_update_atlas.render(self, "objects_full", function (self, atlas_id)
			gui_loyouts.set_texture(self, self.nodes.detail_icon, "objects_full")
			gui_size.play_flipbook_ratio(self, self.nodes.detail_icon, self.nodes.detail_icon_size, item.icon, 150, 150)
		end)
	end
end

return M