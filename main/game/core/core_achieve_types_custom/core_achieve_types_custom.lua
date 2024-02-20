-- Кастомные типы ачивок
local M = {}

local storage_player = require "main.storage.storage_player"

function M.update(self, type, items, achieve, value)
	if type == "full_prize" then
		local prizes = 0
		for k, prize in pairs(storage_player.prizes) do
			prizes = prizes + 1
		end

		table.insert(items, {id = achieve.id, operation = "set", value = prizes})
	end
end

return M