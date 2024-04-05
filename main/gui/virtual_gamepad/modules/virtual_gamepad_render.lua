local M = {}

local onscreen = require "in.onscreen"
--local storage_player = require "main.storage.storage_player"

function M.on_control(action, node, touch)
	if action == onscreen.BUTTON then
		if touch.pressed then
			M.gamepad_run = true
		elseif touch.released then
			M.gamepad_run = false
		end
	elseif action == onscreen.ANALOG then
		if not touch.released then
			if not M.gamepad_moved then
				M.gamepad_moved = vmath.vector3(0, 0, 0)
			end

			M.gamepad_moved.x = touch.x
			M.gamepad_moved.y = touch.y
			M.gamepad_moved.z = 0

			--M.gamepad_moved = vmath.normalize(M.gamepad_moved)
			if storage_player.user_go_url then
				msg.post(storage_player.user_go_url, "input", {action_id = hash("virtual_stick"), action = {input = M.gamepad_moved}})
			end
		else
			M.gamepad_moved = nil
		end
	elseif action == onscreen.ANALOG_UP then
		if touch.pressed then
			--print("analog stick is pushed up beyond specified threshold")
		end
	end
end

-- Инициализация
function M.init(self)
	self.nodes = {
		stick = gui.get_node("stick"),
		stick_wrap = gui.get_node("stick_wrap"),
		btn = gui.get_node("btn_template/btn")
	}

	gui.set_enabled(self.nodes.stick_wrap, false)

	onscreen.register_analog(gui.get_node("stick"), { radius = gui.get_size(self.nodes.stick_wrap).x / 2, threshold = 1 }, M.on_control)
	onscreen.register_button(gui.get_node("btn_template/btn"), nil, M.on_control)
end

-- Инициализация
function M.on_input(self, action_id, action)
	if action_id == hash("touch") then
		if action.pressed then
			if gui.pick_node(self.nodes.btn, action.x, action.y) then
				-- Нажатие на кнопку
				if storage_player.user_go_url then
					msg.post(storage_player.user_go_url, "input", {action_id = hash("action"), action = {pressed = true}})
				end
			else
				-- Стик
				gui.set_enabled(self.nodes.stick_wrap, true)
				gui.set_position(self.nodes.stick_wrap, vmath.vector3(action.x, action.y, 0))
			end
			
		elseif action.released then
			gui.set_enabled(self.nodes.stick_wrap, false)
			gui.set_position(self.nodes.stick_wrap, vmath.vector3(action.x, action.y, 0))
			gui.set_position(self.nodes.stick, vmath.vector3(0))
		end
	end
	onscreen.on_input(action_id, action)
end

-- Ловим обновление
function M.on_update(s)
end

return M