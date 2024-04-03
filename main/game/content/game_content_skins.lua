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
	local human_id = skin["human_"..human_id]
	local atlas_id = skin.atlas_id

	if self._atlas_current_skin ~= atlas_id then
		local atlas = self["atlas_"..atlas_id]
		if atlas then
			go.set(url, "image", atlas)
		end
		self._atlas_current_ski = skin.atlas_id
	end

	if animation_name == "win" then
		-- АНимация победы зомбика
		sprite.play_flipbook(url, "win_skin_"..skin_id)
	else
		-- Передвижение и атака
		local string_animation = skin_id.."_"..human_id
		if skin.is_old and self.max_live and self.live then
			local procent_live = self.live / self.max_live

			if procent_live < 0.2  then
				go.set(url, "image", self.atlas_first_level)
				string_animation = "very-old"
			elseif procent_live < 0.4 then
				go.set(url, "image", self.atlas_first_level)
				string_animation = "old"
			end
		end
		sprite.play_flipbook(url, "zombie_"..string_animation.. "_" .. animation_name)
	end
	
	return M.catalog_keys[id]
end

return M