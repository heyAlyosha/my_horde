-- Функции окончания игры
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_round_step_sector = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector"
local game_core_round_step_sector_catch = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_catch"
local game_core_round_player_defeat = require "main.game.core.round.modules.game_core_round_player_defeat"
local game_core_round_player_win = require "main.game.core.round.modules.game_core_round_player_win"
local timer_linear = require "main.modules.timer_linear"
local lang_core = require "main.lang.lang_core"
local storage_gui = require "main.storage.storage_gui"
local storage_sdk = require "main.storage.storage_sdk"

-- Старт окончания игры
function M.start(self, player_id, type)
	core_layouts.set_data("round_game", {step = "game_over"})

	msg.post("main:/music", "play", {sound = "music-start-game"})
	msg.post("main:/sound", "play", {sound_id = "modal_top_1_2"})
	msg.post("main:/sound", "play", {sound_id = "ovation_win"})

	-- Тип символов
	local type = type or "open_symbol/last_player/full_word"
	local type_fail = ""
	local delay = 0

	local gamer = game_core_gamers.get_player(self, player_id)

	-- Записываем инфу для победителя
	storage_game.game.result.xp = gamer.score
	storage_game.game.result.score = gamer.score
	storage_game.game.result.player_win_id = gamer.player_id

	-- Луч над победителем
	for i = 1, 3 do
		msg.post("game-room:/thumba_"..i, "set_focus", {focus = gamer.index == i})
	end

	self.text_leader = lang_core.get_text(self, "_leader_have_winner_you_winner", before_str, after_str, {name = gamer.name})

	if type == "open_symbol" then
		type_fail = "win_other_gamer"

	elseif type == "last_player" then
		self.text_leader = lang_core.get_text(self, "_leader_have_winner_last_player", before_str, after_str, {name = gamer.name})
		type_fail = "fail_word"

	elseif type == "full_word" then
		type_fail = "fail_word"
	end

	msg.post("/loader_gui", "visible", {
		id = "confetti",
		visible = true,
		type = hash("animated_close"),
	})

	-- Объявляем поюедителя
	timer_linear.add(self, "bubble_1", 0, function (self)
		--M.start_result(self, gamer, type_fail)

		game_core_round_functions.bubble_leader(self, self.text_leader, self.text_leader)

		timer_linear.add(self, "bubble_2", 3, function (self)
			self.text_leader = lang_core.get_text(self, "_leader_game_over_compliment_winner", before_str, after_str, {name = gamer.name})
			game_core_round_functions.bubble_leader(self, self.text_leader, self.text_leader)

			timer_linear.add(self, "bubble_3", 3, function (self)
				self.text_leader = lang_core.get_text(self, "_leader_game_over_goodbye_ower_gamers", before_str, after_str)
				game_core_round_functions.bubble_leader(self, self.text_leader, self.text_leader)

				timer_linear.add(self, "bubble_4", 3, function (self)
					M.start_result(self, gamer, type_fail)

				end)
			end)
		end)
	end)
	
end

-- Функция вызова окна результатов игры
function M.start_result(self, player, type)
	if storage_game.game.round.type == "single" then
		-- Одиночная игра
		if player.player_id == "player" then
			local is_ads_reward = storage_sdk.stats.is_ads_reward
			game_core_round_player_win.start(self, is_ads_reward)
		else
			game_core_round_player_defeat.start(self, nil, type)
		end

	elseif storage_game.game.round.type == "family" then
		-- Несколько игроков за одним экраном
		self.type_game = storage_game.game.round.type
		core_layouts.set_data("round_game", {step = "fail"})

		msg.post("main:/core_screens", "game_result", {
			type = "family"
		})

		self.text_tablo = lang_core.get_text(self, "_tablo_continue_game", before_str, after_str, values)
		msg.post(storage_gui.components_visible.up_label_scene, "add_text", {text = self.text_tablo})

		msg.post("main:/loader_gui", "visible", {
			id = "modal_result_family",
			visible = true
		})

		msg.post("/loader_gui", "visible", {
			id = "confetti",
			visible = false,
			type = hash("animated_close"),
		})

		msg.post("game-room:/core_game", "event", {id = "set_to_start", text_tablo = self.text_tablo, animate_leader = 0.25})
	end
end

return M