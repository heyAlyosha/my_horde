-- Обработчик данных для локального хранения
local M = {}

local defsave = require("defsave.defsave")
local defold = require "nakama.engine.defold"
local storage_player = require "main.storage.storage_player"
local storage_sdk = require "main.storage.storage_sdk" 
local data_handler_functions = require "main.data.modules.data_handler_functions"
local yagames = require("yagames.yagames")

function M.clear(self, callback)
	local payload = {}
	local flush = false
	yagames.player_set_data(payload, flush, callback)
end


-- Инициализация игрока
function M.init_player(self, callback)
	--local clear = sys.get_engine_info("is_debug") or false
	if clear then
		M.get_account(self)
		defsave.set(M.file_name, "userdata", {})
		defsave.save(M.file_name)
	end

	M.get_account(self, function (self, err, account)
		if account.user_name == "" then
			account.user_name = "Анонимный игрок"
		end
		storage_player.id = account.id
		storage_player.name = account.user_name
		storage_player.user_name = account.user_name
		storage_player.avatar_url = account.avatar_url
		storage_player.lang_tag = account.lang_tag
		storage_player.coins = account.wallet.coins or 0
		storage_player.score = account.wallet.score or 0
		storage_player.resource = account.wallet.resource or 0
		storage_player.xp = account.wallet.xp or 0
		account.userdata = data_handler_functions.get_new_day(self, account.userdata)
		storage_player.userdata = account.userdata

		for k, v in pairs(account.userdata) do
			storage_player[k] = v
		end

		storage_sdk.player.is_anonime = nil
		storage_sdk.edit_name = false

		M.set_userdata(self, account.userdata)

		if callback then
			callback(self)
		end
	end)
end

-- Данные аккаунта
function M.get_account(self, callback)
	local keys = nil
	yagames.player_get_data(keys, function (self, err, result)

		if err then
			pprint("ERROR YANDEX GET DATA", err)
		else
			local userdata = result

			return yagames.player_get_stats(keys, function (self, err, wallet)
				if err then
					pprint("ERROR YANDEX GET STATS", err)
				else
					local data =  {
						id = storage_sdk.player.id,
						user_name = userdata.user_name or storage_sdk.player.name or "Анонимный игрок",
						avatar_url = storage_sdk.player.avatar_url, 
						lang_tag = storage_sdk.player.lang_tag or "ru",
						userdata = userdata,
						wallet = wallet or {},
					}

					if callback then
						callback(self, err, data)
					end

					return data
				end
			end)
		end
	end)
end

-- Запись аккаунта
function M.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet, callback)
	local payload = storage_player.userdata
	payload.id = id or storage_player.id
	payload.user_name = user_name or storage_player.user_name
	payload.avatar_url = avatar_url or storage_player.avatar_url
	payload.lang_tag = lang_tag or storage_player.lang_tag

	M.set_userdata(self, payload, callback)

	if wallet then
		M.set_wallet(self, wallet)
	end
end

-- Запись очков
function M.set_wallet(self, wallet, operation, metadata, callback)
	local callback = callback or  function (self, err, result) end
	yagames.player_set_stats(wallet, callback)

	return wallet
end

-- Запись данных игрока
function M.set_userdata(self, data, callback)
	for k, v in pairs(data) do
		storage_player.userdata[k] = v
	end

	local payload = storage_player.userdata
	local flush = false
	local callback = callback or function (self, err, result)
		M.get_account(self, function (self, err, account)
			--pprint("set_userdata", account) 
		end)
	end
	yagames.player_set_data(payload, flush, callback)
end

-- Запись данных игрока по 1 ключу
function M.set_key_userdata(self, key, data, callback)
	storage_player.userdata[key] = data
	local payload = storage_player.userdata

	local flush = false
	local callback = callback or function (self, err, result)
		M.get_account(self, function (self, err, account)
			--pprint("set_key_userdata", account) 
		end)
	end
	yagames.player_set_data(payload, flush, callback)
end


-- Получение места игрока
function M.get_rating_rank(self, callback)
	if callback then
		if not storage_sdk.leaderboard_top then
			-- Рейтинг не подгрузился
			local err = "_error_catalog_rating_no_internet"
			local result = nil
			callback(self, err, result)

		else
			local count = count or 20
			local leaderboard_name = "top"
			local options = {
				includeUser = true,
				quantityAround = 0,
				quantityTop = 0,
				getAvatarSrc = "small",
			} 
			yagames.leaderboards_get_entries("top", options, function (self, err, result)
				local rank = result.userRank
				callback(self, err, rank)

			end)
		end
		
	end
end

-- Топ игроков
function M.get_rating_top(self, count, callback)
	if callback then
		if not storage_sdk.leaderboard_top then
			-- Рейтинг не подгрузился
			local err = "_error_catalog_rating_no_internet"
			callback(self, err, result)

		else
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

					if player.name == "" then
						player.name = "Анонимный игрок"
					end

					users[i] = {
						rank = item.rank, 
						id = player.id, 
						name = player.name, 
						avatar_url = player.avatar_url, 
						score = item.formattedScore,
						is_user = player.id == storage_player.id
					}
				end

				callback(self, err, users)
			end)
		end
	end
end

-- Топ игроков
function M.get_rating_personal(self, count, callback)
	if callback then
		if not storage_sdk.leaderboard_top then
			-- Рейтинг не подгрузился
			local err = "_error_catalog_rating_for_authorization"
			callback(self, err, result)

		else
			local count = count or 20
			local leaderboard_name = "top"
			local options = {
				includeUser = true,
				quantityAround = 10,
				quantityTop = 0,
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

					if player.name == "" then
						player.name = "Анонимный игрок"
					end

					users[i] = {
						rank = item.rank, 
						id = player.id, 
						name = player.name, 
						avatar_url = player.avatar_url, 
						score = item.formattedScore,
						is_user = player.id == storage_player.id
					}
				end

				callback(self, err, users)

			end)
		end
	end
end

-- Обновить данные в рейтинге
function M.update_rating(self, score, callback)
	if callback then
		if not storage_sdk.leaderboard_top then
			-- Рейтинг не подгрузился
			local err = "_error_catalog_rating_for_authorization"
			callback(self, err, result)

		else
			local leaderboard_name = "top"
			local score = storage_player.score
			yagames.leaderboards_set_score(leaderboard_name, score, extra_data, function (self, err)
				callback(self, err, result)
			end)
		end
	end
end

return M