-- Функции для выбора цвета игрока
local M = {}

local color = require("color-lib.color")

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local storage_game = require "main.game.storage.storage_game"

-- Варианты кол-ва очков для покупки для выбора цвета
M.coins = {
	0,
	100, 
	250, 
	500, 
	750,
	1000,
}

-- Пролистываем цвета
function M.listen(self, id)
	local add_index = 1
	self.score = storage_game.family.settings.add_coins

	-- Смотрим в какую сторону листать массив
	if id == "left" then
		add_index = -1
	elseif id == "right" then
		add_index = 1
	else
		add_index = 0
	end

	-- ищем следующую позицию
	local current_index = 0
	for i = 1, #M.coins do
		local item = M.coins[i]

		if item == self.score then
			current_index = i
			break
		end
	end

	-- ищем следующую позицию
	local next_index = current_index + add_index

	-- смотрим есть ли она
	if next_index > #M.coins then
		next_index = 1
	elseif next_index < 1 then
		next_index = #M.coins
	end

	self.score = M.coins[next_index]
	storage_game.family.settings.add_coins = self.score

	gui_loyouts.set_text(self, self.nodes.score_value, self.score)

	return true
end

return M