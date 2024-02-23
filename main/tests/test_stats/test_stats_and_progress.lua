-- Тестирвоание модуля прогресса и статистики
local core_prorgress = require "main.core.core_progress.core_prorgress"
return function()
	describe("Some tests", function()
		before(function()
			-- this function will be run before each test
		end)

		after(function()
			-- this function will be run after each test
		end)

		test("Add Progress Level", function()
			local category_id = hash("sport")
			local level_id = 2
			local value = 3
			core_prorgress.set_progress_level(category_id, level_id, value)

			assert(core_prorgress.get_progress_level(hash("sport"), 2) == 3)
			assert_nil(core_prorgress.get_progress_level(hash("medicine"), 9))
		end)

		test("Add Stats", function()
			local items = {
				{id = "win", operation = "add", value = 1},
				{id = "fail", operation = "add", value = 1},
				{id = "games", operation = "add", value = 1},
			}
			core_prorgress.set_stats(items)

			local items = {
				{id = "win", operation = "add", value = 3},
				{id = "fail", operation = "add", value = 2},
				{id = "games", operation = "add", value = 5},
			}

			core_prorgress.set_stats(items)

			assert(core_prorgress.get_stats().win == 1 + 3)
			assert(core_prorgress.get_stats().fail == 1 + 2)
			assert(core_prorgress.get_stats().games == 1 + 5)
		end)

		test("Set Stats", function()
			local items = {
				{id = "win", operation = "set", value = 25},
				{id = "fail", operation = "set", value = 35},
				{id = "games", operation = "set", value = 5},
			}
			core_prorgress.set_stats(items)

			assert(core_prorgress.get_stats().win == 25)
			assert(core_prorgress.get_stats().fail == 35)
			assert(core_prorgress.get_stats().games == 5)
		end)

	end)
end