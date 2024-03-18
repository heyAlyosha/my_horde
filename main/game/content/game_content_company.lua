-- Храним контент для категорий вопроса
local M = {}

local game_content_functions = require "main.game.content.modules.game_content_functions"
local core_prorgress = require "main.core.core_progress.core_prorgress"

M.catalog = {}

-- Компании по ключу
M.catalog_keys = {}
M.quests_content = {}
M.quests_tournir = {}

function M.init(self)
	local is_replace_placeholder = false
	game_content_functions.load_content(self, "company", group_columns, function (self, row_id, row_item)
		local item = row_item
		item.id = row_id

		M.catalog_keys[row_id] = item

		-- Закачиваем контент для переведённых уровней
		local csv_name = "quests_"..row_id.."_ru"
		local quests = {}
		quests = game_content_functions.load_content(self, csv_name, group_columns, function (self, row_id, row_item)
			row_item.index = tonumber(row_id)
		end, is_replace_placeholder)
		
		M.quests_content[row_id] = game_content_functions.create_catalog(self, "index", quests, function (a, b)
			return a.index < b.index
		end)


	end, is_replace_placeholder)

	M.catalog = game_content_functions.create_catalog(self, "sort", M.catalog_keys, sort_function)

	-- Закачиваем уровни
	game_content_functions.load_content(self, "levels", group_columns, function (self, row_id, row_item)
		local item = row_item

		if M.catalog_keys[item.company_id] then
			M.catalog_keys[item.company_id].levels = M.catalog_keys[item.company_id].levels or {}
			-- Загружаем отдельный уровень
			M.catalog_keys[item.company_id].levels[item.id] = {
				id = item.id,
				quests = {},
				-- Игроки
				party = {
					item.party_1, 
					item.party_2, 
					item.party_3
				},
				-- СЛожность
				complexity = item.complexity,
				-- Звёзды
				stars = {
					type = item.stars_type, 
					values = {
						item.star_1, 
						item.star_2, 
						item.star_3
					},
				}
			}
		end
	end, is_replace_placeholder)

	-- Присваиваем вопросы
	for company_id, v in pairs(M.catalog_keys) do
		for i, quest in ipairs(M.quests_content[company_id]) do
			if M.catalog_keys[company_id].levels[quest.level_id] then
				if company_id == "bloger" then
					--pprint("quest_bloger", quest)
				end

				-- Если тип задания либо
				if quest.type and quest.type ~= "text" then
					M.catalog_keys[company_id].type = quest.type
				end

				table.insert(M.catalog_keys[company_id].levels[quest.level_id].quests, {
					word = quest.word,
					quest = quest.quest,
					type = quest.type,
					resource = quest.resource,
					music = quest.music,
				})
			end
		end
	end

	-- Записываю вопросы в турнир
	M.quests_tournir = game_content_functions.load_content(self, "quests_tournir_ru", nil, nil, is_replace_placeholder)
end

-- Получение всех компаний игрока
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
	local lang = user_lang or "ru"
	local item = M.catalog_keys[id]
	local levels = #item.levels
	local progress_all = levels
	local progress_count = 0
	local status = "default"

	-- НАходим прогресс категории
	local levels_complexity = core_prorgress.get_progress_category(id)
	for level_id, level in pairs(levels_complexity) do
		progress_count = progress_count + 1
	end

	-- забираем значение по ключу
	if progress_count == progress_all then
		status = "success"
	end

	item.progress_all = progress_all
	item.progress_count = progress_count
	item.status = status

	return item
end

return M