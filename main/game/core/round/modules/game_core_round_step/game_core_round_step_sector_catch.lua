-- Функции для хода в игре
local M = {}

local color = require("color-lib.color")
local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local core_layouts = require "main.core.core_layouts"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_content_artifact = require "main.game.content.game_content_artifact"
local game_content_wheel = require "main.game.content.game_content_wheel"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_step_next = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_next"
local lang_core = require "main.lang.lang_core"
local timer_linear = require "main.modules.timer_linear"

-- Игрок наступил на сувенир или его зону
function M.catch(self, sector, player_id, artifact_id, delay)
	local is_break
	local artifact_id = artifact_id or "catch_2"
	local artifact = game_content_artifact.get_item(artifact_id)
	local score = sector.catch.score or 0
	local player_artifact = game_core_gamers.get_player(self, player_id, game_content_wheel)

	local text_leader = lang_core.get_text(self, "_leader_player_to_opponent_catch", before_str, after_str, {
		name = self.player.name, 
		name_player_artifact = player_artifact.name,
		score = score
	})

	game_core_round_functions.bubble_leader(self, text_leader, text_leader)

	msg.post("main:/sound", "play", {sound_id = "response-error"})

	timer_linear.add(self, "sector_core", 0, function (self)
		-- Если есть артифакт
		if sector.catch.artifact_id then
			msg.post("game-room:/loader_gui", "set_status", {
				id = "game_wheel",
				type = "ray_object",
				value = {
					sector_id = sector.id,
					color = color.red,
				},
			})
		end
	end, delay)

	-- Пересылаем очки игроку
	timer_linear.add(self, "sector_core", 0.5, function (self)
		game_core_round_transfer.score_player_to_player(self, score, self.player.player_id, player_id)
	end)

	-- Пересылаем очки игроку
	timer_linear.add(self, "sector_core", 3, function (self)
		msg.post("game-room:/core_game", "event", {id = "get_round_step_start", sector_id = sector.id, skip_catch = true, skip_obereg = self.skip_obereg})
	end)

	is_break = true

	return delay, is_break
end

-- Игрок наступил на капкан
function M.trap(self, sector, player_id, artifact_id, delay)
	local is_break
	local artifact_id = artifact_id 
	local artifact = game_content_artifact.get_item(artifact_id)
	local score = artifact.value.score
	local is_skip = artifact.value.skipping
	local player_artifact = game_core_gamers.get_player(self, player_id, game_content_wheel)
	local text_leader, text_tablo

	msg.post("main:/sound", "play", {sound_id = "zombie_death"})
	msg.post("main:/music", "play", {sound = "music-start-game"})

	msg.post("game-room:/loader_gui", "set_status", {
		id = "game_wheel",
		type = "ray_object",
		value = {
			sector_id = sector.id,
			color = color.red,
		},
	})

	timer_linear.add(self, "sector_core", 0.25, function (self)
		-- Если есть артифакт
		if sector.catch.artifact_id then
			msg.post("main:/sound", "play", {sound_id = "response-error"})
			msg.post("main:/sound", "play", {sound_id = "ovation_fail"})
		end
	end, delay)

	if is_skip then
		text_leader = lang_core.get_text(self, "_leader_player_to_opponent_big_trap", before_str, after_str, {
			name = self.player.name, 
			name_player_artifact = player_artifact.name,
			score = score
		})

	else
		text_leader = lang_core.get_text(self, "_leader_player_to_opponent_trap", before_str, after_str, {
			name = self.player.name, 
			name_player_artifact = player_artifact.name,
			score = score
		})

	end

	game_core_round_functions.bubble_leader(self, text_leader, text_leader)

	-- Оберег
	local player_id = player_id
	local is_game = true
	pprint("is_obereg", game_core_round_functions.is_obereg(self, self.player.player_id, is_game, is_reward), is_reward)
	if not self.skip_obereg and game_core_round_functions.is_obereg(self, self.player.player_id, is_game, is_reward) then
		-- Предлагаем использовать оберег через время и сбрасываем
		timer_linear.add(self, "sector_core", 2, function (self)
			-- Если есть артифакт
			if self.player.type ==  "player" then
				local score = 0
				M.visible_obereg(self, "trap", score, artifact_id)

			elseif self.player.type ==  "bot" then
				M.obereg(self, "trap", true)

			end
		end)
		is_break = true

		return delay, is_break

	else
		timer_linear.add(self, "sector_core", 0.5, function (self)
			self.skip_obereg = nil
			game_core_round_transfer.score_player_to_player(self, score, self.player.player_id, player_id)
		end)

		timer_linear.add(self, "sector_core", 3, function (self)
			if is_skip then
				game_core_round_step_next.start_fail(self)

			else
				msg.post("game-room:/core_game", "event", {id = "get_round_step_start", sector_id = sector.id, skip_catch = true, skip_obereg = self.skip_obereg})

			end
		end)

		is_break = true

		return delay, is_break

	end
end

-- Обработка банков на барабане
function M.bank(self, delay)
	local sectors = game_content_wheel.get_all(self)
	for i, item in ipairs(sectors) do
		if item.catch and item.catch.artifact_id then
			local artifact = game_content_artifact.get_item(item.catch.artifact_id)

			if artifact.type == "bank" then
				msg.post("main:/sound", "play", {sound_id = "popup_show"})
				local score = artifact.value.score
				local sector_id = item.id
				local player_id = item.catch.player_id
				game_core_round_transfer.score_sector_to_player(self, score, sector_id, player_id)
				msg.post("game-room:/loader_gui", "set_status", {
					id = "game_wheel",
					type = "ray_object",
					value = {
						sector_id = item.id,
						color = color.yellow,
					},
				})
			end
		end
	end

	delay = delay + 1
	return delay
end

-- Обработка шампанского и гирь и точности
function M.accuracy_and_speed_caret(self, player_id, delay)
	local sectors = game_content_wheel.get_all(self)
	for i, item in ipairs(sectors) do
		if item.catch and item.catch.artifact_id then
			local artifact = game_content_artifact.get_item(item.catch.artifact_id)

			if (artifact.type == "accuracy" or artifact.type == "speed_caret") and item.catch.player_id == player_id then
				local color_ray 
				if artifact.type == "speed_caret" then
					color_ray = color.lime
				else
					color_ray = color.aqua
				end
				msg.post("main:/sound", "play", {sound_id = "popup_show"})

				msg.post("game-room:/loader_gui", "set_status", {
					id = "game_wheel",
					type = "ray_object",
					value = {
						sector_id = item.id,
						color = color_ray,
					},
				})
			end
		end
	end

	delay = delay + 1
	return delay
end

-- Показ окна с оберегом
function M.visible_obereg(self, type, score, trap_id)
	local score = score or 0

	msg.post("/loader_gui", "visible", {
		id = "modal_obereg",
		visible = true,
		type = type,
		value = {
			trap_id = trap_id, -- для капкана
			score = score, -- Для сектора банкрот
			player_id = self.player.player_id,
			is_game = true,
			is_reward = true
		}
	})
end

-- обрабатываем действия с оберегом
function M.obereg(self, type, confirm)
	if confirm then
		-- Используем 
		local text_leader, text_tablo
		if type == "skipping" then
			text_leader = lang_core.get_text(self, "_leader_player_confirm_obereg_for_skipping", before_str, after_str, {name = self.player.name})

		elseif type == "bankrupt" then
			text_leader = lang_core.get_text(self, "_leader_player_confirm_obereg_for_bankrupt", before_str, after_str, {name = self.player.name})

		elseif type == "trap" then
			local catch = self.sector.catch
			local catch_player = game_core_gamers.get_player(self, catch.player_id)
			local artifact = game_content_artifact.get_item(self.sector.catch.artifact_id, player_id, is_game, is_reward)
			local score = artifact.value.score

			game_core_round_transfer.score_leader_to_player(self, score, catch.player_id)
			
			text_leader = lang_core.get_text(self, "_leader_player_confirm_obereg_for_trap", before_str, after_str, {
				name = self.player.name,
				name_player_artifact = catch_player.name
			})
		end

		text_tablo = text_leader
		game_core_round_functions.bubble_leader(self, text_leader, text_tablo)

		self.player = game_core_gamers.add_artifact_count(self, "try_1", self.player.player_id, -1)

		if self.player.type ~= "player" then
			msg.post("/loader_gui", "visible", {
				id = "game_confirm_obereg", 
				type = hash("animated_close"), 
				visible = true,
				value = {name = self.player.name}
			})

			timer_linear.add(self, "obereg", 2, function (self)
				msg.post("/loader_gui", "visible", {
					id = "game_confirm_obereg", 
					type = hash("animated_close"), 
					visible = false
				})
			end)
		end

		timer_linear.add(self, "obereg", 1.5, function (self)
			local type = "success"
			game_core_round_step_next.start_success(self, type)
		end)
	else
		-- Отказался от использования
		msg.post("game-room:/core_game", "event", {id = "get_round_step_start", sector_id = self.sector.id, skip_obereg = true})
	end
end

return M