-- Функции для старта игры
local M = {}

local storage_game = require "main.game.storage.storage_game"
local storage_gui = require "main.storage.storage_gui"
local game_core_round_test = require "main.game.core.round.modules.game_core_round_test"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_core_round_step_start = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_start"
local game_core_round_step_functions = require "main.game.core.round.modules.game_core_round_step.game_core_round_step_functions"
local game_content_levels = require "main.game.content.game_content_levels"
local game_content_company = require "main.game.content.game_content_company"
local api_core_rating = require "main.core.api.api_core_rating"
local nakama = require "nakama.nakama"
local core_layouts = require "main.core.core_layouts"
local game_core_gamers = require "main.game.core.game_core_gamers"
local game_content_wheel = require "main.game.content.game_content_wheel"
local lang_core = require "main.lang.lang_core"
local timer_linear = require "main.modules.timer_linear"
local core_prorgress = require "main.core.core_progress.core_prorgress"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
local storage_player = require "main.storage.storage_player"
local core_layouts = require "main.core.core_layouts"
local online_image = require "main.online.online_image"

-- Выставляем игровую сцену на старт
function M.to_start(self, text_tablo, animate_leader)
	local animate_leader = animate_leader or  0
	local text_tablo = text_tablo or ""

	storage_game.is_game = false

	-- Брасываем барабан
	-- Показываем барабан
	msg.post("game-room:/loader_gui", "visible", {id = "game_wheel", visible = true})
	-- Сбрасываем барабан
	msg.post("game-room:/loader_gui", "set_status", {id = "game_wheel", type = "reset", value = {sectors = {}}})
	msg.post("game-room:/loader_gui", "set_status", {id = "game_wheel", type = "visible_aim", visible = false})
	-- Диалоговый баббл
	msg.post("/loader_gui", "visible", {id = "dialog_bubble", type = hash("animated_close"), visible = false})

	-- Сбрасываем тумбы
	for i = 1, 3 do
		msg.post("game-room:/thumba_"..i, "set_focus", {focus = false})
		msg.post("game-room:/thumba_"..i, "set_disabled")
	end

	msg.post("game-room:/scene", "close_scene", {animate = 0})

	msg.post("game-room:/leader", "visible", {visible = false, animate = animate_leader})

	timer.delay(0.25, false, function (self)
		msg.post(storage_gui.components_visible.up_label_scene, "add_text", {text = ""})
	end)
	
end

-- Запускаем начало раунда
function M.start_round(self, type, level_id, category_id, quest_type, quest, word, disable_symbols, players, sectors, animate_start, index_player, debug, quest_resourse)
	local level, category

	storage_game.is_game = true

	-- Очищаем оставшиеся данные
	core_layouts.clear_data()

	if level_id and category_id then
		level = game_content_levels.get(level_id, category_id, user_lang)
		category = game_content_company.get_id(category_id, user_lang)

		local type = level.stars_content.type
		local values_stars = level.stars_content.values
		msg.post("main:/core_stars", "start", {
			type = type, values_stars = values_stars
		})

	else
		
	end

	-- Данные для рануда
	storage_game.game.round = {
		type = type or "single",
		level = level or false,
		category = category or false,
		quest_resourse = quest_resourse,
		quest_type = quest_type or "text",
		quest = quest or "",
		word = word or "",
		current_gamer_id = 1,
		disable_symbols = disable_symbols or {},
		is_stars = (level_id and category_id)
	}
	-- Игроки в раунде
	storage_game.game.players = players or {}
	-- Занятые сектора на старте игры
	storage_game.wheel_artifacts = sectors or {}

	game_core_gamers.create_ids(self, game_content_wheel)

	-- Отрисовываем табло
	msg.post("game-room:/scene_tablo", "create_tablo", {word = word})

	-- Отрисовываем фон на сцене
	local sprite_bg_image = "game-room:/scene#sprite_scene_image"
	if quest_resourse then
		online_image.set_texture_sprite(self, sprite_bg_image, quest_resourse)
		go.set(sprite_bg_image, "tint.w", 0.4)
		go.set(sprite_bg_image, "scale", vmath.vector3(1))

	else
		sprite.play_flipbook(sprite_bg_image, "scene_bg")
		go.set(sprite_bg_image, "scale", vmath.vector3(0.00000001))
		
	end

	-- Записываем рейтинг перед раундом (Для инмации раунда в конце)
	api_core_rating.get_rating_gamer(self, count, function (self, err, result)
		storage_gui.old_personal_rating = result
	end)

	--Запускаем звуки и музыку
	msg.post("main:/core_screens", "game")
	msg.post("main:/sound", "play", {sound_id = "ovation_win"})

	--pprint("M.start_animate")

	M.start_animate(self)

	self.animate_start = animate_start
	if not animate_start then
		timer_linear.skip(self, "hello_game")
	end
	--[[
	if animate_start then
		M.start_animate(self)
	else
		M.start_no_animate(self)
	end
	]]--

end

-- Выставляем игровую сцену на старт
function M.start_animate(self, delay)
	local index_player = storage_game.game.message_start.index_player or 1
	local debug = storage_game.game.message_start.debug

	core_layouts.set_data("hello_game")
	self.timers = self.timers or {}
	timer_linear.add(self, "hello_game", 0, function (self)
		local text = lang_core.get_text(self, "_leader_hello_game", before_str, after_str, values)
		--game_core_round_functions.bubble_leader(self, text, text)

		-- Показываем ведущего
		msg.post("game-room:/leader", "visible", {visible = true, animate = 0.25})

	end)

	-- Ведущий приветствует
	timer_linear.add(self, "hello_game", 0.5, function (self)
		local text = lang_core.get_text(self, "_leader_hello_game", before_str, after_str, values)
		game_core_round_functions.bubble_leader(self, text, text)

	end)

	-- Ведущий представляет игроков
	timer_linear.add(self, "hello_game", 2, function (self)
		local text = lang_core.get_text(self, "_leader_hello_players", before_str, after_str, values)
		game_core_round_functions.bubble_leader(self, text)

	end)

	timer_linear.add(self, "hello_game", 0.5, function (self)
	end)

	-- Показываем игроков
	for i = 1, 3 do
		timer_linear.add(self, "hello_game", 0.5, function (self)
			local url = "game-room:/thumba_".. i
			local player = storage_game.game.players[i]

			if player then
				msg.post("main:/sound", "play", {sound_id = "activate_symbol"})
				msg.post(url, "set_gamer", {
					player_id = player.player_id,
					name = player.name, 
					score = player.score, 
					icon = player.avatar,
					color_player = player.color
				})
				msg.post(url, "set_focus", {focus = true})
			end
		end)
	end

	-- Выствляем артфакты
	for i, artifact in ipairs(storage_game.wheel_artifacts) do
		timer_linear.add(self, "hello_game", 0.25, function (self)
			msg.post("game-room:/loader_gui", "set_content", {
				id = "game_wheel", 
				type = "artifact", 
				value = {
					sector_id = artifact.sector_id,
					player_id = artifact.player_id,
					artifact_id = artifact.artifact_id,
				}
			})
		end)
	end

	-- ВНимание вопрос
	timer_linear.add(self, "hello_game", 0.25, function (self)
		local text = lang_core.get_text(self, "_leader_show_quest", before_str, after_str, values)
		game_core_round_functions.bubble_leader(self, text)
	end)

	-- Показ вопроса
	local show_delay = game_core_round_functions.get_show_text_duration(self, storage_game.game.round.quest)

	if storage_game.game.round.quest_type == "image" then
		show_delay = show_delay + 1
	elseif storage_game.game.round.quest_type == "music" then
		show_delay = show_delay
	end

	-- Если обучение, то не показываем вопрос
	if not storage_game.game.study then
		timer_linear.add(self, "hello_game", show_delay, function (self)
			game_core_round_functions.show_quest(self, true, function (self)
				
			end)
		end)

		if storage_game.game.round.quest_type == "music" then
			-- Добавляем паузу пока играет музыка
			local pause_quest_show = self.duration_show or 10
			pause_quest_show = pause_quest_show - 3
			timer_linear.add(self, "hello_game", pause_quest_show, function (self)
			end)
		end
	else
		show_delay = 0
	end

	--Открываем сцену
	timer_linear.add(self, "hello_game", show_delay, function (self)
		msg.post("game-room:/scene", "open_scene", {animate = 0.25})
	end)
	

	-- Открываем заблокированные буквы если есть
	for i, symbol in ipairs(storage_game.game.round.disable_symbols) do
		if game_core_round_step_functions.is_open_simbol(self, symbol, true) then
			timer_linear.add(self, "hello_game", 0.25, function (self)
				msg.post("game-room:/scene_tablo", "open_symbol", {symbol = symbol, is_sound = self.animate_start})
			end)
		end
	end

	timer_linear.add(self, "hello_game", 0.25, function (self)
		local len = utf8.len(storage_game.game.round.word)
		local text = lang_core.get_text(self, "_leader_show_symbols", before_str, after_str, {len = len})
		game_core_round_functions.bubble_leader(self, text)
	end)

	

	-- Начинаем игру
	if not debug then
		timer_linear.add(self, "hello_game", 0.25, function (self)
			msg.post("game-room:/core_game", "event", {
				id = "get_start_step",
				index_player = index_player,
				type = nil,
				first_step = true
			})
		end)
	end

end

return M