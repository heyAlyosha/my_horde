-- Поиск мата из таблицы csv в строках 
local M = {}

local csv = require "main.modules.csv"

M.data = false

function M.is_censoored(self, string)
	local string = string or ""
	string = utf8.lower(string)

	-- Собираем матные слова из таблицы
	if not M.data then
		local config_id = "censoored"
		local separator = ";"
		csv.load(config_id, "/main/game/csv/censoored.csv", separator)
		M.data = csv.get_indexed_row_ids(config_id)
	end

	for i, word in ipairs(M.data) do
		if utf8.find(string, word) then
			return true

		elseif utf8.len(string) >= 3 and utf8.find(word, string) then
			return true
		end
	end

	return false
end

return M