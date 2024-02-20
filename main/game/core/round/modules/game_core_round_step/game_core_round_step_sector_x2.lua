-- Поведение на секторе удвоение очков
local M = {}

local storage_player = require "main.storage.storage_player"
local storage_gui = require "main.storage.storage_gui"
local storage_game = require "main.game.storage.storage_game"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_step_next  = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_next"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local timer_linear = require "main.modules.timer_linear"
local lang_core = require "main.lang.lang_core"

-- Наступил на сектор с удвоением очков
function M.start(self, sector, delay)
	local score = sector.value.score
	local text_leader, text_table
	local layout = core_layouts.get_data()
	local player = layout.data.player
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	msg.post("main:/sound", "play", {sound_id = "modal_top_2_2"})
	msg.post("main:/sound", "play", {sound_id = "ovation_success"})

	-- Удвоение очков на барабане
	score = game_core_gamers.get_player(self, player.player_id, game_content_wheel).score or 0
	if score <= 0 then
		-- Если у игрока нет очков
		score = 100
		start_text_leader = lang_core.get_text(self, "_leader_sector_x2_no_score", before_str, after_str, {score = score})
	else
		start_text_leader = lang_core.get_text(self, "_leader_sector_x2", before_str, after_str, {score = score})
	end
	game_core_round_functions.bubble_leader(self, start_text_leader, start_text_leader)

	start_text_leader = ""
	start_text_tablo = ""

	timer_linear.add(self, "sector_core", 1.5, function (self)
		game_core_round_transfer.score_leader_to_player(self, score, player.player_id)
	end)

	timer_linear.add(self, "sector_core", 3, function (self)end)

	return start_text_leader, start_text_leader, delay, is_break
end

-- После сектора показывают окно для выбора буквы
function M.get_keyboard(self, sector, delay)
	local start_text_leader, start_text_tablo, is_break
	local layout = core_layouts.get_data()
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	start_text_leader = lang_core.get_text(self, "_leader_sector_x2_keyboard", before_str, after_str)

	return start_text_leader, start_text_leader, delay, is_break
end

return M