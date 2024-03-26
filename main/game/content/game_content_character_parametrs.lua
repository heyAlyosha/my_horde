-- Храним контент харакетристик для персонажей
local storage_player = require "main.storage.storage_player"

local M = {}

M.catalog_keys = {}
M.catalog = {}

function M.init(self)
	local is_replace_placeholder = false
	M.catalog_keys = game_content_functions.load_content(self, "character_parametrs", group_columns, function (self, row_id, item)

	end, is_replace_placeholder)

	for k, v in pairs(M.catalog_keys) do
		M.catalog_keys[hash(k)] = v
	end

	pprint(M.catalog_keys)
end

-- Получить характеристику под тип
function M.get_type(self, type_id)
	return M.catalog_keys[type_id]
end

-- Получить характеристику под тип
function M.set_characteristic(self)
	local characteristics = M.get_type(self, self.type_object)

	if characteristics then
		for k, v in pairs(characteristics) do
			self[k] = v
		end
	end
end

return M