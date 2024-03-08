-- Работа с кнопками пульта
local M = {}

local storage_gui = require "main.storage.storage_gui"

M.pressed_button_id = nil
M.input_back = nil
M.action_id = nil
M.action = nil

-- Активация кнопки назад
function M.activate_back(self)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})
	M.input_back = true

	if self.timer_activate_back then
		timer.cancel(self.timer_activate_back)
		self.timer_activate_back = nil

		msg.post("/loader_gui", "visible", {
			id = "modal_exit",
			visible = true,
			type = hash("animated_close"),
		})
	end

	-- Таймер нажатия, для вызова выхолда по двойному клику
	self.timer_activate_back = timer.delay(0.25, false, function (self)
		self.timer_activate_back = nil
	end)
end

-- Ловит коды в ядре го и отправляет сообщения с управлением
function M.on_input_core(self, action_id, action)
	local msg_action = {action_id = nil, action = {}}

	if M.input_back then
		if hash("back") ~= M.pressed_button_id then
			msg_action.action.pressed = true
			M.pressed_button_id = hash("back")
		else
			M.input_back = nil
		end
		msg_action.action_id = hash("back")


	elseif action_id == hash("raw") then
		print("raw")
		self.last_pressed_button_id = M.pressed_button_id

		for i = 1, #action.gamepad_buttons do
			if action.gamepad_buttons[i] > 0.5 then
				print(i)
				M.pressed_button_id = i
				if i == 13 or i == 5 then
					msg_action.action_id = hash("up")
					--msg.post (current_collection, UP)

				elseif i == 14 or i == 1 then
					--msg.post (current collection, DOWN)
					msg_action.action_id = hash("down")

				elseif i == 15  or i == 4 then
					--msg.post(current_collection, LEFT)
					msg_action.action_id = hash("left")

				elseif i == 16  or i == 2 then
					--msg.post (current collection, RIGHT)
					msg_action.action_id = hash("right")

				elseif i == 8 then
					--msg.post (current collection, RIGHT)
					msg_action.action_id = hash("enter")

				end

				break
			elseif i == #action.gamepad_buttons then 
				M.pressed_button_id = nil

			end
		end

		if self.last_pressed_button_id ~= M.pressed_button_id and M.pressed_button_id then
			msg_action.action.pressed = true
		end

	else
		M.pressed_button_id = nil
	end

	if true and msg_action.action_id then
		for i, modal in ipairs(storage_gui.modals) do
			msg.post(modal.url, "acquire_input_focus")
		end
		for i = #storage_gui.modals, 1, -1 do
			local modal = storage_gui.modals[i]
			msg.post(modal.url, "on_input", msg_action)
		end
	end
end

-- Сообщения
function M.on_message(self, message_id, message, sender)
	if message_id == hash("on_input") then
		self.msg_action = message
	end
end

-- Управление
function M.on_input(self, action_id, action)
	self.msg_action = self.msg_action or {}
	
	if self.msg_action.action_id then
		action_id = self.msg_action.action_id
		action = self.msg_action.action
		self.msg_action = {}
	end

	return action_id, action
end

return M