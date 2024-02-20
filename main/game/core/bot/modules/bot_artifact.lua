-- Функции для выставления артефактов ботом
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_content_wheel = require "main.game.content.game_content_wheel"
local game_content_bots = require "main.game.content.game_content_bots"

function M.activate(self, bot, types, sector_id)
	local delay = math.random(200, 400) / 100

	timer.delay(delay, false, function (self)
	
		for i, artifact_type in ipairs(types) do
			local artifact_id = M.activate_artifact(self, bot, artifact_type.id, sector_id)

			if artifact_id then
				msg.post("game-room:/core_game", "event", {
					id = "catch_sector",
					value = {
						type = "confirm",
						sector_id = sector_id,
						player_id = bot.player_id,
						artifact_id = artifact_id,
					}
				})
				return true
			else
				
			end
		end

		msg.post("game-room:/core_game", "event", {
			id = "catch_sector",
			value = {
				type = "close",
				sector_id = sector_id,
				player_id = bot.player_id
			}
		})
		return false
	end)
end

-- Сортируем возможные скетора
function M.sort_artifact_types(self, bot, sector_type)
	local result = {}

	local artifact_types = {"trap", "catch", "bank", "accuracy", "speed_caret"}

	for i, artifact_type in ipairs(artifact_types) do
		local new_item = {}

		-- Находим ценность
		new_item.treasure = 0

		-- Если это один из любимых артефактов
		if game_content_bots.is_favorite_artifact(self, bot.bot_id, artifact_type) then
			if artifact_type == "trap" then
				new_item.treasure = 2
			else
				new_item.treasure = 1
			end
		end

		-- В зависимости от секторо
		if sector_type == "skip" or sector_type == "bankrot" then
			-- Если это сектор пропуск хода 
			if artifact_type == "catch" then
				-- В  приоритете вышки
				new_item.treasure = new_item.treasure + 2

			elseif artifact_type == "bank" or artifact_type == "accuracy" or artifact_type == "speed_caret" then
				new_item.treasure = new_item.treasure + 1

			end

		elseif sector_type == "open_symbol" or sector_type == "x2" then
			-- Откртие буквы или удвоенный опыт
			if artifact_type == "trap" then
				new_item.treasure = new_item.treasure + 3
			elseif artifact_type == "catch" then
				new_item.treasure = new_item.treasure + 2
			end

		end

		-- Докачивается
		if artifact_type == "speed_caret" then
			
			local speed_caret, norm_speed = game_content_wheel.get_speed_aim(self, bot.player_id)
			local procent_norm = speed_caret / norm_speed 

			if speed_caret <= norm_speed then
				if procent_norm <= 0.5 then
					new_item.treasure = new_item.treasure + 2
				else
					new_item.treasure = new_item.treasure + 1
				end
			end

		elseif artifact_type == "accuracy" then
			local size_aim, norm_aim = game_content_wheel.get_size_aim(self, bot.player_id)
			local procent_norm =  norm_aim / size_aim

			if size_aim >= norm_aim then
				if procent_norm <= 0.5 then
					new_item.treasure = new_item.treasure + 2
				else
					new_item.treasure = new_item.treasure + 1
				end
			end
		end

		new_item.id = artifact_type
		result[#result + 1] = new_item
	end

	-- Сортируем по ценности
	table.sort(result, function (a, b) return (a.treasure > b.treasure) end)

	return result
	
end

-- Активация артефакта
function M.activate_artifact(self, bot, artifact_type, sector_id)
	for i = 3, 1, -1 do
		local artifact_id = artifact_type.."_".. i
		if artifact_type == "speed_caret" then
			artifact_id = "speed_caret_" .. i
		end
		local artifact_count = bot.artifacts[artifact_id]

		if artifact_count and artifact_count > 0 then
			return artifact_id, 1
		end
	end

	return false
	
end

return M