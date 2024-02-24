-- Функции для разных этапов игры
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_round_step_start = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_start"
local game_core_round_step_sector = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector"
local game_core_round_player_win = require "main.game.core.round.modules.game_core_round_player_win"
local game_core_round_player_defeat = require "main.game.core.round.modules.game_core_round_player_defeat"
-- Ловим события
function M.on_event(self, message_id, message)
	local layout = core_layouts.get_data()
	if layout.id == "round_game" and layout.data.step == "start" then
		game_core_round_step_start.on_event(self, message_id, message)

	elseif layout.id == "round_game" and layout.data.step == "sector" then
		game_core_round_step_sector.on_event(self, message_id, message)

	elseif layout.id == "round_game" and layout.data.step == "win" then
		game_core_round_player_win.on_event(self, message)

	elseif layout.id == "round_game" and layout.data.step == "fail" then
		game_core_round_player_defeat.on_event(self, message)

	end

end

return M