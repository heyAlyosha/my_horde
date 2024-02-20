local M = {}

function M.debugLog( action , is_gui)
	local add_str = ""
	local str = "gamepad code: ";
	for i = 1, #action.gamepad_axis do
		if math.abs(action.gamepad_axis[i]) > 0.5 then
			add_str = add_str .. " action.gamepad_axis["..i.."]("..action.gamepad_axis[i]..")      "
		end
	end

	for i = 1, #action.gamepad_buttons do
		if action.gamepad_buttons[i] > 0.5 then
			add_str = add_str .. " action.gamepad_buttons["..i.."]("..action.gamepad_buttons[i]..")      "
		end
	end

	for i = 1, #action.gamepad_hats do
		if action.gamepad_hats[i] > 0.5 then
			add_str = add_str .. " action.gamepad_hats["..i.."]("..action.gamepad_hats[i]..")      "
		end
	end

	if add_str and add_str ~= "" then
		str = str .. add_str
	end

	if is_gui then
		gui.set_text(gui.get_node("title"), str)

	else
		label.set_text("/go#value", str)

	end
end

return M