-- Тестирование
local M = {}

local color = require("color-lib.color")
local storage_player = require "main.storage.storage_player"
local game_content_bots = require "main.game.content.game_content_bots"
local storage_game = require "main.game.storage.storage_game"

local storage_sdk = require "main.storage.storage_sdk" 


function M.core(self, id)
	--[[
	msg.post("main:/loader_gui", "visible", {
		id = "modal_characteristics",
		visible = true,
		type = hash("animated_close"),
	})
	--]]
	if id then
		M[id](self)
	else
		M.game_over(self)
	end
end

function M.pause(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("/loader_gui", "visible", {
			id = "modal_pause",
			visible = true,
			type = hash("popup")
		})
	end)
end

-- Клавиатура
function M.keyboard(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		--storage_game.game.study = true
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 8,
			player_id = "player"
			--player_id = "ira"
		})
	end)
end

function M.confirm_obereg(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 11,
			player_id = "ira"
		})

		timer.delay(1.5, false, function (self)
			msg.post("game-room:/core_game", "event", {id = "obereg", confirm = true, type = "skipping"})
		end)
	end)
	
end

function M.wheel(self)
	M.start_game(self)
	timer.delay(0.25, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_start_step",
			index_player = 1,
			type = nil,
			first_step = true
		})
	end)
end

function M.start_game(self)
	local bot_1 = game_content_bots.get("ira")
	local bot_2 = game_content_bots.get("andrew")

	local sectors = {}

	if false then
		local artifacts = {"trap_1", "trap_2", "trap_3", "catch_1", "catch_2", "catch_3", "bank_1", "accuracy_1", "speed_caret_1"}
		local i_artifacts = 1
		for i, v in ipairs(game_content_wheel.sectors) do
			i_artifacts = i_artifacts + 1
			if i_artifacts > #artifacts then
				i_artifacts = 1
			end

			local current_artifact_id = artifacts[i_artifacts]
			
			sectors[i] = {sector_id = i, player_id = "andrew", artifact_id = current_artifact_id}
			--break
		end
	else
		sectors = {
			--{sector_id = 9, player_id = "player", artifact_id = "speed_caret_1"},
			--{sector_id = 8, player_id = "player", artifact_id = "speed_caret_1"},
			--{sector_id = 11, player_id = "player", artifact_id = "accuracy_1"},
			{sector_id = 12, player_id = "ira", artifact_id = "catch_3"},
			{sector_id = 25, player_id = "ira", artifact_id = "accuracy_1"},
		}
	end

	storage_game.game.message_start = {
		animate_start = false,
		index_player = 1,
		debug = true,
		type = "single",
		level_id = 4,
		category_id = "army",
		quest_type = "text",
		quest = "Пример вопроса",
		--word = " вопрос",
		word = "Операция Ы и другие приключения Шурика",
		open_symbols = {},
		sectors = sectors,
		players = {
			{
				player_id = "player", color = color.blue, score = 0, type = "player", 
				name = "Анонимный игрок", avatar = "icon_anonime",
				characteristics = {
					accuracy = 10, speed_caret = 10, mind = 10
				},
				--artifacts = {catch_1 = storage_player.artifacts.catch_1, try_1 = 0}
				artifacts = storage_player.artifacts
			},
			{
				player_id = "ira", color = color.pink, score = 800, type = "bot", 
				name = "Бот 1", avatar = "icon-lyosha",
				characteristics = bot_1.characteristics,
				artifacts = bot_1.artifacts
			},
			{
				player_id = "andrew", color = color.lime, score = 1000, type = "bot", 
				name = "Бот 1", avatar = "icon-alyona",
				characteristics = bot_2.characteristics,
				artifacts = bot_2.artifacts
			},
		}
	}

	msg.post("game-room:/core_game", "start_game")
end

function M.transfer(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_transfer",
			type = "leader_to_player",
			count = 100,
			player_id = "player"
		})
	end)
end

function M.artifact(self)
	M.start_game(self)
	timer.delay(0.25, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 4,
			player_id = "ira"
		})
	end)
end

function M.open_symbol(self)
	M.start_game(self)
	timer.delay(0.25, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 12,
			player_id = "player"
		})
	end)
end

function M.trap(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 9,
			player_id = "player"
		})
	end)
end

function M.sector_catch(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 12,
			player_id = "player"
		})
	end)
end

function M.catch(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 1,
			player_id = "player"
		})
	end)
end

function M.response(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 8,
			player_id = "player"
		})
	end)
end

function M.x2(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 30,
			player_id = "player"
		})
	end)
end

function M.skip(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 7,
			player_id = "player"
		})
	end)
end

function M.bankrot(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 20,
			player_id = "player"
		})
	end)
end

function M.game_over(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		storage_game.game.result.prizes = {
			ipad = 10, 
			iphone = 21,
			pc = 1,
			noteboock = 3,
			tv = 2,
			stiralka = 54,
			tablet = 8,
			video = 8,
			smartphone = 8,
			photo = 8,
			pech = 8,
		}

		storage_game.game.result.stars = 3

		storage_sdk.stats.is_ads_reward = false
		--storage_game.game.study_level = 1
		msg.post("game-room:/core_game", "event", {
			id = "get_start_game_over",
			type = "open_symbol",
			player_id = "ira"
		})
		--[[
		msg.post("game-room:/core_game", "event", {
			id = "get_start_game_over",
			type = "open_symbol",
			player_id = "player"
		})

		msg.post("/loader_gui", "visible", {
			id = "modal_result_single",
			visible = true,
			type = hash("popup"),
			value = {
				type_result = "win",
				score = 0,
				prizes = {{id = 1, count = 0}},
				current_level = {id = 2, stars = 2, category_id = "sport"},
				-- если нет следующего уровня - вылезет плашка с пройденной компанией
				next_level = {id = 3, stars = 2, unlock = true, category_id = "sport"},
			},
		})
		--]]

		
	end)
end

function M.full_word(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)
		
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 8,
			player_id = "player"
		})

		timer.delay(0.5, false, function (self)
			msg.post("game-room:/core_game", "full_word", {word = "тесsт"})
		end)
	end)
end

function M.full_artifacts(self)
	M.start_game(self)
	timer.delay(0.5, false, function (self)

		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = 8,
			player_id = "player"
		})

		timer.delay(0.5, false, function (self)
			msg.post("game-room:/core_game", "full_word", {word = "тесsт"})
		end)
	end)
end

function M.prize_stars(self)
	local comlexity = "easy"
	local all_score = 0 
	local all_coins = 0
	for star = 1, 3 do
		local score, coins = game_content_stars.get_prize(self, star, comlexity)
		all_score = all_score + score
		all_coins = all_coins + coins
		print("Star "..comlexity..":", star, "score:" .. score, "coins:" .. coins)
	end
	print(utf8.upper(comlexity..":"), "score:" .. all_score, "coins:" .. all_coins)

	comlexity = "normal"
	local all_score = 0 
	local all_coins = 0
	for star = 1, 3 do
		local score, coins = game_content_stars.get_prize(self, star, comlexity)
		all_score = all_score + score
		all_coins = all_coins + coins
		print("Star "..comlexity..":", star, "score:" .. score, "coins:" .. coins)
	end
	print(utf8.upper(comlexity..":"), "score:" .. all_score, "coins:" .. all_coins)

	comlexity = "hard"
	local all_score = 0 
	local all_coins = 0
	for star = 1, 3 do
		local score, coins = game_content_stars.get_prize(self, star, comlexity)
		all_score = all_score + score
		all_coins = all_coins + coins
		print("Star "..comlexity..":", star, "score:" .. score, "coins:" .. coins)
	end
	print(utf8.upper(comlexity..":"), "score:" .. all_score, "coins:" .. all_coins)
end


return M