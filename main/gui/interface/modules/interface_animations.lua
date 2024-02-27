-- Анимации интерфейса
local M = {}

local sound_render = require "main.sound.modules.sound_render"
local color = require("color-lib.color")
local gui_animate = require "main.gui.modules.gui_animate"
local storage_player = require "main.storage.storage_player"
local core_player_function = require "main.core.core_player.modules.core_player_function"
local interface_functions = require "main.gui.interface.modules.interface_functions"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local timer_linear = require "main.modules.timer_linear"

--амксимальные и минимальные значения линии уровня
M.min_line = interface_functions.min_line
M.max_line = interface_functions.max_line

-- Анимированное обновление баланса
function M.set_balance(self, type, value)
	local node_wrap = self.nodes.coin_wrap
	local node_text = self.nodes.coin
	local duration = 0.3
	local color_text = color.white
	local text = nil

	if type == 'score' then
		node_wrap = self.nodes.score_wrap
		node_text = self.nodes.score
	elseif type == 'rating' then
		node_wrap = self.nodes.rating_wrap
		node_text = self.nodes.rating
	end

	local current_balance = tonumber(gui.get_text(node_text))
	local difference_balance = value - current_balance

	if difference_balance > 0 then
		color_text = color.lime
		text_diference_balance = '+'..difference_balance
	elseif difference_balance < 0 then
		color_text = color.red
		text_diference_balance = difference_balance
	else
		color_text = nil
		text_diference_balance = nil
	end

	gui_loyouts.set_text(self, node_text, value)
	gui_animate.pulse_update_count(self, node_wrap, node_text, duration, delay, color_text, sound, text_diference_balance, function_end)
end

-- Анимированное обновление линии уровня
function M.set_score_line(self, procent, duration, function_end)
	timer_linear.skip(self, "score_line")
	local node_wrap = self.nodes.account_wrap
	local node_line = self.nodes.score_line
	local name = value
	local min_line = M.min_line
	local max_line = M.max_line
	local procent_to_second = 100

	local duration = duration or 0.3

	local line_active = max_line * procent * 0.01

	-- Если идёт анимация нового уровня, не пропускаем анимацию линии
	--[[
	if self.animate_up_level then
		return false
	end
	--]]

	timer_linear.add(self, "score_line", 0, function (self)
		
	end)
	-- 1 пульсация всей плашки
	gui_animate.pulse_update_count(self, node_wrap, node_line, duration, delay, color_text, sound, text, function_end)

	-- Делаем линию опыта белой
	gui_loyouts.set_blend_mode(self, node_line, gui.BLEND_ADD)

	-- Начинаем анимацию увеличения линии
	local duration_line = -(line_active / procent_to_second)
	if self.animate_line  or gui.get_fill_angle(node_line) == line_active then
		duration = 0
		--gui.cancel_animation(node_line, 'fill_angle')
		self.animate_line = nil
		gui_loyouts.set_blend_mode(self, node_line, gui.BLEND_ALPHA)
	end

	timer_linear.add(self, "score_line", duration, function (self)
		if not self.animate_up_level then
			self.animate_line = gui.animate(node_line, 'fill_angle', line_active, gui.EASING_OUTSINE, duration_line, 0, function (self)
				self.animate_line = nil
				gui_loyouts.set_blend_mode(self, node_line, gui.BLEND_ALPHA)
				if function_end then
					function_end(self)
				end
			end)
		end
	end)
	
end

-- Анимированное обновление уровня
function M.set_level(self, level, function_end)
	local node_wrap = self.nodes.account_wrap
	local node_level_text = self.nodes.account_level
	local node_line = self.nodes.score_line
	local duration_all = 2
	local delay_update_text = 0.3
	local delay = 0

	local duration_animate = 0.1
	local duration_line = 0.1

	if self.current_level == level or self.animate_up_level then
		return
	end

	timer_linear.skip(self, "score_line")

	self.animate_up_level = true
	self.current_values.level = self.current_values.level + 1

	timer_linear.add(self, "set_level", 0, function (self)
		sound_render.play("level_up")

		-- Анимация увеличения плашки с уровнем
		gui.animate(node_wrap, 'scale', 1.1, gui.EASING_LINEAR, duration_animate, delay, function (self)
		end)
		-- Анимация увеличения линии полностью
		gui.animate(node_line, 'fill_angle', M.max_line, gui.EASING_OUTSINE, duration_line)
		-- Красим линию в белый цвет
		gui_loyouts.set_blend_mode(self, node_line, gui.BLEND_ADD)

		-- Анимация появления ареола вокруг плашки
		local name_template = 'areol_template'
		local speed_to_second = 90
		local duration = "loop"
		self.areol_level = gui_animate.areol(self, name_template, speed_to_second, duration, function_end, scale)
	end)

	timer_linear.add(self, "set_level", 0.3, function (self)
		-- Анимация изменения номера уровня
		interface_functions.update_level(self, self.current_values.level)
		gui.animate(node_level_text, 'scale', vmath.vector3(1.3), gui.EASING_LINEAR, 0.2, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)
	end)

	timer_linear.add(self, "set_level", 1.7, function (self)
		-- Анимация уменьшения плашки с уровнем
		-- Красим линию в обычный цвет
		gui_loyouts.set_blend_mode(self, node_line, gui.BLEND_ADD)
		-- Возвращаем линию в нулевое положение
		gui.animate(node_line, 'fill_angle', M.min_line, gui.EASING_OUTSINE, duration_animate)
		if  self.areol_level then
			self.areol_level.stop(self)
		end

		gui_loyouts.set_blend_mode(self, node_line, gui.BLEND_ADD)
		timer.delay(duration_animate, false, function (self)
			self.animate_up_level = nil
		end)
		
		gui.animate(node_wrap, 'scale', 1, gui.EASING_LINEAR, duration_animate, delay, function (self)

			if self.current_values.level < storage_player.level then
				M.set_level(self, self.current_values.level, function_end)
			else
				-- Завершаем анимацию повышения уровня
				-- Отрисовываем линию опыта с очками, которые приходили за время анимации
				local score_player_data = core_player_function.get_level_data_user()
				M.set_score_line(self, score_player_data.procent_to_next_level)

				-- запускаем функцию после окончания, сели она есть
				if function_end then
					function_end(self)
				end
			end
		end)
	end)
end

return M