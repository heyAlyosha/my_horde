-- ИИ зомби
local M = {}

-- Состояние атаки
function M.condition_attack(self, url)
	self.condition = hash("attack")
	self.target = url

	self.is_attack = true

	local function handle_success(self)
		print("Success")
	end

	local function handle_error(self, error_code)
		print("Error", error_code)
	end

	ai_attack.add_target(self, self.target)
	ai_move.move_to_object(self, self.target, handle_success, handle_error, handle_no_object_target)
	self.check_attak = M.check_distantion_attack(self, self.target)
end

-- Получение места в орде
function M.get_horde_position(self)
	local url_script = msg.url(self.parent.socket, self.parent.path, "script")
	local target_add_horde = go.get(url_script, "target_add_horde")
	local dir = target_add_horde - go.get_position(self.target)
	return dir, target_add_horde
end

-- Возвращение в орду
function M.condition_to_horde(self)
	self.condition = hash("run_to_horde")
	self.target = self.parent

	-- Находим место в орде
	if go_controller.url_to_key(self.parent) ~= go_controller.url_to_key(msg.url()) then
		self.target_vector, self.target_add_horde = M.get_horde_position(self)

		local function handle_success(self)
			msg.post(self.parent, "add_horde", {
				skin_id = self.skin_id,
				human_id = self.human_id,
			})
			go.delete()
		end

		local function handle_error(self, error_code)
			self.target_vector, self.target_add_horde = M.get_horde_position(self)
			local duration = vmath.length(self.target_add_horde - go.get_position()) / self.speed
			go.animate(go.get_id(), "position", go.PLAYBACK_ONCE_FORWARD, self.target_add_horde, go.EASING_LINEAR, duration, 0, function (self)
				msg.post(self.parent, "add_horde", {
					skin_id = self.skin_id,
					human_id = self.human_id,
				})
				go.delete()
			end)
		end

		local function handle_item_move(self)
			--self.target_vector, self.target_add_horde = M.get_horde_position(self)
		end

		ai_attack.add_target(self, self.target)
		ai_move.move_to_object(self, self.target, handle_success, handle_error, handle_no_object_target, handle_item_move)
	end

	-- Обозреваем вокруг
	if not self.view then
		self.view = ai_core.view(self, function (self, visible_items)
			if visible_items then
				ai_zombie.condition_attack(self, visible_items[1].url)
				return true
			end
		end)
	end
end

-- Дистанция для атаки
function M.check_distantion_attack(self, url)
	local function attack(self)
		if ai_attack.check_distance_attack(self, url) then
			ai_move.stop(self)
			self.fire = M.fire(self, self.target)
		end
	end

	local function stop(self)
		if self.timer_check_distation_attack then
			timer.cancel(self.timer_check_distation_attack)
			self.timer_check_distation_attack = nil
		end
	end

	stop(self)

	-- Высчитываем дистанцию
	attack(self)
	self.timer_check_distation_attack = timer.delay(0.2, true, function (self)
		attack(self)
	end)

	return {stop = stop}
end


-- Дистанция для атаки
function M.check_distantion_attack(self, url)
	local function attack(self)
		if ai_attack.check_distance_attack(self, url) then
			ai_move.stop(self)
			self.fire = M.fire(self, self.target)
		end
	end

	local function stop(self)
		if self.timer_check_distation_attack then
			timer.cancel(self.timer_check_distation_attack)
			self.timer_check_distation_attack = nil
		end
	end

	stop(self)

	-- Высчитываем дистанцию
	attack(self)
	self.timer_check_distation_attack = timer.delay(0.2, true, function (self)
		attack(self)
	end)

	return {stop = stop}
end

-- Огонь или удар по противнику
function M.fire(self, url)
	local function fire(self)
		character_attack.attack(self, url)
	end

	local function stop(self)
		if self.timer_fire then
			timer.cancel(self.timer_fire)
			self.timer_fire = nil
		end
	end

	stop(self)

	fire(self)
	self.timer_fire = timer.delay(self.speed_damage, true, function (self)
		fire(self)
	end)

	return {
		stop = stop
	}
end

-- Очитска состояний и таймеро
function M.clear_coditions(self, url)
	self.condition = nil

	if self.view then
		self.view.stop(self)
	end

	if self.fire then
		self.fire.stop(self)
	end

	if self.check_attak then
		self.check_attak.stop(self)
	end
end

return M