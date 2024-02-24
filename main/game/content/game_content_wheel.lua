local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"
local api_player = require "main.game.api.api_player"
local color = require "color-lib.color"
local game_content_artifact = require "main.game.content.game_content_artifact"


-- Информация про колесо
local M = {}
M.colors = {even = color.set("#e0b0ffff"), odd = color.white, buff = color.greenyellow, trap = color.deeppink, }
M.sectors = {
	{id = 1, type = "default", value = {score = 100},},
	{id = 2, type = "default", value = {score = 25},},
	{id = 3, type = "default", value = {score = 300},},
	{id = 4, type = "default", value = {score = 25},},
	{id = 5, type = "default", value = {score = 10},},
	{id = 6, type = "default", value = {score = 450},},
	{id = 7, type = "skip", color_default = M.colors.trap, value = {icon = "sector_icon_skip"},},
	{id = 8, type = "default", value = {score = 400},},
	{id = 9, type = "default", value = {score = 25},},
	{id = 10, type = "default", value = {score = 100},},
	{id = 11, type = "default", value = {score = 250},},
	{id = 12, type = "open_symbol", color_default = M.colors.buff, value = {icon = "sector_icon_symbol"},},
	{id = 13, type = "default", value = {score = 150},},
	{id = 14, type = "default", value = {score = 10},},
	{id = 15, type = "default", value = {score = 200},},
	{id = 16, type = "default", value = {score = 10},},
	{id = 17, type = "default", value = {score = 50},},
	{id = 18, type = "default", value = {score = 25},},
	{id = 19, type = "default", value = {score = 750},},
	{id = 20, type = "bankrot", color_default = M.colors.trap, value = {icon = "sector_icon_bankrot"},},
	{id = 21, type = "default", value = {score = 600},},
	{id = 22, type = "default", value = {score = 50},},
	{id = 23, type = "default", value = {score = 100},},
	{id = 24, type = "default", value = {score = 10},},
	{id = 25, type = "default", value = {score = 250},},
	{id = 26, type = "default", value = {score = 100},},
	{id = 27, type = "default", value = {score = 300},},
	{id = 28, type = "default", value = {score = 25},},
	{id = 29, type = "default", value = {score = 10},},
	{id = 30, type = "x2", color_default = M.colors.buff, value = {icon = "sector_icon_x2"},},
	{id = 31, type = "default", value = {score = 10},},
	{id = 32, type = "default", value = {score = 20},},
}

-- Получить все сектора
function M.get_all(self)
	local result = {}
	for i, sector in ipairs(M.sectors) do
		result[i] = M.get_item(self, i)
	end

	return result
end

-- Получить отдельный сектор
function M.get_item(self, id)
	local item = M.sectors[id]

	if not item then return false end

	-- Находим захвачено ли
	item.catch = storage_game.wheel["sector_"..id] or false

	if item.catch then
		item.player = game_core_gamers.get_player(self, item.catch.player_id)
		if item.player then
			item.color = item.player.color

		else
			item.color = color.gray

		end

		if item.catch.artifact_id then
			item.artifact = game_content_artifact.get_item(item.catch.artifact_id)
		end
	else
		-- Находим цвет для сектора
		if item.color_default then
			item.color = item.color_default
		else
			if id % 2 == 0 then
				item.color = M.colors.even
			else
				item.color = M.colors.odd
			end
		end
		item.artifact = nil
		item.player = nil
	end

	return {
		id = id,
		type = item.type,
		color = item.color,
		catch = item.catch,
		artifact = item.artifact,
		player = item.player,
		value = {
			score = item.value.score,
			icon = item.value.icon,
		},
	}
end

-- Получить артефакты на для игрока
function M.get_buff_artifacts_player(self, player_id)
	local sectors = M.get_all(self)
	local result = {}

	for i = 1, #sectors do
		local item = sectors[i]

		-- Нахожу артифакты
		if item.catch and item.catch.artifact_id and item.catch.player_id == player_id then
			local artifact = game_content_artifact.get_item(item.catch.artifact_id, player_id)

			-- Дефолтные значения
			result[artifact.type] = result[artifact.type] or {}
			result[artifact.type].count = result[artifact.type].count or 0
			result[artifact.type].buff = result[artifact.type].buff or 0

			-- Суммируем результаты
			result[artifact.type].count = result[artifact.type].count + 1
			if artifact.type == "catch" then
				result[artifact.type].buff = result[artifact.type].buff + artifact.value.sectors 
			elseif artifact.type == "bank" then
				result[artifact.type].buff = result[artifact.type].buff + artifact.value.score 
			elseif artifact.type == "accuracy" then
				result[artifact.type].buff = result[artifact.type].buff + artifact.value.accuracy
			elseif artifact.type == "speed_caret" then
				result[artifact.type].buff = result[artifact.type].buff + artifact.value.speed_caret
			end
		end
	end

	return result
end

-- Получение скорости прицела для игрока
function M.get_speed_aim(self, player_id, add_buff)
	local gamer = game_core_gamers.get_player(self, player_id, M)
	local add_buff = add_buff or 0

	-- Начальная скорость каретки
	local start_speed = 0.5
	local buff_characteristic_full = 300 / 100
	local buff_characteristic = gamer.buffs.characteristics.speed_caret or 0
	local buff_sectors = gamer.buffs.sectors.speed_caret or 0
	local speed = start_speed + buff_characteristic_full * buff_characteristic / 100 + buff_sectors / 100 + add_buff / 100

	-- Нормальная скорость каретки
	local norm_speed = 2

	return speed, norm_speed
end

-- Получение размера
function M.get_size_aim(self, player_id, add_buff)
	local max_aim_rotate = 100
	local min_aim_rotate = 20
	local add_buff = add_buff or 0
	local buff_characteristic_full = 80

	-- Получаем точность игрока
	local gamer = game_core_gamers.get_player(self, player_id, M) or game_core_gamers._players_ids.default

	local buff_characteristic = gamer.buffs.characteristics.accuracy or 0

	-- Баффы а захваченные сектора
	local buff_sectors = gamer.buffs.sectors.accuracy or 0

	-- Высчитываем текущий размер прицела
	local current_rotate = max_aim_rotate - buff_characteristic_full * buff_characteristic / 100 - buff_sectors - add_buff
	if current_rotate < min_aim_rotate then
		current_rotate = min_aim_rotate
	end

	-- Нормальный размер прицела
	local norm_aim = 55

	return current_rotate, norm_aim
end

return M