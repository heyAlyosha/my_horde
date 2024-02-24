-- Поведение на секторе удвоение очков
local M = {}

local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_step_next  = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_next"
local game_core_round_step_sector_catch = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_catch"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local lang_core = require "main.lang.lang_core"
local timer_linear = require "main.modules.timer_linear"

-- Наступил на сектор с пропуском хода
function M.start(self, sector, delay)
	local score = sector.value.score
	local text_leader, text_table
	local layout = core_layouts.get_data()
	local player = layout.data.player
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	-- Пропуск хода
	local score = player.score

	msg.post("main:/sound", "play", {sound_id = "response-error"})
	msg.post("main:/sound", "play", {sound_id = "ovation_fail"})

	start_text_leader = lang_core.get_text(self, "_leader_your_skip_move", before_str, after_str, {name = player.name})
	game_core_round_functions.bubble_leader(self, start_text_leader)

	-- Оберег
	local player_id = player.player_id
	local is_game = true

	if not game_core_round_functions.is_obereg(self, player_id, is_game, is_reward) then
		-- Если нет оберега
		timer_linear.add(self, "sector_core", 2, function (self)
			game_core_round_step_next.start_fail(self)
		end)

	else
		-- Предлагаем использовать оберег через время и сбрасываем
		timer_linear.add(self, "sector_core", 2, function (self)
			if player.type ==  "player" then
				local score = 0
				game_core_round_step_sector_catch.visible_obereg(self, "skipping", score, "trap_3")

			elseif player.type ==  "bot" then
				game_core_round_step_sector_catch.obereg(self, "skipping", true)

			end
		end)
		is_break = true
	end

	is_break = true

	return start_text_leader, start_text_leader, delay, is_break
end

-- После сектора показывают окно для выбора буквы
function M.get_keyboard(self, sector, delay)
	local start_text_leader, start_text_tablo, is_break
	local layout = core_layouts.get_data()
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	-- Предлагаем использовать оберег через время и сбрасываем
	timer_linear.add(self, "sector_core", 2, function (self)
		if player.type ==  "player" then
			local score = 0
			game_core_round_step_sector_catch.visible_obereg(self, "skipping", score, "trap_3")

		elseif player.type ==  "bot" then
			game_core_round_step_sector_catch.obereg(self, "skipping", true)

		end
	end)

	start_text_leader = lang_core.get_text(self, "_leader_error_blocking_keyboard", before_str, after_str, values)

	return start_text_leader, start_text_leader, delay, is_break
end


return M