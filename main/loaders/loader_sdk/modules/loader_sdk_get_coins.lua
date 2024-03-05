-- Модуль для формирования способов получения монет
local M = {}

local nakama = require "nakama.nakama"
local json = require "nakama.util.json"
local storage_sdk = require "main.storage.storage_sdk"
local storage_player = require "main.storage.storage_player"
--local donate_content = require "main.content.donate.donate_content"
local loader_sdk_modules = require "main.loaders.loader_sdk.modules.loader_sdk_modules"
local loader_sdk_rpc = require "main.loaders.loader_sdk.modules.loader_sdk_rpc"

-- Получение списка способов пополнения монет
function M.get_all(self)
	local collections = {}

	-- Есть ли ревардед видео
	if  storage_sdk.stats.is_ads_reward then
		local content = donate_content.get("rewarded")
		local rewards = loader_sdk_rpc.get_rewards()

		local img_btn = "FrameDonateButtons_Green"
		local description = content.description

		if rewards.count_left < 1 then
			-- Если больше нет видео для рекламы
			img_btn = "FrameDonateButtons_Orange"
			description = content.description_no_video
		end

		collections[#collections + 1] = {
			title = content.title,
			description = description,
			btn = content.btn,
			id = "rewarded",
			type = "rewarded",
			coins = storage_sdk.stats.gifts.rewarded,
			icon = content.icon,
			img_frame = content.img_frame,
			img_btn = img_btn,
			color = content.color,
			rewards_data = rewards
		}
	end

	-- Есть ли награда за оценку игры
	if  
		storage_sdk.stats.is_rating and
		(not storage_player.feedback or not storage_player.feedback.star or not storage_player.feedback.star[sys.get_config("platform.platform")]) 
	then
		local content = donate_content.get("stars")

		collections[#collections + 1] = {
			title = content.title,
			description = content.description,
			btn = content.btn,
			id = "stars",
			type = "stars",
			coins = storage_sdk.stats.gifts.stars,
			icon = content.icon,
			img_frame = content.img_frame,
			img_btn = content.img_btn,
			color = content.color,
		}
	end

	-- Есть ли внутриигровые товары для покупки
	if  storage_sdk.stats.is_shop then
		local products = loader_sdk_modules.shop.get_products(self)

		for i, product in ipairs(products) do
			collections[#collections + 1] = product
		end
	end

	return collections
end

return M