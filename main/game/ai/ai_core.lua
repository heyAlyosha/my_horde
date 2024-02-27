-- Ядро ИИ
local M = {}

-- Обзор окружения
function M.view(self, handle_enemy)
	local function view(self)
		local visible_items = ai_vision.get_visible(self, self.visible_object_id, self.distantion_visible)

		if visible_items and #visible_items > 0 then
			-- Есть враги
			if handle_enemy then
				if handle_enemy(self, visible_items) and self.view then
					self.view.stop(self)
				end
			end

		else
			handle_enemy(self, false)
		end
	end

	local function stop(self)
		if self.timer_view then
			timer.cancel(self.timer_view)
			self.timer_view = nil
		end
	end

	stop(self)

	-- Смотрим вокруг
	view(self)
	self.timer_view = timer.delay(self.time_view, true, function (self)
		view(self)
	end)

	return {stop = stop}
end


return M