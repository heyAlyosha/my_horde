-- Отрисовка каталога типа инвентарь
local M = {}

local gui_lang = require "main.lang.gui_lang"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"
local gui_size = require "main.gui.modules.gui_size"
local lang_core = require "main.lang.lang_core"
local gui_loyouts = require "main.gui.modules.gui_loyouts"

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
		price = item.nodes[hash("item_template/title_price")],
		btn_wrap = item.nodes[hash("item_template/btn_template/btn_wrap")],
		btn_title = item.nodes[hash("item_template/btn_template/btn_title")],
		count = item.nodes[hash("item_template/btn_template/btn_title")],
		loader = item.nodes[hash("item_template/loader_icon_template/loader_icon")],
		wrap_size = item.nodes[hash("item_template/wrap_size")],
	}

	gui.set_enabled(nodes.wrap, true)
	gui.set_position(nodes.wrap, vmath.vector3(coordinate.start_x, -coordinate.start_y, 1))
	local title = lang_core.get_text(self, item.title_id_string, before_str, after_str, values)
	self.druid:new_text(nodes.title, utf8.upper(title))
	--gui_lang.set_text_upper(self, nodes.title, item.title_id_string)

	local node_img = nodes.icon
	local node_loader = nodes.loader
	local atlas_id = "prizes_mini"

	live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
		gui.set_texture(nodes.icon, atlas_id)

		local not_loyouts = true
		local node = nodes.icon
		local node_wrap = nodes.wrap_size
		local animation = item.icon
		gui_size.play_flipbook_ratio(self, node, node_wrap, animation, width, height, not_loyouts)
	end)

	gui.set_text(nodes.price, item.price_sell)
	gui.set_text(nodes.purchased, item.count)

	coordinate.start_x = coordinate.end_x

	if item.count < 1 then
		gui.set_alpha(nodes.wrap, 0.5)
	end

	return coordinate
end

-- Отрисовка подробностей про предмет
function M.render_detail(self, item)
	if not item then
		gui_loyouts.set_enabled(self, self.nodes.wrap_detail, false)

	else
		gui_loyouts.set_enabled(self, self.nodes.wrap_detail, true)

		local text = lang_core.get_text(self, item.title_id_string, before_str, after_str, values)
		self.druid:new_text(self.nodes.detail_title, utf8.upper(text))
		--gui_lang.set_text_upper(self, self.nodes.detail_title, item.title_id_string, before_str, after_str)
		
		
		local text = lang_core.get_text(self, item.description_id_string, before_str, after_str, values)
		self.druid:new_text(self.nodes.detail_description, utf8.upper(text))
		--gui_loyouts.set_druid_text(self, self.nodes.detail_description, text)
		--gui_lang.set_text(self, self.nodes.detail_description, item.description_id_string, before_str, after_str)

		-- Ставим картинку
		if item.icon then
			local node_img = self.nodes.detail_icon
			local node_loader = self.nodes.detail_loader
			local atlas_id = "prizes_mini"

			gui_loyouts.set_enabled(self, node_img, false)
			live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
				gui_loyouts.set_enabled(self, node_img, true)
				gui_loyouts.set_texture(self, self.nodes.detail_icon, atlas_id)
				gui_size.play_flipbook_ratio(self, self.nodes.detail_icon, self.nodes.detail_icon_size, item.icon, 150, 150)
			end)
		end

	end
end

return M