-- Анимации
local M = {}

-- Анимации передвижения персонажа
function M.play(self, animation_id)
	if self.animation_type == hash("human") then
		if animation_id == "move" or animation_id == "idle" then
			if animation_id == "move" then
				if self.running then
					self.animation_current = "human_"..self.human_id .. "_running"
				else
					self.animation_current = "human_"..self.human_id .. "_walking"
				end
				
			elseif animation_id == "idle" then
				self.animation_current = "human_"..self.human_id .. "_default"
			end

			if self.last_animation ~= self.animation_current then
				sprite.play_flipbook("#body", self.animation_current)
				self.last_animation = self.animation_current
			end
		end

	else
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
		position = position_functions.go_get_perspective_z(position)
		go.animate(".", "position.x", go.PLAYBACK_ONCE_FORWARD, position.x, go.EASING_LINEAR, duration, 0)
		go.animate(".", "position.y", go.PLAYBACK_ONCE_PINGPONG, position.y, go.EASING_LINEAR, duration, 0)

		-- Покраснение
		go.set("#body", "tint", vmath.vector4(1, 0.6, 0.6, 1)) -- <1>

		-- Кровь
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