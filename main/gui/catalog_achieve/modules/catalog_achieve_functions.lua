-- Функции 
local M = {}

local gui_catalog = require "main.gui.modules.gui_catalog"
local gui_input = require "main.gui.modules.gui_input"
local gui_loader = require "main.gui.modules.gui_loader"

local core_achieve_functions = require "main.core.core_achieve.modules.core_achieve_functions"

-- Отрисовка катлаога
function M.render_catalog(self)
	gui_loader.visible(true, node_wrap, node_icon, node_body, self)
	gui_catalog.catalog_empty(self, "achieve", false)

	local items = game_content_achieve.get_catalog(self, core_achieve_functions)
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

	for i = 1, #self.cards do
		local item = self.cards[i]

		local btn = {
			id = item.id, 
			type = "btn", 
			section = "card_"..item.cols, 
			node = item.nodes[hash("item_template/wrap")],
			node_title = item.nodes[hash("item_template/btn_template/btn_title")],
			scroll = self["scroll_"..self.id_catalog],
			icon = "bg_modal_",
			-- Смотрим заблокирован ли уровень для покупки
			is_card = true,
			on_set_function = function (self, btn, focus)
				if focus then
					msg.post("/loader_gui", "set_status", {
						id = "inventary_detail",
						type_object = "achieve",
						type = "set_object",
						id_object = item.id
					})
					local card = self.cards_id[btn.id]

					local node_wrap = card.nodes[hash("item_template/wrap")]
					--self["scroll_"..self.id_catalog]:scroll_to(vmath.vector3(0, gui.get_position(node_wrap).y, 0))
				end
			end,
		}

		self.btns_id[item.id] = btn
		self.cards_id[item.id] = item

		table.insert(self.btns, btn)
	end

	gui_input.render_btns(self, self.btns)
	gui_catalog.catalog_empty(self, self.type, #self.cards <= 0)
	gui_loader.visible(false, node_wrap, node_icon, node_body, self)
end

function M.result_buy(self, object)
	-- обновляем каталог
	local focus_last  = self.focus_btn_id or 1

	M.render_catalog(self)

	gui_input.set_focus(self, nil)
	gui_input.set_focus(self, focus_last)
end



return M