-- Модуль для отрисовки однотипных элементов
local M = {}

-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"

-- Отрисовка прогресса
function M.progress(self, count, max_count, node_wrap, node_line, node_number, duration)
	local duration = duration or 0
	gui_loyouts.set_text(self, node_number, count..'/'..max_count)
	-- Отступ
	local border = gui.get_position(node_line).x

	-- Макисмальная и минимальная ширина
	local min_size_x = 40
	local max_size_x = gui.get_size(node_wrap).x - border * 2
	if max_count == 0 then max_count = 1 end 

	-- Процент и ширина
	local procent = count / max_count
	local width_line = max_size_x * procent

	if width_line > max_size_x then
		width_line = max_size_x 

	elseif width_line < min_size_x then
		width_line = min_size_x 
	end

	if duration == 0 then
		gui_loyouts.set_size(self, node_line, width_line, "x")

	else
		gui.animate(node_line, "size.x", width_line, gui.EASING_LINEAR, duration)
		timer.delay(duration, false, function (self)
			gui_loyouts.set_size(self, node_line, width_line, "x")
		end)

	end
	
end

-- Отрисовка карточки с уровнем
function M.render_card_level(self, template_name, content, stars)
	local stars = stars or 0
	local nodes = {
		wrap = gui.get_node(template_name.."/wrap"),
		title = gui.get_node(template_name.."/title"),
		description = gui.get_node(template_name.."/description"),
		btn_wrap = gui.get_node(template_name.."/btn_template/btn_wrap"),
		btn_title = gui.get_node(template_name.."/btn_template/btn_title"),
		btn_title = gui.get_node(template_name.."/btn_template/btn_title"),
		gamer_1_avatar = gui.get_node(template_name.."/gamer_1_template/avatar"),
		gamer_1_name = gui.get_node(template_name.."/gamer_1_template/name"),
		gamer_2_avatar = gui.get_node(template_name.."/gamer_2_template/avatar"),
		gamer_2_name = gui.get_node(template_name.."/gamer_2_template/name"),
		gamer_3_avatar = gui.get_node(template_name.."/gamer_3_template/avatar"),
		gamer_3_name = gui.get_node(template_name.."/gamer_3_template/name"),
		star_1 = gui.get_node(template_name.."/star_1"),
		star_2 = gui.get_node(template_name.."/star_2"),
		star_3 = gui.get_node(template_name.."/star_3"),
		lock_wrap = gui.get_node(template_name.."/lock_wrap_template/lock_wrap"),
	}

	gui_loyouts.set_enabled(self, nodes.wrap, true)
	gui_lang.set_text_upper(self, nodes.title, "_level", before_str, " " .. content.title)
	gui_lang.set_text_upper(self, nodes.description, "_"..content.complexity, before_str)

	-- Отрисовываем противников в уровне
	for i, gamer in ipairs(content.party) do
		local nodes_gamer = {
			avatar = nodes["gamer_"..i.."_avatar"],
			name = nodes["gamer_"..i.."_name"]
		}

		gui_loyouts.play_flipbook(self, nodes_gamer.avatar, gamer.avatar)
		if gamer.complexity ~= "" then
			local complexity_text = lang_core.get_text(self, "_"..gamer.complexity, before_str, after_str, values)
			gui_loyouts.set_text(self, nodes_gamer.name, gamer.name.. " (" .. complexity_text .. " )")

		else
			gui_loyouts.set_text(self, nodes_gamer.name, gamer.name)

		end
	end

	content.party = {}
	pprint("content", content)

	-- Отрисовываем звёздочки
	for i = 1, stars do
		if i <= stars then
			gui_loyouts.play_flipbook(self, nodes['star_'..i], 'star_active')
		else
			break
		end
	end
end

-- Отрисовка карточки с компанией
function M.render_card_company(self, template_name_or_nodes, content, params)
	local params = params or {}
	local nodes = {}
	if type(template_name_or_nodes) == 'table' then
		-- если это массив - значит массив с клонами нод
		local clone_nodes = template_name_or_nodes
		nodes = {
			wrap = clone_nodes.nodes[hash("item_template/wrap")],
			title = clone_nodes.nodes[hash("item_template/title")],
			description = clone_nodes.nodes[hash("item_template/description")],
			preview = clone_nodes.nodes[hash("item_template/preview")],
			icon_status = clone_nodes.nodes[hash("item_template/icon_status")],
			progress_wrap = clone_nodes.nodes[hash("item_template/progress_template/wrap")],
			progress_line = clone_nodes.nodes[hash("item_template/progress_template/line")],
			progress_number = clone_nodes.nodes[hash("item_template/progress_template/number")],
			btn_wrap = clone_nodes.nodes[hash("item_template/btn_template/btn_wrap")],
			btn_title = clone_nodes.nodes[hash("item_template/btn_template/btn_title")],
			success_icon = clone_nodes.nodes[hash("success_icon_template/success_wrap")],
		}
	else 
		-- Если строка - значит это название шаблона
		local template_name = template_name_or_nodes
		nodes = {
			wrap = gui.get_node(template_name..'/wrap'),
			title = gui.get_node(template_name..'/title'),
			description = gui.get_node(template_name..'/description'),
			preview = gui.get_node(template_name..'/preview'),
			loader_img = gui.get_node(template_name..'/loader_icon_template/loader_icon'),
			icon_status = gui.get_node(template_name..'/icon_status'),
			progress_wrap = gui.get_node(template_name..'/progress_template/wrap'),
			progress_line = gui.get_node(template_name..'/progress_template/line'),
			progress_number = gui.get_node(template_name..'/progress_template/number'),
			btn_wrap = gui.get_node(template_name..'/btn_template/btn_wrap'),
			btn_title = gui.get_node(template_name..'/btn_template/btn_title'),
			success_icon = gui.get_node(template_name..'/success_icon_template/success_wrap'),
			
		}
	end

	-- начинаем заполнять контентом
	gui_loyouts.set_enabled(self, nodes.wrap, true)
	if params.start_x and params.start_y then
		gui_loyouts.set_position(self, nodes.wrap, vmath.vector3(start_x, -start_y, 1))
	end
	local title = lang_core.get_text(self, content.name, before_str, after_str, values)
	gui_loyouts.set_text(self, nodes.title, title)
	--[[
	local description = lang_core.get_text(self, content.description, before_str, after_str, values)
	gui.set_text(nodes.description, description)
	--]]

	if content.img then
		local node_img = nodes.preview
		local node_loader = nodes.loader_img
		local atlas_id = "preview"
		live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
			gui_loyouts.set_texture(self, nodes.preview, "preview")
			gui_loyouts.play_flipbook(self, nodes.preview, content.img)
		end)
		
	end

	-- Иконка 
	if content.status == "default" then
		gui_loyouts.set_enabled(self, nodes.icon_status, false)

	elseif content.status == "block" then
		gui_loyouts.set_enabled(self, nodes.icon_status, true)
		gui_loyouts.play_flipbook(self, nodes.icon_status, "icon_lock")

	elseif content.status == "success" then
		gui_loyouts.set_enabled(self, nodes.icon_status, true)
		gui_loyouts.play_flipbook(self, nodes.icon_status, "icon_success")
	end

	-- Прогресс
	gui_loyouts.set_enabled(self, nodes.progress_wrap, content.progress_all and content.progress_all > 0 )
	if content.progress_all and content.progress_all > 0  then
		M.progress(self, content.progress_count, content.progress_all, nodes.progress_wrap, nodes.progress_line, nodes.progress_number, 0)
	end
end

return M