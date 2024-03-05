-- Обработка разных способов получения монет
local M = {}

local loader_sdk_rpc = require "main.loaders.loader_sdk.modules.loader_sdk_rpc"
local loader_sdk_modules = require "main.loaders.loader_sdk.modules.loader_sdk_modules"
local storage_sdk = require "main.storage.storage_sdk"
--local popup_content = require "main.content.popup.popup_content"
local nakama = require "nakama.nakama"
local json = require "nakama.util.json"
--local screen_content = require "main.content.screen.screen_content"
--local gui_global_loader_donate = require "main.gui.global.gui_global_loader_donate"

-- Получение внутриигровых покупок с сервера
function M.get_products(self)
	local products = loader_sdk_rpc.get_products("sber_canvas", "RUB")

	return products
end

-- Активация какого-то способа получения монет
function M.activate_item_shop(self, btn, btn_data)
	local id = btn.donate_id

	if id == "stars" then
		-- Пользователь хочет поставить оценку
		msg.post("main:/loader_gui", "visible", {id = "modal_stars", visible = true})

	elseif id == "rewarded" then
		if not btn_data.rewards_data or btn_data.rewards_data.count_left < 1 then
			-- Показываемошибку, что видео закончились
			msg.post("main:/loader_gui", "add_popup_notify", {
				text = popup_content.get("rewarded", "error_no_video"),
				icon = "Error_icon_popup_2",
				sound = "popup_default",
				type = "error"
			})
			
			return false
		end
		loader_sdk_modules.ads.ads_rewarded_visible(self, true)

	else
		nakama.sync(function ()
			-- Показываем прелоадер
			gui_global_loader_donate.all_loader_visible(self, true, screen_content.get(hash("modal_donate"), "loader_purchase"))

			if self.timer_purchase_loader then
				timer.cancel(self.timer_purchase_loader)
				self.timer_purchase_loader = nil
			end

			-- Через 10 секунд выключаем его насильно
			self.timer_purchase_loader  = timer.delay(10, false, function (self)
				gui_global_loader_donate.all_loader_visible(self, false, screen_content.get(hash("modal_donate"), "loader_purchase"))
			end)

			local data = loader_sdk_rpc.purhase(storage_sdk.stats.platform_id, "add", {type = id})

			-- Если не пришла ошибка
			if not data or not data.order_id then
				gui_global_loader_donate.all_loader_visible(self, false, screen_content.get(hash("modal_donate"), "loader_purchase"))

				return
			else
				if html5 then
					--[[
					html5.run([=[
					window.assistant_client.sendData(
					{
						action: {action_id: 'TEST_BUY', parameters: {id : "]=]..id..[=[", order_id : "]=]..data.order_id..[=[",} }
					});
					]=])
					--]]
					html5.run([=[
					window.assistant_client.sendData(
					{
						action: {action_id: 'BUY', parameters: {id : "]=]..id..[=[", order_id : "]=]..data.order_id..[=[",} }
					});
					]=])
				end

				return
			end
		end)

	end
end

return M