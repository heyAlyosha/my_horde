-- Функции для разных этапов игры
local M = {}

local storage_game = require "main.game.storage.storage_game"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_step_sector_x2 = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_x2"
local game_core_round_step_sector_bankrot = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_bankrot"
local game_core_round_step_sector_skip = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_skip"
local game_core_round_step_sector_open_symbol = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_open_symbol"
local timer_linear = require "main.modules.timer_linear"
local lang_core = require "main.lang.lang_core"

-- Окно с выбором буквы
function M.get_keyboard(self, sector, player, start_text_leader, start_text_tablo)
	section = sector or self.sector
	player = player or self.player

	-- Разные типы секторов.
	if not start_text_leader and not start_text_tablo then
		if section.type == "x2" then
			start_text_leader, start_text_tablo = game_core_round_step_sector_x2.get_keyboard(self, sector, delay)

		elseif section.type == "bankrot" then
			start_text_leader, start_text_tablo = game_core_round_step_sector_bankrot.get_keyboard(self, sector, delay)

		elseif section.type == "skip" then
			start_text_leader, start_text_tablo = game_core_round_step_sector_skip.get_keyboard(self, sector, delay)

		elseif section.type == "open_symbol" then
			start_text_leader, start_text_tablo = game_core_round_step_sector_open_symbol.get_keyboard(self, sector, delay)

		else 
			local score = sector.value.score
			start_text_leader = lang_core.get_text(self, "_leader_score_to_wheel", before_str, after_str, {score = score})

		end
	end

	local text_leader = start_text_leader.. " " .. lang_core.get_text(self, "_leader_symbol", before_str, "?", values)

	game_core_round_functions.bubble_leader(self, text_leader, text_leader)

	local function visible_keyboard(self)
		timer_linear.add(self, "sector_start", 1, function (self)
			if player.type == "player" and storage_game.game.study_level and storage_game.game.study_level > 0 and storage_game.game.round.quest_type ~= "music" then
				game_core_round_functions.show_quest(self, is_first, function_end)
			end

			msg.post("/loader_gui", "visible", {
				id = "keyboard_ru",
				visible = true,
				type = hash("animated_close"),
				value = {
					type = "game", -- Для игры или для ввода текста
					is_player = player.type == "player",
					keys_disabled = storage_game.game.round.disable_symbols,
					player_id = player.player_id
				}
			})

			if player.type == "bot" then
				-- Если бот
				msg.post("/core_bot", "start_symbol", {player_id = self.player.player_id, bot_id = self.player.bot_id})
			end
		end)
	end

	if storage_game.game.study and player.type == "player" then
		-- ОБУЧЕНИЕ
		timer_linear.add(self, "study_1", 0, function (self)
			text_leader = lang_core.get_text(self, "_leader_keyboard_study_1", before_str, after_str, {name = name})
			game_core_round_functions.bubble_leader(self, text_leader, text_leader)

			timer_linear.add(self, "study_2", 6, function (self)
				text_leader = lang_core.get_text(self, "_leader_keyboard_study_2", before_str, after_str, {name = name})
				game_core_round_functions.bubble_leader(self, text_leader, text_leader)

				timer_linear.add(self, "study_3", 6, function (self)
					visible_keyboard(self)
				end)
			end)

		end)
	else
		visible_keyboard(self)
	end
	
end

-- Смотрим есть ли такая буква
function M.is_open_simbol(self, symbol, is_start)
	local word = utf8.lower(storage_game.game.round.word)
	local disable_symbols = storage_game.game.round.disable_symbols
	local symbol = utf8.lower(symbol)

	if not is_start then
		for i, open_symbol in ipairs(disable_symbols) do
			if utf8.lower(open_symbol) == symbol then
				-- Если буква уже была открыта
				return false
			end
		end

		-- Добавляем в заблокированные буквы
		table.insert(storage_game.game.round.disable_symbols, symbol)
	end

	return utf8.find(word, symbol)
end

return M