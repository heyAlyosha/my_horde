-- Работа с API накамы для аккаунта
local M = {}

local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local json = require "nakama.util.json"
local nakama_api_core = require "main.online.nakama.api.nakama_api_core"

-- Получение рейтинга игроков
function M.list_leaderboard_records(self, params, around_owner, is_avatar)
	local owner_ids = params.owner_ids
	local limit = params.limit
	local cursor = params.cursor
	local expiry = params.expiry
	local leaderboard_id = params.leaderboard_id

	local result
	if around_owner then
		result = nakama.list_leaderboard_records_around_owner(storage_player.client, leaderboard_id, owner_ids, limit, cursor, expiry)

	else
		result = nakama.list_leaderboard_records(storage_player.client, leaderboard_id, owner_ids, limit, cursor, expiry)

	end

	if result.error then
		print("ERROR RATING:", result.error.message)
		return
	end

	local rating = {}
	local ids_arr = {}
	local keys = {}
	result.records = result.records or {}

	--pprint("result.records", result.records)

	for _, record in ipairs(result.records) do
		local metadata = json.decode(record.metadata)

		table.insert(ids_arr, record.owner_id)
		table.insert(rating, {
			rank = tonumber(record.rank), 
			id = record.owner_id, 
			name = metadata.display_name or record.username or "", 
			avatar = metadata.avatar_url, 
			score = record.score or 0,
			is_user = storage_player.id ==  record.owner_id
		})

		keys[record.owner_id] = rating[#rating]
	end

	-- Получаем аватарки
	if is_avatar then
		
	end

	local avatar_urls = {}
	local accounts = nakama.get_users(storage_player.client, ids_arr).users

	for i, account in ipairs(accounts) do
		if keys[account.id] then
			keys[account.id].avatar_url = account.avatar_url
		end

	end

	return rating
end

-- Запись рейтинга
function M.write_leaderboard_record(self, params)
	local leaderboard_id = params.leaderboard_id or ""
	local metadata = json.encode({avatar_url = params.avatar_url, display_name = storage_player.name})
	local score = tostring(params.score or storage_player.score or "0")
	local subscore = tostring(params.subscore or "0")

	local result = nakama.write_leaderboard_record(storage_player.client, leaderboard_id, metadata, nil, score, subscore)
end

return M