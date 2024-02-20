-- Функции результата раунда
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_gamers = require "main.game.core.game_core_gamers"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_round_step_next = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_next"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_player_defeat = require "main.game.core.round.modules.game_core_round_player_defeat"
local lang_core = require "main.lang.lang_core"
local timer_linear = require "main.modules.timer_linear"

-- Умпешно открытая буква
function M.success_symbol(self, sector, player, symbol, type)
	local type = type or "success"

	local text_leader = lang_core.get_text(self, "_leader_success_symbol", before_str, after_str, {symbol = utf8.upper(symbol)})

	game_core_round_functions.bubble_leader(self, text_leader, text_leader)
	msg.post("game-room:/scene_tablo", "open_symbol", {symbol = symbol})

	local delay = 0

	local score_buff = player.buffs.characteristics.mind or 0
	local score_sector = sector.value.score or 0
	local score = score_sector + score_buff
	-- Выдаём награду
	if score and score > 0 then
		timer_linear.add(self, "step_result", 2, function (self)
			-- Есть приз
			text_leader = lang_core.get_text(self, "_leader_score_to_player", before_str, after_str, {score = score})

			game_core_round_functions.bubble_leader(self, text_leader, text_leader)
			game_core_round_transfer.score_leader_to_player(self, score, player.player_id)
		end)
	end

	-- Открыто ли слово целиком
	delay = delay + 0
	timer_linear.add(self, "step_result", 0, function (self)
		local is_open_word = game_core_round_functions.is_open_word(self)
		if is_open_word then
			msg.post("game-room:/core_game", "event", {
				id = "get_start_game_over",
				player_id = self.player.player_id, type = "open_symbol"
			})
		else
			msg.post("/loader_gui", "visible", {
				id = "keyboard_ru",
				visible = false,
				type = hash("animated_close"),
			})

			-- Продолжаем игру
			game_core_round_step_next.start_success(self, type)

		end
	end)

end

-- Неправильная буква
function M.fail_symbol(self, sector, player, symbol)
	local text_leader = lang_core.get_text(self, "_leader_fail_symbol", before_str, after_str, {score = score})

	game_core_round_functions.bubble_leader(self, text_leader, text_leader)

	timer_linear.add(self, "step_result", 2, function (self)
		game_core_round_step_next.start_fail(self)
	end)
end

-- Правильное слово
function M.success_word(self, sector, player, word, type)
	local type = type or "success"

	timer_linear.add(self, "step_result", 2, function (self)
		msg.post("main:/sound", "play", {sound_id = "response-success"})
		msg.post("main:/sound", "play", {sound_id = "ovation_success"})

		local text_leader = lang_core.get_text(self, "_leader_success_word", before_str, after_str, {})
		game_core_round_functions.bubble_leader(self, text_leader, text_leader)
		msg.post("game-room:/scene_tablo", "open_word", {symbol = symbol})
	end)

	local score_buff = player.buffs.characteristics.mind or 0
	local score_sector = sector.value.score or 0
	local score = score_sector + score_buff

	-- Выдаём награду
	if score and score > 0 then
		timer_linear.add(self, "step_result", 2, function (self)
			-- Есть приз
			text_leader = lang_core.get_text(self, "_leader_score_to_player", before_str, after_str, {score = score})

			game_core_round_functions.bubble_leader(self, text_leader, text_leader)
			game_core_round_transfer.score_leader_to_player(self, score, player.player_id)
		end)
	end

	-- Открыто ли слово целиком
	timer_linear.add(self, "step_result", 2, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_start_game_over",
			player_id = self.player.player_id, type = "full_word"
		})
	end)

end

-- Неправильное слово
function M.fail_word(self, sector, player, word)
	timer_linear.add(self, "step_result", 3, function (self)
		local text_leader = utf8.upper(lang_core.get_text(self, "_leader_fail_word", before_str, after_str, {}))
		game_core_round_functions.bubble_leader(self, text_leader, text_leader)
		msg.post("main:/sound", "play", {sound_id = "ovation_fail"})
		msg.post("main:/sound", "play", {sound_id = "response-error"})
		msg.post("main:/music", "play", {sound = "music-start-round"})
	end)

	timer_linear.add(self, "step_result", 3, function (self)
		local win_player, delay = game_core_round_player_defeat.player_drop(self, player.player_id, delay)

		timer.delay(delay, false, function (self)
			if win_player then
				msg.post("game-room:/core_game", "event", {
					id = "get_start_game_over",
					player_id = win_player.player_id, type = "last_player"
				})

			elseif player.player_id == "player" then
				local type = "fail_word"
				game_core_round_player_defeat.start(self, player.player_id, type)

			else
				game_core_round_step_next.start_fail(self)

			end
		end)
	end)
end

return M