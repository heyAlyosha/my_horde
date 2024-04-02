-- ИИ вожака зомби
local M = {}

-- Поиск цели вокруг
function M.search_target(self)
	local distantion_visible = 150
	local visible_items = ai_vision.get_visible(self, self.visible_object_id, distantion_visible, self.exclude_commands_view)

	if visible_items and #visible_items > 0 then
		-- Есть враги
		local visible_item
		-- Смотрим есть ли орды зомби вокруг
		for i, item in ipairs(visible_items) do
			local url_script = go_controller.url_script(item.url)
			local type_object = go.get(url_script, "type_object")

			if type_object == hash("zombie_main") then
				-- Смотрим размер орды противника
				local size_horde = go.get(url_script, "size_horde")
				local relation_hordes = 0

				if size_horde > 0 then
					relation_hordes = size_horde / self.size_horde
				end

				if relation_hordes >= 1.2 then
					-- Если орда врага намного больше, убегаем
					self.from_target = item.url
					self.condition_ai = hash("from_target")
					M.behavior(self)
					return

				elseif relation_hordes <= 0.8 then
					-- Если орда врага намного меньше
					pprint("relation_hordes")
					ai_attack.add_target(self, item.url)
					self.condition_ai = hash("to_target")
					M.behavior(self)
					return
				else
					-- Если орда врага приблизительно равна, ничего не делаем
				end
			end
		end
		visible_item = visible_items[1]

		if go_controller.is_object(visible_item.url) and not self.target or (self.target_current_useful and self.target_current_useful < visible_item.target_useful)  then
			-- Помечаем целью
			print("-- Помечаем целью")
			ai_attack.add_target(self, visible_item.url)
			self.condition_ai = hash("to_target")
			M.behavior(self)
		else
			print("else -- Помечаем целью")
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
	print("self.condition_ai", self.condition_ai)
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
			print("handle_error")
		end

		-- Добежал до цели
		local handle_success = function (self)
			print("handle_success")
			self.not_search_target = true
			character_animations.play(self, "idle")
			if not self.target or not go_controller.is_object(self.target) or vmath.length(go.get_position(self.target) - go.get_position()) > 150 then
				-- Цель пропала, гуляет
				ai_attack.delete_target(self, self.target)
				self.condition_ai = nil
				M.behavior(self)

			else
				-- Добежали до цели
				local url_script = go_controller.url_script(self.target)
				local type = url_script
				ai_attack.delete_target(self, self.target)
				self.condition_ai = nil
				M.behavior(self)
			end
		end

		if self.target and go_controller.is_object(self.target) then
			local url_script = go_controller.url_script(self.target)
			local type_object = go.get(url_script, "type_object")
			-- Если это вожак зомби 
			pprint("type_object", type_object, self.is_circle_horde)
			if type_object == hash("zombie_main") and not self.is_circle_horde then
				pprint("ai_move.stop")
				ai_move.stop(self)
				-- Начинаем вращение
				horde_circle.set(self, true, function (self)
					pprint("horde_circle_set")
					ai_core.condition_attack(self, self.target, handle_success, handle_error, handle_success)
				end)

				return
			else
				ai_core.condition_attack(self, self.target, handle_success, handle_error, handle_success)
			end

			return
			
		else
			-- Цели нет или она исчезла
			self.condition_ai = nil   
			M.behavior(self)
			return
		end
	end

	if self.is_circle_horde then
		horde_circle.set(self, false)
	end

	-- Убегает
	if self.condition_ai == hash("from_target") then
		self.speed = self.speed_attack

		local max_cost = 5
		if go_controller.is_object(self.from_target)  then
			local dir = vmath.normalize((go.get_position() - go.get_position(self.from_target)))
			ai_move.move_random(self, max_cost, M.search_target)

		else
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