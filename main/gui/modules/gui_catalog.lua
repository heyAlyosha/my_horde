-- Модуль отрисовки и управление каталогом
local M = {}

local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local color = require("color-lib.color")
local sound_render = require "main.sound.modules.sound_render"
local api_player = require "main.game.api.api_player"
local gui_catalog_type_inventary = require "main.gui.modules.gui_catalog.gui_catalog_type_inventary"
local gui_catalog_type_shop = require "main.gui.modules.gui_catalog.gui_catalog_type_shop"
local gui_catalog_type_achieve = require "main.gui.modules.gui_catalog.gui_catalog_type_achieve"
local gui_catalog_type_buff_horisontal = require "main.gui.modules.gui_catalog.gui_catalog_type_buff_horisontal"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"

--[[
params = {
	margin = 15,
	node_for_clone = gui.get_node(),
	node_catalog_view = gui.get_node(),
	node_catalog_input = gui.get_node(),
	node_catalog_content = gui.get_node(),
	node_scroll = gui.get_node(),
	node_scroll_wrap = gui.get_node(),
	node_scroll_caret = gui.get_node(),
}
]]--

function M.create_catalog(self, id, catalog_array, type_catalog, params)
	local margin = params.margin
	local orientation = params.orientation or "vertical"
	local width_wrap = gui.get_size(params.node_catalog_content).x
	local height_wrap = 0

	local width_card = gui.get_size(params.node_for_clone).x * gui.get_scale(params.node_for_clone).x + margin
	local height_card = gui.get_size(params.node_for_clone).y * gui.get_scale(params.node_for_clone).y + margin

	local start_x,start_y,end_x,end_y = 0, 0, 0, 0
	local cols = 1
	local prev_complete = false

	local progress = api_player.get_levels_progress(self, id)

	gui.set_enabled(params.node_for_clone, false)

	if type_catalog == "buff_horisontal" then
		start_x = gui.get_position(params.node_for_clone).x
		start_y = gui.get_position(params.node_for_clone).y
	end

	for i, item in ipairs(catalog_array) do
		local coordinate = {
			start_x = start_x, start_y = start_y, end_x = end_x, end_y = end_y, 
			width_card = width_card, height_card = height_card, cols = cols, 
			width_wrap = width_wrap, height_wrap = height_wrap
		}

		if type_catalog == "inventary" then
			coordinate = gui_catalog_type_inventary.render_item(self, item, coordinate, catalog_array, params)

		elseif type_catalog == "shop" then
			coordinate = gui_catalog_type_shop.render_item(self, item, coordinate, catalog_array, params)

		elseif type_catalog == "achieve" then
			coordinate = gui_catalog_type_achieve.render_item(self, item, coordinate, catalog_array, params)

		elseif type_catalog == "buff_horisontal" then
			coordinate = gui_catalog_type_buff_horisontal.render_item(self, item, coordinate, catalog_array, params)
		
		end

		start_x = coordinate.start_x
		start_y = coordinate.start_y
		end_x = coordinate.end_x
		end_y = coordinate.end_y
		width_card = coordinate.width_card
		height_card = coordinate.height_card
		cols = coordinate.cols
	end

	--gui.animate(params.node_catalog_view, "size.y", height_content, gui.EASING_LINEAR, 0)

	local height_content

	if orientation == "vertical" then
		height_content = cols * (height_card + margin)
		-- Отступ
		height_content = height_content + 50 
		gui.set_size(params.node_catalog_content, vmath.vector3(gui.get_size(params.node_catalog_content).x, height_content, 0))

		self["scroll_"..id] = self.druid:new_scroll(params.node_catalog_input, params.node_catalog_content)
		self["scroll_"..id]:scroll_to(vmath.vector3(0, 0, 0), true)

		self["scroll_"..id]:set_horizontal_scroll(false)
	else
		self["scroll_"..id] = self.druid:new_scroll(params.node_catalog_input, params.node_catalog_content)
		self["scroll_"..id]:set_vertical_scroll(false)
	end

	if params.node_scroll_wrap then
		
		local height_scroll_line = gui.get_size(params.node_scroll_wrap).y - gui.get_size(params.node_scroll_caret).y 

		self["scroll_"..id].on_scroll:subscribe(function(_, point)
			-- Получение текущего скролла
			self["current_point_scroll_"..id..""] = point.y

			if not height_content then
				height_content = cols * (height_card + margin)
			end
			

			local percent = point.y / height_content
			local caret_position =  -height_scroll_line *  (1 - self["scroll_"..id]:get_percent().y)

			-- Передвигаем каретку
			if caret_position > -2 then
				caret_position = -2
			elseif (caret_position) < -(height_scroll_line - gui.get_size(params.node_scroll_caret).y + 2) then
				caret_position = caret_position + 7
			end

			msg.post("main:/core_study", "event", {
				type = "scroll", from_id = self.id
			})

			gui.animate(params.node_scroll_caret, "position.y", caret_position, gui.EASING_LINEAR, 0.1)
			--gui.set_position(params.node_scroll_caret, vmath.vector3(gui.get_position(params.node_scroll_caret).x, caret_position, 1))
		end)
	end

	height_content = cols * (height_card + margin)

	return catalog_array
end

function M.catalog_input(self, id, action_id, action, type_catalog, function_activate, function_back)
	if self.focus_btn_id and action_id == hash("up") and action.pressed then
		local btn = self.btns[self.focus_btn_id]
		--msg.post(storage_gui.components_visible[hash("interface")], "focus", {focus = 1})
		if not self.modal then
			if btn.section == "card_1" then
				msg.post("main:/loader_gui", "focus", {
					id = "inventary_wrap", -- id компонента в лоадер гуи
					focus = 1 -- кнопка фокуса
				})

				sound_render.play("focus_main_menu")
				return true
			end
		end
	end

	local function function_post_focus(self, index, btn)
		-- Находим
		local height_card = gui.get_size(self.nodes.node_for_clone).y
		local height_view_content = gui.get_size(self.nodes.catalog_content).y

		local card = self.cards_id[btn.id]

		if card then
			local center_card = gui.get_position(card.nodes[hash("item_template/wrap")]).y + height_view_content/2 + height_card / 2
			local center_view = center_card - height_view_content / 2
			if center_view > 0 then center_view = 0 end

			self["scroll_"..id]:scroll_to(vmath.vector3(0, center_view, 0), false)
		end
	end

	return gui_input.on_input(self, action_id, action, function_focus, function_activate, function_back, function_post_focus)
end

-- Если пустой каталог
function M.catalog_empty(self, type, visible, node_text, node_wrap)
	local node_text = node_text or gui.get_node("text_empty_catalog")
	local node_wrap = node_wrap or gui.get_node("catalog_stencil")

	gui.set_enabled(node_text, visible)
	gui.set_enabled(node_wrap, not visible)

	msg.post("/loader_gui", "visible", {
		id = "inventary_detail",
		visible = false,
	})
end

return M