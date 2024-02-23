-- Анимации
local M = {}

-- Анимации персонажа
function M.play(self, animation_id)
	if animation_id == "move" or animation_id == "idle" then
		if animation_id == "move" then
			self.animation_current = "zombie_0_0_run"
		elseif animation_id == "idle" then
			self.animation_current = "zombie_0_0_default"
		end

		if self.last_animation ~= self.animation_current then
			sprite.play_flipbook("#body", self.animation_current)
			self.last_animation = self.animation_current
		end

	elseif animation_id == "attack" then
		self.hflip_stop = true
		sprite.play_flipbook("#body", "zombie_0_0_attack", function (self)
			self.last_animation = nil
			self.hflip_stop = nil
		end)
	end
end

return M