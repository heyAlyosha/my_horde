-- Ядро для перевода текстов
local M = {}

local csv = require "main.modules.csv"
local gui_text = require "main.gui.modules.gui_text"

M.data = {}
M.lang = M.lang or "ru"

-- Запись всех переводов из csv
function M.init(self)
	-- Гуи
	local config_id = "gui"
	local separator = ";"
	csv.load(config_id, "/main/game/csv/gui_lang.csv", separator)
	for k, v in pairs(csv.get_matrix(config_id)) do
		M.data[k] = v
	end

	-- Контент
	local config_id = "content"
	local separator = ";"
	csv.load(config_id, "/main/game/csv/content_lang.csv", separator)
	for k, v in pairs(csv.get_matrix(config_id)) do
		M.data[k] = v
	end
end

-- Получение перевода
function M.get_text(self, id_string, before_str, after_str, values)
	local string = id_string
	local before_str = before_str or ""
	local after_str = after_str or ""

	if M.data[id_string] and M.data[id_string][M.lang] then
		string = M.data[id_string][M.lang]
	end

	if values then
		string = gui_text.set_placeholder(string, values)
	end

	return before_str .. string .. after_str
end

return M