-- Работа с данными барабана
local M = {}

local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"

-- Обновление статистики игрока
function M.get_buffs(self, player_id)
	a
end

-- Добавление данны в статистику по игре
function M.add(self, id)
	storage_player.stats = storage_player.stats or {}
	storage_player.stats[id] = storage_player.stats[id] or 0

	return storage_player.stats[id]
end

return M