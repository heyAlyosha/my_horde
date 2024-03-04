-- Функции для работы с рейтинго через АПИ
local M = {}

local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local nakama_api_rating = require "main.online.nakama.api.nakama_api_rating"
local yagames = require("yagames.yagames")
local data_handler = require "main.data.data_handler"

M.name_global_rating = "global_rating"

-- Обновить рейтинг игрока
function M.update_rating_player(self, score, callback)
	data_handler.update_rating(self, handler, storage_player.score, function (self, err)
		if not err then
			callback(self, err)
		end
	end)
	--[[
	local function write_leaderboard_record(self)
		nakama_api_rating.write_leaderboard_record(self, {
			leaderboard_id = M.name_global_rating,
			score = score or storage_player.score or 0,
		})
	end
	
	if nakama_sync then
		nakama.sync(write_leaderboard_record, cancellation_token)
	else
		write_leaderboard_record(self)
	end
	--]]
	
end

-- Получение лучших игроков игры
function M.get_rating_top(self, count, callback)
	data_handler.get_rating_top(self, handler, count, callback)
	--[[
	local is_avatar = true
	return nakama_api_rating.list_leaderboard_records(self, {
		limit = count or 100,
		leaderboard_id = M.name_global_rating,
	}, around_owner, is_avatar)
	--]]
end

-- Получение рейтинга с игроком
function M.get_rating_gamer(self, count, callback)
	data_handler.get_rating_personal(self, handler, count, callback)
	--[[
	local around_owner = true
	local is_avatar = true
	return nakama_api_rating.list_leaderboard_records(self, {
		limit = count or 20,
		owner_ids = storage_player.id,
		leaderboard_id = M.name_global_rating,
	}, around_owner, is_avatar)
	--]]
end

-- Получение рейтинга яндекса
--[[
function M.get_rating_sdk(self, count, callback)
	local count = count or 20
	local leaderboard_name = "top"
	local options = {
		quantityTop = count,
		getAvatarSrc = "small",
		
	} 
	yagames.leaderboards_get_entries("top", options, function (self, err, result)
		local entries = result.entries
		local users = {}

		for i, item in ipairs(entries) do
			item.player = item.player or {}
			local player = {
				id = item.player.uniqueID or "anonym",
				avatar_url = item.player.getAvatarSrc,
				name = item.player.publicName or "Анонимный игрок",
			}
			users[i] = {
				rank = item.rank, 
				id = player.id, 
				name = player.name, 
				avatar_url = player.avatar_url, 
				score = item.formattedScore
			}
		end
		callback(self, users)
	end)
end
--]]

-- Получение рейтинга яндекса
function M.get_rating_test(self, count)
	local count = count or 20

	return {
		{rank = 1, id = 1, name = "Пример теста 1", avatar = nil, score = 10000, is_user = true},
		{rank = 2, id = 2, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 3, id = 3, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 4, id = 4, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 5, id = 5, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 6, id = 6, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 7, id = 7, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 8, id = 8, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 9, id = 9, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 10, id = 10, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 11, id = 11, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 12, id = 12, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 13, id = 13, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 14, id = 14, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 15, id = 15, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 16, id = 16, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 17, id = 17, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 18, id = 18, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 19, id = 19, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 20, id = 20, name = "Пример теста 123124124", avatar = nil, score = 10000},
	}

end

-- Получение сутаревшего рейтинга
function M.get_rating_old(self, count)
	local count = count or 20

	return {
		{rank = 1, id = 1, name = "Пример теста 1", avatar = nil, score = 10000, is_user = true},
		{rank = 2, id = 2, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 3, id = 3, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 4, id = 4, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 5, id = 5, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 6, id = 6, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 7, id = 7, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 8, id = 8, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 9, id = 9, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 10, id = 10, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 11, id = 11, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 12, id = 12, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 13, id = 13, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 14, id = 14, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 15, id = 15, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 16, id = 16, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 17, id = 17, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 18, id = 18, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 19, id = 19, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 20, id = 20, name = "Пример теста 123124124", avatar = nil, score = 10000},
	}
	
	--[[
	return {
		{rank = 51, id = 1, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 52, id = 2, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 53, id = 3, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 54, id = 4, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 55, id = 5, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 56, id = 6, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 57, id = 7, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 58, id = 8, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 59, id = 9, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 60, id = 10, name = "Пример теста 123124124", avatar = nil, score = 10000,},
		{rank = 61, id = 11, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 62, id = 12, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 63, id = 13, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 64, id = 14, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 65, id = 15, name = "Пример теста 312", avatar = nil, score = 900},
		{rank = 66, id = 16, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 67, id = 17, name = "Пример теста 123124124", avatar = nil, score = 10000},
		{rank = 68, id = 18, name = "Пример теста 1", avatar = nil, score = 10000},
		{rank = 69, id = 19, name = "Пример теста 312", avatar = nil, score = 900, is_user = true},
		{rank = 70, id = 20, name = "Пример теста 123124124", avatar = nil, score = 10000},
	}
	--]]
end

-- Позиция игрока в рейтинге
function M.get_rating_rank(self, hadler, callback)
	data_handler.get_rating_rank(self, handler, callback)
end



return M