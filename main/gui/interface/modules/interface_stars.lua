-- Функции для отрисовки звёздочек в интерфейсе
local M = {}

local storage_player = require "main.storage.storage_player"
local core_player_function = require "main.core.core_player.modules.core_player_function"
local gui_size = require "main.gui.modules.gui_size"
local gui_animate = require "main.gui.modules.gui_animate"
local timer_linear = require "main.modules.timer_linear"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local lang_core = require "main.lang.lang_core"

-- Добавил или убавили звёздочки
function M.visible(self, visible)
	self.visible_stars = visible
	gui_loyouts.set_enabled(self, self.nodes.stars_wrap, visible)
end

-- Добавил или убавили звёздочки
function M.set_star(self, stars, unwrap)
	timer_linear.add(self, "stars", 0, function (self)
		if self.set_star_timer then
			self.set_star_timer.stop(self)
			self.set_star_timer = nil
		end
		msg.post("main:/sound", "play", {sound_id = "modal_top_2_2"})
		self.set_star_timer = gui_animate.areol(self, "aoreol_template", speed_to_second, "loop", function_end, scale)
		gui.animate(self.nodes.stars_wrap, "scale", vmath.vector3(1.1), gui.EASING_LINEAR, 0.25)
	end)
	
	-- Анимация звёздочек
	timer_linear.add(self, "stars", 1, function (self)
		for star_i = 1, 3, 1 do
			local node_star = self.nodes["star_"..star_i]
			local sprite = gui.get_flipbook(node_star)
			local get_active = sprite == hash("star_active")
			local set_active = star_i <= stars

			if set_active ~= get_active then
				gui_animate.set_star(self, node_star, duration, delay, function_end_animation, set_active)
				gui_animate.set_star(self, self.nodes["list_item_"..star_i].icon, duration, delay, function_end_animation, set_active)
			end
		end
	end)

	timer_linear.add(self, "stars", 0.5, function (self)
		self.set_star_timer.stop(self)
		self.set_star_timer = nil
		gui.animate(self.nodes.stars_wrap, "scale", vmath.vector3(1), gui.EASING_LINEAR, 0.25)
	end)

	--
	if unwrap and stars < 3 then
		
		timer_linear.add(self, "stars", 0.5, function (self)
			M.unwrap(self, true, true)
		end)
		timer_linear.add(self, "stars", 5, function (self)
			M.unwrap(self, false, true)
		end)
		
	end
end

return M