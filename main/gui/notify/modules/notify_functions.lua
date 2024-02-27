local M = {}

local gui_animate = require "main.gui.modules.gui_animate"
local gui_input = require "main.gui.modules.gui_input"
local gui_size = require "main.gui.modules.gui_size"
local gui_text = require "main.gui.modules.gui_text"
local notify_animations = require "main.gui.notify.modules.notify_animations"
local timer_linear = require "main.modules.timer_linear"
local sound_render = require "main.sound.modules.sound_render"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local RichText = require("druid.custom.rich_text.rich_text")
local storage_game = require "main.game.storage.storage_game"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"

-- Показываем уведомление
function M.visible(self, type, data)
	local type = type or 'default'
	local data = data or {}
	local title = data.title or ""
	local title_formated = data.title_formated
	local description = data.description 
	local description_formated = data.description_formated
	local icon = data.icon or false
	local sound = data.sound or false

	local btn = data.btn or {}
	local btn_type = btn.type or false
	local btn_title = btn.title or ""

	local progress_bar = data.progress_bar or {}
	local progress_max = progress_bar.max or 0
	local progress_current = progress_bar.progress_current or 0
	local progress_animate = progress_bar.progress_animate

	sound_render.play("notify_open", url_object)

	timer.delay(0.25, false, function (self)
		if sound then
			sound_render.play(sound, url_object)
		end
	end)

	-- Отрисовываем статичные данные
	local title = title_formated or title
	if data.title_formated then
		local nodes = gui_loyouts.set_rich_text(self, self.nodes.title, title_formated)

		-- Ставим описание под заголовок
		local last_elem = nodes[#nodes]
		local position_y_description = last_elem.position_y
		local positiob_description = gui.get_position(self.nodes.description) 
		gui_loyouts.set_position(self, self.nodes.description, positiob_description.y + position_y_description, "y")

	else
		self.druid:new_text(self.nodes.title, utf8.upper(title))

	end

	if data.description_formated then
		gui_text.set_text_formatted(self, self.nodes.description, description_formated)
	else
		self.druid:new_text(self.nodes.description, utf8.upper(description))
	end

	if icon then
		local node_img = self.nodes.animation_icon
		local node_loader = self.nodes.loader_img
		local atlas_id
		if type == "progress" then
			atlas_id = "achieves"
		else
			atlas_id = "notify"
		end

		live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self, atlas_id)
			gui_loyouts.set_texture(self, self.nodes.icon, atlas_id)
			gui_loyouts.set_texture(self, self.nodes.animation_icon, atlas_id)
			gui_loyouts.set_blend_mode(self, self.nodes.animation_icon, gui.BLEND_ALPHA)
			gui_loyouts.set_blend_mode(self, self.nodes.icon, gui.BLEND_ALPHA)

			gui_loyouts.play_flipbook(self, self.nodes.icon, icon)
			gui_loyouts.play_flipbook(self, self.nodes.animation_icon, icon)
		end)
		
	else
		gui_loyouts.set_enabled(self, self.nodes.icon, false)
		gui_loyouts.set_enabled(self, self.nodes.animation_icon, false)
	end

	-- Отрисовываем типы сообщений
	if type == "button" then
		-- Если есть кнопка, показываем и добавляем её
		gui_loyouts.set_text(self, self.nodes.btn_title, btn_title)
		self.btns[2] = {id = btn_type, type = "btn", section = "main", node = self.nodes.btn, node_title = self.nodes.btn_title, icon = "btn_ellipse_green_",}
		
		gui_size.set_gui_wrap_from_text(self.nodes.btn_title, self.nodes.btn, "width", 100, self)
		gui_size.set_btn_list_horisontal(self.nodes.wrap_btns, {self.nodes.btn}, 0, self)

	elseif type == "progress" then
		-- Если кнопка отключена и нужно нарисовать прогресс бар
		gui_loyouts.set_text(self, self.nodes.progress_number, "0/" ..progress_max)

	end
	-- Включаем/отключаем кнопки и прогресс 
	gui_loyouts.set_enabled(self, self.nodes.btn, type == "button")
	gui_loyouts.set_enabled(self, self.nodes.progress_wrap, type == "progress")

	notify_animations.visible(self, type, data, function (self)
		gui_input.set_focus(self, #self.btns)

		timer.delay(7, false, function (self)
			M.hidden(self)
		end)

	end)
end

-- Закрытие
function M.hidden(self, function_end)
	gui.set_clipping_mode(self.nodes.wrap_bg, gui.CLIPPING_MODE_STENCIL)
	

	local delay = 0
	gui.animate(self.nodes.wrap_bg, "size.x", 200, gui.EASING_LINEAR, 0.25)
	gui.animate(self.nodes.wrap, "position.x", self._start_position_wrap.x - 100 + self._start_size_wrap.x / 2, gui.EASING_LINEAR, 0.25, 0, function (self)
		gui.set_scale(self.nodes.animation_wrap_bg, self._start_scale_wrap)
		gui.set_scale(self.nodes.wrap_bg, vmath.vector3(0.00001))
		sound_render.play("popup_hidden", url_object)
	end)
	delay = delay + 0.35

	gui.animate(self.nodes.animation_wrap_bg, "scale", 0.00001, gui.EASING_INOUTBACK, 0.25, delay, function (self)
		--Запуск удачной прокачки в окне улучшений:
		msg.post("/loader_gui", "visible", {
			id = "notify",
			visible = false
		})

		if function_end then
			function_end(self)
		end
	end)
end

return M