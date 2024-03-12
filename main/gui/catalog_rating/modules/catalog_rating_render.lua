-- Функции отрисовки рейтинга
local M = {}

local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local color = require("color-lib.color")
local gui_size = require "main.gui.modules.gui_size"
local gui_animate = require "main.gui.modules.gui_animate"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

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

function M.update_catalog(self, catalog_array, score_current)
	local score_current = score_current or 900
	for i, item in ipairs(catalog_array) do
		gui.set_text(item.nodes[hash("item_template/title_purchased")], "У ВАС: " .. item.count)
		if item.count  < 1 then
			gui.set_color(item.nodes[hash("item_template/title_purchased")], color.red)
		else
			gui.set_color(item.nodes[hash("item_template/title_purchased")], color.white)
		end

		catalog_array[i].is_buy = score_current >= item.price_buy
		local btn = self.btns[i + 1]

		if catalog_array[i].is_buy then
			gui.set_alpha(item.nodes[hash("item_template/wrap")], 1)
			gui.set_color(item.nodes[hash("item_template/title_price")], color.white)
			self.btns[i + 1].icon = "btn_ellipse_green_"
		else
			gui.set_alpha(item.nodes[hash("item_template/wrap")], 0.5)
			gui.set_color(item.nodes[hash("item_template/title_price")], color.red)
			self.btns[i + 1].icon = "btn_ellipse_orange_"
		end

		if self.focus_btn_id and self.focus_btn_id == i + 1 then
			gui.play_flipbook(btn.node, btn.icon .. "focus")
		else
			gui.play_flipbook(btn.node, btn.icon .. "default")
		end
	end
end

-- Скроллинг до игрока
function M.scroll_to_user(self, id, catalog)
	local node_wrap_input = gui.get_node("catalog_input")
	local node_item = gui.get_node("item_template/wrap")
	local node_wrap_size = gui.get_size(node_wrap_input)
	for i, item in ipairs(catalog) do
		if item.is_user then
			local pos = gui.get_position(item.nodes[hash("item_template/wrap")])
			
			pos.y = pos.y + node_wrap_size.y / 2  - gui.get_size(node_item).y / 2

			self["scroll_"..id]:scroll_to(pos, true)

			return i, item
		end
	end
end

-- Скроллинг до элемента по индеку
function M.scroll_to_index(self, index, not_animate, catalog_id)
	local not_animate = not_animate or false
	local catalog_id = catalog_id or self.id_catalog
	local node_wrap_input = gui.get_node("catalog_input")
	local node_item = gui.get_node("item_template/wrap")
	local node_wrap_size = gui.get_size(node_wrap_input)
	local item = self.cards[index]

	local pos = gui.get_position(item.nodes[hash("item_template/wrap")])
	pos.y = pos.y + node_wrap_size.y / 2  - gui.get_size(node_item).y / 2

	self["scroll_"..catalog_id]:scroll_to(pos, not_animate)
	return true
end

function M.render_title_and_icon(self, item, nodes)
	local nodes = nodes or {
		wrap = item.nodes[hash("item_template/wrap")],
		wrap_content = item.nodes[hash("item_template/wrap-content")],
		title = item.nodes[hash("item_template/title")],
		ranks = item.nodes[hash("item_template/ranks")],
		icon = item.nodes[hash("item_template/avatar_img")],
		icon_trofey = item.nodes[hash("item_template/icon_trofey")],
		price = item.nodes[hash("item_template/title_price")],
	}

	-- Отрисовываем трофеи и игрока
	if item.rank >= 0  and item.rank <= 3 then
		if item.rank == 0 then
			item.rank = 1
		end

		-- Первые места
		gui.play_flipbook(nodes.icon_trofey, "icon_rating_" .. item.rank)
		if item.is_user then
			gui.set_text(nodes.title, "("..lang_core.get_text(self, "_you")..") " .. item.name)
		else
			gui.set_text(nodes.title, item.name)
		end

	elseif item.is_user then
		-- Игрок
		--gui.play_flipbook(nodes.icon_trofey, "account_anonim")
		gui.play_flipbook(nodes.icon_trofey, "btn_circle_bg_green_default")
		gui.set_text(nodes.title, "("..lang_core.get_text(self, "_you")..") " .. item.name)

	else
		-- Обычный игроки
		gui.set_enabled(nodes.icon_trofey, false)
		local position_title = gui.get_position(nodes.title)
		
		position_title.x = 200 - (gui.get_size(nodes.icon_trofey).x + 30)
		gui.set_position(nodes.title, position_title)
		gui.set_text(nodes.title, item.name)
	end

	local size_tab = gui_size.get_size_gui_text(nodes.ranks).width

	-- Выставляем позицию имени игрока в карточке в зависимости от величины блока с местом
	local position_title = gui.get_position(nodes.wrap_content)
	position_title.x = size_tab + 30 - gui.get_size(nodes.wrap).x /2
	gui.set_position(nodes.wrap_content, position_title)
end

function M.render_item(self, item)
	local nodes = {
		wrap = item.nodes[hash("item_template/wrap")],
		wrap_content = item.nodes[hash("item_template/wrap-content")],
		title = item.nodes[hash("item_template/title")],
		ranks = item.nodes[hash("item_template/ranks")],
		icon = item.nodes[hash("item_template/avatar_img")],
		icon_trofey = item.nodes[hash("item_template/icon_trofey")],
		price = item.nodes[hash("item_template/title_price")],
	}


	gui.set_position(nodes.wrap, vmath.vector3(item.start_x, -item.start_y, 1))
	gui.set_text(nodes.price, item.score)
	gui.set_text(nodes.ranks, item.rank)
	gui.play_flipbook(nodes.icon, "account_anonim")

	M.render_title_and_icon(self, item, nodes)
end

function M.create_catalog(self, id, catalog_array, params)
	M.clear_catalog(self)

	local margin = params.margin
	local width_wrap = gui.get_size(params.node_catalog_content).x
	local height_wrap = 0

	local width_card = gui.get_size(params.node_for_clone).x * gui.get_scale(params.node_for_clone).x + margin
	local height_card = gui.get_size(params.node_for_clone).y * gui.get_scale(params.node_for_clone).y + margin

	local start_x, start_y, end_x, end_y = 0, 0, 0, 0
	local cols = 1
	local prev_complete = false

	local params = params or {}
	params.not_render = params.not_render or {}

	-- Cобираем id, которые не надо отрисовывать
	local not_render = {}
	for i = 1, #params.not_render do
		not_render[params.not_render[i]] = true
	end

	gui.set_enabled(params.node_for_clone, false)

	for i, item in ipairs(catalog_array) do
		local clone_node = params.node_for_clone
		end_x = start_x + width_card
		end_y = start_y

		item.nodes = gui.clone_tree(clone_node)

		local nodes = {
			wrap = item.nodes[hash("item_template/wrap")],
			wrap_content = item.nodes[hash("item_template/wrap-content")],
			title = item.nodes[hash("item_template/title")],
			ranks = item.nodes[hash("item_template/ranks")],
			icon = item.nodes[hash("item_template/avatar_img")],
			icon_trofey = item.nodes[hash("item_template/icon_trofey")],
			price = item.nodes[hash("item_template/title_price")],
		}

		gui.set_enabled(nodes.wrap, true)

		if not_render[i] then
			gui.set_enabled(nodes.wrap, false)
		end

		if i == 1 and not not_render[i] then
			-- Если это первый элемент
			start_x = 10 + width_card / 2
			start_y = height_card / 2
			cols = cols + 1

		elseif end_x > width_wrap and not not_render[i] then
			-- Если это последний
			start_x = 10 + width_card / 2
			start_y = start_y + height_card
			end_x = width_card
			cols = cols + 1
		else
			
		end

		item.cols = cols
		item.start_x = start_x
		item.start_y = start_y

		M.render_item(self, item)
		
		start_x = end_x
	end

	local height_content = cols * (height_card + margin)

	gui.set_size(params.node_catalog_content, vmath.vector3(gui.get_position(params.node_catalog_content).x, height_content, 0))
	--gui.animate(params.node_catalog_view, "size.y", height_content, gui.EASING_LINEAR, 0)

	self["scroll_"..id] = self.druid:new_scroll(params.node_catalog_input, params.node_catalog_content)
	self["scroll_"..id]:set_horizontal_scroll(false)

	local height_scroll_line = gui.get_size(params.node_scroll_wrap).y - gui.get_size(params.node_scroll_caret).y 

	self["scroll_"..id].on_scroll:subscribe(function(_, point)
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

		if point.y < 0 then
			self["scroll_"..id]:scroll_to(vmath.vector3(0, 0, 0), true)
		end
	end)
	self["scroll_"..id]:scroll_to(vmath.vector3(0, 0, 0), true)

	

	return catalog_array
end

-- Очистка каталога
function M.clear_catalog(self)
	
	self.cards = self.cards or {}

	-- ОЧищаем карточки и ноды
	for i = #self.cards, 1, -1 do
		local item = self.cards[i]
		for k, node in pairs(item.nodes) do
			gui.delete_node(node)
		end
		--gui.delete_node(item.nodes[hash("item_template/wrap")])

		self.cards[i] = nil
	end

	-- Ооищаем кнопки
	for i = #self.btns, 1, -1 do
		local btn = self.btns[i]
		if btn.is_item then
			self.btns[i] = nil
		end
	end
end

function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = "catalog_rating",
			visible = false,
		})
	end)
end

function M.catalog_input(self, id, action_id, action, function_activate)
	if self.focus_btn_id == 1 and action_id == hash("up") and action.pressed and not self.is_modal then
		msg.post(storage_gui.components_visible[hash("interface")], "focus", {focus = 1})
	end

	-- Пролистывание к текущему игроку, если он есть
	if 
		(self.focus_btn_id == 2 or 
		self.focus_btn_id == 3 or
		self.focus_btn_id == 4) and 
		action_id == hash("down") and self.user_i 
	then
		gui_input.set_focus(self, self.user_i + 4)
		self.user_i = nil
		return true
	end

	local function function_post_focus(self, index, btn)
		if btn.is_card then
			-- Находим
			local height_card = gui.get_size(self.nodes.node_for_clone).y
			local height_view_content = gui.get_size(self.nodes.catalog_view).y

			--local center_card = gui.get_position(btn.wrap_node).y +  height_view_content/2 + height_card * 2
			--local center_view = center_card - height_view_content/2
			local center_view = gui.get_position(btn.wrap_node).y +  height_view_content/2

			if action_id then
				self["scroll_"..id]:scroll_to(vmath.vector3(0, center_view, 0), false)
			end
		end
	end

	if gui_input.on_input(self, action_id, action, function_focus, function_activate, M.hidden, function_post_focus) then
		return true
	end
end

-- Ошибка
function M.error(self, err)
	gui_loyouts.set_enabled(self, self.nodes.loader_wrap, true)
	gui_loyouts.set_enabled(self, self.nodes.loader_icon, false)
	gui_loyouts.set_enabled(self, self.nodes.loader_text, true)
	gui_loyouts.set_enabled(self, self.nodes.catalog_content, false)

	gui_lang.set_text_upper(self, self.nodes.loader_text, err, before_str, after_str)
end

return M