-- Тестирвоание Импорта прогресса между аккаунтами
local online_import_account = require "main.online.online_import_account"

return function()
	describe("Import test ", function()
		before(function()
			
		end)

		after(function()
			-- this function will be run after each test
		end)

		test("Score and coins", function()
			local player_data = {
				score = 150, coins = 200,
			}

			local anonym_data = {
				score = 150, coins = 200,
			}

			local score, coins = online_import_account.from_anonym(self, player_data, anonym_data)

			assert_true(score == 300)
			assert_true(coins == 400)

		end)

		test("Characteristics", function()
			local player_data = {
				characteristics = {
					mind = 5,
					accuracy = 2,
					speed_caret = 3,
					charisma = 6
				}
			}

			local anonym_data = {
				characteristics = {
					mind = 5,
					accuracy = 4,
					speed_caret = 1,
					trade = 1,
				}
			}

			local score, coins, metadata = online_import_account.from_anonym(self, player_data, anonym_data)

			local characteristics = metadata.characteristics 
			assert_true(characteristics.mind == 5)
			assert_true(characteristics.accuracy == 4)
			assert_true(characteristics.speed_caret == 3)
			assert_true(characteristics.charisma == 6)
			assert_true(characteristics.trade == 1)
			assert_nil(characteristics.random_name)

		end)

		test("Prizes, shop, stats", function()
			local player_data = {
				prizes = {
					test_1 = 5,
					test_3 = 2,
					test_4 = 0
				},
				shop = {
					test_1 = 5,
					test_3 = 2,
					test_4 = 0
				},
				stats = {
					test_1 = 5,
					test_3 = 2,
					test_4 = 0
				},
			}

			local anonym_data = {
				prizes = {
					test_1 = 5,
					test_2 = 3,
					test_4 = 1
				},
				shop = {
					test_1 = 5,
					test_2 = 3,
					test_4 = 1
				},
				stats = {
					test_1 = 5,
					test_2 = 3,
					test_4 = 1
				},
			}

			local score, coins, metadata = online_import_account.from_anonym(self, player_data, anonym_data)

			local prizes = metadata.prizes 
			assert_true(prizes.test_1 == 10)
			assert_true(prizes.test_2 == 3)
			assert_true(prizes.test_3 == 2)
			assert_true(prizes.test_4 == 1)
			assert_nil(prizes.random_id)

			local shop = metadata.shop 
			assert_true(shop.test_1 == 10)
			assert_true(shop.test_2 == 3)
			assert_true(shop.test_3 == 2)
			assert_true(shop.test_4 == 1)
			assert_nil(shop.random_id)

			local stats = metadata.stats 
			assert_true(stats.test_1 == 10)
			assert_true(stats.test_2 == 3)
			assert_true(stats.test_3 == 2)
			assert_true(stats.test_4 == 1)
			assert_nil(stats.random_id)

		end)

		test("Visible Levels", function()
			local player_data = {
				visible_levels = {
					test_1 = {
						test_1 = 2,
						test_3 = 2,
						test_4 = 1,
					},
					test_3 = {
						test_1 = 4
					},
				}
			}

			local anonym_data = {
				visible_levels = {
					test_1 = {
						test_1 = 1,
						test_2 = 2,
						test_3 = 3,
					},
					test_2 = {
						test_2 = 8
					},
				}
			}

			local score, coins, metadata = online_import_account.from_anonym(self, player_data, anonym_data)

			local visible_levels = metadata.visible_levels 
			assert_true(visible_levels.test_1.test_1 == 1)
			assert_true(visible_levels.test_1.test_2 == 2)
			assert_true(visible_levels.test_1.test_3 == 3)
			assert_true(visible_levels.test_1.test_4 == 1)
			assert_true(visible_levels.test_2.test_2 == 8)
			assert_true(visible_levels.test_3.test_1 == 4)
			assert_nil(visible_levels.test_4)

		end)

		test("Progress Levels", function()
			local player_data = {
				progress = {
					test_1 = {
						test_1 = 2,
						test_3 = 2,
						test_4 = 1,
						test_5 = 1,
					},
					test_3 = {
						test_1 = 4
					},
				}
			}

			local anonym_data = {
				progress = {
					test_1 = {
						test_1 = 1,
						test_2 = 2,
						test_3 = 3,
						test_5 = 3,
					},
					test_2 = {
						test_2 = 8
					},
				}
			}

			local score, coins, metadata = online_import_account.from_anonym(self, player_data, anonym_data)

			local progress = metadata.progress 
			assert_true(progress.test_1.test_1 == 2)
			assert_true(progress.test_1.test_2 == 2)
			assert_true(progress.test_1.test_3 == 3)
			assert_true(progress.test_1.test_4 == 1)
			assert_true(progress.test_1.test_5 == 3)
			assert_true(progress.test_2.test_2 == 8)
			assert_true(progress.test_3.test_1 == 4)
			assert_nil(progress.test_4)

		end)

		test("Achieve", function()
			local player_data = {
				achieve = {
					test_1 = true,
					test_2 = true,
					test_3 = true
				}
			}

			local anonym_data = {
				achieve = {
					test_2 = true,
					test_4 = true,
					test_5 = true
				}
			}

			local score, coins, metadata = online_import_account.from_anonym(self, player_data, anonym_data)

			local achieve = metadata.achieve 
			assert_true(achieve.test_1)
			assert_true(achieve.test_2)
			assert_true(achieve.test_3)
			assert_true(achieve.test_5)
			assert_nil(achieve.test_6)

		end)

	end)
end