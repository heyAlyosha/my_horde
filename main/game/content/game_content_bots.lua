local storage_player = require "main.storage.storage_player"
local core_content_text = require "main.content.core.core_content_text"
local global_function = require "main.modules.global_function"
local game_content_bots_characters = require "main.game.content.game_content_bots_characters"
local color = require("color-lib.color") 


-- Информация про ботов
local M = {
	andrew = {
		name = "Андрей",
		complexity = "easy",
		avatar = "icon-andrew",
		character = "bank",
		color = "LightYellow"
	},
	denis = {
		name = "Денис",
		complexity = "easy",
		avatar = "icon-denis",
		character = "catch",
		color = "LightCyan"
	},
	igor = {
		name = "Игорь",
		complexity = "easy",
		avatar = "icon-igor",
		character = "bank",
		color = "LightBlue"
	},
	ira = {
		name = "Ира",
		complexity = "easy",
		avatar = "icon-ira",
		character = "accuracy",
		color = "LightSeaGreen"
	},
	lena = {
		name = "Лена",
		complexity = "normal",
		avatar = "icon-lena",
		character = "accuracy",
		color = "LightSalmon"
	},
	max = {
		name = "Макс",
		complexity = "normal",
		avatar = "icon-max",
		character = "catch",
		color = "LightGreen"
	},
	alyona = {
		name = "Алёна",
		complexity = "normal",
		avatar = "icon-alyona",
		character = "trap",
		color = "LightBlue"
	},
	antonina = {
		name = "Антонина",
		complexity = "normal",
		avatar = "icon-antonina",
		character = "accuracy",
		color = "LightPink"
	},
	lyosha = {
		name = "Лёша",
		complexity = "hard",
		avatar = "icon-lyosha",
		character = "trap",
		color = "MediumSpringGreen"
	},
	proskovia = {
		name = "Просковья",
		complexity = "hard",
		avatar = "icon-proskovia",
		character = "catch",
		color = "PaleGreen"
	},
}

function M.get_player(id)
	if id == "player" then
		return {
			id = id,
			color = M.get_color(storage_player.settings.color),
			type = "player",
			name = storage_player.user_name or "Анонимный игрок",
			avatar = storage_player.user_avatar or "icon-anonim",
			complexity = "",
			complexity_visible = "",
			value = {}
		}
	else
		local bot = M[id]

		local complexity_visible = "("..core_content_text.get_local_text("complexity", bot.complexity)..")"

		return {
			id = id,
			type = "bot",
			color = M.get_color(bot.color), 
			name = bot.name,
			avatar = bot.avatar,
			complexity = bot.complexity,
			complexity_visible = complexity_visible,
			favorite_artifacts = bot.favorite_artifacts,
			value = M.get(id)
		}
	end
end



-- Получаем бота по id
function M.get(id)
	local bot = M[id]
	local result = {}

	local character =  game_content_bots_characters[bot.character]
	local complexity = bot.complexity

	-- Находим характеристики
	result.characteristics = M.get_characteristics(self, character.characteristics_step, complexity)
	-- Находим артефакты
	result.artifacts = {}
	for artifact_type, random_array in pairs(character.counts_step) do
		local artifacts = M.get_artifacts(self, artifact_type, random_array, complexity)

		for k, v in pairs(artifacts) do
			result.artifacts[k] = v
		end
	end

	-- Находим любимые предметы
	local favorite_artifacts = character.favorite_artifacts

	return {
		player_id = id, 
		color = M.get_color(bot.color), 
		score = 0, 
		type = "bot", 
		name = bot.name, 
		avatar = bot.avatar,
		characteristics = result.characteristics,
		character = bot.character,
		complexity = bot.complexity,
		artifacts = result.artifacts,
		favorite_artifacts = favorite_artifacts,
	}
end

function M.get_level(complexity)
	local levels = {
		easy = 1,
		normal = 2,
		hard = 3
	}

	return levels[complexity]
end

-- Получение значения характеристик
function M.get_characteristics(self, characteristics, complexity)
	local level = M.get_level(complexity)
	local result = {}

	for key, item in pairs(characteristics) do
		result[key] = item * level
	end

	return result
end

-- Получение артефактов
function M.get_artifacts(self, artifact_type, random_array, complexity)
	local level = M.get_level(complexity)
	local result = {}

	local artifact_count = 0

	for i = 1, level do
		math.randomseed(os.clock()*i)
		artifact_count = math.random(random_array[1], random_array[2])

		if random_array[1] == 0 and random_array[2] == 0 then
			
		elseif artifact_type == "trap" or artifact_type == "catch" then
			for i_artifact = 1, artifact_count do
				math.randomseed(os.clock()*i_artifact * artifact_count * random_array[2])
				local artifact_id = artifact_type.."_"..level

				result[artifact_id] = result[artifact_id] or 0
				result[artifact_id] = result[artifact_id] + 1
			end

		else
			local artifact_id = artifact_type.."_1"
			result[artifact_id] = result[artifact_id] or 0
			result[artifact_id] = result[artifact_id] + artifact_count
		end
	end

	return result
end

-- Является ли это любимым артефактом
function M.is_favorite_artifact(self, bot_id, artifact_type)
	local bot = M.get_player(bot_id)
	bot.favorite_artifacts = bot.favorite_artifacts or {}

	for i, type in ipairs(bot.favorite_artifacts) do
		if type == artifact_type then
			return true
		end
	end
	
	return false
end

function M.get_color(color_name)
	return color[utf8.lower(color_name)]
end

return M