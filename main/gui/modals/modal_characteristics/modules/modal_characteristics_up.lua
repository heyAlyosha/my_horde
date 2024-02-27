-- Функция улучшения характеристики
local M = {}

local sound_render = require "main.sound.modules.sound_render"

function M.activate(self, btn, not_modal)
	local id = btn.id

	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	msg.post("main:/core_player", "set_characteristic", {
		operation = "add",
		value = 1,
		id = id,
		not_modal = not_modal
	})

	msg.post("main:/core_study", "event", {
		id = "activate_characteristic"
	})

	

	return self.btns
end

return M