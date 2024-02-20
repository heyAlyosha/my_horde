-- Работа с игроками
local M = {}

local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local color = require("color-lib.color")
local api_player = require "main.game.api.api_player"

M._players_ids = {}
M._players_ids["default"] = {
	index = 0, 
	player_id = "default",
	name = "default",
	avatar = nil,
	type = "bot",
	score = 0,
	characteristics = {},
	color = "gray",
	buffs = {
		characteristics = {},
		sectors = {},
	},
	artifacts = {}
}

-- Кешируем id игроков
function M.create_ids(self, game_content_wheel)
	local players = storage_game.game.players

	for i = 1, #players do
		local gamer = players[i]

		-- Получаем характеристики и баффы
		gamer.buffs = {
			characteristics = {},
			sectors = {}
		}
		-- Баффы от характеристик
		for id, level in pairs(gamer.characteristics) do
			gamer.buffs.characteristics[id] = game_content_characteristic.get_buff(self, id, level)
		end

		-- За сектора
		if game_content_wheel then 
			local buff_sectors = game_content_wheel.get_buff_artifacts_player(self, gamer.player_id)
			for id, buff in pairs(buff_sectors) do
				gamer.buffs.sectors[id] = buff.buff
			end
		end

		M._players_ids = M._players_ids or {}

		M._players_ids[gamer.player_id] = {
			index = i, 
			player_id = gamer.player_id,
			bot_id = gamer.bot_id,
			name = gamer.name,
			avatar = gamer.avatar,
			type = gamer.type,
			score = gamer.score,
			characteristics = gamer.characteristics,
			color = gamer.color,
			buffs = {
				characteristics = gamer.buffs.characteristics,
				sectors = gamer.buffs.sectors,
			},
			artifacts = gamer.artifacts
		}

	end
end

-- Получение игрока во время раунда
function M.get_player(self, player_id, game_content_wheel)
	M._players_ids = M._players_ids or {}
	local gamer =  M._players_ids[player_id]

	if not gamer then
		return
	end

	-- Получаем характеристики и баффы
	gamer.buffs = {
		characteristics = {},
		sectors = {}
	}
	-- Баффы от характеристик
	for id, level in pairs(gamer.characteristics) do
		gamer.buffs.characteristics[id] = game_content_characteristic.get_buff(self, id, level)
	end

	-- За сектора
	if game_content_wheel then 
		local buff_sectors = game_content_wheel.get_buff_artifacts_player(self, player_id)
		for id, buff in pairs(buff_sectors) do
			gamer.buffs.sectors[id] = buff.buff
		end
	end

	return gamer
end


-- Добавление/Вычитание колы-ва артефактов у игркоа
function M.add_artifact_count(self, artifact_id, player_id, count)
	local player = M.get_player(self, player_id)
	local count = count or 1

	-- Увеличиваем или уменьшаем
	if player then
		player.artifacts[artifact_id] = player.artifacts[artifact_id] or 0
		player.artifacts[artifact_id] = player.artifacts[artifact_id] + count
	end

	if player_id == "player" then
		local set_nakama = true
		api_player.set_artifacts(self, artifact_id, 0, "add", set_nakama)
	end

	return M.get_player(self, player_id)
end

return M