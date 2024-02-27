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

-- Возвращение в орду
function M.condition_to_horde(self, url)
	self.condition = hash("run_to_horde")
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

	if self.fire then
		pprint(self.fire)
		self.fire.stop(self)
	end

	if self.check_attak then
		self.check_attak.stop(self)
	end
end

return M