-- Скины зомбей
local M = {}

local game_content_functions = require "main.game.content.modules.game_content_functions"
local core_prorgress = require "main.core.core_progress.core_prorgress"

-- Скины по id
M.catalog_keys = {}
M.catalog = {}


function M.init(self)
	-- Закачиваем таблицу сос кинами
	local is_replace_placeholder = false
	game_content_functions.load_content(self, "skins", group_columns, function (self, row_id, row_item)
		M.catalog_keys[row_id] = row_item
		pprint("init_csv", row_id)
	end, is_replace_placeholder)

	M.catalog = game_content_functions.create_catalog(self, "price", M.catalog_keys, sort_function)
end

function M.get_all(user_lang)
	local default_lang = "ru"
	local lang = user_lang or "ru"
	local result = {}

	for i = 1, #M.catalog do
		result[#result + 1] = M.get_id(M.catalog[i].id, user_lang)
	end

	return result
end

-- Получение компании по id
function M.get_id(id, user_lang)
	return M.catalog_keys["skin_"..skin_id]
end

-- Запуск анимации
function M.play_flipbook(self, url, skin_id, human_id, animation_name)
	local skin = M.catalog_keys["skin_"..skin_id]
	pprint("M.catalog_keys", skin_id, M.catalog_keys[skin_id])
	local human_id = skin["human_"..human_id]

	if animation_name == "win" then
		-- АНимация победы зомбика
		sprite.play_flipbook(url, "win_skin_"..skin_id)
	else
		sprite.play_flipbook(url, "zombie_"..skin_id.."_"..human_id.. "_" .. animation_name)
	end
	
	return M.catalog_keys[id]
end

return M