-- Поведение на секторах
local M = {}

local storage_player = require "main.storage.storage_player"
local storage_game = require "main.game.storage.storage_game"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_step_functions = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_functions"
local game_core_round_transfer = require "main.game.core.round.modules.game_core_round_transfer"
local game_core_round_step_next  = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_next"
local game_core_round_step_sector_x2 = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_x2"
local game_core_round_step_sector_bankrot = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_bankrot"
local game_core_round_step_sector_skip = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_skip"
local game_core_round_step_sector_open_symbol = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_open_symbol"
local game_core_round_step_sector_catch = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_catch"
local game_content_wheel = require "main.game.content.game_content_wheel"
local game_content_artifact = require "main.game.content.game_content_artifact"
local core_layouts = require "main.core.core_layouts"
local lang_core = require "main.lang.lang_core"
-- ЛИНЕЙНЫЕ ТАЙМЕР (друг за другом)
local timer_linear = require "main.modules.timer_linear"
local game_core_gamers = require "main.game.core.game_core_gamers"

-- Наступил на сектор
function M.start(self, sector, skip_catch, skip_obereg)
	local score = sector.value.score
	local text_leader, text_table
	local layout = core_layouts.get_data()
	local player = layout.data.player
	local start_text_leader, start_text_tablo, is_break
	local is_break

	self.skip_obereg = skip_obereg

	local delay = 0

	-- Зачисляем все очки от газировок на барабане
	if not skip_catch and not self.skip_obereg then
		timer_linear.add(self, "sector_core", 0, function (self)
			game_core_round_step_sector_catch.bank(self, delay)

		end)

		timer_linear.add(self, "sector_core", 0.5, function (self)

		end)
	end

	-- Сектор завхвачен другим игроком
	if not skip_catch and sector.catch and sector.catch.player_id ~= self.player.player_id then
		if sector.catch.artifact_id then
			local artifact = game_content_artifact.get_item(sector.catch.artifact_id)

			if artifact.type == "catch" and not self.skip_obereg then
				-- Наступил в подарок
				local artifact_id = sector.catch.artifact_id
				local player_id = sector.catch.player_id
				local sector = self.sector
				delay, is_break = game_core_round_step_sector_catch.catch(self, sector, player_id, artifact_id, delay)

			elseif artifact.type == "trap" then
				-- Наступил в капкан
				local artifact_id = sector.catch.artifact_id
				local player_id = sector.catch.player_id
				local sector = self.sector
				delay, is_break = game_core_round_step_sector_catch.trap(self, sector, player_id, artifact_id, delay)
			end

		elseif not sector.catch.artifact_id and not self.skip_obereg then
			-- Если нет артефакта, значит захвачен сувениром
			local artifact_id = "catch_2"
			local player_id = sector.catch.player_id
			local sector = self.sector
			delay, is_break = game_core_round_step_sector_catch.catch(self, sector, player_id, artifact_id, delay)

		end
	end
	
	if is_break then
		return true
	end

	-- Определяем тип сектора
	local type = sector.type or "default"
	if type == "x2" then
		start_text_leader, start_text_tablo, delay, is_break = game_core_round_step_sector_x2.start(self, sector, delay)

	elseif type == "bankrot" then
		start_text_leader, start_text_tablo, delay, is_break = game_core_round_step_sector_bankrot.start(self, sector, delay)

	elseif type == "skip" then
		start_text_leader, start_text_tablo, delay, is_break = game_core_round_step_sector_skip.start(self, sector, delay)

	elseif type == "open_symbol" then
		start_text_leader, start_text_tablo, delay, is_break = game_core_round_step_sector_open_symbol.start(self, sector, delay)

	else
		start_text_leader = lang_core.get_text(self, "_leader_score_to_wheel", before_str, after_str, {score = score})

	end

	if is_break then
		return true
	end

	-- Проверяем, может ли человек захватить этот сектор
	if not sector.catch then
		-- Сектор можно захватить
		local function sector_catch(self)
			text_leader = start_text_leader..lang_core.get_text(self, "_leader_to_player_catch_sector", before_str, after_str)

			timer_linear.add(self, "sector_core", 0, function (self)
				game_core_round_functions.bubble_leader(self, text_leader, text_leader)

			end)

			if player.type == "player" then
				pprint("storage_game.game.round.type", storage_game.game.round.type)
				timer_linear.add(self, "sector_core", 2, function (self)
					-- Показываем и фокусируем
					msg.post("/loader_gui", "visible", {
						id = "game_hud_buff_horisontal",
						visible = true,
						value = {
							is_game = true,
							is_reward = storage_game.game.round.type ~= "family",
							sector_id = layout.data.sector_id,
							player_id = player.player_id,
						}
					})

					msg.post("game-room:/loader_gui", "set_status", {
						id = "game_wheel",
						type = "focus_wheel",
						visible = true,
						value = {type = "bottom"}
					})
				end)

			elseif player.type == 'bot' then
				msg.post("/core_bot", "start_artifact", {
					player_id = self.player.player_id,
					bot_id = self.player.bot_id,
					sector_id = sector.id
				})
			end
		end

		if not storage_game.game.study then
			sector_catch(self)
		else
			timer_linear.add(self, "study_1", 0, function (self)
				text_leader = lang_core.get_text(self, "_leader_catch_study_1", before_str, after_str, {name = name})
				game_core_round_functions.bubble_leader(self, text_leader, text_leader)

				timer_linear.add(self, "study_2", 6, function (self)
					text_leader = lang_core.get_text(self, "_leader_catch_study_2", before_str, after_str, {name = name})
					game_core_round_functions.bubble_leader(self, text_leader, text_leader)

					timer_linear.add(self, "study_3", 6, function (self)
						text_leader = lang_core.get_text(self, "_leader_catch_study_3", before_str, after_str, {name = name})
						game_core_round_functions.bubble_leader(self, text_leader, text_leader)

						timer_linear.add(self, "study_4", 0, function (self)
							sector_catch(self)
						end)
					end)
				end)
			end)
		end
		

	else
		timer_linear.add(self, "sector_core", 0, function (self)
			-- Сектор уже захвачен
			game_core_round_step_functions.get_keyboard(self, self.sector, self.player)

		end)

	end

	
end

-- Захват сектора
function M.catch(self)
	
end

-- Ловим события
function M.on_event(self, message_id, message)
	if message.id == "catch_sector" then
		if message.value.type == "close" then
			-- Отказ от захвата сектора
			local score = self.sector.value.score
			local layout = core_layouts.get_data()
			local player = layout.data.player
			game_core_round_step_functions.get_keyboard(self, self.sector, self.player)
			msg.post("game-room:/loader_gui", "set_status", { id = "game_wheel", type = "focus_wheel", visible = false})


		elseif message.value.type == "confirm" then
			-- Захват сектора
			local score = self.sector.value.score
			local layout = core_layouts.get_data()
			local player = layout.data.player
			local data = message.value

			-- Удаляем у игрока этот предмет
			game_core_gamers.add_artifact_count(self, data.artifact_id, player.player_id, -1)

			msg.post("game-room:/loader_gui", "set_content", {
				id = "game_wheel",
				type = "artifact",
				value = {
					sector_id = data.sector_id,
					player_id = data.player_id,
					artifact_id = data.artifact_id,
				}
			})

			timer_linear.add(self, "sector_core", 1, function (self)
				msg.post("game-room:/loader_gui", "set_status", { id = "game_wheel", type = "focus_wheel", visible = false})
			end)

			timer_linear.add(self, "sector_core", 0.25, function (self)
				game_core_round_step_functions.get_keyboard(self, self.sector, self.player)
				
			end)

		end
	end
end

return M