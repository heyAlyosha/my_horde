-- Api получения данных игрока с сервера
local M = {}

local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local nakama_api_rating = require "main.online.nakama.api.nakama_api_rating"
local censoored_csv = require "main.core.censoored.censoored_csv"
local data_handler = require "main.data.data_handler"

-- Запись имени игрока
function M.set_name(self, name)
	if not name then
		return {status = "error", msg = "name_nil", name = name}
	else
		
		nakama.sync(function ()
			if censoored_csv.is_censoored(self, name) then
				msg.post("/loader_gui", "set_status", {
					id = "modal_settings",
					type = "result_set_name",
					value = {
						status = "error",
						msg = "censoored",
					}
				})
				return false
			end

			local result = nakama_api_account.set_display_name(self, name)

			storage_player.name = name
			msg.post("/loader_gui", "set_status", {
				id = "interface",
				type = "update_name"
			})

			if not result.error then
				msg.post("/loader_gui", "set_status", {
					id = "modal_settings",
					type = "result_set_name",
					value = {
						status = "success",
						name = name,
						msg = result.msg,
					}
				})

				return {status = "success", name = name}
			else
				msg.post("/loader_gui", "set_status", {
					id = "modal_settings",
					type = "result_set_name",
					value = {
						status = "error",
						--msg = result.message,
					}
				})

				pprint("ERROR SET NAME:", result)
				return {status = "success", name = name}
			end
		end)
	end
end

-- Получение прогресса игрока
function M.get_levels_progress(self, category_id)
	return {
		level_1 = {stars = 1, max_score = 130},
		level_2 = {stars = 3, max_score = 560},
		level_3 = {stars = 2, max_score = 220},
	}
end

-- Получение призов игрока
function M.get_prizes(self)
	return storage_player.prizes
end

-- Запись кол-ва призов игрока
function M.set_prizes(self, id_prize, count, operation, set)
	local operation = operation or "set"
	storage_player.prizes = storage_player.prizes or {}
	storage_player.prizes[id_prize] = storage_player.prizes[id_prize] or 0

	if operation == "set" then
		storage_player.prizes[id_prize] = count
	elseif operation == "add" then
		storage_player.prizes[id_prize] = storage_player.prizes[id_prize] + count

		if storage_player.prizes[id_prize] < 0 then
			storage_player.prizes[id_prize] = 0
		end
	end

	if set then
		data_handler.set_key_userdata(self, "prizes", storage_player.prizes, function_result)
	end

	return storage_player.prizes
end

-- Обновление призов группой пачкой
function M.update_prizes(self, operation, prizes)
	local operation = operation or "add"

	for id, count in pairs(prizes) do
		local set_nakama = false
		M.set_prizes(self, id, count, operation, set_nakama)
	end

	data_handler.set_key_userdata(self, "prizes", storage_player.prizes, function_result)

	return storage_player.prizes
end

-- Получение артефактов игрока
function M.get_artifacts(self)
	return storage_player.artifacts
end

-- Запись кол-ва артефактов
function M.set_artifacts(self, id_artifact, count, operation, set)
	local operation = operation or "set"
	storage_player.artifacts = storage_player.artifacts or {}
	storage_player.artifacts[id_artifact] = storage_player.artifacts[id_artifact] or 0

	if operation == "set" then
		storage_player.artifacts[id_artifact] = count
	elseif operation == "add" then
		storage_player.artifacts[id_artifact] = storage_player.artifacts[id_artifact] + count

		if storage_player.artifacts[id_artifact] < 0 then
			storage_player.artifacts[id_artifact] = 0
		end
	end

	if set then
		data_handler.set_key_userdata(self, "artifacts", storage_player.artifacts, function_result)
	end

	return storage_player.artifacts
end

-- Получение просмотров рекламы за вознаграждение игрока
function M.get_view_rewards(self)
	return storage_player.view_rewards
end

-- Запись кол-ва артефактов
function M.set_view_rewards(self, id_reward, count, operation, set)
	local operation = operation or "set"
	storage_player.view_rewards = storage_player.view_rewards or {}
	storage_player.view_rewards[id_reward] = storage_player.view_rewards[id_reward] or 0

	if operation == "set" then
		storage_player.view_rewards[id_reward] = count
	elseif operation == "add" then
		storage_player.view_rewards[id_reward] = storage_player.view_rewards[id_reward] + count

		if storage_player.view_rewards[id_reward] < 0 then
			storage_player.view_rewards[id_reward] = 0
		end
	end

	if set then
		data_handler.set_key_userdata(self, "view_rewards", storage_player.view_rewards, function_result)
	end

	return storage_player.view_rewards
end

-- Получение кишированных настроек
function M.get_settings(self)
	local settings = storage_player.settings

	local result = {
		lang = settings.lang or 'ru',
		color = settings.color or "aqua",
		volume_music = settings.volume_music or 0.5,
		volume_effects = settings.volume_effects or 0.5,
		study = settings.study,
		help_shop = settings.help_shop
	}

	if result.study == nil then
		result.study = true
	end
	if result.help_shop == nil then
		result.help_shop = true
	end

	return result
end

-- Сохранение данных настроек
function M.save_settings(self, settings, function_result)
	local lang = settings.lang or storage_player.settings.lang or "ru"

	storage_player.settings = {
		lang = lang,
		color = settings.color or storage_player.settings.color,
		volume_music = settings.volume_music or storage_player.settings.volume_music,
		volume_effects = settings.volume_effects or storage_player.settings.volume_effects,
		study = settings.study,
		help_shop = settings.help_shop
	}

	data_handler.set_key_userdata(self, "settings", storage_player.settings, function_result)

	return true
end

-- Получение рейтинга игрока
function M.get_rating(self, update_inteface, nakama_sync)
	data_handler.get_rating_rank(self, handler, function (self, err, rank)
		storage_player.rating = rank or 0

		if update_inteface then
			msg.post("/loader_gui", "set_status", {
				id = "interface",
				type = "update_balance",
				animate = true,
			})
		end

	end)
	--[[
	local function rating(self)
		-- Место игрока в рейтинге
		local leader_boards = nakama_api_rating.list_leaderboard_records(self, {
			owner_ids = storage_player.id, limit = 1, leaderboard_id = "global_rating"
		}, true)

		if leader_boards and leader_boards[1] then
			storage_player.rating = leader_boards[1].rank or 0
		else
			storage_player.rating = account.user.metadata.global_rank or 0
		end

		if update_inteface then
			msg.post("/loader_gui", "set_status", {
				id = "interface",
				type = "update_balance",
				animate = true,
			})
		end

		return storage_player.rating
	end

	if nakama_sync then
		return nakama.sync(rating, cancellation_token)
	else
		return rating(self)
	end
	--]]
end

--Обновление кошелька
function M.update_wallet(self, wallet, metadata, callback)
	storage_player.coins = wallet.coins or storage_player.coins
	storage_player.score = wallet.score or storage_player.score
	storage_player.xp = wallet.xp or storage_player.xp
	storage_player.resource = wallet.resource or storage_player.resource

	data_handler.set_wallet(self, wallet, operation, metadata, callback)
end

return M