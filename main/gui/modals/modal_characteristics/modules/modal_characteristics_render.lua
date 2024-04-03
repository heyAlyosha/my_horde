-- Отрисовка характеристик
local M = {}

local storage_player = require "main.storage.storage_player"
local gui_text = require "main.gui.modules.gui_text"

local game_content_characteristic = require "main.game.content.game_content_characteristic"
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"

-- Отрисовка описания улучшения
function M.description(self, node)
	local node = self.nodes.description
	local points = storage_player.characteristic_points

	gui_lang.set_text_formated(self, node, "_points_improvement", before_str, ": <color=lime>"..points..'</color>')
end

-- Отрисовка элементов
function M.render(self, not_modal)
	M.description(self)
	-- Очищаем старые данные, если есть
	for i, v in ipairs(self.btns) do
		if not_modal then
			self.btns[i] = nil
		else
			if i >= 2 then
				self.btns[i] = nil
			end
		end
		
	end

	for i, value in ipairs(self.cards) do
		-- очищаем старые карточки
		value = {id = value.id, template_name = value.template_name}

		local card = M.card(self, value)

		-- Если есть кнопка,
		if card.btn then
			self.btns[#self.btns + 1] = {
				id = card.id, -- айдишник для активации кнопки
				type = "btn",
				name_template = value.template_name,
				is_characteristic = true, 
				section = card.id,  -- Секция, если одинаоквая, то можно переключаться вправо-влево
				node = card.btn.btn_wrap, -- нода с иконкой, подставляется icon
				--wrap_node = card.btn.next_level_circle, --обёртка, подставляется wrap_icon
				node_title = card.btn.btn_title, -- Текст, окрашивается в зелёный
				node_wrap_title = card.btn.wrap_title, -- Текст заголовка секции вокруг кнопки, окрашивается в зелёный
				next_level_circle = card.btn.next_level_circle,
				on_set_function = function (self, btn, focus)
					if focus  then
						gui_loyouts.play_flipbook(self, btn.next_level_circle, 'btn_circle_bg_green_default')
					else
						gui_loyouts.play_flipbook(self, btn.next_level_circle, 'btn_circle_bg_violet_default')
					end
				end,
				icon = "btn_ellipse_green_", 
				wrap_icon = "btn_circle_bg_violet_"
			}

			self.btns_id[card.id] = self.btns[#self.btns]
		end
	end

	-- Кнопка пропуска
	if not not_modal then
		self.btns[#self.btns + 1] = {
			id = "skip", -- айдишник для активации кнопки
			type = "btn",
			section = 'skip',  -- Секция, если одинаоквая, то можно переключаться вправо-влево
			node = gui.get_node("btn_next_template/btn_wrap"), -- нода с иконкой, подставляется icon
			node_title = gui.get_node("btn_next_template/btn_title"), -- Текст, окрашивается в зелёный
			icon = "btn_ellipse_green_", 
		}
	end

	gui_loyouts.set_enabled(self, gui.get_node("btn_next_template/btn_wrap"), not not_modal)

	if not_modal then
		return true
	elseif storage_player.characteristic_points > 0 then
		gui_lang.set_text_upper(self, self.btns[#self.btns].node_title, "_skip", before_str, after_str)

	else
		gui_lang.set_text_upper(self, self.btns[#self.btns].node_title, "_continue", before_str, after_str)

	end
end

-- Отрисовка карточки хар-ки
function M.card(self, item)
	local content = game_content_characteristic.get_id(self, item.id)

	local up_level = storage_player.characteristic_points > 0

	local nodes = {
		title = gui.get_node(item.template_name..'/title'),
		img = gui.get_node(item.template_name..'/img'),
		loader_img = gui.get_node(item.template_name..'/loader_icon_template/loader_icon'),
		val = gui.get_node(item.template_name..'/val'),
		description = gui.get_node(item.template_name..'/description'),
		btn_wrap = gui.get_node(item.template_name..'/btn_template/btn_wrap'),
		btn_title = gui.get_node(item.template_name..'/btn_template/btn_title'),
	}

	-- Заполняем статичные данные
	gui_lang.set_text_upper(self, nodes.title, content.title_id_string, before_str, after_str)
	gui_lang.set_text_upper(self, nodes.description, content.description_id_string, before_str, after_str)

	if content.img_preview then
		local node_img = nodes.img
		local node_loader = nodes.loader_img
		local atlas_id = "characteristics"

		live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
			gui_loyouts.set_texture(self, nodes.img, atlas_id)
			gui_loyouts.play_flipbook(self, nodes.img, content.img_preview)
		end)
		--gui.play_flipbook(nodes.img, content.img_preview)
	end

	-- Заполняем данные с текущей прокачкой
	local text_buff = lang_core.get_text(self, "_characteristic_value_"..content.id, before_str, after_str, {value = content.buff})
	gui_loyouts.set_text(self, nodes.val, text_buff)

	-- Заполняем данные с следующим уровнем
	if content.next_level then
		--gui_lang.set_text_formated(self, nodes.next_val, "_improve_to", before_str, ": <color=lime>"..content.next_buff..'</color>')
	else
		up_level = false
	end

	-- Отрисовываем кружочки
	for i = 1, 10 do
		local circle_node = gui.get_node(item.template_name..'/item_characteristics'..i)

		if i <= content.level  then
			gui.play_flipbook(circle_node, "btn_circle_bg_green_default")
		else
			gui.play_flipbook(circle_node, "btn_circle_bg_violet_default")
		end
	end

	-- Если нет следующего уровня, удаляем кнопки и 
	gui.set_enabled(nodes.btn_wrap, up_level)
	--gui.set_enabled(nodes.next_val, up_level)
	if up_level then
		local text_buff = lang_core.get_text(self, "_characteristic_value_"..content.id, before_str, after_str, {value = content.buff})
		local text_next_buff = lang_core.get_text(self, "_characteristic_value_"..content.id, before_str, after_str, {value = content.next_buff})
		gui_loyouts.set_rich_text(self, nodes.val, text_buff .." => " .. "<color=lime>"..text_next_buff.."</color>")

		item.btn = {
			btn_wrap = nodes.btn_wrap,
			btn_title = nodes.btn_wrap,
			next_level_circle = gui.get_node(item.template_name..'/item_characteristics'..content.next_level),
			wrap_title = nodes.title
		}

	else
		local text_buff = lang_core.get_text(self, "_characteristic_value_"..content.id, before_str, after_str, {value = content.buff})
		gui_loyouts.set_rich_text(self, nodes.val, text_buff)
		item.is_btn = nil
	end

	return item
end

function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("main:/loader_gui", "visible", {
			id = "modal_characteristics",
			visible = false,
			type = hash("popup")
		})
	end)
end

return M