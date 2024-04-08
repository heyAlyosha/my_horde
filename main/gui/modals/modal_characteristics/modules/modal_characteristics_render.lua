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
	--M.description(self)
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
				wrap_node = card.btn.btn_wrap, --обёртка, подставляется wrap_icon
				--node_title = card.btn.btn_title, -- Текст, окрашивается в зелёный
				--node_wrap_title = card.btn.wrap_title, -- Текст заголовка секции вокруг кнопки, окрашивается в зелёный
				--next_level_circle = card.btn.next_level_circle,
				--icon = "button_green_default", 
				wrap_icon = "button_green_"
			}

			self.btns_id[card.id] = self.btns[#self.btns]
		end
	end

	return true
end

-- Отрисовка карточки хар-ки
function M.card(self, item)
	local content = game_content_characteristic.get_id(self, item.id)
	local up_level = content.max_level > content.level

	local nodes = {
		title = gui.get_node(item.template_name..'/title'),
		val = gui.get_node(item.template_name..'/val'),
		price = gui.get_node(item.template_name.."/price"),
		btn_wrap = gui.get_node(item.template_name..'/btn_template/btn_wrap'),
		btn_title = gui.get_node(item.template_name..'/btn_template/btn_title'),
	}

	-- Заполняем статичные данные
	gui_lang.set_text_upper(self, nodes.title, content.title_id_string, before_str, after_str)

	-- Заполняем данные с текущей прокачкой
	local text_buff = lang_core.get_text(self, "_characteristic_value_"..content.id, before_str, after_str, {value = content.buff})
	gui_loyouts.set_text(self, nodes.val, text_buff)

	-- Заполняем данные с следующим уровнем
	if content.next_level then
		--gui_lang.set_text_formated(self, nodes.next_val, "_improve_to", before_str, ": <color=lime>"..content.next_buff..'</color>')
	else
		up_level = false
	end

	-- Отрисовываем линию прокачки

	
	-- Если нет следующего уровня, удаляем кнопки и 
	gui.set_enabled(nodes.btn_wrap, up_level)
	if up_level then
		local text_buff = lang_core.get_text(self, "_characteristic_value_"..content.id, before_str, after_str, {value = content.buff})
		local text_next_buff = lang_core.get_text(self, "_characteristic_value_"..content.id, before_str, after_str, {value = content.next_buff})
		gui_loyouts.set_rich_text(self, nodes.val, text_buff .." => " .. "<color=lime>"..text_next_buff.."</color>")

		item.btn = {
			btn_wrap = nodes.btn_wrap,
			btn_title = nodes.btn_wrap,
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