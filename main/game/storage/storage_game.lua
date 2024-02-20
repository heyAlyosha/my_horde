-- Хранилище для данных игры
local M = {}

local color = require("color-lib.color")

-- Хранение информации о захваченных секторах на барабане игроками
-- Заполняются через соощения к барабану
M.wheel = {
	--sector_1 = {player_id = "player", artifact_id = "accuracy_1"},
	sector_2 = {player_id = "player", artifact_id = "speed_caret_1"},
	sector_3 = {player_id = "player", artifact_id = "speed_caret_1"},
	sector_18 = {player_id = "player", artifact_id = "accuracy_1"},

	sector_22 = {player_id = "player", artifact_id = "accuracy_1"},
}
-- Запущена ли сейчас игра
M.is_game = false
-- Вероятные сектора для прицеливания
M.possible_aim_sectors = {}
-- Вероятные сектора для прицеливания
M.aim_sectors = {}
-- Сырые данные захваченный секторов
M.wheel_artifacts = {
	{sector_id = 1, player_id = "player", artifact_id = "speed_caret_1"},
	{sector_id = 3, player_id = "player", artifact_id = "speed_caret_1"},
	{sector_id = 6, player_id = "player", artifact_id = "speed_caret_1"},
	{sector_id = 8, player_id = "player", artifact_id = "speed_caret_1"},
}

-- Хранилище для игры
M.game = {
	study = false, -- Обучение
	-- Сообщение для старта (для перезапуска миссии)
	message_start = {},
	-- Данные для игрового раунда
	round = {
		type = "single/family",
		level = {},
		category = {},
		quest = "Текст вопроса",
		quest_type = 'text/image/sound/video',
		word = "слово",
		disable_symbols = {}, -- Заблокированные буквы для ответа
		tablo = {}, -- Состояние табло,
		is_stars = nil
	},
	-- Результаты игрового раунда
	result = {
		xp = 1200, -- Опыт
		score = 1200, -- Для покупок подарков в магазине
		prizes = {},
		player_win_id = "player",
		stars = 3
	},
	players = {}
}

-- Хранилище для бота
M.bot = {
	-- Череда успешных ответов
	success_response = 0
}

-- Хранилище для завёзд за миссию
M.stars = {}

-- Текущаяя проигрываемая музыка
M.current_music_play = {}

-- Сообщения запуска игры, для повтора
M.play_message = {}

M.family = {
	bank = {
		player_1 = 900,
		player_2 = 900,
		player_3 = 900,
	},
	inventaries = {
		player_1 = {}, player_2 = {}, player_3 = {},
	},
	settings = {
		add_coins = 100,
		debug = false,
		players = {
			{
				id = "player_1",
				type = "player",
				name = "Игрок 1",
				avatar = "icon-gamer-1",
				color = "aquamarine"
			},
			{
				id = "player_2",
				type = "player",
				name = "Игрок 2",
				avatar = "icon-gamer-2",
				color = "chartreuse"
			},
			{
				id = "player_3",
				type = "player",
				name = "Игрок 3",
				avatar = "icon-gamer-3",
				color = "coral"
			},
		},
	}

}

-- Urls объектов в игре
M.go_urls = {}

return M