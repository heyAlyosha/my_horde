-- Поведение на секторе удвоение очков
local M = {}

local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_step_next  = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_next"
local game_core_round_step_sector_catch = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_catch"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local timer_linear = require "main.modules.timer_linear"
local lang_core = require "main.lang.lang_core"
local game_core_gamers = require "main.game.core.game_core_gamers"

-- Наступил на сектор с удвоением очков
function M.start(self, sector, delay)
	local score = sector.value.score
	local text_leader, text_table
	local layout = core_layouts.get_data()
	local player = game_core_gamers.get_player(self, self.player.player_id, game_content_wheel)
	
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	msg.post("main:/sound", "play", {sound_id = "response-error"})
	msg.post("main:/sound", "play", {sound_id = "ovation_fail"})

	-- Банкрот
	local score = player.score
	start_text_leader = lang_core.get_text(self, "_leader_sector_bankropt", before_str, after_str, {name = player.name})
	game_core_round_functions.bubble_leader(self, start_text_leader, start_text_leader)
	start_text_leader = ""
	start_text_tablo = ""

	-- Оберег
	local player_id = player.player_id
	local is_game = true
	if not game_core_round_functions.is_obereg(self, player_id, is_game, is_reward) then
		-- Если нет оберега - сразу отбираем очки
		delay = delay + 0.5
		timer_linear.add(self, "sector_core", 0.5, function (self)
			game_core_round_transfer.score_player_to_leader(self, score, player.player_id)
		end)
		timer_linear.add(self, "sector_core", 3, function (self)end)
	else
		-- Предлагаем использовать оберег через время и сбрасываем
		delay = delay + 3

		timer_linear.add(self, "sector_core", 3, function (self)
			if player.type ==  "player" then
				game_core_round_step_sector_catch.visible_obereg(self, "bankrupt", score, "trap_3")
			elseif player.type ==  "bot" then
				game_core_round_step_sector_catch.obereg(self, "bankrupt", true)
			end
		end)

		is_break = true
	end

	return start_text_leader, start_text_leader, delay, is_break
end

-- После сектора показывают окно для выбора буквы
function M.get_keyboard(self, sector, delay)
	local layout = core_layouts.get_data()
	local start_text_leader, start_text_tablo, is_break
	local delay = delay or 0

	start_text_leader = lang_core.get_text(self, "_leader_sector_bankropt_keyboard", before_str, after_str, values)

	return start_text_leader, start_text_leader, delay, is_break
end

return M