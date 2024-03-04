-- Модули для общения SDK c сервером
local M = {}

local nakama = require "nakama.nakama"
local json = require "nakama.util.json"
local storage_sdk = require "main.storage.storage_sdk"
local storage_player = require "main.storage.storage_player"
--local nakama_controller = require "main.online.nakama.modules.nakama_controller"
--local donate_content = require "main.content.donate.donate_content"

-- Отправка данных на сервер c оценкой и отзывом
function M.add_feedback(self, type, success_function, fail_function)
	nakama.sync(function ()
		local type = type or "star"
		local star = self.active_star or 0
		local content_feedback = "" 

		if self.input_name then
			content_feedback = self.input_name:get_text()
		end

		local stats = {
			-- ID платформы
			id_platform = sys.get_config("platform.platform"),
			time_running_game = math.floor((os.time() - storage_sdk.stats.start_time_running) / 60 * 100) / 100,
			count_play_game = storage_sdk.stats.count_play_game,
			count_round_play_game = storage_sdk.stats.count_round_play_game,
			system = sys.get_sys_info(),
		}

		local push_feedback = nakama.rpc_func(storage_player.client, "feedback", json.encode({
			data = {
				method = "add",
				type = type,
				id_platform = sys.get_config("platform.platform"), 
				star = star, 
				feedback = content_feedback,
				stats = stats
			}
		}), storage_player.token)

		push_feedback = json.decode(push_feedback.payload)
		--nakama_controller.read_old_notification(self)
		
		if push_feedback.status and success_function then
			success_function(self)

		elseif not push_feedback.status and fail_function then
			fail_function(self)

		end
	end)
end

-- Получение виртуальных покупок
function M.get_products(platform_id, valute_id)
	-- Получаем коллекцию скинов игрока
	local products = nakama.rpc_func(storage_player.client, "products", json.encode({method = "get", platform_id = platform_id, valute_id = valute_id}), storage_player.token)
	products = json.decode(products.payload)

	-- Собираем коллекцию
	local collections = {}

	for i, item in ipairs(products) do
		local content = donate_content.get(item.id)

		collections[#collections + 1] = {
			title = content.title,
			description = content.description,
			btn = content.btn,
			id = item.id,
			type = item.id,
			price = item.price,
			old_price = item.old_price,
			coins = item.coins,
			valute = item.valute,
			icon = content.icon,
			img_frame = content.img_frame,
			img_btn = content.img_btn,
			color = content.color,
		}
	end

	return collections
end

-- Получение виртуальных покупок
function M.get_rewards()
	-- Получаем коллекцию скинов игрока
	local data = nakama.rpc_func(storage_player.client, "rewarded", json.encode({method = "get"}), storage_player.token)
	return json.decode(data.payload)
end

-- добавление умпешного просмотра рекламы за вознаграждение
function M.add_reward(platform_id, type)
	-- Получаем коллекцию скинов игрока
	local data = nakama.rpc_func(storage_player.client, "rewarded", json.encode({method = "add", platform_id = platform_id, type = type}), storage_player.token)
	return json.decode(data.payload)
end

-- Получение данных по подписке пользователя
function M.get_subscribe(platform_id)
	local data = nakama.rpc_func(storage_player.client, "subscribe", json.encode({method = "get", platform_id = platform_id}), storage_player.token)
	return json.decode(data.payload)
end

-- Покупка чего либо
function M.buy(platform_id, type)
	local data = nakama.rpc_func(storage_player.client, "buy", json.encode({method = "buy", platform_id = platform_id, type = type}), storage_player.token)
	return json.decode(data.payload)
end

-- Покупка чего либо
function M.purhase(platform_id, method, data)
	local data = nakama.rpc_func(storage_player.client, "purchase", json.encode({method = method, platform_id = platform_id, data = data}), storage_player.token)
	return json.decode(data.payload)
end

return M