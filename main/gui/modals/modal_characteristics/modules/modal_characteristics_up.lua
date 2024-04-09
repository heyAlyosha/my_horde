-- Функция улучшения характеристики
local M = {}

local sound_render = require "main.sound.modules.sound_render"
local gui_input = require "main.gui.modules.gui_input"

function M.activate(self, btn, not_modal)
	local id = btn.id

	if not btn.disabled then
		msg.post("main:/sound", "play", {sound_id = "activate_btn"})
		if btn.is_characteristic then
			--Улучшение
			-- Оплата
			local values = {}
			values[btn.valute] = -btn.price
			msg.post("main:/core_player", "balance", {
				operation = "add",
				values = values,
			})

			-- Улучшение
			msg.post("main:/core_player", "set_characteristic", {
				operation = "add",
				value = 1,
				id = id,
				not_modal = not_modal
			})

			msg.post("main:/core_study", "event", {
				id = "activate_characteristic"
			})

		elseif btn.is_transfer then
			-- Обмен
			local values = {}
			values[btn.valute] = -btn.price
			values[btn.valute_to] = 1

			gui_input.set_disabled(self, btn, true)

			msg.post("main:/core_player", "balance", {
				operation = "add",
				values = values,
			})
		end
	end

	print("activate")

	return self.btns
end

return M