-- Модуль отрисовки и управление каталогом с превьюшкой.
local M = {}

local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local storage_gui = require "main.storage.storage_gui"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local gui_render = require "main.gui.modules.gui_render"
local sound_render = require "main.sound.modules.sound_render"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"
local game_content_company = require "main.game.content.game_content_company"

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

function M.create_catalog(self, id, catalog_array, params)
	local margin = params.margin
	local width_wrap = gui.get_size(params.node_catalog_content).x
	pprint("width_wrap", width_wrap)
	local height_wrap = 0

	local width_card = gui.get_size(params.node_for_clone).x * gui.get_scale(params.node_for_clone).x + margin
	local height_card = gui.get_size(params.node_for_clone).y * gui.get_scale(params.node_for_clone).y + margin

	local start_x,start_y,end_x,end_y = 0, 0, 0, 0
	local cols = 1

	pprint("M.create_catalog", start_x,start_y,end_x,end_y)

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
			loader_img = item.nodes[hash("item_template/loader_icon_template/loader_icon")],
			icon_status = item.nodes[hash("item_template/icon_status")],
			progress_wrap = item.nodes[hash("item_template/progress_template/wrap")],
			progress_line = item.nodes[hash("item_template/progress_template/line")],
			progress_number = item.nodes[hash("item_template/progress_template/number")],
			btn_wrap = item.nodes[hash("item_template/btn_template/btn_wrap")],
			btn_title = item.nodes[hash("item_template/btn_template/btn_title")],
		}

		gui.set_enabled(nodes.wrap, true)
		gui.set_position(nodes.wrap, vmath.vector3(start_x, -start_y, 1))

		-- Текстовое содержимое
		gui_lang.set_text_upper(self, nodes.btn_title, "_play", before_str, after_str)

		-- название компании
		local name = lang_core.get_text(self, item.name, before_str, after_str, values)
		--gui_lang.set_text_upper(self, nodes.title, item.name, before_str, after_str)
		self.druid:new_text(nodes.title, utf8.upper(name))
		--gui_loyouts.set_druid_text(self, nodes.title, utf8.upper(name))
		
		local description
		if item.type == "image" or item.type == "music" then
			description = utf8.upper(lang_core.get_text(self, "_type_quest_"..item.type, before_str, after_str, values))

		elseif item.description then
			description = lang_core.get_text(self, item.description, before_str, after_str, values)

		end
		gui_lang.set_text(self, nodes.description, description or "", before_str, after_str)

		-- Картинка
		if item.img then
			--gui.set_texture(nodes.preview, "preview")
			--gui.play_flipbook(nodes.preview, item.img)

			local node_img = nodes.preview
			local node_loader = nodes.loader_img
			local atlas_id = "preview"
			live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
				gui.set_texture(nodes.preview, atlas_id)
				gui.play_flipbook(nodes.preview, item.img)
			end)
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

		-- Прогресс
		gui.set_enabled(nodes.progress_wrap, item.progress_all and item.progress_all > 0)
		if item.progress_all then
			gui_render.progress(self, item.progress_count, item.progress_all, nodes.progress_wrap, nodes.progress_line, nodes.progress_number, 0.01)
		end

		start_x = end_x
	end

	local height_content = cols * (height_card + margin) + 25

	gui.set_size(params.node_catalog_content, vmath.vector3(gui.get_size(params.node_catalog_content).x, height_content, 0))
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

function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("main:/loader_gui", "visible", {id = self.id, visible = false})
		msg.post("main:/core_screens", "main_menu", {})
	end)
end

function M.activate_category(self, id, focus_level)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("main:/loader_gui", "visible", {id = self.id, visible = false})
		msg.post("main:/core_screens", "catalog_levels", {
			category_id = id,
			focus_level = focus_level,
			from_company = true
		})
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
			-- Находим
			M.scroll_to_btn(self, btn)
		end
	end

	return gui_input.on_input(self, action_id, action, function_focus, function_activate, M.hidden, function_post_focus)
end

function M.render_catalog(self, type_id)
	-- УДаляем ноды карточек
	if self.cards then
		for k, item in pairs(self.cards) do
			gui.delete_node(item.nodes[hash("item_template/wrap")])
			self.cards[k] = nil
		end
	end

	-- УДаляем кнопки старых карточек, если есть
	for i = #self.btns, 1, -1 do
		local item = self.btns[i]

		if item.is_card then
			table.remove(self.btns, i)
		end
	end

	if not self.params then
		self.params = {
			margin = 5,
			node_for_clone = self.nodes.node_for_clone,
			node_catalog_view = self.nodes.catalog_view,
			node_catalog_content = self.nodes.catalog_content,
			node_catalog_input = self.nodes.catalog_input,
			node_scroll = self.nodes.catalog,
			node_scroll_wrap = self.nodes.scroll_wrap,
			node_scroll_caret = self.nodes.scroll_caret,
		}
	end

	pprint("params", params)

	local companies = game_content_company.get_all()

	if type_id then
		for i = #companies, 1, -1 do
			local item = companies[i]

			if item.type ~= type_id then
				table.remove(companies, i)
			end
		end
	end

	-- Добавляем в каталог плашку с турниром
	table.insert(companies, 1, {
		id = "tournir",
		sort = 8,
		type = "default",
		name = "_company_name_tournir",
		description = "_company_description_tournir",
		img = "bg_tournir",
		status = "default",
		progress_all = 0,
		progress_count = 0
	})
	pprint("companies", self.cards)
	self.cards = M.create_catalog(self, self.id_catalog, companies, self.params)

	for i = 1, #self.cards do
		local item = self.cards[i]

		local btn = {
			id = item.id, 
			type = "btn", 
			section = "card_"..item.cols, 
			--node = item.nodes[hash("item_template/wrap")],
			node = item.nodes[hash("item_template/btn_template/btn_wrap")],
			node_icon = item.nodes[hash("item_template/btn_template/btn_wrap")],
			node_title = item.nodes[hash("item_template/btn_template/btn_title")],
			wrap_node = item.nodes[hash("item_template/wrap")],
			icon = "button_default_green_",
			wrap_icon = "bg_modal_",
			is_card = true
		}

		table.insert(self.btns, btn)
	end
end

return M