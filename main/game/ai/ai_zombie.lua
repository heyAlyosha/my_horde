-- ИИ зомби
local M = {}

-- Поведение
function M.behavior(self)
	self.view = ai_core.view(self, function (self, visible_items)
		if self.target and go_controller.is_object(self.target) then
			-- Есть цель и она существует
			-- Следуем к ней
			if not self.condition_attack then
				-- Прокладываем путь для атаки
				self.condition_attack = true
				self.condition_to_horde = nil
				ai_move.stop(self)
				
				-- НЕ может найти путь для атаки
				local handle_error = function (self, error_code)
					-- Не может найти путь для атаки, повторяем поиск
					self.target = nil
					self.condition_attack = nil
					ai_zombie.behavior(self)
				end

				-- Добежал до цели
				local handle_success = function (self)
					if self.target and go_controller.is_object(self.target) and ai_attack.check_distance_attack(self, self.target, handle_distantion_error) then
						-- Атакуем
						local handle_fire = function (self)
							if self.target and go_controller.is_object(self.target) and ai_attack.check_distance_attack(self, self.target, handle_distantion_error) then
								-- Цель есть, атакуем
								if not self.is_attack_fire then
									self.is_attack_fire = true
									character_attack.attack(self, self.target)
									self.timer_attack = timer.delay(self.speed_damage, true, function (self, handle)
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
								self.condition_attack = nil

								-- Отключаем атаку
								self.is_attack_fire = nil
								if self.timer_attack then
									timer.cancel(self.timer_attack)
									self.timer_attack = nil
								end

								ai_zombie.behavior(self)
							end
						end
						self.attack = ai_core.fire(self, self.target, handle_fire)
					else
						-- Цели нет, подходим
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
						ai_zombie.behavior(self)
					end
				end

				ai_core.condition_attack(self, self.target, handle_success, handle_error, handle_success)
			end
			
		else
			-- Нет цели, ищем возможные вокруг
			self.is_attack_fire = nil

			if visible_items then
				for i = 1, #visible_items do
					local visible_item = visible_items[i]
					if go_controller.is_object(visible_item.url) then
						-- Есть объект для атаки
						-- Помечаем целью
						self.target = visible_item.url
						ai_zombie.behavior(self)
						return true
					end
				end

				-- Найденные объекты удалены из игры
				-- Перезапускаем поиск вокруг
				self.target = nil
				self.condition_attack = nil
				ai_zombie.behavior(self)
			else
				-- Цели нет, возвращаемся в орду
				if not self.condition_to_horde then
					-- Ищем путь к месту в орде
					self.condition_to_horde = true
					self.target = nil
					self.condition_attack = nil

					if self.parent and go_controller.url_to_key(self.parent) ~= go_controller.url_to_key(msg.url()) and go_controller.is_object(self.parent) then
						self.target_add_horde = go.get_position(self.parent)
						local function handle_success(self)
							--Добежал до пункта
							-- Цель до орды
							self.target_add_horde = go.get_position(self.parent)

							-- Смотрим дистацию до игрока
							local position_from = go.get_position()
							if horde.check_distantion_add_horde(self, self.parent, position_from, self.target_add_horde) then
								-- Добежал
								msg.post(self.parent, "add_horde", {
									skin_id = self.skin_id,
									human_id = self.human_id,
									position_from = position_from
								})
								go.delete()
							else
								-- До позиции далеко
								self.condition_to_horde = nil
								self.target = nil
								self.condition_attack = nil
								ai_move.stop(self)

								ai_zombie.behavior(self)
							end
						end

						local function handle_error(self, error_code)
							-- Не может найти путь к месту в орде
							self.target_add_horde = go.get_position(self.parent)
							local position_from = go.get_position()
							local duration = vmath.length(self.target_add_horde - position_from) / self.speed
							
							go.animate(go.get_id(), "position", go.PLAYBACK_ONCE_FORWARD, self.target_add_horde, go.EASING_LINEAR, duration, 0, function (self)
								msg.post(self.parent, "add_horde", {
									skin_id = self.skin_id,
									human_id = self.human_id,
									position_from = position_from
								})
								go.delete()
							end)
						end

						-- Пересчитываем каждый тайтл пути
						local handle_item_move = function (self)
							handle_success(self)
						end
						ai_move.move_to_position(self, self.target_add_horde, handle_success, handle_error, handle_no_object_target, handle_item_move)

					else
						--
						ai_attack.delete_target(self, self.parent)
						self.condition_to_horde = nil
						self.target = nil
						self.condition_attack = nil
					end
				end
			end
		end

		if self.condition_to_horde and horde.check_distantion_add_horde(self, self.parent, position_from, position_to) then
			-- Добежал
			local position_from = go.get_position()
			msg.post(self.parent, "add_horde", {
				skin_id = self.skin_id,
				human_id = self.human_id,
				position_from = position_from
			})
			go.delete()
		end
	end)
end

-- Получение места в орде
function M.get_horde_position(self, url)
	local url_script = msg.url(self.parent.socket, self.parent.path, "script")
	local target_add_horde = go.get(url_script, "target_add_horde")
	local dir = target_add_horde - go.get_position(url)
	return dir, target_add_horde
end

return M