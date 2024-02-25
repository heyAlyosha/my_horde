-- Анимации
local M = {}

-- Анимации персонажа
function M.play(self, animation_id)
	if animation_id == "move" or animation_id == "idle" then
		if animation_id == "move" then
			self.animation_current = "zombie_"..self.skin_id.."_"..self.human_id.."_run"
		elseif animation_id == "idle" then
			self.animation_current = "zombie_"..self.skin_id.."_"..self.human_id.."_default"
		end

		if self.last_animation ~= self.animation_current then
			sprite.play_flipbook("#body", self.animation_current)
			self.last_animation = self.animation_current
		end

	elseif animation_id == "attack" then
		self.hflip_stop = true
		sprite.play_flipbook("#body", "zombie_"..self.skin_id.."_"..self.human_id.."_attack", function (self)
			self.last_animation = nil
			self.hflip_stop = nil
		end)
	end
end

return M