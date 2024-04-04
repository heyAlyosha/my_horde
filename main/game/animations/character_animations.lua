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

	elseif self.animation_type == hash("soldier") then
		if animation_id == "move" or animation_id == "idle" then
			if animation_id == "move" then
				if self.running then
					self.animation_current = "human_"..self.human_id .. "_walking"
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

		elseif animation_id == "aim" or animation_id == "attack" then
			self.animation_current = "human_"..self.human_id .. "_"..animation_id
			self.last_animation = self.animation_current
			sprite.play_flipbook("#body", self.animation_current)
		end

	else
		
		if animation_id == "move" or animation_id == "idle" or animation_id == "win" then
			if animation_id == "move" then
				self.animation_current = "run"
			elseif animation_id == "idle" then
				self.animation_current = "default"
			elseif animation_id == "win" then
				self.animation_current = "win"
			end

			if self.last_animation ~= self.animation_current then
				game_content_skins.play_flipbook(self, "#body", self.skin_id, self.human_id, self.animation_current)
				self.last_animation = self.animation_current
			end

		elseif animation_id == "attack" then
			self.hflip_stop = true
			game_content_skins.play_flipbook(self, "#body", self.skin_id, self.human_id, animation_id)

			timer.delay(0.1, false, function (self)
				self.hflip_stop = nil
				self.last_animation = nil
			end)
		end
	end
	
end

-- Анимация дамага
function M.damage(self, from_object_damage, handle)
	self.damage_animate_x = self.damage_animate_x or 5
	self.damage_animate_y = self.damage_animate_y or 5
	-- Анимация дамага
	if not self.particle then
		local duration = 0.15
		local position = go.get_position()
		local last_position = go.get_position()
		local dir = go.get_position(from_object_damage) - position
		local particle_name

		-- Отпрыгивание
		if dir.x < 0 then
			position.x = position.x + self.damage_animate_x
			particle_name = "#blood_right"
		else
			position.x = position.x - self.damage_animate_x
			particle_name = "#blood_left"
		end
		
		-- Если есть коллизии
		local collision = physics.raycast(go.get_position(), position, {hash("default")}, options)

		if collision then
			--position.x = go.get_position().x
			position = position + collision.normal * collision.fraction
		end

		--position.y = position.y + self.damage_animate_y
		
		
		position = position_functions.go_get_perspective_z(position)

		if not self.animate_position_damage then
			self.animate_position_damage = true
			--M.play(self, "idle")
			go.animate(".", "position.x", go.PLAYBACK_ONCE_FORWARD, position.x, go.EASING_LINEAR, duration, 0)
			go.animate(".", "position.y", go.PLAYBACK_ONCE_PINGPONG, position.y + self.damage_animate_y, go.EASING_LINEAR, duration, 0)
			go.animate(".", "position.z", go.PLAYBACK_ONCE_FORWARD, position.z, go.EASING_LINEAR, duration, 0)
			live_bar.position_to(self, position, duration)

			timer.delay(duration, false, function (self)
				local dir_from = go.get_position() - last_position
				if self.damage_animate_x > 0 and vmath.length(dir_from) > 0 then
					M.play(self, "move")
					--sprite.set_hflip("#body", dir_from.x > 0)
					
					go.animate(".", "position", go.PLAYBACK_ONCE_FORWARD, last_position, go.EASING_LINEAR, duration, 0, function (self)
						M.play(self, "idle")
					end)

					local delay = self.damage_interval_move or duration + 0.5
					timer.delay(delay, false, function (self)
						self.animate_position_damage = nil
					end)
				else
					self.animate_position_damage = nil
					--M.play(self, "idle")
				end
			end)
		end

		-- Покраснение
		go.set("#body", "tint", vmath.vector4(1, 0.3, 0.3, 1)) -- <1>

		-- Кровь
		if self.damage_blood then
			particlefx.play(particle_name)
		end

		--self.particle = true
		timer.delay(duration, false, function (self)
			go.set("#body", "tint", vmath.vector4(1, 1, 1, 1)) -- <1>
			self.particle = nil

			if handle then
				handle(self)
			end
		end)
	end
end


function M.damage_zombie_horde(self, from_object_damage, handle)
	local duration = 0.2
	-- Анимация дамага
	if not self.particle then
		-- Покраснение
		go.set("#body", "tint", vmath.vector4(1, 0.6, 0.6, 1)) -- <1>

		--self.particle = true
		timer.delay(duration, false, function (self)
			go.set("#body", "tint", vmath.vector4(1, 1, 1, 1)) -- <1>
			self.particle = nil

			if handle then
				handle(self)
			end
		end)
	end
end

function M.damage_player(self, from_object_damage)
	-- Анимация дамага
	if not self.particle then
		local duration = 0.1
		local position = go.get_position()
		local dir = go.get_position(from_object_damage) - position
		local particle_name

		-- Отпрыгивание
		position.y = position.y + 3
		if dir.x < 0 then
			position.x = position.x + 3
			particle_name = "#blood_right"
			--camera.recoil(camera_id, vmath.vector3(-3,3, 0), duration)
		else
			position.x = position.x - 3
			particle_name = "#blood_left"
			--camera.recoil(camera_id, vmath.vector3(3,3, 0), duration)
		end
		position = position_functions.go_get_perspective_z(position)
		--camera.unfollow(camera_id, ".")
		--go.animate(".", "position.x", go.PLAYBACK_ONCE_FORWARD, position.x, go.EASING_LINEAR, duration, 0)
		--go.animate(".", "position.y", go.PLAYBACK_ONCE_PINGPONG, position.y, go.EASING_LINEAR, duration, 0)
		--camera.shake(camera_id, 0.005, 0.1)

		--[[
		go.animate("camera", "position", go.PLAYBACK_ONCE_FORWARD, go.get_position(), go.EASING_LINEAR, duration, duration, function (self)
			--camera.follow(camera_id, go.get_id())
		end)
		--]]

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
			
			--go.cancel_animations("camera", "position")
			if self.timer_camera_animation then
				timer.cancel(self.timer_camera_animation)
				self.timer_camera_animation = nil
			end
			self.timer_camera_animation = timer.delay(0.5, false, function (self)
				
			end)
		end)
	end
end

-- Старение
function M.aging_zombie(self, no_effect)
	local step_aging 
	local procent_live = self.live/self.max_live

	if procent_live < 0.2  then
		step_aging = "very-old"
	elseif procent_live < 0.4 then
		step_aging = "old"
	end

	if self.step_aging ~= step_aging then
		if not no_effect then
			msg.post(storage_game.map.url_script, "effect", {
				position = go.get_position(),
				animation_id = hash("destroy"), 
				timer_delete = 0
			})
		end
		game_content_skins.play_flipbook(self, "#body", self.skin_id, self.human_id, self.animation_current or self.animation_horde or "run")
		self.step_aging = step_aging
	end
end
return M