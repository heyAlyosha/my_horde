-- Тестирование
local M = {}

local color = require("color-lib.color")
local storage_player = require "main.storage.storage_player"
local game_content_bots = require "main.game.content.game_content_bots"
local storage_game = require "main.game.storage.storage_game"
local game_content_wheel = require "main.game.content.game_content_wheel"

function M.core(self, id)
	M.catch(self)
end

function M.constructor(self)
	msg.post("/core_screens", "constructor_family", {})

	timer.delay(0.1, false, function (self)
		--msg.post("/loader_gui", "visible", {id = "game_constructor_player", visible = true, player_index = 1})
	end)
	
end

function M.shop(self)
	msg.post("main:/core_screens", "game_family_shop")

end

function M.start_game(self, id)
	msg.post("game-room:/core_game", "start_family", {})

end

function M.start_game_players(self, id, is_bot)
	if is_bot then
		storage_game.family.settings.players[1].type = "bot"
		storage_game.family.settings.players[1].bot_id = "andrew"
		storage_game.family.settings.players[2].type = "bot"
		storage_game.family.settings.players[2].bot_id = "ira"
		storage_game.family.settings.players[3].type = "bot"
		storage_game.family.settings.players[3].bot_id = "lyosha"
	else
		storage_game.family.settings.players[1].type = "player"
		storage_game.family.settings.players[2].type = "player"
		storage_game.family.settings.players[3].type = "player"
	end

	storage_game.family.inventaries = {
		player_1 = {accuracy_1 = 5, try_1 = 5}, player_2 = {accuracy_1 = 5, try_1 = 5}, player_3 = {accuracy_1 = 5, try_1 = 5},
	}
	storage_game.family.settings.debug = true

	msg.post("game-room:/core_game", "start_family", {
		sectors = {
			{sector_id = 1, player_id = "player_3", artifact_id = "accuracy_1"},
			{sector_id = 2, player_id = "player_3", artifact_id = "accuracy_1"},
			{sector_id = 8, player_id = "player_2", artifact_id = "accuracy_1"},
			{sector_id = 9, player_id = "player_2", artifact_id = "accuracy_1"},
			{sector_id = 10, player_id = "player_1", artifact_id = "accuracy_1"},
			{sector_id = 11, player_id = "player_1", artifact_id = "accuracy_1"},

			{sector_id = 24, player_id = "player_2", artifact_id = "trap_3"},

			{sector_id = 30, player_id = "player_2", artifact_id = "catch_3"},

			{sector_id = 31, player_id = "player_2", artifact_id = "bank_1"},
			{sector_id = 26, player_id = "player_2", artifact_id = "bank_1"},
			{sector_id = 25, player_id = "player_2", artifact_id = "bank_1"},
		},
		animate_start = false
	})
end

function M.wheel(self)
	M.start_game_players(self)
	--[[
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_start_step",
			index_player = 1,
			type = nil,
			first_step = true
		})
	end)
	]]--
end

-- 
function M.transfer(self)
	M.start_game_players(self)

	timer.delay(1, false, function (self)
	
		msg.post("game-room:/core_game", "event", {
			id = "get_transfer",
			type = "leader_to_player",
			count = 500,
			player_id = "player_1",
			player_from_id = "",
			player_to_id = "",
			sector_id = ""
		})

		timer.delay(3, false, function (self)
			msg.post("game-room:/core_game", "event", {
				id = "get_round_step_sector_start",
				sector_id = 30,
				player_id = "player_1"
			})
		end)
	end)
end

function M.catch(self)
	M.start_game_players(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 13,
			player_id = "player_1"
		})
	end)
end

function M.skip(self)
	local is_bot = true
	M.start_game_players(self, id, is_bot)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 7,
			player_id = "player_1"
		})
	end)
end

function M.open_symbol(self)
	local is_bot = false
	M.start_game_players(self, id, is_bot)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 12,
			player_id = "player_1"
		})
	end)
end

function M.bankrot(self)
	local is_bot = true
	M.start_game_players(self, id, is_bot)
	timer.delay(0.5, false, function (self)

		msg.post("game-room:/core_game", "event", {
			id = "get_transfer",
			type = "leader_to_player",
			count = 500,
			player_id = "player_1",
			player_from_id = "",
			player_to_id = "",
			sector_id = ""
		})

		timer.delay(3, false, function (self)
			msg.post("game-room:/core_game", "event", {
				id = "get_round_step_sector_start",
				sector_id = 20,
				player_id = "player_1"
			})
		end)
	end)
end

function M.trap(self)
	local is_bot = true
	M.start_game_players(self, id, is_bot)
	timer.delay(0.5, false, function (self)

		msg.post("game-room:/core_game", "event", {
			id = "get_transfer",
			type = "leader_to_player",
			count = 1000,
			player_id = "player_1",
			player_from_id = "",
			player_to_id = "",
			sector_id = ""
		})

		timer.delay(3, false, function (self)
			msg.post("game-room:/core_game", "event", {
				id = "get_round_step_sector_start",
				sector_id = 24,
				player_id = "player_1"
			})
		end)
	end)
end

function M.cath_artifact(self)
	local is_bot = true
	M.start_game_players(self, id, is_bot)
	timer.delay(0.5, false, function (self)

		msg.post("game-room:/core_game", "event", {
			id = "get_transfer",
			type = "leader_to_player",
			count = 1000,
			player_id = "player_1",
			player_from_id = "",
			player_to_id = "",
			sector_id = ""
		})

		timer.delay(3, false, function (self)
			msg.post("game-room:/core_game", "event", {
				id = "get_round_step_sector_start",
				sector_id = 31,
				player_id = "player_1"
			})
		end)
	end)
end

function M.bank(self)
	local is_bot = false
	M.start_game_players(self, id, is_bot)
	timer.delay(0.5, false, function (self)

			timer.delay(0., false, function (self)
				msg.post("game-room:/core_game", "event", {
					id = "get_round_step_sector_start",
					sector_id = 1,
					player_id = "player_1"
				})
			end)
	end)
end

function M.result_game(self, id)
	storage_game.family.settings.players[1].type = "player"
	storage_game.family.settings.players[2].type = "player"
	storage_game.family.settings.players[3].type = "player"

	-- Записываем инфу для победителя
	storage_game.game.result.xp = 3000
	storage_game.game.result.score = 3000
	storage_game.game.result.player_win_id = "player_1"

	-- Рейтинг
	storage_game.family.rating =  {
		{ 
			player_id = storage_game.family.settings.players[1].id,
			avatar = storage_game.family.settings.players[1].avatar,
			name = storage_game.family.settings.players[1].name,
			score = 500,
			wins = 2
		},
		{ 
			player_id = storage_game.family.settings.players[2].id,
			avatar = storage_game.family.settings.players[2].avatar,
			name = storage_game.family.settings.players[2].name,
			score = 0,
			wins = 3
		},
		{ 
			player_id = storage_game.family.settings.players[3].id,
			avatar = storage_game.family.settings.players[3].avatar,
			name = storage_game.family.settings.players[3].name,
			score = 100,
			wins = 0
		}
	}

	msg.post("main:/loader_gui", "visible", {
		id = "modal_result_family",
		visible = true
	})
end


return M