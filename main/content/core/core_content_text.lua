-- Храним контент для текста
local storage_player = require "main.storage.storage_player"

local M = {}

M.content = {
	complexity = {
		easy = {ru = "Лёгкий"},
		normal = {ru = "Средний"},
		hard = {ru = "Тяжёлый"},
	}
}

-- Получение текста в зависимости от языка
function M.get_local_text(category_id, id, lang)
	local lang = lang or storage_player.lang_tag
	if M.content[category_id] and M.content[category_id][id] and M.content[category_id][id][lang] then
		return M.content[category_id][id][lang]
	else
		return "-"
	end
end

return M