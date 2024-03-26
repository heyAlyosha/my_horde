-- ИИ зомби
local M = {}

-- Поиск цели вокруг
function M.search_target(self)
	if not self.view then
		self.view = ai_core.view(self, function (self, visible_items)
			if visible_items and not self.no_view then
				-- Есть цель
				local visible_item = visible_items[1]
				-- Если объект существует или он ценнее текущего
				
				if not self.target or (self.target_current_useful and self.target_current_useful < visible_item.target_useful) then
					-- Если нет цели
					if go_controller.is_object(visible_item.url) then
						if self.target and self.target_id_point and go_controller.is_object(self.target) then
							ai_attack.delete_target(self, self.target)
						end

						-- Помечаем целью
						self.target = visible_item.url

						self.condition_ai = hash("to_target")
						M.behavior(self)
					end
				end
			end
		end, self.exclude_commands_view)
	end
end

-- Поведение
function M.behavior(self)
	-- Состояние зомбика
	self.condition_ai = self.condition_ai or nil

	-- Исключаем объекты из атаки
	self.exclude_commands_view = self.exclude_commands_view or {}
	self.exclude_commands_view[hash("building_ruin")] = true

	--pprint("behavior", self.condition_ai, self.target)

	-- ДИСТАНЦИЯ ОТ ПЕРВОНАЧАЛЬНОЙ ТОЧКИ
	if false and not self.check_distantion then
		self.check_distantion = timer.delay(1, true, function (self)
			if self.from_point_position and vmath.length(go.get_position() - self.from_point_position) >= 300 then
				if self.view then
					self.view.stop(self)
				end
				--self.no_view = true
				self.condition_ai = nil
				M.behavior(self)
				return
			else
				self.no_view = nil
			end
		end)
	end

	-- АТАКА
	if self.condition_ai == hash("attack") then
		local handle_fire = function (self)
			if not self.target or not go_controller.is_object(self.target) then
				-- Цель пропала, возвращаемся в орду
				self.condition_ai = nil
				self.no_view = nil
				ai_attack.delete_target(self, self.target)
				M.search_target(self)

				M.behavior(self)

			elseif not ai_attack.check_distance_attack(self, self.target, handle_distantion_error) then
				-- Цель убежала далеко возвращаемся к ней
				self.no_view = true
				self.condition_ai = hash("to_target")
				M.behavior(self)

			else
				-- Цель есть, добежали
				character_animations.play(self, "idle")
				self.no_view = true
				local target_damage = self.target
				character_attack.attack(self, self.target, target_damage)
			end
		end
		if not self.timer_damage then
			handle_fire(self)
			self.timer_damage = timer.delay(self.speed_damage, true, handle_fire)
		end
		return true
	end

	if not self.no_view then
		M.search_target(self)
	end

	-- ОЧИЩАЕМ АТАКУ
	if self.timer_attack then
		timer.cancel(self.timer_attack)
		self.timer_attack = nil
	end
	if self.attack then
		--self.attack.stop(self)
	end

	-- К ЦЕЛИ
	if self.condition_ai == hash("to_target") then
		self.speed = self.speed_attack
		-- Прокладываем путь для атаки
		ai_move.stop(self)

		-- НЕ может найти путь для атаки
		local handle_error = function (self, error_code)
			-- Не может найти путь для атаки, повторяем поиск
			self.condition_ai = nil
			M.behavior(self)
		end

		-- Добежал до цели
		local handle_success = function (self)
			ai_move.stop(self)
			character_animations.play(self, "idle")
			if not self.target or not go_controller.is_object(self.target) then
				-- Цель пропала, гуляет
				ai_attack.delete_target(self, self.target)
				self.condition_ai = nil
				M.behavior(self)

			else
				-- Добежали до цели 
				self.condition_ai = hash("attack")
				M.behavior(self)

			end
		end
		if self.target and go_controller.is_object(self.target) then
			ai_core.condition_attack(self, self.target, handle_success, handle_error)
		else
			-- Цели нет или она исчезла
			self.condition_ai = nil
			M.behavior(self)
		end
	end

	-- ГУЛЯЕТ
	if not self.condition_ai then
		-- Обычная скорость
		self.speed = self.speed_default

		if not self.to_point then
			-- Нет точек следования
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

				--character_animations.play(self, "move")
				ai_move.move_item_from(self, random_position, function (self)
					character_animations.play(self, "idle")
					self.animation_walking = nil
					self.condition_ai = nil
					M.behavior(self)
				end, self.speed)
			else
				-- Просто стоит
				character_animations.play(self, "idle")
				timer.delay(1, false, function (self)
					self.hflip = not self.hflip
					sprite.set_hflip("#body", self.hflip)
					character_animations.play(self, "idle")
					self.animation_walking = nil
					M.behavior(self)
				end)
			end
		else
			-- Точки следования
			self.animation_walking = true
			self.running = self.animation_running
			self.move_to_point = not self.move_to_point
			ai_move.stop(self)

			local function handle_success(self)
				self.animation_walking = nil
				self.condition_ai = nil
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

return M