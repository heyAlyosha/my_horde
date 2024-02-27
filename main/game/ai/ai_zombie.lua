-- ИИ зомби
local M = {}

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

	else
		pprint("object_visible_kill")
		ai_attack.delete_target(self, self.target)
		ai_core.clear_coditions(self)

		-- Обозреваем вокруг
		if not self.view then
			self.view = ai_core.view(self, function (self, visible_items)
				pprint("self.view", visible_items)
				if visible_items then
					ai_core.condition_attack(self, visible_items[1].url)
					return true
				end
			end)
		end

	end

	-- Обозреваем вокруг
	if not self.view then
		self.view = ai_core.view(self, function (self, visible_items)
			
			if visible_items then
				ai_core.condition_attack(self, visible_items[1].url)
				return true
			end
		end)
	end
end

return M