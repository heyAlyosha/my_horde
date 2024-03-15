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

	if not visible then
		--Сбрасываем заполненные звёздочки
		gui.animate(self.nodes.wrap_stars_active, "size.x", 0, gui.EASING_OUTCUBIC, 0.001)
	end
end

-- Добавил или убавили звёздочки
function M.set_star(self, stars, unwrap)
	timer_linear.add(self, "stars", 0, function (self)
		--msg.post("main:/sound", "play", {sound_id = "modal_top_2_2"})
		gui.animate(self.nodes.stars_wrap, "scale", vmath.vector3(0.8), gui.EASING_LINEAR, 0.1)
	end)
	
	-- Анимация звёздочек
	timer_linear.add(self, "stars", 0.1, function (self)
		local size_wrap_start_active = gui.get_size(self.nodes.wrap_stars_bg).x / 3 * stars
		gui.animate(self.nodes.wrap_stars_active, "size.x", size_wrap_start_active, gui.EASING_OUTCUBIC, 0.25)
	end)

	-- Анимация звёздочек
	timer_linear.add(self, "stars", 0.25, function (self)
		gui.animate(self.nodes.stars_wrap, "scale", vmath.vector3(0.75), gui.EASING_LINEAR, 0.1)
	end)
end

return M