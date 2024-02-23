-- Победа игрока в игре
local M = {}

local storage_game = require "main.game.storage.storage_game"
local api_player = require "main.game.api.api_player"
local storage_sdk = require "main.storage.storage_sdk"
local game_core_round_functions = require "main.game.core.round.modules.game_core_round_functions"
local game_content_wheel = require "main.game.content.game_content_wheel"
local core_layouts = require "main.core.core_layouts"
local game_core_gamers = require "main.game.core.game_core_gamers"
local storage_player = require "main.storage.storage_player"
local api_core_shop = require "main.core.api.api_core_shop"
local game_content_characteristic = require "main.game.content.game_content_characteristic"
local game_content_artifact = require "main.game.content.game_content_artifact"
local timer_linear = require "main.modules.timer_linear"
local storage_gui = require "main.storage.storage_gui"
local core_prorgress = require "main.core.core_progress.core_prorgress"
local nakama_api_account = require "main.online.nakama.api.nakama_api_account"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local data_handler = require "main.data.data_handler"

function M.start(self, is_ads_reward, player_id, delay)
	if is_ads_reward == nil then is_ads_reward = storage_sdk.stats.is_ads_reward end
	local player_id = player_id or "player"
	self.player = game_core_gamers.get_player(self, player_id, game_content_wheel)
	local delay = delay or 0
	core_layouts.set_data("round_game", {step = "win"})


	if is_ads_reward then
		-- Если есть реклама за вознаграждение
		delay = M.ads_reward(self, delay)

	else
		-- Магазин подарков
		delay = M.shop(self, delay)

		--M.result(self, player_id, type, delay)
	end

	return delay
end

-- Магазин призов
function M.shop(self, delay)
	-- Формруем призовые очки
	local gamer = game_core_gamers.get_player(self, storage_game.game.result.player_win_id)
	storage_game.game.result.xp = gamer.score
	storage_game.game.result.score = gamer.score
	storage_game.game.result.prizes = {}
	
	local function visible_shop(self)
		local delay = delay or 0
		local text = lang_core.get_text(self, "_leader_prize_to_game_magazine", before_str, after_str, values)
		game_core_round_functions.bubble_leader(self, text, text)

		timer_linear.add(self, "bubble", 3, function (self)
			msg.post("main:/loader_gui", "visible", {
				id = "catalog_prize_magazine", 
				visible = true
			})
		end)

		return delay
	end

	if storage_game.game.study then
		-- ОБУЧЕНИЕ
		timer_linear.add(self, "study_1", 0, function (self)
			text_leader = lang_core.get_text(self, "_leader_shop_study_1", before_str, after_str, {name = name})
			game_core_round_functions.bubble_leader(self, text_leader, text_leader)

			timer_linear.add(self, "study_2", 6, function (self)
				text_leader = lang_core.get_text(self, "_leader_shop_study_2", before_str, after_str, {name = name})
				game_core_round_functions.bubble_leader(self, text_leader, text_leader)

				timer_linear.add(self, "study_3", 6, function (self)
					text_leader = lang_core.get_text(self, "_leader_shop_study_3", before_str, after_str, {name = name})
					game_core_round_functions.bubble_leader(self, text_leader, text_leader)

					timer_linear.add(self, "study_4", 6, function (self)
						text_leader = lang_core.get_text(self, "_leader_shop_study_4", before_str, after_str, {name = name})
						game_core_round_functions.bubble_leader(self, text_leader, text_leader)

						timer_linear.add(self, "study_5", 6, function (self)
							visible_shop(self)
						end)
					end)
				end)
			end)

		end)
	else
		visible_shop(self)
	end
	
end

-- Окно увеличения награды за рекалму
function M.ads_reward(self, delay)
	-- Если есть реклама за вознаграждение
	local delay = delay or 0
	local text = ""
	
	local text = lang_core.get_text(self, "_leader_up_score_reward", before_str, after_str, values)
	game_core_round_functions.bubble_leader(self, text, text)

	-- Формруем призовые очки
	local gamer = game_core_gamers.get_player(self, storage_game.game.result.player_win_id)
	storage_game.game.result.xp = gamer.score
	storage_game.game.result.score = gamer.score

	timer_linear.add(self, "bubble", 2, function (self)
		local score = storage_game.game.result.score
		msg.post("/loader_gui", "visible", {
			id = "modal_reward_score",
			visible = true,
			type = hash("animated_close"),
			value = {score = score}
		})
	end)

	return delay
	
end

-- Окно результата
function M.result(self, player_id, type, delay)
	local delay = delay or 0
	local player_id = player_id or "player"
	local type_win = type or "full_word/last_player/open_symbol"
	local score = storage_game.game.result.xp
	local prizes = {}
	local stars = storage_game.game.result.stars or 0

	self.text = lang_core.get_text(self, "_leader_victory_to_next_game", before_str, after_str, values)

	game_core_round_functions.bubble_leader(self, self.text, self.text)

	--Добавляем призы игрока
	local prizes = {}

	-- Подготавливаем призы для победы
	for id, count in pairs(storage_game.game.result.prizes) do
		-- Для гуи окна победы
		table.insert(prizes, {id = id, count = count})
	end

	local current_level, next_level
	self.type_game = storage_game.game.round.type

	-- Записываем статиститку
	local items = {
		{id = "wins", operation = "add", value = 1},
		{id = "games", operation = "add", value = 1},
	}
	core_prorgress.set_stats(items)

	-- Если это уровень (если нет, то это турнир)
	if storage_game.game.round.level and storage_game.game.round.category then
		current_level = storage_game.game.round.level or false

		if storage_game.game.round.level.next_level then
			next_level = storage_game.game.round.level.next_level or false
		end

		-- Смотрим улучшил ли игрок свой результат
		local category_id = storage_game.game.round.category.id
		local level_id = current_level.id
		local old_stars = core_prorgress.get_progress_level(category_id, level_id)

		if old_stars == nil then
			-- Если нет звёзд, значит это новый пройденный уровень
			core_prorgress.set_progress_level(category_id, level_id, stars)

		elseif stars > old_stars then
			-- Если игрок улучшил результат
			core_prorgress.set_progress_level(category_id, level_id, stars)

		elseif stars <= old_stars then
			-- Результат такой же или меньше
			stars = old_stars

		end
	end

	-- Сохраняем результат На сервере
	data_handler.set_userdata(self, {
		progress = storage_player.progress,
		stats = storage_player.stats,
	})

	if current_level then
		current_level = {id = current_level.id, stars = stars, category_id = storage_game.game.round.category.id}
	end

	if next_level then
		next_level = {id = next_level.id, stars = next_level.stars, category_id = storage_game.game.round.category.id}
	else
		self.text_tablo = lang_core.get_text(self, "_leader_victory_complexity_all_company", before_str, after_str, values)
	end

	timer_linear.add(self, "bubble", 3, function (self)
		timer.delay(delay, false, function (self)
			msg.post("main:/core_screens", "game_result", {
				type = "win"
			})

			msg.post("main:/loader_gui", "visible", {
				id = "modal_result_single",
				visible = true,
				type = hash("popup"),
				value = {
					type_result = "win",
					score = score,
					prizes = prizes,
					current_level = current_level,
					-- если нет следующего уровня - вылезет плашка с пройденной компанией
					next_level = next_level,
				},
			})
			msg.post("game-room:/core_game", "event", {id = "set_to_start", text_tablo = self.text_tablo, animate_leader = 0.25})
		end)
	end)

end

-- Завершилась обработка sdk элементов
function M.sdk_completion(self)
	if storage_player.characteristic_points > 0 then
		-- Если есть очки прокачки
		msg.post("main:/loader_gui", "visible", {
			id = "modal_characteristics",
			visible = true,
			type = hash("animated_close"),
		})
	else
		-- Если нет очков прокачки
		if storage_sdk.leaderboard_personal then
			-- Если есть персональный рейтинг
			msg.post("/loader_gui", "visible", {
				id = "catalog_rating",
				visible = true,
				type = hash("animated_close"),
				value = {
					hidden_bg = false,
					type_rating = 'change_animated'
				}
			})
		else
			-- Нет персонального рейтинга
			-- Зачисляем случайные
			api_core_shop.add_random_shop(self, game_content_artifact)
			game_core_round_functions.result_all_showing(self, "win")
		end 
	end
end

-- Открылось окно победы
function M.visible_result(self)
	msg.post("/loader_gui", "visible", {
		id = "confetti",
		visible = false,
		type = hash("animated_close"),
	})

	msg.post("main:/loader_sdk", "game_over", {type = "win"})
end

-- СОбытия в результатах игры
function M.on_event(self, message)
	if message.id == "close_reward_score" then
		if message.score then
			self.player.score = message.score
			msg.post("game-room:/thumba_"..self.player.index, "update_score", {score = message.score})
		end

		-- Закрытие окна с удвоением приза
		M.shop(self, delay)

	elseif message.id == "close_game_shop" then
		-- Закрывают магазин призов
		M.result(self, delay)

	elseif message.id == "visible_game_result" then
		M.visible_result(self)

	elseif message.id == "visible_gui" then
		if message.component_id == "modal_characteristics" then
			self.last_text_tablo = self.text_tablo
			self.text_tablo = lang_core.get_text(self, "_tablo_up_level_points_characteristics", before_str, after_str, values)
			msg.post(storage_gui.components_visible.up_label_scene, "add_text", {text = self.text_tablo})
		end 
		
	elseif message.id == "close_gui" then
		if message.component_id == "modal_characteristics" then
			msg.post(storage_gui.components_visible.up_label_scene, "add_text", {text = self.last_text_tablo})
			-- Закрвается модальное окно характеристик
			if storage_sdk.leaderboard_personal then
				-- Если есть персональный рейтинг
				msg.post("/loader_gui", "visible", {
					id = "catalog_rating",
					visible = true,
					type = hash("animated_close"),
					value = {
						hidden_bg = false,
						type_rating = 'change_animated'
					}
				})
			else
				-- Нет персонального рейтинга
				-- Зачисляем случайные
				api_core_shop.add_random_shop(self, game_content_artifact)
				game_core_round_functions.result_all_showing(self, "win")
			end 

		elseif message.component_id == "catalog_rating" then
			-- Закрытие рейтинга
			-- Зачисляем случайные
			api_core_shop.add_random_shop(self, game_content_artifact)
			game_core_round_functions.result_all_showing(self, "win")
		end

	elseif message.id == "sdk_completion" then
		M.sdk_completion(self)
	end
end

return M