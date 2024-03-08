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
			M.gamepad_moved.z = 1

			M.gamepad_moved = vmath.normalize(M.gamepad_moved)
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
function M.init(s)
	onscreen.register_analog(gui.get_node("stick"), { radius = 40, threshold = 0.9 }, M.on_control)
	onscreen.register_button(gui.get_node("btn_run"), nil, M.on_control)
end

-- Инициализация
function M.on_input(s, action_id, action)
	onscreen.on_input(action_id, action)
end

-- Ловим обновление
function M.on_update(s)
	if M.gamepad_run then
		storage_player.virtual_gamepad.gamepad_run = true
	else
		storage_player.virtual_gamepad.gamepad_run = nil
	end

	if M.gamepad_moved then
		storage_player.virtual_gamepad.moved = M.gamepad_moved
	else
		storage_player.virtual_gamepad.moved = nil
	end
end

return M