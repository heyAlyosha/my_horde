-- События входа в игру
local M = {}

local color = require("color-lib.color")
local storage_player = require "main.storage.storage_player"
local loader_sdk_modules = require "main.loaders.loader_sdk.modules.loader_sdk_modules"
local api_core_shop = require "main.core.api.api_core_shop"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local api_player = require "main.game.api.api_player"
local game_tests_gui = require "main.game.tests.game_tests_gui"
local game_tests_gui_family = require "main.game.tests.game_tests_gui_family"
local data_handler = require "main.data.data_handler"
local core_player_function = require "main.core.core_player.modules.core_player_function"
local storage_game = require "main.game.storage.storage_game"
local timer_linear = require "main.modules.timer_linear"
local gui_integer = require "main.gui.modules.gui_integer"

function M.start(self, message)
	self.start = nil
	msg.post("/loader_gui", "visible", {id = "plug", visible = false})
	msg.post("/core_screens", "clear", {})

	loader_sdk_modules.logout.start()
end

function M.error(self, message)
	msg.post("/loader_gui", "visible", {
		id = "plug", visible = true, value = {
			title = "ОШИБКА ПРИ ПОЛУЧЕНИИ ДАННЫХ...",
			color = color.yellow,
			icon = "icon_danger",
			btns = {
				{
					id = "logout",
					title = "ПОВТОРИТЬ ВХОД",
					bg = "button_default_green_",
				},
			},
		}
	})
	msg.post("/core_screens", "clear", {})
end

-- Успешный вход
function M.success(self, message)
	if not self.start then
		self.start = true
	else
		return
	end

	msg.post("/loader_gui", "visible", {
		id = "plug", visible = false
	})

	storage_player.settings = api_player.get_settings(self)

	-- Новый игрок
	if storage_player.created then
		-- запускаем обучение
		--msg.post("game-room:/core_game", "start_study", {})

	elseif not storage_player.created and storage_player.new_day then
		
	end

	-- Новый день в игре
	if storage_player.new_day and not storage_player.created then
		-- Старый игрок приходит впервые за день
		-- Сбрасываем его старые просмотры рекламы
		local userdata = {
			view_rewards = {}
		}
		data_handler.set_userdata(self, userdata, function_result)

	end

	if not message.import then
		msg.post("main:/music", "play", {sound = "music-default", loop = nil})

		-- ЗАПУСК ИГРЫ -- 
		local production = true
		if production then
			if storage_player.created then
				-- Дарим тестовые предметы
				storage_player.artifacts = {
					trap_1 = 1,
					accuracy_1 = 1,
					speed_caret = 1,
					bank_1 = 1,
					catch_1 = 1,
				}
				-- Запускаем обучение
				--msg.post("game-room:/core_game", "start_study", {})

			else
				--msg.post("main:/core_screens", "main_menu", {})

			end
		end

		-- ЗАПУСК ИГРЫ -- 
		--msg.post("game-room:/core_game", "start_study", {})
		--game_tests_gui.core(self, "sector_catch")
		--msg.post("/core_screens", "catalog_company", {category_id = nil})
		--msg.post("/loader_gui", "visible", {id = "catalog_company", visible = true})
		-- ТЕСТЫ --
		if false then
			-- Игровой уровень
			msg.post("main:/loader_main", "load_level", {
				company_id = "city_hospital", level_id = 2
			})

		elseif false then
			-- карта
			msg.post("main:/loader_main", "load_level", {
				company_id = "world_map", level_id = "world_map"
			})
		else
			-- Прототип с противниками
			msg.post("main:/loader_main", "load_level", {
				company_id = "prototypes", level_id = "prototype_enemy"
			})
		end

		
	end

	-- Заходит н-ый день подряд 
	if not storage_player.created and storage_player.new_day and not storage_player.add_reward_visit then
		timer.delay(0.1, false, function (self)
			msg.post("/loader_gui", "visible", {
				id = "modal_reward_visit",
				visible = true,
				value = {day = storage_player.day_to_game},
				type = hash("animated_close"),
			})
		end)
	else
		
	end

	msg.post("/loader_gui", "visible", {
		id = "interface",
		visible = true
	})

	-- Характеристики
	storage_player.characteristics.damage = 1
	storage_player.coins = 10
	msg.post("main:/loader_gui", "visible", {
		id = "catalog_characteristic",
		visible = true,
	})
end


return M