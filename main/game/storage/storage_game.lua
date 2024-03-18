-- Хранилище для данных игры
local M = {}

local color = require("color-lib.color")

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


-- Хранилище для завёзд за миссию
M.stars = {}

-- Текущаяя проигрываемая музыка
M.current_music_play = {}

-- Сообщения запуска игры, для повтора
M.play_message = {}

-- Url объектов в игре
M.go_urls = {}
-- ID объектов
M.go_ids = {}
-- Данные игровых объектов
M.go_objects = {}
-- Ключи
M.go_keys = {}
-- Цели игровых объектов
M.go_targets = {}

-- Группы для зрения ИИ
M.groups_aabbcc = {}

-- Текущая карта
M.map = {
	url = nil,
	url_script = nil,
	size = vmath.vector3(2000, 1000, 0),
	-- Для звёзд
	player_stars = 0,
	count_stars = nil,
	-- Остальные предметы для карты
	count_coins = nil,
	count_resource = nil,
	count_xp = nil,
	-- Подобрал предметов игрок
	player_add_items = {
		coins = 0,
		xp = 0,
		resource = 0,
	}
}

return M