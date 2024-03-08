-- Храним контент для категорий вопроса
local M = {}

local game_content_company = require "main.game.content.game_content_company"
local game_content_bots = require "main.game.content.game_content_bots"
local core_content_text = require "main.content.core.core_content_text"
local core_prorgress = require "main.core.core_progress.core_prorgress"

-- Получение всех уровней для игрока
function M.get_all(category_id, local_category, user_lang)
	local local_category = true or local_category
	local default_lang = "ru"
	local lang = user_lang or "ru"
	local result = {}
	local status = "default"
	local company = game_content_company.catalog_keys[category_id] 

	if not company then
		return result
	end

	for i = 1, #company.levels do
		result[#result + 1] = M.get(company.levels[i].id, category_id, user_lang)

		--[[
		-- Формируем игроков на уровне
		local party = {}
		for i, v in ipairs(level.party) do
			party[i] = game_content_bots.get_player(v)
		end

		result[#result + 1] = {
			id = level.id,
			index = i,
			title = i,
			complexity = level.complexity,
			party = party,
		}]]--
	end

	return result
end

function M.get_party_gamer(gamer_id)
	
end

-- Получение уровня 
function M.get(level_id, category_id, user_lang)
	local default_lang = "ru"
	local lang = user_lang or "ru"
	local company = game_content_company.catalog_keys[category_id]  

	if not company then
		return false
	end

	local level = company.levels[level_id]

	-- Получаем выбранный уровень 
	if level then
		-- Формируем игроков на уровне
		local party = {}
		for i_p, v in ipairs(level.party) do
			party[i_p] = game_content_bots.get_player(v)
		end

		local stars = core_prorgress.get_progress_level(category_id, level_id)

		local type_quests = "text"
		for i, quest in ipairs(level.quests) do
			if quest.type and quest.type ~= "text" then
				type_quests = quest.type
			end
		end
		result = {
			id = level.id,
			index = level.id,
			title = level.id,
			type = type_quests,
			description = core_content_text.get_local_text("complexity", level.complexity),
			complexity = level.complexity,
			party = party,
			stars_content = level.stars,
			stars = stars,
			quests = level.quests
		}

		-- Получаем следующий уровень, если есть
		local next_i = level.id + 1
		
		local next_level =  company.levels[next_i]

		if next_level then
			local next_party = {}
			for i_p, v in ipairs(next_level.party) do
				next_party[i_p] = game_content_bots.get_player(v)
			end

			result.next_level = {
				id = next_level.id,
				index = next_i,
				title = next_i,
				description = core_content_text.get_local_text("complexity", next_level.complexity),
				complexity = next_level.complexity,
				party = next_party
			}
		end

		return result
	else
		return false
	end
end

return M