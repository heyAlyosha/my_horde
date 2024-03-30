-- ИИ вожака зомби
local M = {}

-- Поиск цели вокруг
function M.search_target(self)
	if not self.view then
		local distantion_visible = 150
		self.view = ai_core.view(self, function (self, visible_items)
			if false and visible_items and not self.no_view then
				-- Есть цели вокруг
				local visible_item = visible_items[1].url

				if go_controller.is_object(visible_item)  then
					-- Помечаем целью
					ai_attack.add_target(self, visible_item)

					self.condition_ai = hash("to_target")
					M.behavior(self)
				end

				if not self.target or (self.target_current_useful and self.target_current_useful < visible_item.target_useful) then
					-- Если нет цели
					
				end
			else
				-- Целей нет
				--self.condition_ai = nil
				--M.behavior(self)
			end
		end, self.exclude_commands_view, distantion_visible)
	end
end

-- Поведение
function M.behavior(self)
	-- Состояние зомбика
	self.condition_ai = self.condition_ai or nil
	self.dir = self.dir or vmath.normalize(vmath.vector3(math.random(-100, 100), math.random(-100, 100), 0))

	-- Исключаем объекты из атаки
	self.exclude_commands_view = self.exclude_commands_view or {}
	self.exclude_commands_view[hash("building_ruin")] = true
	self.exclude_commands_view[hash("zombie_enemy")] = true

	if not self.no_view then
		M.search_target(self)
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

		local max_cost = 5
		ai_move.move_random(self, max_cost, M.behavior)
	end
end

return M