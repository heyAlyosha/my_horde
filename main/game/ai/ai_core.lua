-- Ядро ИИ
local M = {}

-- Состояние атаки
function M.condition_attack(self, url, handle_success, handle_error, handle_fire)
	self.condition = hash("attack")
	self.target = go_controller.url_object(url)
	self.is_attack = true

	local handle_success = handle_success or function (self)
		if not ai_attack.check_distance_attack(self, url, handle_distantion_error) then
			M.condition_attack(self, url, handle_success, handle_error)
		end
	end

	local handle_error = handle_error or function (self, error_code)
		print("Error", error_code)
	end

	-- Расстояние до цели
	local function handle_distantion_success(self)
		ai_move.stop(self)
		self.fire = ai_core.fire(self, self.target, handle_fire)
	end
	local function handle_distantion_error(self)
		ai_core.clear_coditions(self, url)
		M.condition_to_horde(self)
	end

	--[[
	if not self.last_target or go_controller.url_to_key(self.target) ~= go_controller.url_to_key(self.last_target) then
		
		print("condition_attack", self.last_target, self.target, go_controller.url_to_key(self.target) ~= go_controller.url_to_key(self.last_target))
	end
	--]]

	ai_attack.add_target(self, self.target)
	ai_move.move_to_object(self, self.target, handle_success, handle_error, handle_no_object_target)

	--self.check_attak = ai_core.check_distantion_attack(self, self.target, handle_distantion_success, handle_distantion_error)
end

-- Обзор окружения
function M.view(self, handle_enemy, exclude_commands)
	local function view(self)
		local visible_items = ai_vision.get_visible(self, self.visible_object_id, self.distantion_visible, exclude_commands)

		if visible_items and #visible_items > 0 then
			-- Есть враги
			if handle_enemy then
				if handle_enemy(self, visible_items) and self.view then
					self.view.stop(self)
				end
			end

		else
			handle_enemy(self, false)
		end
	end

	local function stop(self)
		if self.timer_view then
			timer.cancel(self.timer_view)
			self.timer_view = nil
			self.view = nil
		end
	end

	stop(self)

	-- Смотрим вокруг
	view(self)
	self.timer_view = timer.delay(self.time_view, true, function (self)
		view(self)
	end)

	return {stop = stop}
end

-- Дистанция для атаки
function M.check_distantion_attack(self, url, handle_success, handle_error)
	local function attack(self)
		if ai_attack.check_distance_attack(self, url, hendle_error) then
			if handle_success then
				handle_success(self)
			end
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

-- Огонь или удар по противнику
function M.fire(self, url, handle_fire)
	local handle_fire = handle_fire or function (self)
		--pprint("core_handle_fire")
		character_attack.attack(self, url)
	end

	local function stop(self)
		if self.timer_fire then
			timer.cancel(self.timer_fire)
			self.timer_fire = nil
		end
	end

	stop(self)

	handle_fire(self)
	self.timer_fire = timer.delay(self.speed_damage, true, function (self)
		handle_fire(self)
	end)

	return {
		stop = stop
	}
end


return M