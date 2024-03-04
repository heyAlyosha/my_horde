-- Функции для ползунка
local M = {}

local color = require("color-lib.color")
local gui_size = require "main.gui.modules.gui_size"

M.states = {
	off = {x = 35, img = "btn_circle_bg_red_default"},
	on = {x = 75, img = "btn_circle_bg_green_default"},
}

-- Инициализация
function M.init(self, btn)
	btn.on = btn.on or function (self, value) print("Switch", value) end

	-- Запись значений
	btn.set = function (self, value)
		btn.value = value

		local state
		if btn.value then
			state = M.states.on
		else
			state = M.states.off
		end

		gui.play_flipbook(btn.nodes.circle, state.img)
		gui.animate(btn.nodes.circle, "position.x", state.x, gui.EASING_LINEAR, 0.1)

		btn.on(self, btn.value)
	end
end

return M