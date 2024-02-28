-- Анимации
local M = {}

-- Анимации передвижения персонажа
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

-- Анимация дамага
function M.damage(self, from_object_damage)
	-- Анимация дамага
	if not self.particle then
		local duration = 0.15
		local position = go.get_position()
		local dir = go.get_position(from_object_damage) - position
		local particle_name

		-- Отпрыгивание
		if dir.x < 0 then
			position.x = position.x + 3
			position.y = position.y + 3
			particle_name = "#blood_right"
		else
			position.x = position.x - 3
			position.y = position.y - 3
			particle_name = "#blood_left"
		end
		go.animate(".", "position.x", go.PLAYBACK_ONCE_FORWARD, position.x, go.EASING_LINEAR, duration, 0)
		go.animate(".", "position.y", go.PLAYBACK_ONCE_PINGPONG, position.y, go.EASING_LINEAR, duration, 0)

		go.set("#body", "tint", vmath.vector4(1, 0.6, 0.6, 1)) -- <1>

		if self.damage_blood then
			particlefx.play(particle_name)
		end
		self.particle = true
		timer.delay(duration, false, function (self)
			go.set("#body", "tint", vmath.vector4(1, 1, 1, 1)) -- <1>
			self.particle = nil
		end)
	end
end

return M