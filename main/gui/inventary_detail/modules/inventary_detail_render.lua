-- функции для показа и отрисовки подробностей об объекте
local M = {}




local game_content_characteristic = require "main.game.content.game_content_characteristic"
local core_achieve_functions = require "main.core.core_achieve.modules.core_achieve_functions"
local gui_text = require "main.gui.modules.gui_text"
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local gui_render = require "main.gui.modules.gui_render"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local color = require("color-lib.color")
local gui_size = require "main.gui.modules.gui_size"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"

-- Отрисовка  объекта из инвентаря
function M.prize(self, id, nodes)
	-- Создаём кнопку
	self.btns[1] = self.btn_object
	-- Переносим нужные ноды
	self.nodes = self.nodes_object
	gui_loyouts.set_enabled(self, self.nodes_object.wrap, true)

	-- Отключаем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes.count_shop, false)
	gui_loyouts.set_enabled(self, self.nodes.error, false)
	gui_loyouts.set_enabled(self, self.nodes_achieve.wrap, false)

	self.type = 'prize'
	self.content = game_content_prize.get_prize(id)

	self.btn_type = 'sell'

	if not self.content then
		gui_loyouts.set_enabled(self, self.nodes.img, false)
		return false
	else
		gui_loyouts.set_enabled(self, self.nodes.img, true)
	end

	self.content.price_buy = nil

	-- Отрисовываем
	if self.content.title_id_string then gui_lang.set_text_upper(self, self.nodes.title, self.content.title_id_string) end
	if self.content.description_id_string then gui_lang.druid_text(self, self.nodes.description, self.content.description_id_string)end
	if self.content.price_sell then gui_loyouts.set_text(self, self.nodes.price, self.content.price_sell) end
	if self.content.count then 
		gui_lang.set_text_formated(self, self.nodes.count, "_at_you", "", ": <color=lime>"..self.content.count.."</color>")
	end
	if self.content.btn_title then gui_lang.set_text_upper(self, self.nodes.btn_title, "_sell") end
	if self.content.icon then
		local node_img = self.nodes.img
		local node_loader = self.nodes.loader_img
		local atlas_id = "prizes_mini"

		live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
			gui_loyouts.set_texture(self, self.nodes.img, atlas_id)

			gui_size.play_flipbook_ratio(self, self.nodes.img, self.nodes.img_wrap, self.content.icon, 300, 300)
		end)
	end

	gui_input.set_disabled(self, self.btns[1], not (self.content.count >= 1))
	--gui_input.set_focus(self, 1,  nil, false)

	M.btns(self, self.nodes)
end

-- Отрисовка  объекта из инвентаря
function M.shop(self, id, nodes)
	-- Создаём кнопку
	self.btns[1] = self.btn_object
	-- Переносим нужные ноды
	self.nodes = self.nodes_object
	gui_loyouts.set_enabled(self, self.nodes_object.wrap, true)

	-- Отключаем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes.count_shop, true)
	gui_loyouts.set_enabled(self, self.nodes.error, true)
	gui_loyouts.set_enabled(self, self.nodes_achieve.wrap, false)

	self.type = 'shop'
	self.content = game_content_artifact.get_item(id)

	if not self.content then
		gui_loyouts.set_enabled(self, self.nodes.img, false)
		return false
	else
		gui_loyouts.set_enabled(self, self.nodes.img, true)
	end

	-- Отрисовваем состояния
	local error_id_string = self.content.buy.error_id_string
	local disabled = self.content.disable_buy
	self.btn_type = self.content.buy.buy_type

	--pprint("self.content", self.content)

	if error_id_string == "_required_level_charisma" then
		gui_lang.set_text(self, self.nodes.error, error_id_string, before_str, " " .. self.content.level)
	else
		gui_lang.set_text(self, self.nodes.error, error_id_string, before_str, after_str)
	end

	-- Отрисовываем
	if self.content.title_id_string then gui_lang.set_text_upper(self, self.nodes.title, self.content.title_id_string) end
	if self.content.description_id_string then gui_lang.druid_text(self, self.nodes.description, self.content.description_id_string)end
	if self.content.count then 
		gui_lang.set_text_formated(self, self.nodes.count, "_at_you", "", ": <color=lime>"..self.content.count.."</color>")
	end
	if self.content.count_shop then 
		gui_lang.set_text(self, self.nodes.count_shop, "_to_shop", before_str, ": "..self.content.count_shop.."")
	end
	if self.content.btn_title then gui_loyouts.set_text(self, self.nodes.btn_title, self.content.btn_title) end
	if self.content.icon then 
		gui_size.play_flipbook_ratio(self, self.nodes.img, self.nodes.img_wrap, self.content.icon, 300, 300)

		live_update_atlas.render(self, "objects_full", function (self, atlas_id)
			gui_loyouts.set_texture(self, self.nodes.img, "objects_full")
			gui_size.play_flipbook_ratio(self, self.nodes.img, self.nodes.img_wrap, self.content.icon, 300, 300)
		end)
	end

	gui_input.set_disabled(self, self.btns[1], disabled)
	--gui_input.set_focus(self, 1,  nil, false)
	M.btns(self, self.nodes)
end

-- Отрисовка ачивки
function M.achieve(self, id, nodes)
	-- Удаляем кнопки
	self.btns = {}
	-- Переносим нужные ноды
	self.nodes = self.nodes_achieve
	gui_loyouts.set_enabled(self, self.nodes_achieve.wrap, true)

	-- Отключаем ненужные блоки
	gui_loyouts.set_enabled(self, self.nodes_object.wrap, false)

	-- Получаем контент
	self.content = game_content_achieve.get_item(id, core_achieve_functions)

	-- Отрисоввыаем
	if self.content.title_id_string then gui_lang.set_text_upper(self, self.nodes.title, self.content.title_id_string) end
	if self.content.description_id_string then gui_lang.druid_text(self, self.nodes.description, self.content.description_id_string)end
	if self.content.icon then 
		--gui_size.play_flipbook_ratio(self, self.nodes.img, self.nodes.img_wrap, self.content.icon, 300, 300)

		local node_img = self.nodes.img
		local node_loader = self.nodes.loader_img
		local atlas_id = "achieves"
		live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
			gui_loyouts.set_texture(self, self.nodes.img, atlas_id)
			gui_loyouts.play_flipbook(self, self.nodes.img, self.content.icon)
		end)
	end

	self._start_position_success_achieve = self._start_position_success_achieve or gui.get_position(self.nodes.img_wrap)
	self._animate_y = self._animate_y or gui.get_position(self.nodes.img_wrap).y + 25

	-- Анимация плавания полученного достижения над пьедесталом
	gui_loyouts.set_position(self, self.nodes.img_wrap, self._start_position_success_achieve)
	gui.cancel_animation(self.nodes.img_wrap, "position.y")
	if self.content.success then
		gui.animate(self.nodes.img_wrap, "position.y", self._animate_y, gui.EASING_INOUTSINE, 3, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
		
		gui_loyouts.set_color(self, self.nodes.pedestal, color.white)
	else
		gui_loyouts.set_color(self, self.nodes.pedestal, color.indigo)
	end
	-- Получено или нет достижение
	gui_loyouts.set_enabled(self, self.nodes.ray, self.content.success)
	gui_loyouts.set_enabled(self, self.nodes.img_wrap, self.content.success)

	gui_render.progress(self, self.content.count, self.content.max_count, self.nodes.progress_wrap, self.nodes.progress_line, self.nodes.progress_number)
end

-- отрисовка кнопки
function M.btns(self, nodes)
	local price = self.content.price_buy or self.content.price_sell
	-- Отрисовываем тип кнопки
	if self.btn_type == "buy" then
		gui_loyouts.set_text(self, self.nodes.price, price)
		gui_lang.set_text_upper(self, self.nodes.btn_title, "_buy")
		gui_loyouts.play_flipbook(self, self.nodes.price_icon, 'icon_gold')

	elseif self.btn_type == "sell" then
		gui_loyouts.set_text(self, self.nodes.price, price)
		gui_lang.set_text_upper(self, self.nodes.btn_title, "_sell")
		gui_loyouts.play_flipbook(self, self.nodes.price_icon, 'icon_gold')

	elseif self.btn_type == "reward" then
		gui_loyouts.set_text(self, self.nodes.price, "1")
		gui_lang.set_text_upper(self, self.nodes.btn_title, "_view")
		gui_loyouts.play_flipbook(self, self.nodes.price_icon, 'icon_reward')

	else
		gui_loyouts.set_text(self, self.nodes.price, "0")
		gui_lang.set_text_upper(self, self.nodes.btn_title, "_press")

	end
end

return M