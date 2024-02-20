-- Функции Следующего раунда
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"


-- Правильно ответил и продолжает играть
function M.start_success(self, type)
	local type = type or "success"
	local layout = core_layouts.get_data()

	local delay = 2
	timer.delay(delay, false, function (self)

		msg.post("/loader_gui", "visible", {
			id = "keyboard_ru",
			visible = false,
			type = hash("animated_close"),
		})

		msg.post("game-room:/core_game", "event", {id = "get_start_step", index_player = layout.data.index_player, type = type})
	end)
end

-- Неправильно ответил и ход переходит к следующему игроку
function M.start_fail(self)
	local layout = core_layouts.get_data()

	local delay = 1
	timer.delay(delay, false, function (self)
		local index_player = layout.data.index_player
		local gamers = storage_game.game.players
		local next_player

		-- Ищем следующего игрока
		repeat
			index_player = index_player + 1
			if index_player > 3 then
				index_player = 1
			end

			next_player = gamers[index_player]
		until next_player

		msg.post("/loader_gui", "visible", {
			id = "keyboard_ru",
			visible = false,
			type = hash("animated_close"),
		})

		msg.post("game-room:/core_game", "event", {id = "get_start_step", index_player = index_player, type = 'fail'})
	end)

end

return M