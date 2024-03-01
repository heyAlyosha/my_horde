-- ИИ зомби
local M = {}

-- Спокойная жизнь бота
function M.live(self)
	self.view = ai_core.view(self, function (self, visible_items)
		if visible_items then
			-- Убегает от врагов
			self.animation_walking = nil
			if not self.animation_run then
				self.running = true
				character_animations.play(self, "move")
				ai_move.move_item_from(self, go.get_position(visible_items[1].url), function (self)
					character_animations.play(self, "idle")
					self.animation_run = nil
				end, self.speed_from)
			end
			--return true
		else
			-- Гуляет
			if not self.to_point then
				-- Нет точек следования
				if not self.animation_walking then
					self.running = self.animation_running
					self.animation_walking = true
					if math.random(1, 4) <= 3 then
						-- рандомное направление
						math.randomseed()
						local random_p
						if not self.random_dir then
							self.random_dir = vmath.vector3(1, 0, 0)
							random_p = math.random(1, 314) / 100
						else
							self.random_dir = self.random_dir
							random_p = math.random(1, 628) / 100
						end
						local rot = vmath.quat_rotation_z(random_p)
						random_position  = vmath.rotate(rot, self.random_dir) * 50 + go.get_position() 

						character_animations.play(self, "move")
						ai_move.move_item_from(self, random_position, function (self)
							self.animation_walking = nil
							character_animations.play(self, "idle")
							M.live(self)
						end, self.speed)
					else
						-- Просто стоит
						timer.delay(2, false, function (self)
							self.hflip = not self.hflip
							sprite.set_hflip("#body", self.hflip)
							character_animations.play(self, "idle")
							self.animation_walking = nil
						end)
					end
				end
			else
				-- Точки следования
				if not self.animation_walking then
					self.animation_walking = true
					self.running = self.animation_running
					self.move_to_point = not self.move_to_point
					ai_move.stop(self)

					local function handle_success(self)
						self.animation_walking = nil
						ai_human.live(self)
					end
					if self.move_to_point then
						ai_move.move_to_position(self, self.to_point_position, handle_success, handle_error)
					else
						ai_move.move_to_position(self, self.from_point_position, handle_success, handle_error)
					end
				end
			end
		end
	end)
end

return M