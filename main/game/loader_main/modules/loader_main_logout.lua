-- События входа в игру
local M = {}

local color = require("color-lib.color")
local storage_player = require "main.storage.storage_player"
local game_core_round_start = require "main.game.core.round.modules.game_core_round_start"
local loader_sdk_modules = require "main.loaders.loader_sdk.modules.loader_sdk_modules"
local game_content_artifact = require "main.game.content.game_content_artifact"
local api_core_shop = require "main.core.api.api_core_shop"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local api_player = require "main.game.api.api_player"
local game_content_notify_add = require "main.game.content.game_content_notify_add"
local game_tests_gui = require "main.game.tests.game_tests_gui"
local game_tests_gui_family = require "main.game.tests.game_tests_gui_family"
local data_handler = require "main.data.data_handler"
local core_player_function = require "main.core.core_player.modules.core_player_function"
local game_content_prize = require "main.game.content.game_content_prize"
local storage_game = require "main.game.storage.storage_game"
local timer_linear = require "main.modules.timer_linear"
local gui_integer = require "main.gui.modules.gui_integer"

function M.start(self, message)
	self.start = nil
	game_core_round_start.to_start(self)
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

	api_core_shop.add_start_shop(self, game_content_artifact)

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
				msg.post("game-room:/core_game", "start_study", {})

			else
				msg.post("main:/core_screens", "main_menu", {})

			end
		end

		-- ЗАПУСК ИГРЫ -- 
		--msg.post("game-room:/core_game", "start_study", {})
		--game_tests_gui.core(self, "sector_catch")
		--msg.post("/core_screens", "catalog_company", {category_id = nil})
		--msg.post("/loader_gui", "visible", {id = "catalog_company", visible = true})
		-- ТЕСТЫ
		--msg.post("game-room:/core_game", "start_company_level", {category_id = "music_russkiy_rok", level_id = 1})
		--[[
		msg.post("main:/loader_gui", "visible", {id = "quest_music", visible = true, value = {
			title = "Тест"
		}})
		--]]
		--[[
		storage_player.study.shop = nil
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
					id = "catalog_shop",
					visible = false
				},
			},
		})
		--]]
		--storage_player.view_rewards = { try_1 = 0}
		--game_tests_gui.core(self, "wheel")
		--game_tests_gui_family.core(self, "catch")
		--msg.post("game-room:/core_game", "start_study", {})

		--[[
		msg.post("/loader_gui", "set_content", {id = "interface", type = "set_btns", 
			value = {
				id =  "testing"
			}
		})

		msg.post("/loader_gui", "set_status", {
			id = "game_wheel",
			type = "preview_aim",
			value = {speed = 10,size = 100},
			visible = true
		})

		--Зачисление очков или приза из 
		local count = 10000
		local interval_add_score
		local add_score = 150
		local interval_add_score = 0.1
		gui_integer.to_parts(self, count, add_score, function (self, value)
			timer_linear.add(self, "result_single", interval_add_score, function (self)
				msg.post("/loader_gui", "set_status", {
					id = "add_balance",
					type = "coins",
					start_position = vmath.vector3(500),
					value = value
				})
				msg.post("main:/sound", "play", {sound_id = "game_result_leaders_1"})
			end)
		end)
		--]]

		timer.delay(0.5, false, function (self)
			--storage_player.characteristic_points = 5
			--msg.post("game-room:/core_game", "start_study", {})
		end)
		--storage_player.artifacts.catch_2 = 3
		--storage_player.artifacts.accuracy_2 = 2
		--storage_player.artifacts.speed_caret_2 = 2
		--storage_player.characteristics.accuracy = 20
		--pprint(storage_player.characteristics)
		--game_tests_gui.core(self, "wheel")

		if not storage_player.reset then
			--game_tests_gui.core(self, "catch")
			--msg.post("main:/loader_gui", "visible", {id = "modal_reset", visible = true})
			--msg.post("/loader_gui", "visible", {id = "catalog_company", visible = true})
			--msg.post("game-room:/core_game", "start_company_level", {category_id = "music_russkiy_rok", level_id = 1})
		else
			
			--msg.post("main:/loader_gui", "visible", {id = "modal_reset", visible = true})
		end

		--storage_player.characteristics.trade = 5
		--storage_player.artifacts = {}

		--msg.post("main:/core_screens", "main_menu", {})
		--msg.post("main:/core_screens", "constructor_family", {})
		--msg.post("main:/core_screens", "game_family_shop")

		-- Показываем и фокусируем
		--[[
		msg.post("/loader_gui", "visible", {
			id = "game_hud_buff_horisontal",
			visible = true,
			value = {
				is_game = true,
				is_reward = true,
				sector_id = 1,
				player_id = "player",
			}
		})
		--]]

		timer.delay(0.2, false, function (self)
			--[[
			msg.post("main:/loader_gui", "visible", {
				id = "modal_characteristics",
				visible = true,
			})

			local items = game_content_prize.catalog_keys
			local index = 0
			for id, item in pairs(items) do
				storage_player.prizes[id] = 1
				index = index + 1

				if index > 3 then
					break
				end
			end
			--]]

			--[[
			storage_player.prizes = {
				ipad = 2,
				duhi = 2,
			}
			msg.post("main:/loader_gui", "visible", {
				id = "catalog_inventary",
				visible = true,
				modal = false,
			})

			storage_player.characteristic_points = 1
			msg.post("main:/loader_gui", "visible", {
				id = "modal_characteristics",
				visible = true,
			})
			
			
			storage_player.shop = {
				trap_1 = 1
			}
			msg.post("main:/loader_gui", "visible", {
				id = "catalog_inventary",
				visible = true,
				modal = false,
				-- Кнопка внизу
				btn_smart = {
					type = "message",
					title_id = "_to_buy",
					message_url = "main:/loader_gui",
					message_id = "visible",
					message = {
						id = "catalog_shop",
						visible = true
					},
				},
			})
			--]]

			--[[
			msg.post("main:/loader_gui", "visible", {
				id = "catalog_inventary",
				visible = true,
				modal = false,
				-- Кнопка внизу
				btn_smart = {
					type = "message",
					title_id = "_to_buy",
					message_url = "main:/loader_gui",
					message_id = "visible",
					message = {
						id = "catalog_shop",
						visible = true
					},
				},
			})
			
			storage_player.coins = 2000
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
						id = "catalog_shop",
						visible = false
					},
				},
			})
			--]]
			--[[
			storage_player.characteristics.trade = 10
			storage_player.characteristic_points = 1

			msg.post("main:/loader_gui", "visible", {
				id = "modal_characteristics",
				visible = true,
			})
			msg.post("main:/loader_gui", "visible", {
				id = "catalog_characteristic",
				visible = true,
			})
			--]]
		end)

		if not self.start then
			self.start = true
			--[[
			storage_player.view_rewards = {
				try_1 = 3,
				catch_1 = 10
			}
			--]]
			--storage_player.artifacts.try_1 = 0
			--game_tests_gui.core(self, "catch")
			--msg.post("game-room:/core_game", "start_company_level", {category_id = "bloger", level_id = 1})
			--storage_game.game.study_level = 2
			--msg.post("game-room:/core_game", "start_study", {})
			
			--[[
			storage_player.characteristic_points = 1
			msg.post("main:/loader_gui", "visible", {
				id = "modal_characteristics",
				visible = true,
			})
			
			storage_player.characteristic_points = 1
			msg.post("main:/loader_gui", "visible", {
				id = "modal_characteristics",
				visible = true,
			})
			--]]

			--[[
			msg.post("main:/loader_gui", "visible", {
				id = "catalog_prize_magazine", 
				visible = true
			})
			--]]
			--msg.post("game-room:/core_game", "start_study", {})
		end
		--[[
		msg.post("/loader_gui", "visible", {
			id = "game_word",
			visible = true,
			type = hash("animated_close")
		})
		--]]

		--msg.post("/core_screens", "catalog_levels", {category_id = "army", focus_level = nil})
		--msg.post("/loader_gui", "visible", {id = "catalog_levels", category_id = "bloger", visible = true})
		--msg.post("/loader_gui", "visible", {id = "catalog_company", visible = true})
		--[[
		msg.post("main:/loader_gui", "visible", {
			id = "catalog_prize_magazine", 
			visible = true
		})
		
		storage_player.characteristic_points = 5
		timer.delay(10, false, function (self)
			msg.post("game-room:/core_game", "start_study", {})
		end)
		]]--
	end

	--[[
	msg.post("/loader_gui", "visible", {
		id = "catalog_rating",
		visible = true,
		type = hash("animated_close"),
		value = {
			--type_default_rating = 'top/personal/yandex',
			type_rating = 'top',
			type_default_rating = "top",
		}
	})
	--]]

	timer.delay(0.2, false, function (self)
		--[[
		msg.post("main:/loader_gui", "visible", {
			id = "modal_settings",
			visible = true,
			type = hash("animated_close"),
		})

		msg.post("main:/loader_gui", "visible", {
			id = "modal_characteristics",
			visible = true,
			type = hash("animated_close"),
		})
		msg.post("/loader_gui", "visible", {
			id = "modal_result_single",
			visible = true,
			type = hash("popup"),
			value = {
				type_result = "win",
				score = 0,
				prizes = {{id = "ipad", count = 2,}, {id = "tv", count = 1,}},
				current_level = {id = 2, stars = 2, category_id = "sport"},
				-- если нет следующего уровня - вылезет плашка с пройденной компанией
				--next_level = {id = 3, stars = 2, unlock = true/false, category_id = hash("sport")},
			},
		})
		--]]
	end)

	--core_player_function.print_score_for_levels(40)

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
		--[[
		timer.delay(0.1, false, function (self)
			msg.post("/loader_gui", "visible", {
				id = "modal_reward_visit",
				visible = true,
				value = {day = storage_player.day_to_game},
				type = hash("animated_close"),
			})
		end)

		msg.post("main:/loader_gui", "visible", {
			id = "catalog_shop",
			visible = true,
		})
		--]]
	end

	--[[
	msg.post("main:/loader_gui", "visible", {
		id = "modal_settings",
		visible = true,
	})

	msg.post("/loader_gui", "visible", {
		id = "character_dialog",
		visible = true
	})
	--]]
	--msg.post("/core_screens", "catalog_company", {category_id = "history"})
	--msg.post("/core_screens", "catalog_levels", {category_id = "army", focus_level = nil})

	
	--msg.post("game-room:/core_game", "start_tournir")

	--game_content_notify_add.update_shop(self)

	--game_content_notify_add.add_achieve(self, "coins_500")
	--game_content_notify_add.add_achieve(self, "full_mind")
	--game_content_notify_add.add_achieve(self, "score_2500")
	--game_content_notify_add.add_achieve(self, "full_charisma")
	
end


return M