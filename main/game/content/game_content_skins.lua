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
	return M.catalog_keys["skin_"..id]
end

-- Запуск анимации
function M.play_flipbook(self, url, skin_id, human_id, animation_name, no_old, live, max_live)
	local skin = M.catalog_keys["skin_"..skin_id]
	local human_id = skin["human_"..human_id]
	local atlas_id = skin.atlas_id
	local animate_id

	if self._atlas_current_skin ~= atlas_id then
		local atlas = self["atlas_"..atlas_id]
		if atlas then
			go.set(url, "image", atlas)
		end
		self._atlas_current_ski = skin.atlas_id
	end

	if animation_name == "win" then
		-- АНимация победы зомбика
		animate_id = "win_skin_"..skin_id
	else
		-- Передвижение и атака
		local string_animation = skin_id.."_"..human_id
		-- Старение
		local live = live or self.live 
		local max_live = max_live or self.max_live
		if human_id ~= 0 and not no_old and skin.is_old and max_live and live then
			local procent_live = live / max_live

			if procent_live < 0.2  then
				go.set(url, "image", self.atlas_first_level)
				string_animation = "very-old"
			elseif procent_live < 0.4 then
				go.set(url, "image", self.atlas_first_level)
				string_animation = "old"
			end
		end
		animate_id = "zombie_"..string_animation.. "_" .. animation_name
	end
	
	sprite.play_flipbook(url, animate_id)
	return animate_id
end

return M