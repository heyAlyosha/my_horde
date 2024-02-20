-- Запускаем игру
local M = {}

local color = require("color-lib.color") 
local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"
local game_content_company = require "main.game.content.game_content_company"
local game_content_levels = require "main.game.content.game_content_levels"
local core_prorgress = require "main.core.core_progress.core_prorgress"
local game_content_bots = require "main.game.content.game_content_bots"
local core_functions_array = require "main.core.functions.core_functions_array"
local game_global_modules = require "main.game.core.game_global_modules"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local data_handler = require "main.data.data_handler"
local online_image = require "main.online.online_image"

-- Запуск уровня компании
function M.company_level(self, category_id, level_id)
	-- Получаем контент для уровня
	local level_content = game_content_levels.get(level_id, category_id, user_lang)

	-- формируем игроков
	local players = {}

	for i, item in ipairs(level_content.party) do
		if item.id == "player" then
			-- Игрок
			players[i] = {
				player_id = item.id, color = item.color, score = 0, type = "player", 
				name = item.name, avatar = item.avatar,
				characteristics = storage_player.characteristics,
				artifacts = storage_player.artifacts
			}

		else
			-- Боты
			players[i] = {
				player_id = item.id, bot_id = item.id, color = item.color, score = 0, type = "bot", 
				name = item.name, avatar = item.avatar,
				characteristics = item.value.characteristics,
				artifacts = item.value.artifacts
			}
		end
		
	end

	-- Находим квест
	local quest
	local number_quest = core_prorgress.get_visible_level(category_id, level_id)

	if level_content.quests[number_quest] then
		quest = level_content.quests[number_quest]

	else
		core_prorgress.set_visible_level(category_id, level_id, 1, operation)
		number_quest = core_prorgress.get_visible_level(category_id, level_id)
		quest = level_content.quests[number_quest]
	end

	-- Записываем, что промотрели уровень
	-- Сохраняем результат На сервере
	data_handler.set_userdata(self, {
		visible_levels = core_prorgress.set_visible_level(category_id, level_id, 1, "add")
	})

	storage_game.game.message_start = {
		animate_start = true,
		index_player = 1, -- Порядковый номер игрока, с которого начинается игра
		debug = false, -- Потреубется запускать ходы вручную
		type = "single",
		level_id = level_id,
		category_id = category_id,
		word = quest.word,
		quest_resource = quest.resource,
		quest_type = quest.type or "text",
		quest_music = quest.music,
		quest = quest.quest,
		word = quest.word,
		image = "",
		disable_symbols = {},
		sectors = {},
		players = players
	}

	
	msg.post("/core_game", "start_game")
end

-- Запуск уровня в турнире
function M.tournir(self)
	-- формируем игроков
	local players = {}
	local bots = {
		"andrew", "denis", "igor", "ira", "lena", "max", "alyona", "antonina", "lyosha", "proskovia"
	}
	-- Перемешиваем ботов
	core_functions_array.shake(bots)

	local party = {
		bots[1], bots[2], "player"
	}

	-- Перемешиваем пати
	core_functions_array.shake(party)
	-- Формируем данные для игроков
	for i, id in ipairs(party) do
		party[i] = game_content_bots.get_player(id)
	end

	for i, item in ipairs(party) do
		if item.id == "player" then
			-- Игрок
			players[i] = {
				player_id = item.id, 
				color = color[item.color] or item.color, 
				score = 0, type = "player", 
				name = item.name, avatar = item.avatar,
				characteristics = storage_player.characteristics,
				artifacts = storage_player.artifacts
			}

		else
			-- Боты
			players[i] = {
				player_id = item.id, 
				bot_id = item.id,
				color = color[item.color] or item.color, 
				score = 0, type = "bot", 
				name = item.name, avatar = item.avatar,
				characteristics = item.value.characteristics,
				artifacts = item.value.artifacts
			}

		end

	end

	core_functions_array.shake(players)

	-- Формируем вопрос
	local quests = game_content_company.quests_tournir
	local levels = game_global_modules.get_new_levels(self, quests, storage_player.visible_levels.tournir)

	-- Записываем, что промотрели уровень
	local category_id = "tournir"
	local quest_id

	if #levels > 0 then
		quest_id = levels[math.random(#levels)]

		data_handler.set_userdata(self, {
			visible_levels = core_prorgress.set_visible_level(category_id, quest_id, 1, "add")
		})

	else
		-- Если закончились уровни
		storage_player.visible_levels.tournir = {}

		levels = game_global_modules.get_new_levels(self, quests, storage_player.visible_levels.tournir)
		quest_id = levels[math.random(#levels)]

		data_handler.set_userdata(self, {
			visible_levels = core_prorgress.set_visible_level(category_id, quest_id, 1, "add")
		})

	end

	local quest = quests[quest_id]
	
	storage_game.game.message_start = {
		animate_start = true,
		index_player = 1, -- Порядковый номер игрока, с которого начинается игра
		debug = false, -- Потреубется запускать ходы вручную
		type = "single",
		level_id = nil,
		category_id = nil,
		quest_type = "text",
		quest = quest.quest,
		word = quest.word,
		disable_symbols = {},
		sectors = {},
		players = players
	}

	msg.post("/core_game", "start_game")
end

-- Запуск уровня в турнире
function M.family(self, message)
	-- формируем игроков
	local players = {}
	local party = storage_game.family.settings.players
	-- Перемешиваем
	core_functions_array.shake(party)

	-- Формируем данные для игроков
	for i, item in ipairs(party) do
		if item.type == "player" then
			-- Игрок
			players[i] = {
				player_id = item.id, 
				color = color[item.color] or item.color, 
				score = 0, type = item.type, 
				name = item.name, avatar = item.avatar,
				characteristics = {},
				artifacts = storage_game.family.inventaries[item.id]
			}

		else
			-- Боты
			local bot = game_content_bots.get_player(item.bot_id)
			players[i] = {
				player_id = item.id, 
				bot_id = item.bot_id, 
				color = color[item.color] or item.color,
				score = 0, type = item.type, 
				name = item.name, avatar = item.avatar,
				characteristics = bot.value.characteristics,
				artifacts = bot.value.artifacts
			}
		end

	end

	-- Формируем вопрос
	local quests = game_content_company.quests_tournir
	local levels = game_global_modules.get_new_levels(self, quests, storage_player.visible_levels.tournir)

	-- Записываем, что промотрели уровень
	local category_id = "tournir"
	local quest_id

	if #levels > 0 then
		quest_id = levels[math.random(#levels)]

		data_handler.set_userdata(self, {
			visible_levels = core_prorgress.set_visible_level(category_id, quest_id, 1, "add")
		})

	else
		-- Если закончились уровни
		storage_player.visible_levels.tournir = {}

		levels = game_global_modules.get_new_levels(self, quests, storage_player.visible_levels.tournir)
		quest_id = levels[math.random(#levels)]

		data_handler.set_userdata(self, {
			visible_levels = core_prorgress.set_visible_level(category_id, quest_id, 1, "add")
		})

	end

	local quest = quests[quest_id]

	local animate_start
	if message.animate_start == nil then
		animate_start = true
	else
		animate_start = message.animate_start
	end

	storage_game.game.message_start = {
		animate_start = animate_start,
		index_player = 1, -- Порядковый номер игрока, с которого начинается игра
		debug = storage_game.family.settings.debug, -- Потреубется запускать ходы вручную
		type = "family",
		level_id = nil,
		category_id = nil,
		quest_type = "text",
		quest = quest.quest,
		word = quest.word,
		disable_symbols = {},
		sectors = message.sectors or {},
		players = players
	}

	msg.post("/core_game", "start_game")
end

-- Запуск уровня в турнире
function M.family(self, message)
	-- формируем игроков
	local players = {}
	local party = storage_game.family.settings.players
	-- Перемешиваем
	core_functions_array.shake(party)

	-- Формируем данные для игроков
	for i, item in ipairs(party) do
		if item.type == "player" then
			-- Игрок
			players[i] = {
				player_id = item.id, 
				color = color[item.color] or item.color, 
				score = 0, type = item.type, 
				name = item.name, avatar = item.avatar,
				characteristics = {},
				artifacts = storage_game.family.inventaries[item.id]
			}

		else
			-- Боты
			local bot = game_content_bots.get_player(item.bot_id)
			players[i] = {
				player_id = item.id, 
				bot_id = item.bot_id, 
				color = color[item.color] or item.color,
				score = 0, type = item.type, 
				name = item.name, avatar = item.avatar,
				characteristics = bot.value.characteristics,
				artifacts = bot.value.artifacts
			}
		end

	end

	-- Формируем вопрос
	local quests = game_content_company.quests_tournir
	local levels = game_global_modules.get_new_levels(self, quests, storage_player.visible_levels.tournir)

	-- Записываем, что промотрели уровень
	local category_id = "tournir"
	local quest_id

	if #levels > 0 then
		quest_id = levels[math.random(#levels)]

		data_handler.set_userdata(self, {
			visible_levels = core_prorgress.set_visible_level(category_id, quest_id, 1, "add")
		})


	else
		-- Если закончились уровни
		storage_player.visible_levels.tournir = {}

		levels = game_global_modules.get_new_levels(self, quests, storage_player.visible_levels.tournir)
		quest_id = levels[math.random(#levels)]

		data_handler.set_userdata(self, {
			visible_levels = core_prorgress.set_visible_level(category_id, quest_id, 1, "add")
		})

	end

	local quest = quests[quest_id]

	local animate_start
	if message.animate_start == nil then
		animate_start = true
	else
		animate_start = message.animate_start
	end

	storage_game.game.message_start = {
		animate_start = animate_start,
		index_player = 1, -- Порядковый номер игрока, с которого начинается игра
		debug = storage_game.family.settings.debug, -- Потреубется запускать ходы вручную
		type = "family",
		level_id = nil,
		category_id = nil,
		quest_type = "text",
		quest = quest.quest,
		word = quest.word,
		disable_symbols = {},
		sectors = message.sectors or {},
		players = players
	}

	msg.post("/core_game", "start_game")
end


-- Запуск уровней для обучения
function M.study(self)
	-- Уровни обучения
	storage_game.game.study_level = storage_game.game.study_level or 0
	storage_game.game.study_level = storage_game.game.study_level + 1

	local levels = {
		{
			party = {"player", "andrew", "igor"},
			quest = "Он от бабушки ушёл, он от дедушки ушёл",
			quest_type = "text",
			word = "колобок",
			sectors = {
				{sector_id = 22, player_id = "player", artifact_id = "speed_caret_1"},
				{sector_id = 24, player_id = "player", artifact_id = "accuracy_1"},
			}
		},
		{
			party = {"player", "igor", "ira"},
			quest = "Что это за планета?",
			quest_type = "image",
			quest_resource = "study/study_ear.jpg",
			quest_music = nil,
			word = "Земля",
			sectors = {}
		},
		{
			party = {"player", "denis", "ira"},
			quest = "Что это за песня?",
			quest_type = "music",
			quest_music = "russkiy_rok/gruppa_krovi.ogg",
			word = "группа крови",
			sectors = {}
		},
	}
	-- формируем игроков
	local players = {}
	local level_content = levels[storage_game.game.study_level]
	local party = level_content.party

	-- Формируем данные для игроков
	for i, id in ipairs(party) do
		party[i] = game_content_bots.get_player(id)
	end

	for i, item in ipairs(party) do
		if item.id == "player" then
			storage_player.artifacts = storage_player.artifacts or {}

			-- Игрок
			players[i] = {
				player_id = item.id, 
				color = color[item.color] or item.color, 
				score = 0, type = "player", 
				name = item.name, avatar = item.avatar,
				characteristics = storage_player.characteristics,
				artifacts = storage_player.artifacts
			}

		else
			-- Боты
			players[i] = {
				player_id = item.id, 
				bot_id = item.id,
				color = color[item.color] or item.color, 
				score = 0, type = "bot", 
				name = item.name, avatar = item.avatar,
				characteristics = item.value.characteristics,
				artifacts = item.value.artifacts
			}

		end

	end

	-- Формируем вопрос
	local word = level_content.word
	local quest = level_content.quest

	local sectors = level_content.sectors

	--storage_game.game.study = true
	storage_game.game.study_character = true

	storage_game.game.message_start = {
		animate_start = true,
		index_player = 1, -- Порядковый номер игрока, с которого начинается игра
		--debug = true, -- Потреубется запускать ходы вручную
		type = "single",
		level_id = nil,
		category_id = nil,
		quest_type = level_content.quest_type,
		quest_resource = level_content.quest_resource,
		quest_music = level_content.quest_music,
		quest = quest,
		word = word,
		disable_symbols = {},
		sectors = sectors,
		players = players
	}

	msg.post("/core_game", "start_game")
end


return M