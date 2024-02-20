-- Функции старта раунда
local M = {}

local storage_game = require "main.game.storage.storage_game"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_round_step_sector = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector"
local game_core_round_step_sector_catch = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_sector_catch"
local timer_linear = require "main.modules.timer_linear"
local lang_core = require "main.lang.lang_core"


-- Начало хода игроков
function M.start_step(self, index_player, type, first_step)
	msg.post("main:/music", "play", {sound = "music-gameplay", loop = nil})

	local player = storage_game.game.players[index_player]

	self.player = player
	local type = type or "default"
	local delay = 0

	self.index_player = index_player

	-- Ставим нужный лайоут
	core_layouts.set_data("round_game", {step = "start", index_player = index_player, player = player})

	local text_tablo, text_leader

	if not player then 
		return false 
	end

	local name = utf8.upper(player.name)
	-- Текстовое содержимое
	if first_step then
		-- Если это начало игры и 1 раунд
		text_leader = lang_core.get_text(self, "_leader_step_start_first", before_str, after_str, {name = name})
	else
		-- Обынчный раунд
		if type == "success" then
			text_leader = lang_core.get_text(self, "_leader_step_start_success", before_str, after_str, {name = name})

		elseif type == "fail" then
			text_leader = lang_core.get_text(self, "_leader_step_start_fail", before_str, after_str, {name = name})

		else
			text_leader = lang_core.get_text(self, "_leader_step_start_default", before_str, after_str, {name = name})

		end

	end

	if false and storage_game.game.study and first_step then
		-- ОБУЧЕНИЕ
		-- Обучение перенёс в диалоги персонажей
		timer_linear.add(self, "study_1", 0, function (self)
			text_leader = lang_core.get_text(self, "_leader_step_start_study_1", before_str, after_str, {name = name})
			game_core_round_functions.bubble_leader(self, text_leader, text_leader)

			timer_linear.add(self, "study_2", 6, function (self)
				text_leader = lang_core.get_text(self, "_leader_step_start_study_2", before_str, after_str, {name = name})
				game_core_round_functions.bubble_leader(self, text_leader, text_leader)

				timer_linear.add(self, "study_3", 6, function (self)
					text_leader = lang_core.get_text(self, "_leader_step_start_study_3", before_str, after_str, {name = name})
					game_core_round_functions.bubble_leader(self, text_leader, text_leader)

					timer_linear.add(self, "study_4", 0, function (self)
						M.wheel(self, delay)
					end)
				end)
			end)

		end)
	else
		-- обычная игра
		timer_linear.add(self, "step_start", 2, function (self)
			game_core_round_functions.bubble_leader(self, text_leader, text_leader)
			
		end)

		M.wheel(self, delay)

	end

	-- Фокусировка светом на игроке
	for i = 1, 3 do
		local url = "game-room:/thumba_".. i
		msg.post(url, "set_focus", {focus = i == self.index_player})
	end

	
end

-- Предлагаем крутить барарабан
function M.wheel(self, delay)
	if self.player.type == "player" then
		timer_linear.add(self, "step_start", 0.5, function (self)
			-- Показываем окно вращения барабана
			msg.post("game-room:/loader_gui", "set_status", {
				id = "game_wheel",
				type = "visible_aim",
				visible = true,
				value = {
					player_id = self.player.player_id, -- если нет размера, высчитывается для него
					size = size -- Размер прицела, id игрока игнорируется
				}
			})
			msg.post("/loader_gui", "visible", {
				id = "scale_power",
				visible = true,
				type = hash("animated_close"),
				value = {player_id = self.player.player_id}
			})
			msg.post("main:/sound", "play", {sound_id = "modal_close_1", is_single = true})
		end)
	else
		timer_linear.add(self, "step_start", 0.5, function (self)
			msg.post("/core_bot", "start_aim", {bot_id = self.player.bot_id, player_id = self.player.player_id})
		end)
	end

	timer_linear.add(self, "step_start", 0.25, function (self)
		game_core_round_step_sector_catch.accuracy_and_speed_caret(self, self.player.player_id, delay)
	end)
end


-- Ловим события
function M.on_event(self, message_id, message)
	if message.id == "wheel_rotate" and message.value.step == "end" then
		-- Барабан остановился, запускаем обработку сектора
		msg.post("game-room:/core_game", "event", {
			id = "get_round_step_sector_start",
			sector_id = message.value.sector_id
		})
		--game_core_round_step_sector.start(self, message.value.sector_id)

	elseif message.id == "wheel_rotate" and message.value.step == "start" then
		-- Барабан начал крутиться
		msg.post("main:/music", "play", {sound = "music-wheel"})
		msg.post("main:/sound", "play", {sound_id = "modal_close_1"})

	end

end

return M