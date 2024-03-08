-- Информация про достижения
local M = {}

local storage_game = require "main.game.storage.storage_game"

M.types = {
	score = {
		quest = "_stars_quest_score",
		module_core = false,
	},
	symbol = {
		quest = "_stars_quest_symbol",
		module_core = false,
	},
	catch = {
		quest = "_stars_quest_catch",
		module_core = false,
	},
}

-- Поулчение приза за звёздочки
function M.get_prize(self, star, complexity)
	-- Награда за звёздочки
	local coefficient_level 
	if complexity == "easy" then
		coefficient_level = 1
	elseif complexity == "normal" then
		coefficient_level = 2
	elseif complexity == "hard" then
		coefficient_level = 3
	end

	-- Выпадение кучи монеток и опыта
	local stars_score = star * 25 * coefficient_level
	local stars_coins = star * 10 * coefficient_level

	return stars_score, stars_coins
end

return M