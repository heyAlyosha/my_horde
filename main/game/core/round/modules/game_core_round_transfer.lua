-- Обмен между персонажами во время игры
local M = {}

local sound_render = require "main.sound.modules.sound_render"
local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_gamers = require "main.game.core.game_core_gamers"

-- ВЕдущий передаёт игрока
function M.score_leader_to_player(self, count, player_id)
	local player = game_core_gamers.get_player(self, player_id, game_content_wheel)
	local position_player = go.get_world_position("game-room:/thumba_"..player.index)

	msg.post("main:/sound", "play", {sound_id = "sold_bulb_1"})

	msg.post("/loader_gui", "set_status", {
		id = "game_transfer",
		type = "transfer",
		value = {
			count = {score = count},
			-- От кого
			where = {
				type = "leader", id = "leader", 
				position = go.get_world_position("game-room:/leader_dialog_spawn"),
				value = {}
			},
			-- Кому
			to = {
				type = "player", id = player_id, 
				position = position_player, 
				value = {}
			},
		}
	})
end


-- Игрок отдаёт очик ведущему
function M.score_player_to_leader(self, count, player_id)
	local player = game_core_gamers.get_player(self, player_id, game_content_wheel)
	local position_player = go.get_world_position("game-room:/thumba_"..player.index)

	msg.post("main:/sound", "play", {sound_id = "sold_bulb_1"})

	msg.post("/loader_gui", "set_status", {
		id = "game_transfer",
		type = "transfer",
		value = {
			count = {score = count},
			-- От кого
			where = {
				type = "player", id = player_id, 
				position = position_player, 
				value = {}
			},
			-- Кому
			to = {
				type = "leader", id = "leader", 
				position = go.get_world_position("game-room:/leader_dialog_spawn"),
				value = {}
			},
		}
	})
end

function M.score_player_to_player(self, count, player_from_id, player_to_id)
	local player_from = game_core_gamers.get_player(self, player_from_id, game_content_wheel)
	local player_to = game_core_gamers.get_player(self, player_to_id, game_content_wheel)

	msg.post("main:/sound", "play", {sound_id = "sold_bulb_1"})

	local position_player_from = go.get_world_position("game-room:/thumba_"..player_from.index)
	local position_player_to = go.get_world_position("game-room:/thumba_"..player_to.index)

	-- Смотрим есть ли столько очков у отдающего
	--[[
	if count > player_from.score then
		count = player_from.score
	end
	]]--

	msg.post("/loader_gui", "set_status", {
		id = "game_transfer",
		type = "transfer",
		value = {
			count = {score = count},
			-- От кого
			where = {
				type = "player", id = player_from_id, 
				position = position_player_from,
				value = {}
			},
			-- Кому
			to = {
				type = "player", id = player_to_id, 
				position = position_player_to, 
				value = {}
			},
		}
	})
end

function M.score_sector_to_player(self, count, sector_id, player_to_id)
	local player_to = game_core_gamers.get_player(self, player_to_id, game_content_wheel)
	local sector = game_content_wheel.sectors[sector_id]

	msg.post("main:/sound", "play", {sound_id = "sold_bulb_1"})

	local position_sector_from = sector.screen_positions.object
	--local position_sector_from = camera.screen_to_world(camera_id, sector.screen_positions.object) 
	local position_player_to = go.get_world_position("game-room:/thumba_"..player_to.index)

	msg.post("/loader_gui", "set_status", {
		id = "game_transfer",
		type = "transfer",
		value = {
			count = {score = count},
			-- От кого
			where = {
				type = "object", id = sector_id, 
				position = position_sector_from,
				value = {}
			},
			-- Кому
			to = {
				type = "player", id = player_to_id, 
				position = position_player_to, 
				value = {}
			},
		}
	})
end

function M.score_sector_preview(self, count, sector_id, player_to_id)
	local player_to = game_core_gamers.get_player(self, player_to_id, game_content_wheel)
	local sector = game_content_wheel.sectors[sector_id]

	msg.post("main:/sound", "play", {sound_id = "sold_bulb_1"})

	local position_sector_from = sector.screen_positions.object
	--local position_sector_from = camera.screen_to_world(camera_id, sector.screen_positions.object) 
	local position_player_to = go.get_world_position("game-room:/thumba_"..player_to.index)

	msg.post("/loader_gui", "set_status", {
		id = "game_transfer",
		type = "transfer",
		value = {
			count = {score = count},
			-- От кого
			where = {
				type = "object", id = sector_id, 
				position = position_sector_from,
				value = {}
			},
			-- Кому
			to = false,
		}
	})
end

-- Слушаем события о передаче между игроками
function M.on_event(self, message_id, message)
	local data = message.to or message.where

	if data.type == "player" then
		local player = game_core_gamers.get_player(self, data.id, game_content_wheel)
		player.score = player.score + message.count.score
		if player.score < 0 then
			player.score = 0
		end
		msg.post("game-room:/thumba_" .. player.index, "update_score", {score = player.score})

	end
end

return M