local M = {}

local gui_animate = require "main.gui.modules.gui_animate"
local gui_input = require "main.gui.modules.gui_input"
local gui_render = require "main.gui.modules.gui_render"
local timer_linear = require "main.modules.timer_linear"
local sound_render = require "main.sound.modules.sound_render"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"

-- Анимация поялвения
function M.visible(self, type, data, function_end)
	local type = type or "default"
	self.animate_visible = true
	self._start_size_wrap = self._start_size_wrap or gui.get_size(self.nodes.wrap_bg)
	self._start_position_wrap = self._start_position_wrap or gui.get_position(self.nodes.wrap)
	self._start_scale_wrap = self._start_scale_wrap or gui.get_scale(self.nodes.wrap_bg)

	-- Устанавливаем стартовые позиции

	gui_loyouts.set_size(self, self.nodes.wrap_bg, 200, "x")
	gui_loyouts.set_position(self, self.nodes.wrap, self._start_position_wrap.x - 100 + self._start_size_wrap.x / 2 + 75, "x")
	gui.set_scale(self.nodes.wrap_bg, vmath.vector3(0.01))
	gui.set_scale(self.nodes.animation_wrap_bg, vmath.vector3(0.01))

	-- Анимация появления
	local delay = 0.25
	timer_linear.add(self, "notify", 0.25, function (self)
		gui.animate(self.nodes.animation_wrap_bg, "scale", self._start_scale_wrap, gui.EASING_OUTBACK, 0.25, delay, function (self)
			gui_loyouts.set_scale(self, self.nodes.wrap_bg, self._start_scale_wrap)
			gui_loyouts.set_scale(self, self.nodes.animation_wrap_bg, vmath.vector3(0.01))
		end)
	end)
	

	-- Анимация ореола
	if type == "progress" then
		timer_linear.add(self, "notify", 0, function (self)
			gui_animate.areol(self, "aureola_template", speed_to_second, 2, nil, scale)
		end)

		timer_linear.add(self, "notify", 2, function (self)
			
		end)
	end

	timer_linear.add(self, "notify", 0.5, function (self)
		gui.animate(self.nodes.wrap, "position.x", self._start_position_wrap.x, gui.EASING_INOUTSINE, 0.25)
		gui.animate(self.nodes.wrap_bg, "size.x", self._start_size_wrap.x, gui.EASING_INOUTSINE, 0.25)
		
	end)

	-- Поялвение кнопки закрыть
	-- отключаем обрезание лишнего контента
	-- Если есть кнопка, анимируем её
	gui.set_enabled(self.nodes.btn, false)
	-- Кнопка закрытия
	gui.set_enabled(self.nodes.btn_close, false)
	-- прогресс
	gui.set_enabled(self.nodes.progress_wrap, false)
	-- 
	gui.set_enabled(self.nodes.progress_wrap, false)
	timer_linear.add(self, "notify", 0.2, function (self)
		gui_loyouts.set_clipping_mode(self, self.nodes.wrap_bg, gui.CLIPPING_MODE_NONE)

		timer.delay(0.25, false, function (self)
			sound_render.play("notify_show_item", url_object)
		end)
		gui_animate.show_elem_popping(self, self.nodes.btn_close, 0.25, 0)

		if type == "button" then
			
			timer.delay(0.25, false, function (self)
				sound_render.play("notify_show_item", url_object)
			end)

			gui_animate.show_elem_popping(self, self.nodes.btn, 0.15, 0, function_end_animation)

		elseif type == "progress" then
			-- Если есть прогресс
			timer.delay(0.15, false, function (self)
				sound_render.play("notify_show_item", url_object)
			end)
			gui_animate.show_elem_popping(self, self.nodes.progress_wrap, 0.25, delay, function (self)

				local progress_bar = data.progress_bar or {}
				local progress_max = progress_bar.max  or 0
				local progress_current = progress_bar.progress_current or 0
				timer.delay(0.25, false, function (self)
					sound_render.play("animate_rating_change_place", url_object)
					gui_render.progress(self, progress_current, progress_max, self.nodes.progress_wrap, self.nodes.progress_line, self.nodes.progress_number, 0.5)
				end)

			end)
		end

		timer_linear.add(self, "notify", 0.1, function (self)
			self.animate_visible = nil

			if function_end then
				function_end(self)
			end
		end)
	end)

	
end

return M