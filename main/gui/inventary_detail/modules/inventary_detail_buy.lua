-- функции для показа и отрисовки подробностей об объекте
local M = {}


local game_content_characteristic = require "main.game.content.game_content_characteristic"
local gui_text = require "main.gui.modules.gui_text"
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local sound_render = require "main.sound.modules.sound_render"

-- Функция покупки
function M.buy(self, id, type)
	local type = "artifact"

	if type == "artifact" then
		sound_render.play("buy", url_object)
		gui_input.set_disabled(self, self.btns[1], true)
		gui_animate.activate(self, self.btns[1].node)
		--gui_input.render_btns(self, self.btns)
		self.content = game_content_artifact.get_item(id)

		-- ОТправляем запрос на покупку
		msg.post("main:/core_player", "buy", {
			type = "artifact",
			count = 1,
			id = id,
		})
	end
end

-- Покупка за рекламу
function M.reward(self, id, type)
	local type = "artifact"

	if type == "artifact" then
		gui_input.set_disabled(self, self.btns[1], true)
		gui_animate.activate(self, self.btns[1].node)

		-- ОТправляем запрос на покупку
		msg.post("main:/core_reward", 
			"get_reward", {
				type = "artifact", 
				id = id, 
				player_id = "player", 
				is_game = false
			}
		)
	end
end

-- Результат покупки
function M.result(self, status, id, type_object, inventary_detail_function)

	if status == "error" then
		-- Если ошибка при продаже
		inventary_detail_function.render(self, "shop", self.content.id)
		gui_input.set_disabled(self, self.btns[1], false)

		return false
	elseif status == "success" then
		local object = game_content_artifact.get_item(id, player_id, is_game, is_reward)
		inventary_detail_function.render(self, "shop", object.id)

		self._scale_count = self._scale_count or gui.get_scale(self.nodes.count)

		-- Анимация
		gui.set_scale(self.nodes.count, self._scale_count)
		gui.animate(self.nodes.count, "scale", self._scale_count * 1.1, gui.EASING_LINEAR, 0.25, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)

	end
end

return M