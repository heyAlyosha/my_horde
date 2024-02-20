-- Функции
local M = {}

function M.get_new_day(self, userdata)
	--local current_day = M.get_day(3600 * 24 * 4) + 2 -- Для теста
	local current_day = M.get_day()
	local userdata = userdata or {}

	-- Создан ли игрок
	if userdata.last_day_to_game or userdata.created then
		userdata.created = false
	else
		userdata.created = true
	end

	-- Смотрим новый ли это день для пользователя
	userdata.last_day_to_game = userdata.last_day_to_game or 0
	userdata.new_day = userdata.last_day_to_game ~= current_day

	--Если это новый день смотрим какой по счёту подряд
	userdata.day_to_game = userdata.day_to_game or 1
	if userdata.new_day then
		-- Новый день для игрока
		if userdata.last_day_to_game + 1 == current_day then
			-- Если последний раз игрок был вчера
			userdata.day_to_game = userdata.day_to_game + 1
		else
			-- Игрок был больше 3-х дней назад
			-- Сбрасываем счётчик
			userdata.day_to_game = 1
		end
	end

	--Запоминаем текущий день
	userdata.last_day_to_game = current_day

	return userdata
end

-- Получение текущего дня
function M.get_day(time)
	local time = time or os.time()
	return math.floor(time / 86400)
end

-- Сброс прогресса
function M.reset(self)
	local time = time or os.time()
	return math.floor(time / 86400)
end

return M