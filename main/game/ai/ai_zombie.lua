-- ИИ зомби
local M = {}

-- Атака
function M.condition_attack(self, url)
	pprint("condition_attack")
	-- НЕ может найти путь для атаки
	local handle_error = function (self, error_code)
		pprint("handle_error", ai_attack.check_distance_attack(self, url, hendle_error))
		M.condition_to_horde(self)
	end
	-- Добежал до цели
	local handle_success = handle_success or function (self)
		pprint("handle_success", ai_attack.check_distance_attack(self, url, hendle_error))
		if not ai_attack.check_distance_attack(self, url, handle_distantion_error) then
			ai_zombie.condition_attack(self, url)
		else
			ai_zombie.condition_attack(self, url)
		end
	end
	-- Обработка 
	local handle_fire = function (self)
		pprint("handle_fire", ai_attack.check_distance_attack(self, url, hendle_error))
		if ai_attack.check_distance_attack(self, url, hendle_error) then
			character_attack.attack(self, url)

		else
			ai_zombie.condition_attack(self, url, handle_success, handle_error, handle_fire)
		end
	end

	ai_core.condition_attack(self, url, handle_success, handle_error, handle_fire)
end

-- Получение места в орде
function M.get_horde_position(self)
	local url_script = msg.url(self.parent.socket, self.parent.path, "script")
	local target_add_horde = go.get(url_script, "target_add_horde")
	local dir = target_add_horde - go.get_position(self.target)
	return dir, target_add_horde
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
	pprint("condition_to_horde")
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

	else
		ai_attack.delete_target(self, self.target)
		ai_core.clear_coditions(self)

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

return M