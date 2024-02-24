-- Функции для хода в игре
local M = {}

local storage_gui = require "main.storage.storage_gui"
local storage_game = require "main.game.storage.storage_game"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_round_step_sector_core = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_core"
local game_core_round_step_functions = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_functions"
local game_core_round_step_result = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_result"
local timer_linear = require "main.modules.timer_linear"
local lang_core = require "main.lang.lang_core"

-- Назвали букву
function M.start(self, symbol)
	local result = game_core_round_step_functions.is_open_simbol(self, symbol)

	local text = "БУКВА "..utf8.upper(symbol).. "!"
	game_core_round_functions.bubble_leader(self, text, text)

	timer.delay(1, false, function (self)
		if result then
			-- Есть такая буква
			msg.post("/loader_gui", "set_status", {
				id = "keyboard_ru",
				type = "result",
				value = {type = "success", player_id == self.player.player_id}
			})

			game_core_round_step_result.success_symbol(self, self.sector, self.player, symbol)

			if self.player.type == "bot" then
				msg.post("/core_bot", "open_symbol", {player_id = self.player.player_id, bot_id = self.player.bot_id, success = true})
			end
		else
			msg.post("main:/music", "play", {sound = "music-start-round"})
			
			-- Неправильная 
			msg.post("/loader_gui", "set_status", {
				id = "keyboard_ru",
				type = "result",
				value = {type = "error", player_id == self.player.player_id}
			})

			game_core_round_step_result.fail_symbol(self, self.sector, self.player, symbol)

			if self.player.type == "bot" then
				msg.post("/core_bot", "open_symbol", {player_id = self.player.player_id, bot_id = self.player.bot_id, success = false})
			end
		end
	end)
end

-- Назвали слово
function M.word(self, word, player_id)
	local word = utf8.lower(word or "")
	local success_word = utf8.lower(storage_game.game.round.word)
	local player = game_core_gamers.get_player(self, player_id, game_content_wheel)

	word = string.gsub(word, '%s+', '')
	success_word = string.gsub(success_word, '%s+', '')

	-- Ведущий объявляет слово
	timer_linear.add(self, "step_result", 0, function (self)
		msg.post("main:/sound", "play", {sound_id = "activate_symbol"})
		local text_leader = utf8.upper(lang_core.get_text(self, "_leader_player_answer_word", before_str, after_str, {name = player.name, word = word}))
		game_core_round_functions.bubble_leader(self, text_leader, text_leader)
	end)

	if word == success_word then
		game_core_round_step_result.success_word(self, self.sector, player, word, type)

	else
		game_core_round_step_result.fail_word(self, self.sector, player, word)

	end
end

return M