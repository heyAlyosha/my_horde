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

	local types = {
		coins = {
			node_wrap = self.nodes.coin_wrap,
			node_text = self.nodes.coin
		},
		score = {
			node_wrap = self.nodes.avatar_wrap,
			node_text = self.nodes.score
		},
		xp = {
			node_wrap = self.nodes.xp_wrap,
			node_text = self.nodes.xp
		},
		resource = {
			node_wrap = self.nodes.resource_wrap,
			node_text = self.nodes.resource
		},
	}

	node_wrap = types[type].node_wrap
	node_text = types[type].node_text

	pprint("type", type, node_wrap, node_text)

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

return M