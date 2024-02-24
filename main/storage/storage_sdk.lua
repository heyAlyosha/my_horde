-- Модуль для хранения данных для разных SDK
local M = {}
-- Путь до игрового объекта SDK
M.url_go = nil

M.player = {

}

-- Показывается ли горизонтальный блок рекламы снизу
M.ads_horisontal_block = {
	url = nil,
	visible = false,
	focus = false
}

-- Обработчик данных
M.handler = "local"

-- Данные окружения
M.stats = {
	-- Платформа
	platform_id = nil,
	-- Тип девайса
	device_type = "mobile/sberbox/sberbox_top/sberbox_time",
	-- Есть ли возможность выйти
	is_exit = true,
	-- Есть ли лидерборды
	is_lidearboard = false,
	-- Можно ли рейтинг выставлять оценки
	is_rating = true,
	-- Есть ли горизонтальные блоки с рекламой
	is_ads_horisontal_block = false,
	-- Есть ли полноэкранная реклама
	is_ads_fullscreen = true,
	-- Есть ли реклама с вознаграждением
	is_ads_reward = false,
	max_reward_video_today = 3,
	-- Есть ли возможность что либо купить
	is_shop = true,
	-- Есть ли возможность оформить подписку
	is_subscribe = true,
	-- Подарки за действия 
	gifts = {
		reward = 25, -- Просмотр ролика
		stars = 100, -- Поставить оценку
	}
}

-- Управление через SDK
M.controlls = {
	-- Пульт
	remote = nil 
}

-- Доступен ли рейтинг
M.leaderboard_top = false
M.leaderboard_personal = false

-- Можно ли редактировать имя
M.edit_name = false

return M