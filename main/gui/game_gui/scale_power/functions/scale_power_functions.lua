-- Функции
local M = {}

local gui_scale = require "main.gui.modules.gui_scale"
local color = require("color-lib.color")
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local game_core_gamers = require "main.game.core.game_core_gamers" 
local game_content_wheel = require "main.game.content.game_content_wheel"
local storage_game = require "main.game.storage.storage_game"

-- Показываем
function M.visible(self, data)
	gui_animate.show_bottom(self, self.nodes.wrap, function_after)

	local data = data or {}
	local player_id = data.player_id or "player"
	local gamer = game_core_gamers.get_player(self, player_id, game_content_wheel)
	-- Начальная скорость каретки (сек за туда и обратно)
	self.speed = game_content_wheel.get_speed_aim(self, player_id)

	self.focus_btn_id = nil

	self.animation_scale = gui_scale.start(self, "scale_template", self.speed, M.change_scale, M.stop_scale)
	gui_animate.pulse_loop(self, self.nodes.btn, delay)

	-- Если есть звёзды в мисии, то показываем, что для этого нужно
	if player_id == "player" and storage_game.stars.type then
		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "stars_unwrap",
			values = {
				unwrap = true,
				animated = true
			}
		})
	end
end

-- Изменение каретки
function M.change_scale(self, procent)
	-- Фокусировка на разных частях барабана
	msg.post("game-room:/loader_gui", "set_status", {
		id = "game_wheel",
		type = "focus_wheel",
		visible = true,
		value = {type = "top"}
	})

	msg.post("game-room:/loader_gui", "set_content", {
		id = "game_wheel",
		type = "aim",
		value = {
			procent = 1 - procent
		}
	})
end

-- Остановка каретки
function M.stop_scale(self,procent)
	msg.post("game-room:/loader_gui", "set_content", {
		id = "game_wheel",
		type = "rotate",
		value = {
			procent = 1 - procent
		}
	})
	msg.post("main:/sound", "play", {sound_id = "modal_close_1"})

	msg.post("game-room:/loader_gui", "set_status", {
		id = "game_wheel",
		type = "focus_wheel",
		visible = false,
		value = {type = "bottom/top"}
	})
end

-- Функция закрытия
function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = self.id,
			visible = false,
		})
	end)
end

-- Функция активации
function M.activate(self)
	self.animation_scale.stop(self)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})
	M.hidden(self)
end
	
return M