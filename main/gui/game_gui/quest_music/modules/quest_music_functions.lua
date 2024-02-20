local M = {}

-- Анимация проигрыша
function M.play_animation(self, duration, function_handler)
	pprint("Привет!")
	gui.animate(self.nodes.notes_active, "size.x", gui.get_size(self.nodes.notes_bg).x, gui.EASING_LINEAR, duration)

	timer.delay(duration, false, function (self)
		if function_handler then
			function_handler(self)
		end
	end)
end

return M