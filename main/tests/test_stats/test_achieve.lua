-- Тестирвоание ачивок
local core_achieve_functions = require "main.core.core_achieve.modules.core_achieve_functions"

local core_prorgress = require "main.core.core_progress.core_prorgress"
local storage_player = require "main.storage.storage_player"
local api_core_player = require"main.core.api.api_core_player"

return function()
	describe("Achieve tests", function()
		before(function()
			storage_player.progress = {}
			storage_player.stats = {}
		end)

		after(function()
			-- this function will be run after each test
		end)

		test("Add Achieve Value", function()
			local items = {
				{id = "full_stars_50", operation = "add", value = 55},
				{id = "win_1", operation = "add", value = 1},
				{id = "win_50", operation = "add", value = 20},
			}
			local success_achive = core_achieve_functions.set_progress(self, items)

			assert_true(success_achive.full_stars_50)
			assert_true(success_achive.win_1)
			assert_nil(success_achive.win_50)

			local items = {
				{id = "win_50", operation = "add", value = 40},
			}

			success_achive = core_achieve_functions.set_progress(self, items)
			assert_true(success_achive.win_50)
		end)

		test("Set Achieve Value and Get progress", function()
			local items = {
				{id = "full_inventary", operation = "set", value = 10},
			}
			local success_achive = core_achieve_functions.set_progress(self, items)

			local progress = core_achieve_functions.get_progress("full_inventary")

			assert(progress.achieve_progress == 10)
			assert_nil(progress.status)
		end)

		test("Success update Achieve", function()
			-- Обновление уже полученного достижения
			storage_player.achieve_progress = {}
			storage_player.achieve = {}
			storage_player.stats = {}

			for i = 1, 50 do
				storage_player.prizes['test_'..i] = math.random(300)
			end
			core_achieve_functions.update(self)
			local achieves = game_content_achieve.get_catalog(self, core_achieve_functions)
			local progress = core_achieve_functions.get_progress("full_inventary")
			assert(progress.achieve_progress == 50)
			assert_true(progress.status)

			storage_player.prizes = {}
			for i = 1, 30 do
				storage_player.prizes['test_'..i] = math.random(300)
			end
			core_achieve_functions.update(self)

			local progress = core_achieve_functions.get_progress("full_inventary")

			local progress = core_achieve_functions.get_progress("full_inventary")
			assert(progress.achieve_progress == 50)
			assert_true(progress.status)
			
		end)

		test("Stars Type Achieve", function()
			-- Тестирую тип ачивки со звёздами
			-- Тестовые выполненные уровни на 3 звезды
			local categories = {hash("astronomy"), hash("geography")}
			for i = 1, 60 do
				local category_id_random = categories[math.random(#categories)]
				core_prorgress.set_progress_level(category_id_random, i, 3)
			end

			core_achieve_functions.update(self)
			local progress = core_achieve_functions.get_progress("full_stars_50")

			assert(progress.achieve_progress == 60)
			assert_true(progress.status)
		end)

		test("Wins Type Achieve", function()
			-- Тестирую тип ачивки с победами
			storage_player.achieve_progress = {}
			storage_player.achieve = {}
			storage_player.stats = {}
			local items = {
				{id = "win", operation = "add", value = 1}
			}
			core_prorgress.set_stats(items)
			core_achieve_functions.update(self)

			local progress = core_achieve_functions.get_progress("win_1")
			assert(progress.achieve_progress == 1)
			assert_true(progress.status)
			progress = core_achieve_functions.get_progress("win_50")
			assert(progress.achieve_progress == 1)
			assert_true(not progress.status)

			local items = {
				{id = "win", operation = "add", value = 49}
			}
			core_prorgress.set_stats(items)
			core_achieve_functions.update(self)

			progress = core_achieve_functions.get_progress("win_50")
			assert(progress.achieve_progress == 50)
			assert_true(progress.status)
		end)

		test("Coins and Score Type Achieve", function()
			-- Тестирую тип ачивки с победами
			storage_player.achieve_progress = {}
			storage_player.achieve = {}
			storage_player.stats = {}

			storage_player.coins = 499
			storage_player.score = 800
			core_achieve_functions.update(self)

			local progress = core_achieve_functions.get_progress("coins_500")
			assert(progress.achieve_progress == 499)
			assert_true(not progress.status)
			progress = core_achieve_functions.get_progress("score_10000")
			assert(progress.achieve_progress == 800)
			assert_true(not progress.status)

			storage_player.coins = 500
			storage_player.score = 10000
			core_achieve_functions.update(self)

			local progress = core_achieve_functions.get_progress("coins_500")
			assert(progress.achieve_progress == 500)
			assert_true(progress.status)
			progress = core_achieve_functions.get_progress("coins_5000")
			assert_true(not progress.status)
			progress = core_achieve_functions.get_progress("score_10000")
			assert(progress.achieve_progress == 10000)
			assert_true(progress.status)
		end)

		test("Characteristics Type Achieve", function()
			-- Тестирую тип ачивки с победами
			storage_player.achieve_progress = {}
			storage_player.achieve = {}
			storage_player.stats = {}
			storage_player.characteristics = {}
			storage_player.characteristic_points = 200

			api_core_player.set_characteristic(self, "mind", "set", 9)
			core_achieve_functions.update(self)

			local progress = core_achieve_functions.get_progress("full_mind")
			assert(progress.achieve_progress == 9)
			assert(storage_player.characteristic_points == (200 - 9))
			assert_true(not progress.status)
			progress = core_achieve_functions.get_progress("full_accuracy")
			assert(progress.achieve_progress == 0)
			assert_true(not progress.status)

			api_core_player.set_characteristic(self, "mind", "add", 1)
			core_achieve_functions.update(self)
			progress = core_achieve_functions.get_progress("full_mind")
			assert(progress.achieve_progress == 10)
			assert(storage_player.characteristic_points == (200 - 9 - 1))
			assert_true(progress.status)
			progress = core_achieve_functions.get_progress("full_accuracy")
			assert(progress.achieve_progress == 0)
			assert_true(not progress.status)

		end)

		test("Full Company Type Achieve", function()
			-- Тестирую тип ачивки со звёздами
			-- Тестовые выполненные уровни
			for i = 1, 10 do
				core_prorgress.set_progress_level(hash("astronomy"), i, 0)
			end

			core_achieve_functions.update(self)
			local progress = core_achieve_functions.get_progress("full_company_astronomy")
			assert(progress.achieve_progress == 10)
			assert_true(not progress.status)

			core_prorgress.set_progress_level(hash("astronomy"), 11, 0)
			core_prorgress.set_progress_level(hash("astronomy"), 12, 0)
			core_achieve_functions.update(self)

			progress = core_achieve_functions.get_progress("full_company_astronomy")
			assert(progress.achieve_progress == 12)
			assert_true(progress.status)

			progress = core_achieve_functions.get_progress("full_company_geography")
			assert(progress.achieve_progress == 0)
			assert_true(not progress.status)
			
		end)

		test("Full Prizes Type Achieve", function()
			-- Тестирую тип ачивки со звёздами
			-- Тестовые выполненные уровни
			storage_player.achieve_progress = {}
			storage_player.achieve = {}
			storage_player.stats = {}
			storage_player.prizes = {}

			for i = 1, 10 do
				storage_player.prizes['test_'..i] = math.random(300)
			end

			core_achieve_functions.update(self)
			
			local progress = core_achieve_functions.get_progress("full_inventary")
			assert(progress.achieve_progress == 10)
			assert_true(not progress.status)

			for i = 1, 30 do
				storage_player.prizes['test_'..i] = math.random(300)
			end
			core_achieve_functions.update(self)

			local progress = core_achieve_functions.get_progress("full_inventary")
			assert(progress.achieve_progress == 30)
			assert_true(progress.status)
		end)
	end)
end