-- Управление оценками в игре
local M = {}

--local screen_content = require "main.content.screen.screen_content"
local storage_sdk = require "main.storage.storage_sdk"
local storage_player = require "main.storage.storage_player"
local storage_gui = require "main.storage.storage_gui"
local nakama = require "nakama.nakama"
local json = require "nakama.util.json"
--local nakama_controller = require "main.online.nakama.modules.nakama_controller"
--local loader_sdk_rpc = require "main.loaders.loader_sdk.modules.loader_sdk_rpc"
--local modal_stars_blocks = require "main.gui.modal.modal_stars.modules.modal_stars_blocks"
--local modal_stars_listen = require "main.gui.modal.modal_stars.modules.modal_stars_listen"
--local screen_content = require "main.content.screen.screen_content"

local success_function = function (self)
	local title = screen_content.get(hash("modal_stars"), "success_message").title
	local title_color = "lime"
	local content = screen_content.get(hash("modal_stars"), "success_message").description

	if storage_gui.components_visible.modal_stars then
		msg.post(storage_gui.components_visible.modal_stars, "set_status", {status = "visible_loader", visible = visible, title = title})
	end
	modal_stars_blocks.visible_message(self, title, title_color, content, btn_id, btn_color, btn_title, {count = storage_sdk.stats.gifts.stars})

	timer.delay(5, false, function ()
		modal_stars_listen.close_animate(self, gui)
	end)
end

local fail_function = function (self)
	local title = screen_content.get(hash("modal_stars"), "title_error")
	local title_color = "red"
	local content = screen_content.get(hash("modal_stars"), "errors").push.description

	if storage_gui.components_visible.modal_stars then
		msg.post(storage_gui.components_visible.modal_stars, "set_status", {status = "visible_loader", visible = visible, title = title})
	end
	modal_stars_blocks.visible_message(self, title, title_color, content, btn_id, btn_color, btn_title, {count = storage_sdk.stats.gifts.stars})
	

	timer.delay(5, false, function ()
		modal_stars_listen.close_animate(self, gui)
	end)
end

-- Активация кнопки "Оценить игру"
function M.activate_catalog_rating(self)
	if not self.loader_visible then
		local title = screen_content.get(hash("modal_stars"), "loader_sdk_catalog")
		modal_stars_listen.visible_loader(self, true, title)

		if html5 then
			html5.run([=[
			window.assistant_client.sendData(
			{
				action: {
					action_id: 'SHOW_STARS'
				}
			});]=])
		end
	end
end

-- Пришла оценка от платвормы SDK
function M.sdk_set_star(self, data)
	local code = data.code or 0
	local code = tonumber(data.code)
	if code == 1 then
		self.active_star = data.star or 0
		local type = "star"
		loader_sdk_rpc.add_feedback(self, type, success_function, fail_function)

	else
		if storage_gui.components_visible.modal_stars then
			msg.post(storage_gui.components_visible.modal_stars, "set_status", {status = "visible_loader", visible = visible, title = title})
		end
	end

end

-- Поставлена хорошая оценка
function M.good_star(self)
	
end

-- Поставлена плохая оценка
function M.bad_star(self)
	-- Показываем, что оценка отправляется
	local title = screen_content.get(hash("modal_stars"), "title_push")
	local title_color = "white"
	local content = screen_content.get(hash("modal_stars"), "description_push")
	modal_stars_blocks.visible_message(self, title, title_color, content, btn_id, btn_color, btn_title)

	local type = "star"
	loader_sdk_rpc.add_feedback(self, type, success_function, fail_function)
end



return M