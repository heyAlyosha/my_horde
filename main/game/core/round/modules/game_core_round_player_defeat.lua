-- Поражение в игре
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_gamers = require "main.game.core.game_core_gamers"
local api_core_shop = require "main.core.api.api_core_shop"
local game_content_artifact = require "main.game.content.game_content_artifact"
local api_player = require "main.game.api.api_player"
local storage_gui = require "main.storage.storage_gui"
local core_prorgress = require "main.core.core_progress.core_prorgress"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local storage_player = require "main.storage.storage_player"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local data_handler = require "main.data.data_handler"

-- Проигрыш игрока
function M.start(self, player_id, type)
	-- Тип проигрыша
	-- "fail_word/win_other_gamer/surrender"
	local type_fail = type or "fail_word"
	local current_level, next_level
	self.type_game = storage_game.game.round.type
	core_layouts.set_data("round_game", {step = "fail"})

	msg.post("main:/core_screens", "game_result", {
		type = "fail"
	})

	self.text_tablo = lang_core.get_text(self, "_tablo_you_fails_refresh_game", before_str, after_str, values)
	msg.post(storage_gui.components_visible.up_label_scene, "add_text", {text = self.text_tablo})

	if self.type_game == "single" then
		-- Если это уровень (если нет, то это турнир)
		if storage_game.game.round.level and storage_game.game.round.category then
			current_level = storage_game.game.round.level or false

			if storage_game.game.round.level.next_level then
				next_level = storage_game.game.round.level.next_level or false
			end
		end

		if current_level then
			current_level = {id = current_level.id, stars = current_level.stars, category_id = storage_game.game.round.category.id}
		end
		if next_level then
			next_level = {id = next_level.id, stars = next_level.stars, category_id = storage_game.game.round.category.id}
		end

		msg.post("main:/loader_gui", "visible", {
			id = "modal_result_single",
			visible = true,
			type = hash("popup"),
			value = {
				type_result = "fail",
				type_fail= type_fail,
				current_level = current_level,
				next_level = next_level,
			},
		})
	end

	-- Записываем статиститку
	local items = {
		{id = "fail", operation = "add", value = 1},
		{id = "games", operation = "add", value = 1},
	}
	core_prorgress.set_stats(items)

	-- Сохраняем результат На сервере
	data_handler.set_userdata(self, {
		stats = storage_player.stats, 
	})
end

-- Завершилась обработка sdk элементов
function M.sdk_completion(self)
	local update_inteface = true
	local nakama_sync = true
	api_player.get_rating(self, update_inteface, nakama_sync)

	-- Зачисляем случайные товары в магазин
	api_core_shop.add_random_shop(self, game_content_artifact)
	msg.post("game-room:/core_game", "event", {id = "set_to_start", text_tablo = self.text_tablo, animate_leader = 0.25})

	-- 
	game_core_round_functions.result_all_showing(self, "fail")
end


-- СОбытия в результатах игры
function M.on_event(self, message)
	if message.id == "visible_game_result" then
		msg.post("/loader_gui", "visible", {
			id = "confetti",
			visible = false,
			type = hash("animated_close"),
		})

		msg.post("main:/loader_sdk", "game_over", {type = "fail"})

	elseif message.id == "sdk_completion" then
		M.sdk_completion(self)

	end
end


-- Выбывание игрока
function M.player_drop(self, player_id, delay)
	local player = game_core_gamers.get_player(self, player_id)
	local delay = delay or 0
	local win_player

	local text_leader = lang_core.get_text(self, "_leader_drop_player", before_str, after_str, {name = player.name})
	game_core_round_functions.bubble_leader(self, text_leader, text_leader)

	-- Удаляем игрока из игры
	local index_player 
	for index, player in ipairs(storage_game.game.players) do
		if player and player.player_id == player_id then
			storage_game.game.players[index] = false
			index_player = index

			if game_core_gamers._players_ids[player_id] then
				game_core_gamers._players_ids[player_id] = nil

			end
			break
		end
	end

	local thumba_url = "game-room:/thumba_"..index_player
	local ray_timer = 0 
	local focus = true
	timer.delay(0.2, true, function (self, handle)
		focus = not focus
		ray_timer = ray_timer + 1
		msg.post(thumba_url, "set_focus", {focus = focus})

		if ray_timer > 8 then
			timer.cancel(handle)
		end
	end)

	-- Скрываем его тумбу
	delay = delay + 2
	timer.delay(delay, false, function (self)
		msg.post(thumba_url, "set_disabled")
	end)

	-- Проверяем сколько игроков ещё осталось
	local count_players = 0
	local index_player_win
	for index, player in ipairs(storage_game.game.players) do
		if player  then
			count_players = count_players + 1
			index_player_win = index
		end
	end

	-- Если остался один игрок - он победил
	if count_players == 1 then
		win_player = storage_game.game.players[index_player]
		win_player = game_core_gamers.get_player(self, win_player.player_id, game_content_wheel)
	end


	return win_player, delay
end


return M