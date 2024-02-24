-- Работа с API накамы для аккаунта
local M = {}

local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local json = require "nakama.util.json"
local nakama_api_core = require "main.online.nakama.api.nakama_api_core"
local data_handler = require "main.data.data_handler"

-- Запись в метадату
function M.set_metadata(self, key, data, function_result)
	local payload

	-- Если нет ключа метадаты, значит это группа ключей метадаты
	if not key then
		for key_item, data_item in pairs(data) do
			storage_player.user_metadata[key_item] = data_item
		end

		payload = {
			data = data,
		}

	else
		storage_player.user_metadata[key] = data
		payload = {
			key = key,
			data = data
		}

	end

	nakama_api_core.rpc_push(self, "set_metadata", payload, function_result)
end

-- Запись в метадату
function M.set_metadata_all(self, key, data, function_result)
	storage_player.user_metadata[key] = data
	
	local payload = storage_player.user_metadata
	nakama_api_core.rpc_push(self, "set_metadata_all", payload, function_result)
end

function M.update_account(self, params, sync, callback)
	params = params or {}

	local function update_account(self, callback)
		local avatar_url = params.avatar_url
		local display_name = params.display_name
		local lang_tag = params.lang_tag
		local location = params.location
		local timezone = params.timezone
		local newUsername = params.newUsername

		if avatar_url then
			storage_player.avatar_url = avatar_url
		end

		if display_name then
			storage_player.name = display_name
			storage_player.user_name = display_name
		end

		return nakama.update_account(storage_player.client, avatar_url, display_name, lang_tag, location, timezone, newUsername, callback)
	end

	if sync then
		return nakama.sync(update_account)
	else
		return update_account(self, callback)
	end
	
end

function M.set_display_name(self, name)
	local sync = false
	return M.update_account(self, {display_name = name or ''}, false)
end

-- Запись в кошелёк
function M.set_wallet(self, data, metadata, function_result)
	local payload = {
		data = data,
		metadata = metadata
	}

	
	nakama_api_core.rpc_push(self, "set_wallet", payload, function_result)
end

return M