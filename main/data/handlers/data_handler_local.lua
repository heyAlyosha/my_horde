-- Обработчик данных для локального хранения
local M = {}

local defsave = require("defsave.defsave")
local defold = require "nakama.engine.defold"
local storage_player = require "main.storage.storage_player"
local data_handler_functions = require "main.data.modules.data_handler_functions"

M.file_name = "data"

-- Инициализация игрока
function M.clear(self, callback)
	storage_player.userdata = {}
	defsave.set(M.file_name, "userdata", {})
	defsave.set(M.file_name, "wallet", {})
	defsave.save(M.file_name)

	if callback then
		callback(self)
	end
end

-- Инициализация игрока
function M.init_player(self, callback)
	--local clear = sys.get_engine_info("is_debug") or false
	if clear then
		M.clear(self, callback)
	end

	local account = M.get_account(self)

	--pprint("M.init_player", account)

	storage_player.id = account.id
	storage_player.name = account.user_name
	storage_player.user_name = account.user_name
	storage_player.avatar_url = account.avatar_url
	storage_player.lang_tag = account.lang_tag
	storage_player.coins = account.wallet.coins or 0
	storage_player.score = account.wallet.score or 0

	storage_player.userdata = data_handler_functions.get_new_day(self, account.userdata)

	pprint("storage_player.userdata", storage_player.userdata)

	for k, v in pairs(storage_player.userdata) do
		storage_player[k] = v
	end

	M.set_userdata(self, storage_player.userdata, callback)

	if callback then
		callback(self)
	end

	return account
end

-- Данные аккаунта
function M.get_account(self)
	defsave.load(M.file_name)

	local result =  {
		id = defsave.get(M.file_name, "id") or "local-" .. defold.uuid(),
		user_name = defsave.get(M.file_name, "user_name") or "Анонимный игрок",
		avatar_url = defsave.get(M.file_name, "avatar_url"), 
		lang_tag = defsave.get(M.file_name, "lang_tag") or "ru",
		userdata = defsave.get(M.file_name, "userdata") or storage_player.userdata,
		wallet = defsave.get(M.file_name, "wallet") or {},
	}

	return result
end

-- Запись аккаунта
function M.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet)
	local data = M.get_account(self)

	defsave.set(M.file_name, "id", id or data.id)
	defsave.set(M.file_name, "user_name", user_name or data.user_name)
	defsave.set(M.file_name, "avatar_url", avatar_url or data.avatar_url)
	defsave.set(M.file_name, "lang_tag", lang_tag or data.lang_tag)
	defsave.set(M.file_name, "userdata", userdata or data.userdata)
	defsave.set(M.file_name, "wallet", wallet or data.wallet)

	defsave.save(M.file_name)

	return true
end

-- Запись аккаунта
function M.set_wallet(self, new_wallet, operation, metadata, callback)
	local wallet = M.get_account(self).wallet or {}

	for k, v in pairs(new_wallet) do
		wallet[k] = v
	end

	M.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet)

	if callback then
		callback(self)
	end 

	return wallet
end

-- Запись данных игрока
function M.set_userdata(self, data, callback)
	local userdata = M.get_account(self).userdata or {}

	for k, v in pairs(data) do
		userdata[k] = v
	end

	M.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet)

	if callback then
		callback(self, userdata)
	end

	return userdata
end

-- Запись данных игрока по 1 ключу
function M.set_key_userdata(self, key, data, callback)
	local userdata = M.get_account(self).userdata or {}

	userdata[key] = data

	M.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet)

	if callback then
		callback(self, userdata[key])
	end

	return userdata[key]
end

-- Получение места игрока
function M.get_rating_rank(self, callback)
	if callback then
		local result = nil
		callback(self, err, result)
	end
end

-- Топ игроков
function M.get_rating_top(self, count, callback)
	if callback then
		local user_rank = nil
		local err = "_error_catalog_rating_no_internet"

		callback(self, err, result)
	end
end

-- Топ игроков
function M.get_rating_personal(self, count, callback)
	if callback then
		local user_rank = nil
		local err = "_error_catalog_rating_no_internet"
		callback(self, err, result)
	end
end

return M