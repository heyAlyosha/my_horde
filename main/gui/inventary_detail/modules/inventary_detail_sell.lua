-- функции для показа и отрисовки подробностей об объекте
local M = {}

local game_content_prize = require "main.game.content.game_content_prize"
local game_content_artifact = require "main.game.content.game_content_artifact"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local gui_text = require "main.gui.modules.gui_text"
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local sound_render = require "main.sound.modules.sound_render"

-- Функция продажи
function M.sell(self, id, type)
	local type = "prize"

	if type == "prize" then
		gui_input.set_disabled(self, self.btns[1], true)
		self.content = game_content_prize.get_prize(id)

		-- Анимация уменьшения
		self.scale_prize = gui.get_scale(self.nodes.img)
		gui.animate(self.nodes.img, "scale", vmath.vector3(0), gui.EASING_INOUTBACK, 0.25, 0, function (self)
			sound_render.play("sell")
			msg.post("main:/core_player", "sell", {
				type = "prize",
				count = 1,
				id = id,
			})
		end)
	end
end

-- Успешная продажа
function M.result_sell(self, status, object, type_object, coins, score, inventary_detail_function)
	if status == "error" then
		-- Если ошибка при продаже
		inventary_detail_function.render(self, "prize", self.content.id)
		gui_input.set_disabled(self, self.btns[1], false)

		return false
	elseif status == "success" then
		-- Выпадение кучи монеток и опыта
		local end_position = gui.get_screen_position(gui.get_node("gift_target"))

		msg.post("/loader_gui", "set_status", {
			id = "add_balance",
			type = "stack", -- Обычный перелёт или куча
			setting_stack ={
				score = score,
				coins = coins,
				end_position = end_position,
				height_flight = 300,
				random_height = 50,
				random_width = 400,
			}, -- Настройки для кучи
			start_position = gui.get_screen_position(self.nodes.img),
			value = 0
		})

		inventary_detail_function.render(self, "prize", object.id)

		gui.set_scale(self.nodes.img, self.scale_prize)

		if object.count >= 1 then
			gui_input.set_disabled(self, self.btns[1], false)
		end
	end
end

return M