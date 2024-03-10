-- Баланс игрока
local M = {}

local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local data_handler = require "main.data.data_handler"
-- запись имени


-- Операции с балансом
function M.update_balance(self, operation, values, animate)
	local operation = operation or 'set'
	local values = values or {}
	local animate = animate or true
	
	-- Обновдяем значения статок игрока
	for key, value in pairs(values) do
		if operation == 'add' then
			-- Если это добавление статок
			storage_player[key] = storage_player[key] + value
		else
			-- Если это перезапись 
			storage_player[key] = value
		end

		-- Если изменялся опыт, смотрим не нужно ли изменять уровень 
		pprint("update_balance")
		if key == 'score' then
			local level_data_user = M.get_level_data_user()

			if level_data_user.procent_to_next_level >= 100 then
				M.level_up(self)
			end
		end
	end 

	-- Обновляем интерфейс
	msg.post("/loader_gui", "set_status", {
		id = "interface",
		type = "update_balance",
		animate = animate,
	})
end

-- Левел ап игрока
function M.level_up(self)
	local level_data_user = M.get_level_data_user()
	nakama.sync(function (self)

	while level_data_user.procent_to_next_level >= 100 do
		storage_player.level = storage_player.level + 1
		storage_player.characteristic_points = storage_player.characteristic_points + 1

		local userdata = {
			level = storage_player.level,
			characteristic_points = storage_player.characteristic_points,
		}
		data_handler.set_userdata(self, userdata, callback)

		level_data_user = M.get_level_data_user()
		msg.post("/loader_gui", "set_status", {
			id = "interface",
			type = "level_up"
		})
		end
	end, cancellation_token)
end

-- Номер левела по опыту
function M.get_level_from_score(score)
	s = (500 + 650 * l) * l 
	return 
end

-- Сколько опыта для левела
function M.get_score_to_level(level)
	level = level - 1
	return (500 + 650 * level) * level
end

-- Сколько опыта для левела
function M.print_score_for_levels(count)
	local count = count or 40
	for level = 1, count do
		local score = M.get_score_to_level(level)
		print("SCORE TO LEVEL ", level, ":", score)
	end
end

-- Получение данных левела пользователя
function M.get_level_data_user()
	-- Текущий и следующий уровни
	local current_level = storage_player.level
	local score_user = storage_player.score
	local next_level = current_level + 1

	-- Cколько опыта для текущего и следующего опыта
	local score_to_current_level = M.get_score_to_level(current_level)
	local score_to_next_level = M.get_score_to_level(next_level)

	-- Разница в опыте между уровнями
	local dif_score = score_to_next_level - score_to_current_level
	-- Разница в опыте между текущим уровнем и опытом игрока
	local dif_score_user = score_user - score_to_current_level
	-- Сколько процентов опыта игрок получил до следующего опыта
	
		
	local procent_to_next_level = dif_score_user / dif_score * 100

	return {
		current_level = current_level,
		next_level = next_level,
		score_to_next_level = score_to_next_level,
		procent_to_next_level = procent_to_next_level,
	}
end

return M