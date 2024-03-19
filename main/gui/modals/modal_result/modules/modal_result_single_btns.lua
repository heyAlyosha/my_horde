-- Кнопки
local M = {}

local druid = require("druid.druid")
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local gui_animate = require "main.gui.modules.gui_animate"
local storage_sdk = require "main.storage.storage_sdk"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local loader_sdk_modules = require "main.loaders.loader_sdk.modules.loader_sdk_modules"
local storage_game = require "main.game.storage.storage_game"
local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"
local game_content_artifact = require "main.game.content.game_content_artifact"
local lang_core = require "main.lang.lang_core"

function M.function_back(self)
	M.function_activate(self, 1)
end

-- Нажатие на кнопки
function M.function_activate(self, focus_btn_id)
	local btn = self.btns[focus_btn_id]

	gui_animate.activate(self, btn.node)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	-- Нажатие на центральную кнопку
	if focus_btn_id == 3 then
		local settings = api_player.get_settings(self)

		-- Нужно ли напоминать про магазин
		if settings.help_shop and not self.open_shop and not self.help_shop then
			-- Включена настройка
			local is_open_show = false

			local objects = {
				trap_1 = game_content_artifact.get_item("trap_1", player_id, is_game, is_reward),
				catch_1 = game_content_artifact.get_item("catch_1", player_id, is_game, is_reward),
				accuracy_1 = game_content_artifact.get_item("accuracy_1", player_id, is_game, is_reward),
				speed_caret_1 = game_content_artifact.get_item("speed_caret_1", player_id, is_game, is_reward),
				try_1 = game_content_artifact.get_item("try_1", player_id, is_game, is_reward),
			}

			for object_id, object in pairs(objects) do
				-- Если доступны для покупки
				local help_shop = object.count < 1 and (not object.disable_buy or object.buy.sell or not storage_player.study.shop or not storage_player.study.inventary)

				if help_shop then
					is_open_show = true
					break
				end
			end

			if is_open_show then
				self.help_shop = true

				msg.post("main:/core_study", "event", {
					id = "open_shop_for_games"
				})

				msg.post("main:/loader_gui", "visible", {
					id = "catalog_shop",
					visible = true,
					modal = false,
					-- Кнопка внизу
					btn_smart = {
						type = "message",
						title_id = "_start_play",
						message_url = "main:/loader_gui",
						message_id = "visible",
						message = {
							id = "inventary_wrap",
							--all_msg = true,
							visible = false
						},
					},
				})

				return
			end
		end
	end

	if btn.id ~= "login" then
		gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
			msg.post("/loader_gui", "visible", {
				id = "modal_result_single",
				visible = false
			})
		end)
	end

	if focus_btn_id ~= 3  and storage_game.game.study_level then
		-- если во время учения нажимает на любую кнопку кроме продолжения
		storage_game.game.study_level = nil
	end

	

	if btn.id == "close" or btn.id == "back" then
		-- Закрытие/возврат назад
		msg.post("main:/core_screens", "back_menu", {})

	elseif btn.id == "continue" then
		-- Следующий уровень
		msg.post(storage_game.map.url_script, "next")

	elseif btn.id == "refresh" then
		-- Повтор игры
		msg.post("main:/core_screens", "refresh_round", {})
		
	elseif btn.id == "home" then
		-- В главное меню
		msg.post("main:/core_screens", "main_menu", {})

	elseif btn.id == "login" then
		-- Авторизация
		loader_sdk_modules.logout.open_auth_window(self)
		return
	end

	storage_game.game.study_level = nil
end

function M.render_login_btn(self)
	-- Если игрок не авторизован
	gui_loyouts.set_enabled(self, self.nodes.login_wrap, storage_sdk.player.is_anonime)
	if not storage_sdk.player.is_anonime then
		for i, btn in ipairs(self.btns) do
			if btn.id == "login" then
				table.remove(self.btns, i)
			end
		end
	end
end

return M