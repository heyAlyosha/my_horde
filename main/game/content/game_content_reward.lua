-- Храним контент для наград
local storage_player = require "main.storage.storage_player"

local M = {}

M.rewards = {
	-- Награда за визит каждый день
	visit = {
		coins = 100,
		score = 200,
	},
}

return M