-- Запись и получение данных
local M = {}

local data_handler_local = require "main.data.handlers.data_handler_local"
local data_handler_yandex = require "main.data.handlers.data_handler_yandex"
local storage_sdk = require "main.storage.storage_sdk" 
local storage_player = require "main.storage.storage_player"

-- Осичтка всех данных игрока
function M.clear(self, callback)
	local handler = storage_sdk.handler or "local"
	storage_player.reset = nil
	storage_player.add_reward_visit = nil
	storage_player.level = 0
	storage_player.coins = 0
	storage_player.score = 0
	storage_player.rating = 0
	storage_player.characteristics = {}
	storage_player.prizes = {}
	storage_player.shop = {}
	storage_player.visible_levels = {}
	storage_player.artifacts = {}
	storage_player.view_rewards = {}
	storage_player.progress = {}
	storage_player.achieve_progress = {}
	storage_player.achieve = {}
	storage_player.characteristic_points = 0
	storage_player.stats = {}
	storage_player.study = {}
	storage_player.userdata = {}
	storage_player.upgrades = {}

	msg.post("main:/core_player", "balance", {
		operation = "set",
		values = {
			coins = 0, score = 0, rating = 0
		},
		animate = false,
	})

	msg.post("game-room:/core_game", "event", {id = "set_to_start", text_tablo = "", animate_leader = false})

	if handler == "local" then
		return data_handler_local.clear(self, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.clear(self, callback)
	end
end

-- Сброс прогресса
function M.reset(self, handler)
	local handler = handler or storage_sdk.handler or "local"

	return M.clear(self, function (self)

		storage_player.reset = true
		msg.post('main:/loader_main', 'event', {id = "start_logout"})

		--msg.post('main:/loader_main', 'event', {id = "start_logout"})
		if html5 then
			--html5.run("location.reload();")
			--msg.post('main:/loader_main', 'event', {id = "start_logout"})
		else
			--pprint("sys.reboot")
			--sys.reboot()
		end
	end)
end

-- Инициализация игркоа
function M.init_player(self, handler, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.init_player(self, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.init_player(self, callback)
	end
end

-- Данные игрока
function M.get_account(self, handler, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.get_account(self, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.get_account(self, callback)
	end
end

-- Запись данных
function M.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.set_account(self, id, user_name, avatar_url, lang_tag, userdata, wallet, callback)

	end
end

-- Запись в кошелёк игрока
function M.set_wallet(self, wallet, operation, metadata, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.set_wallet(self, wallet, operation, metadata, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.set_wallet(self, wallet, operation, metadata, callback)
	end
end

-- Запись всех данных игрка
function M.set_userdata(self, data, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.set_userdata(self, data, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.set_userdata(self, data, callback)
	end
end

-- Запись данных по ключу
function M.set_key_userdata(self, key, data, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.set_key_userdata(self, key, data, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.set_key_userdata(self, key, data, callback)
	end
end


-- Позиция игрока в рейтинге
function M.get_rating_rank(self, handler, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.get_rating_rank(self, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.get_rating_rank(self, callback)
	end
end

-- Топ игроков
function M.get_rating_top(self, handler, count, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.get_rating_top(self, count, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.get_rating_top(self, count, callback)
	end
end

-- Игрок в рейтинге
function M.get_rating_personal(self, handler, count, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		return data_handler_local.get_rating_personal(self, count, callback)

	elseif handler == "yandex" then
		return data_handler_yandex.get_rating_personal(self, count, callback)
	end
end

-- Игрок в рейтинге
function M.update_rating(self, handler, score, callback)
	local handler = handler or storage_sdk.handler or "local"

	if handler == "local" then
		if callback then
			callback(self, err, result)
		end
		return 

	elseif handler == "yandex" then
		return data_handler_yandex.update_rating(self, score, callback)
	end
end


return M