-- ИИ зомби
local M = {}

-- Поведение стреляющего человека
function M.behavior(self)
	self.exclude_commands_view = self.exclude_commands_view or {}
	self.exclude_commands_view[hash("building_ruin")] = true

	self.view = ai_core.view(self, function (self, visible_items)
		if visible_items then
			-- Бежит к врагу
			self.target = visible_items[1].url
			self.animation_walking = nil
			if go_controller.is_object(self.target) then
				if not self.condition_attack then
					-- Прокладываем путь для атаки
					self.condition_attack = true
					ai_move.stop(self)

					-- НЕ может найти путь для атаки
					local handle_error = function (self, error_code)
						-- Не может найти путь для атаки, повторяем поиск
						self.target = nil
						self.condition_attack = nil
						--M.behavior(self)
					end

					-- Добежал до цели
					local handle_success = function (self)
						if self.target and go_controller.is_object(self.target) and ai_attack.check_distance_attack(self, self.target, handle_distantion_error) then
							character_animations.play(self, "aim")
							-- Атакуем
							local handle_fire = function (self)
								if self.target and go_controller.is_object(self.target) and ai_attack.check_distance_attack(self, self.target, handle_distantion_error) then
									-- Цель есть, атакуем
									
									if not self.is_attack_fire then
										self.is_attack_fire = true
										character_attack.attack(self, self.target)
										self.timer_attack = timer.delay(self.speed_damage, true, function (self, handle)
											print("attack_bullet", self.is_attack_fire)
											if self.target and go_controller.is_object(self.target) and ai_attack.check_distance_attack(self, self.target, handle_distantion_error) then
												character_attack.attack(self, self.target)
												
											else
												
												timer.cancel(handle)
												self.is_attack_fire = nil
												self.target = nil
												self.condition_attack = nil
												M.behavior(self)
											end
										end)
									end
								else
									-- Цели нет, либо убежала далеко, повторяем
									self.target = nil
									if self.attack then
										self.attack.stop(self)
										self.attack = nil
									end
									-- Отключаем атаку
									self.is_attack_fire = nil
									if self.timer_attack then
										timer.cancel(self.timer_attack)
										self.timer_attack = nil
									end
									
									self.condition_attack = nil

									M.behavior(self)
								end
							end
							if self.attack then
								self.attack.stop(self)
								self.attack = nil
							end
							self.attack = ai_core.fire(self, self.target, handle_fire)
						else
							-- Цели нет, подходим
							
							character_animations.play(self, "move")
							self.condition_attack = nil
							self.target = nil
							if self.attack then
								self.attack.stop(self)
								self.attack = nil
							end
							-- Отключаем атаку
							self.is_attack_fire = nil
							if self.timer_attack then
								timer.cancel(self.timer_attack)
								self.timer_attack = nil
							end

							M.behavior(self)
						end
					end
					ai_core.condition_attack(self, self.target, handle_success, handle_error, handle_success)
				end
			else
				-- Цель была удалена
				self.target = nil
				self.condition_attack = nil
				-- Отключаем атаку
				self.is_attack_fire = nil
				if self.timer_attack then
					timer.cancel(self.timer_attack)
					self.timer_attack = nil
				end
				M.behavior(self)
			end
		else
			-- Гуляет
			-- Отключаем атаку
			self.is_attack_fire = nil
			self.condition_attack = nil
			if self.timer_attack then
				timer.cancel(self.timer_attack)
				self.timer_attack = nil
			end

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
							M.behavior(self)
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
						M.behavior(self)
					end
					if self.move_to_point then
						ai_move.move_to_position(self, self.to_point_position, handle_success, handle_error)
					else
						ai_move.move_to_position(self, self.from_point_position, handle_success, handle_error)
					end
				end
			end
		end
	end, self.exclude_commands_view)
end

return M