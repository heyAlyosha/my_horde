-- ИИ вожака зомби
local M = {}

-- Поиск цели вокруг
function M.search_target(self)
	local distantion_visible = 150
	local visible_items = ai_vision.get_visible(self, self.visible_object_id, distantion_visible, self.exclude_commands_view)

	if visible_items and #visible_items > 0 then
		-- Есть враги
		local visible_item = visible_items[1]

		if go_controller.is_object(visible_item.url) and not self.target or (self.target_current_useful and self.target_current_useful < visible_item.target_useful)  then
			-- Помечаем целью
			ai_attack.add_target(self, visible_item.url)
			self.condition_ai = hash("to_target")
			M.behavior(self)
		else
			ai_attack.delete_target(self, self.target)
			self.condition_ai = nil
			self.not_search_target = true
			M.behavior(self)
		end
	else
		self.condition_ai = nil
		self.not_search_target = true
		M.behavior(self)
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

	-- К ЦЕЛИ
	if self.condition_ai == hash("to_target") then
		self.speed = self.speed_attack

		-- НЕ может найти путь для атаки
		local handle_error = function (self, error_code)
			-- Не может найти путь для атаки, повторяем поиск
			self.condition_ai = nil
			M.behavior(self)
		end

		-- Добежал до цели
		local handle_success = function (self)
			self.not_search_target = true
			character_animations.play(self, "idle")
			if not self.target or not go_controller.is_object(self.target) then
				-- Цель пропала, гуляет
				ai_attack.delete_target(self, self.target)
				self.condition_ai = nil
				M.behavior(self)

			else
				-- Добежали до цели
				ai_attack.delete_target(self, self.target)
				self.condition_ai = nil
				M.behavior(self)
			end
		end

		if self.target and go_controller.is_object(self.target) then
			ai_core.condition_attack(self, self.target, handle_success, handle_error, handle_success)
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

		if not self.not_search_target then
			M.search_target(self)
		end

		local max_cost = 5
		ai_move.move_random(self, max_cost, M.behavior)

		self.not_search_target = nil
	end
end

return M