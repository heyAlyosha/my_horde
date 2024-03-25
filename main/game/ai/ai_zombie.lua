-- ИИ зомби
local M = {}

-- Поиск цели вокруг
function M.search_target(self)
	if true or not self.view then
		self.view = ai_core.view(self, function (self, visible_items)
			if not self.no_view and visible_items then
				-- Есть цель
				local visible_item = visible_items[1]

				-- Если объект существует или он ценнее текущего
				if not self.target or (self.target_current_useful and self.target_current_useful < visible_item.target_useful) then
					-- Если нет цели
					if go_controller.is_object(visible_item.url) then																																																									
						-- Помечаем целью
						ai_attack.add_target(self, visible_item.url)
						--self.target = visible_item.url

						self.condition_ai = hash("to_target")
						M.behavior(self)
					end
				end
			end
		end)
	end
end

-- Поведение
function M.behavior(self)
	-- Состояние зомбика
	self.condition_ai = self.condition_ai or nil

	M.search_target(self)

	-- ДИСТАНЦИЯ ОТ ИГРОКА
	if not self.check_distantion then
		self.check_distantion = timer.delay(1, true, function (self)
			if self.parent and go_controller.is_object(self.parent) and vmath.length(go.get_position() - go.get_position(self.parent)) >= 150 then
				if self.view then
					self.view.stop(self)
				end
				if self.target then
					ai_attack.delete_target(self, self.target)
				end
				self.no_view = true
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
				M.behavior(self)

			elseif not ai_attack.check_distance_attack(self, self.target, handle_distantion_error) then
				-- Цель убежала далеко возвращаемся к ней
				self.condition_ai = hash("to_target")
				M.behavior(self)

			else
				-- Цель есть, добежали
				character_attack.attack(self, self.target)
			end
		end
		if not self.timer_damage then
			handle_fire(self)
			self.timer_damage = timer.delay(self.speed_damage, true, handle_fire)
		end
		--self.attack = ai_core.fire(self, self.target, handle_fire)
		return true
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
		-- Прокладываем путь для атаки
		

		-- НЕ может найти путь для атаки
		local handle_error = function (self, error_code)
			-- Не может найти путь для атаки, повторяем поиск
			self.condition_ai = nil
			ai_zombie.behavior(self)
		end

		-- Добежал до цели
		local handle_success = function (self)
			if not self.target or not go_controller.is_object(self.target) then
				-- Цель пропала, возвращаемся в орду
				self.condition_ai = nil
				M.behavior(self)

			else
				-- Добежали до цели
				character_animations.play(self, "idle")
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

	-- ВОЗВРАЩАЕТСЯ В ОРДУ
	if not self.condition_ai then
		-- Ищем путь к месту в орде
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
					self.add_horde = true
				else
					-- До позиции далеко
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
					self.add_horde = true
					go.delete()
				end)
			end

			-- Пересчитываем каждый тайтл пути
			local handle_item_move = function (self)
				handle_success(self)
			end
			ai_move.move_to_position(self, self.target_add_horde, handle_success, handle_error, handle_no_object_target, handle_item_move)
		end
	end
end

-- Получение места в орде
function M.get_horde_position(self, url)
	local url_script = msg.url(self.parent.socket, self.parent.path, "script")
	local target_add_horde = go.get(url_script, "target_add_horde")
	local dir = target_add_horde - go.get_position(url)
	return dir, target_add_horde
end

return M