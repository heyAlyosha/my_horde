-- Put functions in this file to use them in several other scripts.
local M = {}

local gui_input = require "main.gui.modules.gui_input"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_animate = require "main.gui.modules.gui_animate"
local gui_lang = require "main.lang.gui_lang"
local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"

function M.render_timeline(self)
	for i, item in ipairs(self.timeline) do
		if item.type == "touch" then
			local position_end

			if item.gui_object_end then
				-- Есть объекты для курсора
				local id_comonent = item.gui_object_end.id_comonent
				local node_name = item.gui_object_end.node_name

				if id_comonent and node_name then
					position_end = gui.screen_to_local(self.nodes.cursor, storage_gui.positions[id_comonent][node_name])
				else
					return false
				end

			elseif item.position_end then
				-- Есть точные координаты
				position_end = gui.screen_to_local(self.nodes.cursor, item.position_end)

			else 
				return false
			end

			gui.set_render_order(item.set_order or 15)
			gui_loyouts.set_position(self, self.nodes.cursor, position_end)
			gui_loyouts.set_enabled(self, self.nodes.cursor, true)

			gui.cancel_animation(self.nodes.cursor, "scale")
			if self.timer_pulse then
				timer.cancel(self.timer_pulse)
			end

			gui_loyouts.set_scale(self, self.nodes.cursor, vmath.vector3(storage_player.zoom))

			local scale = gui.get_scale(self.nodes.cursor)
			local duration = 0.4
			gui_animate.show_elem_popping(self, self.nodes.cursor, duration, delay, function_end_animation)
			gui.animate(self.nodes.cursor, "scale", scale * 0.75, gui.EASING_LINEAR, duration, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)
			self.timer_pulse = timer.delay(1.5, true, function (self)
				gui.animate(self.nodes.cursor, "scale", scale * 0.75, gui.EASING_LINEAR, duration, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)
			end)

		end
	end
end

return M