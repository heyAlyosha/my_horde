-- Тестирование разных этапов игры
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_step_sector_catch = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_catch"
local game_core_round_step_start = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_start"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_round_player_defeat = require "main.game.core.round.modules.game_core_round_player_defeat"
local game_core_round_player_win = require "main.game.core.round.modules.game_core_round_player_win"
local game_core_round_step_game_over = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_game_over"
local game_content_artifact = require "main.game.content.game_content_artifact"
local api_core_shop = require "main.core.api.api_core_shop"

-- 
function M.core(self)
	-- Тестируем
	timer.delay(0.1, false, function (self)
		--game_core_round_test.end_rotate(self)
		--game_core_round_test.result_win(self)
		--game_core_round_step_game_over.start(self, "player", "fail_word")
		--M.player_win(self)

		--M.before_start_rotate(self)
		--M.artifact_bot(self)
		M.end_rotate(self)
		
	end)
end

-- Запись тестовых данных
function M.set_data_test(self)
	local index_player = 1
	local player = storage_game.game.players[index_player]
	-- Ставим нужный лайоут
	storage_game.game.round.level = nil
	core_layouts.set_data("round_game", {step = "start", index_player = index_player, player = player})
end

-- Победа игрока
function M.player_win(self)
	M.set_data_test(self)

	game_core_round_step_game_over.start(self, "player", "fail_word")
end

-- Проигрыш игрока
function M.player_win(self)
	M.set_data_test(self)

	game_core_round_step_game_over.start(self, "bot_1", "fail_word")
end


-- Окончание вращения барабана барабана
function M.result_add_shop(self)
	api_core_shop.add_random_shop(self, game_content_artifact)
end

-- Окончание вращения барабана барабана
function M.result_fail(self)
	M.set_data_test(self)

	--game_core_round_step_game_over.start(self, "player", "fail_word")
	game_core_round_player_defeat.start(self, "player", "fail_word")
end

-- Перед вращением барабана
function M.before_start_rotate(self)
	local index_player = 2
	local player = storage_game.game.players[index_player]
	-- Ставим нужный лайоут
	core_layouts.set_data("round_game", {step = "start", index_player = index_player, player = player})
	game_core_round_step_start.start_step(self, index_player)

end

-- Бот активирует артефакт
function M.artifact_bot(self)
	local index_player = 2
	local player = storage_game.game.players[index_player]
	-- Ставим нужный лайоут
	core_layouts.set_data("round_game", {step = "start", index_player = index_player, player = player})

	-- 
	timer.delay(0.5, false, function (self)
		-- Открытие любой буквы
		local current_sector_id = 12
		-- СЕктор x2
		local current_sector_id = 30
		-- Банкрот
		local current_sector_id = 20

		-- Пропуск хода
		local current_sector_id = 7
		-- Другой сектор
		local current_sector_id = 22
		-- Банкрот
		local current_sector_id = 20

		local current_sector_id = 22

		msg.post("game-room:/core_game", "event", {
			id = "wheel_rotate",
			value = {
				step = "end",
				sector_id = current_sector_id
			}
		})
	end)
end


-- Окончание вращения барабана барабана
function M.end_rotate(self)
	local index_player = 3
	local player = storage_game.game.players[index_player]
	-- Ставим нужный лайоут
	core_layouts.set_data("round_game", {step = "start", index_player = index_player, player = player})

	-- 
	timer.delay(0.5, false, function (self)
		-- Открытие любой буквы
		local current_sector_id = 12
		-- СЕктор x2
		local current_sector_id = 30
		-- Банкрот
		local current_sector_id = 20

		-- Пропуск хода
		local current_sector_id = 7
		-- Другой сектор
		local current_sector_id = 22
		-- Банкрот
		local current_sector_id = 12
		
		msg.post("game-room:/core_game", "event", {
			id = "wheel_rotate",
			value = {
				step = "end",
				sector_id = current_sector_id
			}
		})

		--game_core_round_player_defeat.start(self, "player", "fail_word")

		-- Если нет очков прокачки
		--[[
		msg.post("/loader_gui", "visible", {
			id = "catalog_rating",
			visible = true,
			type = hash("animated_close"),
			value = {
				hidden_bg = false,
				type_rating = 'change_animated'
			}
		})
		--]]
	end)

	timer.delay(0, false, function (self)
		local count = 750
		local player_id = "player_1"
		--game_core_round_transfer.score_leader_to_player(self, count, player_id)

		local player_from_id = "player"
		local player_to_id = "player_2"
		--game_core_round_transfer.score_player_to_player(self, count, player_from_id, player_to_id)
		--game_core_round_step_sector_catch.visible_obereg(self, "bankrupt", 300, trap_id)

	end)

end

return M