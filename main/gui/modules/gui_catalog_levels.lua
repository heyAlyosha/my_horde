-- Модуль отрисовки и управление каталогом с превьюшкой.
local M = {}

local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local game_content_bots = require "main.game.content.game_content_bots"
local api_player = require "main.game.api.api_player"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local sound_render = require "main.sound.modules.sound_render"
local game_content_levels = require "main.game.content.game_content_levels"
local core_prorgress = require "main.core.core_progress.core_prorgress"
local gui_animate = require "main.gui.modules.gui_animate"

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

function M.scroll_to_btn(self, btn)
	if btn.is_card then
		-- Находим
		local height_card = gui.get_size(self.nodes.node_for_clone).y
		local height_view_content = gui.get_size(self.nodes.catalog_content).y

		local center_card = gui.get_position(btn.wrap_node).y + height_view_content/2 + height_card / 2
		local center_view = center_card - height_view_content/2

		if center_view > 0 then
			center_view = 0
		end

		self["scroll_"..self.id_catalog]:scroll_to(vmath.vector3(0, center_view, 0), false)
	end
end

-- Показ или скрытие лоадера загрузки
function M.visible(self, message)
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

	local levels = game_content_levels.get_all(self.category_id, local_category, user_lang)

	self.cards = M.create_catalog(self, self.id_catalog, levels, params)

	self.btns = {
		{id = "close", type = "btn", section = "close", node = self.nodes.btn_close, wrap_node = self.nodes.btn_close_icon, node_title = false, icon = "btn_circle_bg_red_", wrap_icon = "btn_icon_close_",},
	}
	self.focus_btn_id = nil


	for i = 1, #self.cards do
		local item = self.cards[i]

		local btn_bg = "button_default_green_"

		if not item.is_play then
			btn_bg = "button_default_yellow_"
		end

		local btn = {
			id = item.id, 
			type = "btn", 
			section = "card_"..item.cols, 
			--node = item.nodes[hash("item_template/wrap")],
			node = item.nodes[hash("item_template/btn_template/btn_wrap")],
			node_icon = item.nodes[hash("item_template/btn_template/btn_wrap")],
			node_title = item.nodes[hash("item_template/btn_template/btn_title")],
			wrap_node = item.nodes[hash("item_template/wrap")],
			icon = btn_bg,
			wrap_icon = "bg_modal_",
			is_card = true,
			is_play = item.is_play
		}

		table.insert(self.btns, btn)
	end

	timer.delay(0.1, false, function(self)
		local focus
		
		if self.focus_card then
			focus = self.focus_card + 1

		elseif self.last_is_play_btn_index then
			focus = self.last_is_play_btn_index + 1

		else
			focus = 2
		end

		gui_input.set_focus(self, focus)
		local btn = self.btns[focus]
		M.scroll_to_btn(self, btn)
	end)
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
			description = item.nodes[hash("item_template/description")],
			preview = item.nodes[hash("item_template/preview")],
			icon_status = item.nodes[hash("item_template/icon_status")],
			progress_wrap = item.nodes[hash("item_template/progress_template/wrap")],
			progress_line = item.nodes[hash("item_template/progress_template/line")],
			progress_number = item.nodes[hash("item_template/progress_template/number")],
			btn_wrap = item.nodes[hash("item_template/btn_template/btn_wrap")],
			btn_title = item.nodes[hash("item_template/btn_template/btn_title")],
			gamer_1_avatar = item.nodes[hash("item_template/gamer_1_template/avatar")],
			gamer_1_name = item.nodes[hash("item_template/gamer_1_template/name")],
			gamer_2_avatar = item.nodes[hash("item_template/gamer_2_template/avatar")],
			gamer_2_name = item.nodes[hash("item_template/gamer_2_template/name")],
			gamer_3_avatar = item.nodes[hash("item_template/gamer_3_template/avatar")],
			gamer_3_name = item.nodes[hash("item_template/gamer_3_template/name")],
			star_1 = item.nodes[hash("item_template/star_1")],
			star_2 = item.nodes[hash("item_template/star_2")],
			star_3 = item.nodes[hash("item_template/star_3")],
			success_wrap = item.nodes[hash("item_template/success_wrap_template/success_wrap")],
			lock_wrap = item.nodes[hash("item_template/lock_wrap_template/lock_wrap")],
			icon_type = item.nodes[hash("item_template/icon_type")],
		}

		gui.set_enabled(nodes.wrap, true)
		gui.set_position(nodes.wrap, vmath.vector3(start_x, -start_y, 1))

		gui_lang.set_text_upper(self, nodes.title, "_level", before_str, " "..item.title)
		gui_lang.set_text_upper(self, nodes.description, "_"..item.complexity, before_str)

		-- Иконка типа задания
		gui.set_enabled(nodes.icon_type, item.type == "image")
		if item.type == "image" then
			
		else
			
		end

		-- Отрисовываем противников в уровне
		for i, gamer in ipairs(item.party) do
			local nodes_gamer = {
				avatar = nodes["gamer_"..i.."_avatar"],
				name = nodes["gamer_"..i.."_name"]
			}

			gui.play_flipbook(nodes_gamer.avatar, gamer.avatar or "")
			local name 
			if gamer.complexity == "" then
				name = gamer.name
			else
				name = gamer.name.. " " .. lang_core.get_text(self, "_"..gamer.complexity, before_str, after_str)
			end

			gui.set_text(nodes_gamer.name, name)
		end

		

		-- Иконка 
		if item.status == "default" then
			gui.set_enabled(nodes.icon_status, false)

		elseif item.status == "block" then
			gui.set_enabled(nodes.icon_status, true)
			gui.play_flipbook(nodes.icon_status, "icon_lock")

		elseif item.status == "success" then
			gui.set_enabled(nodes.icon_status, true)
			gui.play_flipbook(nodes.icon_status, "icon_success")

		end

		start_x = end_x

		-- Отрисовываем прогресс в уровнях
		catalog_array[i].complete = item.stars ~= nil

		gui.set_enabled(nodes.success_wrap, catalog_array[i].complete)

		if catalog_array[i].complete then
			-- Уровень пройден
			for i_star = 1, 3 do
				if i_star <= catalog_array[i].stars  then
					gui.play_flipbook(nodes["star_"..i_star], "star_active")
				end
			end
			catalog_array[i].is_play = true
			prev_complete = true
			self.last_is_play_btn_index = i
		else
			if i == 1 or prev_complete then
				catalog_array[i].is_play = true
			else
				catalog_array[i].is_play = false
			end

			gui.set_enabled(nodes.lock_wrap, not catalog_array[i].is_play)

			if catalog_array[i].is_play then
				gui.set_alpha(nodes.wrap, 1)
				gui_lang.set_text_upper(self, nodes.btn_title, "_play", before_str, after_str)
				gui.play_flipbook(nodes.btn_wrap, "button_default_green_default")
				self.last_is_play_btn_index = i
			else
				--gui.set_alpha(nodes.wrap, 0.75)
				gui_lang.set_text_upper(self, nodes.btn_title, "_unavailable", before_str, after_str)
				gui.play_flipbook(nodes.btn_wrap, "button_default_yellow_default")
			end

			prev_complete = false
		end
	end

	local height_content = cols * (height_card + margin)

	gui.set_size(params.node_catalog_content, vmath.vector3(gui.get_position(params.node_catalog_content).x, height_content + 20, 0))
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
	end)
	self["scroll_"..id]:scroll_to(vmath.vector3(0, 0, 0), true)

	return catalog_array
end


function M.close(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {id = self.id, visible = false})
		msg.post("/core_screens", "catalog_company", {category_id = self.category_id})
	end)
end

function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {id = self.id, visible = false})
	end)
end

function M.catalog_input(self, id, action_id, action, function_activate)
	if self.focus_btn_id == 1 and action_id == hash("up") and action.pressed then
		msg.post(storage_gui.components_visible.interface, "focus", {focus = 1})

		sound_render.play("focus_main_menu")
		return true
	end

	local function function_post_focus(self, index, btn)
		if btn.is_card then
			M.scroll_to_btn(self, btn)
		end
	end

	return gui_input.on_input(self, action_id, action, function_focus, function_activate, M.close, function_post_focus)
end

return M