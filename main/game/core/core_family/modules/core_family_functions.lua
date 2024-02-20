-- Put functions in this file to use them in several other scripts.
local M = {}

local storage_game = require "main.game.storage.storage_game"

-- Запуск своместной игры
function M.play_game(self)
	local add_coins = storage_game.family.settings.add_coins

	-- Обрабатываем всех игроков перед игрой
	for i, player in ipairs(storage_game.family.settings.players) do
		if player.type == "player" then
			storage_game.family.bank[player.id] = storage_game.family.bank[player.id] + add_coins
		end

		-- Формируем рейтинг
		if #storage_game.family.rating < 3 then
			table.insert(storage_game.family.rating, {
				player_id = player.id,
				avatar = player.avatar,
				name = player.name,
				score = 0,
				wins = 0
			})
		end
	end

	if M.is_player(self) and add_coins > 0 then
		-- Если есть игроки и золото, запускаем магазин
		msg.post("main:/core_screens", "game_family_shop", {})
	else
		-- Запускаем игру
		msg.post("game-room:/core_game", "start_family", {})
	end

	
end

-- Есть ли игроки в совместной игре
function M.is_player(self)
	for i, player in ipairs(storage_game.family.settings.players) do
		if player.type == "player" then
			return true
		end
	end

	return false
end

-- Сброс данных для своместной игры
function M.reset_data(self)
	storage_game.family.bank = {
		player_1 = 0, player_2 = 0, player_3 = 0,
	}

	storage_game.family.inventaries = {
		player_1 = {}, player_2 = {}, player_3 = {},
	}

	storage_game.family.rating = {}
end

return M