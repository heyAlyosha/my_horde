-- Модуль отрисовки и управление каталогом с превьюшкой.
local M = {}

local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local color = require("color-lib.color")
local api_player = require "main.game.api.api_player"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"
local gui_size = require "main.gui.modules.gui_size"

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

-- Показ или скрытие лоадера загрузки
function M.loader_visible(visible, node_body)
	local node_wrap = gui.get_node("loader_template/loader_wrap")
	local node_icon = gui.get_node("loader_template/loader_icon")
	local node_body = node_body or gui.get_node("catalog_content") 

	gui.set_enabled(node_wrap, visible)
	gui.set_enabled(node_body, not visible)
	gui.cancel_animation(node_icon, "rotation.z")

	if visible then
		gui.animate(node_icon, "rotation.z", 360, gui.EASING_LINEAR, 3, 0, nil, gui.PLAYBACK_LOOP_FORWARD)
	end
end

function M.update_catalog(self, catalog_array, score_current)
	local score_current = score_current or self.score
	for i, item in ipairs(catalog_array) do

		local to_you = lang_core.get_text(self, "_at_you", before_str, ": " .. item.count, values)
		gui.set_text(item.nodes[hash("item_template/title_purchased")], utf8.upper(to_you))
		if item.count  < 1 then
			gui.set_color(item.nodes[hash("item_template/title_purchased")], color.red)
		else
			gui.set_color(item.nodes[hash("item_template/title_purchased")], color.white)
		end

		local btn_title = lang_core.get_text(self, "_buy", before_str, after_str, values)
		gui.set_text(item.nodes[hash("item_template/btn_template/btn_title")], utf8.upper(btn_title))

		catalog_array[i].is_buy = score_current >= item.price_buy
		local btn = self.btns[i + 1]

		btn.is_buy = catalog_array[i].is_buy

		if catalog_array[i].is_buy or catalog_array[i].id == "close" then
			gui.set_alpha(item.nodes[hash("item_template/wrap")], 1)
			gui.set_color(item.nodes[hash("item_template/title_price")], color.white)
			self.btns[i + 1].icon = "button_default_green_"
		else
			gui.set_alpha(item.nodes[hash("item_template/wrap")], 0.5)
			gui.set_color(item.nodes[hash("item_template/title_price")], color.red)
			self.btns[i + 1].icon = "button_default_yellow_"
		end

		if self.focus_btn_id and self.focus_btn_id == i + 1 then
			gui.play_flipbook(btn.node, btn.icon .. "focus")
		else
			gui.play_flipbook(btn.node, btn.icon .. "default")
		end
	end
	

	-- Отрисовываем баланс
	gui_loyouts.set_text(self, self.nodes.balance_number, self.score)

end

-- Скроллинг до элемента доступного для покупок
function M.scroll_to_buy(self, id, catalog)
	for i, item in ipairs(catalog) do
		if item.is_buy then
			local pos = gui.get_position(item.nodes[hash("item_template/wrap")])
			pos.y = pos.y + 200

			self["scroll_"..id]:scroll_to(pos)

			return i, item
		end
	end

	

end

function M.create_catalog(self, id, catalog_array, params)
	local margin = params.margin
	local width_wrap = gui.get_size(params.node_catalog_content).x
	local height_wrap = 0

	local width_card = gui.get_size(params.node_for_clone).x * gui.get_scale(params.node_for_clone).x + margin
	local height_card = gui.get_size(params.node_for_clone).y * gui.get_scale(params.node_for_clone).y + margin

	local start_x,start_y,end_x,end_y = 0, 0, 0, 0
	local cols = 1
	local prev_complete = false

	local progress = api_player.get_levels_progress(self, id)
	

	gui.set_enabled(params.node_for_clone, false)

	for i, item in ipairs(catalog_array) do
		local clone_node = params.node_for_clone
		end_x = start_x + width_card
		end_y = start_y

		if end_x > width_wrap then
			start_x = 0
			start_y = start_y + height_card
			end_x = width_card
			cols = cols + 1
		end

		item.cols = cols
		item.nodes = gui.clone_tree(clone_node)

		local nodes = {
			wrap = item.nodes[hash("item_template/wrap")],
			title = item.nodes[hash("item_template/title")],
			icon = item.nodes[hash("item_template/icon")],
			icon_size = item.nodes[hash("item_template/icon_size")],
			loader_img = item.nodes[hash("item_template/loader_icon_template/loader_icon")],
			purchased = item.nodes[hash("item_template/title_purchased")],
			price = item.nodes[hash("item_template/title_price")],
			btn_wrap = item.nodes[hash("item_template/btn_template/btn_wrap")],
			btn_title = item.nodes[hash("item_template/btn_template/btn_title")],
			count = item.nodes[hash("item_template/btn_template/btn_title")]
		}

		gui.set_enabled(nodes.wrap, true)
		gui.set_position(nodes.wrap, vmath.vector3(start_x, -start_y, 1))

		local title = lang_core.get_text(self, item.title_id_string, before_str, after_str, values)
		gui.set_text(nodes.title, utf8.upper(title))

		local node_img = nodes.icon
		local node_loader = nodes.loader_img
		local atlas_id = "prizes_mini"
		live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
			gui.set_texture(nodes.icon, atlas_id)

			local not_loyouts = true
			local node_wrap = nodes.icon_size
			gui_size.play_flipbook_ratio(self, nodes.icon, node_wrap, item.icon, width, height, not_loyouts)
		end)
		
		gui.set_text(nodes.price, item.price_buy)
		gui.set_text(nodes.purchased, "У ВАС: " .. item.count)

		start_x = end_x

		-- Отрисовываем прогресс в уровнях
		catalog_array[i].complete = progress["level_"..item.id]
	end

	

	local height_content = cols * (height_card + margin)
	height_content = height_content

	gui.set_size(params.node_catalog_content, vmath.vector3(gui.get_position(params.node_catalog_content).x, height_content, 0))
	--gui.animate(params.node_catalog_view, "size.y", height_content, gui.EASING_LINEAR, 0)

	
	self["scroll_"..id] = self.druid:new_scroll(params.node_catalog_input, params.node_catalog_content)
	self["scroll_"..id]:set_horizontal_scroll(false)

	local height_scroll_line = gui.get_size(params.node_scroll_wrap).y - gui.get_size(params.node_scroll_caret).y 

	self["scroll_"..id].on_scroll:subscribe(function(_, point)
		msg.post("main:/loader_gui", "visible", {
			id = "study",
			visible = false
		})
		-- Получение текущего скролла
		self["current_point_scroll_"..id..""] = point.y

		local percent = point.y / height_content
		local caret_position =  -height_scroll_line *  (1 - self["scroll_"..id]:get_percent().y)

		-- Передвигаем каретку
		if caret_position > -2 then
			caret_position = -2
		elseif (caret_position) < -(height_scroll_line - gui.get_size(params.node_scroll_caret).y + 2) then
			caret_position = caret_position + 7
		end

		gui.animate(params.node_scroll_caret, "position.y", caret_position, gui.EASING_LINEAR, 0.1)
		--gui.set_position(params.node_scroll_caret, vmath.vector3(gui.get_position(params.node_scroll_caret).x, caret_position, 1))

		msg.post("main:/core_study", "event", {
			type = "scroll", from_id = self.id
		})
	end)
	self["scroll_"..id]:scroll_to(vmath.vector3(0, 0, 0), true)

	

	return catalog_array
end

function M.catalog_input(self, id, action_id, action, function_activate, function_back)
	if self.focus_btn_id == 1 and action_id == hash("up") and action.pressed then
		msg.post(storage_gui.components_visible[hash("interface")], "focus", {focus = 1})
	end

	local function function_post_focus(self, index, btn)
		if btn.is_card then
			-- Находим
			local height_card = gui.get_size(self.nodes.node_for_clone).y
			local height_view_content = gui.get_size(self.nodes.catalog_content).y

			local center_card = gui.get_position(btn.wrap_node).y + height_view_content/2 + height_card / 2
			local center_view = center_card - height_view_content/2

			self["scroll_"..id]:scroll_to(vmath.vector3(0, center_view, 0), false)
		end
	end

	return gui_input.on_input(self, action_id, action, function_focus, function_activate, function_back, function_post_focus)
end

return M