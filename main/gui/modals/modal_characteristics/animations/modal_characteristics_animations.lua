-- Анимации для блока с результатами
local M = {}

local gui_size = require 'main.gui.modules.gui_size'
local gui_animate = require "main.gui.modules.gui_animate"
local sound_render = require "main.sound.modules.sound_render"

-- Анимация улучшения характеристики
function M.up(self, name_template)
	local duration = 2
	local node_icon_wrap = gui.get_node(name_template..'/icon_wrap')
	local node_areola = gui.get_node(name_template..'/aureola-template/wrap')
	self.scale_areol = self.scale_areol or gui.get_scale(node_areola)
	self.scale_icon_wrap = self.scale_icon_wrap or gui.get_scale(node_icon_wrap)

	msg.post("main:/sound", "play", {sound_id = "improve"})

	gui_animate.ray(self, name_template..'/ray_template', duration_ray, function_end)

	timer.delay(0, false, function (self)
		gui.animate(node_icon_wrap, 'scale', self.scale_icon_wrap * 1.15, gui.EASING_LINEAR, 0.15, 0)
		timer.delay(duration - 0.15, false, function (self)
			gui.animate(node_icon_wrap, 'scale', self.scale_icon_wrap, gui.EASING_LINEAR, 0.15, 0)
		end)
		gui_animate.areol(self, name_template..'/aureola-template', speed_to_second, duration, function_end, self.scale_areol)
	end)

end

return M