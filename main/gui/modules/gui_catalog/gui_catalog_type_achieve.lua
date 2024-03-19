-- Отрисовка каталога типа инвентарь
local M = {}

local color = require("color-lib.color")
local gui_render = require "main.gui.modules.gui_render"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local gui_input = require "main.gui.modules.gui_input"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"
local lang_core = require "main.lang.lang_core"

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
		loader_img = item.nodes[hash("item_template/loader_icon_template/loader_icon")],
		icon_success = item.nodes[hash("item_template/icon_success")],
		progress_wrap = item.nodes[hash("item_template/progress_bar_template/wrap")],
		progress_line = item.nodes[hash("item_template/progress_bar_template/line")],
		progress_number = item.nodes[hash("item_template/progress_bar_template/number")],
	}

	gui.set_enabled(nodes.wrap, true)
	gui.set_position(nodes.wrap, vmath.vector3(coordinate.start_x, -coordinate.start_y, 1))
	gui_lang.set_text_upper(self, nodes.title, item.title_id_string)
	--pprint(item.description_id_string)
	--local description = lang_core.get_text(self, item.description_id_string, before_str, after_str, values)
	--self.druid:new_text(nodes.description, description)
	gui_lang.set_text(self, nodes.description, item.description_id_string)

	local node_img = nodes.icon
	local node_loader = nodes.loader_img
	local atlas_id = "achieves"
	live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
		gui_loyouts.set_texture(self, nodes.icon, atlas_id)
		gui_loyouts.play_flipbook(self, nodes.icon, item.icon)
	end)
	--gui.play_flipbook(nodes.icon, item.icon)

	-- Статус получения ачивки
	if item.success then
		gui.set_color(nodes.icon, color.white)
		item.count = item.max_count
	else
		gui.set_color(nodes.icon, color.gray)
	end
	gui.set_enabled(nodes.icon_success, item.success)

	gui_render.progress(self, item.count, item.max_count, nodes.progress_wrap, nodes.progress_line, nodes.progress_number)

	coordinate.start_x = coordinate.end_x

	return coordinate
end

return M