-- Поведение на секторе удвоение очков
local M = {}

local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_step_next  = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_next"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local lang_core = require "main.lang.lang_core"
local timer_linear = require "main.modules.timer_linear"

-- Наступил на сектор с удвоением очков
function M.start(self, sector, delay)
	local score = sector.value.score
	local text_leader, text_table
	local layout = core_layouts.get_data()
	local player = layout.data.player
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	msg.post("main:/sound", "play", {sound_id = "game_result_leaderboard"})
	msg.post("main:/sound", "play", {sound_id = "ovation_success"})

	-- Открытие символа
	local score = player.score
	start_text_leader = lang_core.get_text(self, "_leader_sector_open_symbol", before_str, after_str, {name = player.name})
	game_core_round_functions.bubble_leader(self, start_text_leader, start_text_leader)


	delay = delay + 0.5
	timer_linear.add(self, "sector_core", 0.5, function (self)
		if player.type == "player" then
			-- Показываем окно открытия
			msg.post("/loader_gui", "visible", {
				id = "game_open_symbol",
				visible = true,
				type = hash("animated_close"),
				value = {word = storage_game.game.round.word, open_symbols = storage_game.game.round.disable_symbols}
			})

		elseif player.type == "bot" then
			msg.post("/core_bot", "sector_open_symbol", {player_id = self.player.player_id, bot_id = self.player.bot_id})
		end
	end, delay)

	is_break = true

	return start_text_leader, start_text_leader, delay, is_break
end

-- После сектора показывают окно для выбора буквы
function M.get_keyboard(self, sector, delay)
	local start_text_leader, start_text_tablo, is_break
	local layout = core_layouts.get_data()
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	start_text_leader = lang_core.get_text(self, "_leader_sector_open_symbol_keyboard", before_str, after_str)

	return start_text_leader, start_text_tablo, delay, is_break
end

return M