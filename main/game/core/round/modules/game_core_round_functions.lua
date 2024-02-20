-- Функции для игры
local M = {}

local storage_game = require "main.game.storage.storage_game"
local game_content_artifact = require "main.game.content.game_content_artifact"
local game_core_gamers = require "main.game.core.game_core_gamers"
local color = require("color-lib.color")
local storage_gui = require "main.storage.storage_gui"
local storage_sdk = require "main.storage.storage_sdk" 

-- Реплика ведущего
function M.bubble_leader(self, text, text_tablo, callback)
	local text = text or ""
	
	--position = rendercam.world_to_screen(position)
	--position = rendercam.screen_to_gui(position.x, position.y)

	local position = go.get_world_position("game-room:/leader_dialog_spawn")

	msg.post("game-room:/loader_gui", "visible", { id = "dialog_bubble", visible = false,})
	msg.post("main:/sound", "play", {sound_id = "game_result_leaderboard"})
	msg.post("game-room:/loader_gui", "visible", {
		id = "dialog_bubble",
		visible = true,
		type = hash("animated_close"),
		position = position,
		text = text,
		side = "right",
	})
	

	if text_tablo and storage_gui.components_visible.up_label_scene then
		msg.post(storage_gui.components_visible.up_label_scene, "add_text", {text = text_tablo})
	end
end

-- Получаем время на прочитывание текста
function M.get_show_text_duration(self, text)
	local min_visible_second = 2
	local visible_second_symbol = 0.05

	return min_visible_second + visible_second_symbol * utf8.len(text)

end

-- Показываем вопрос
function M.show_quest(self, is_first, function_end)
	local text = storage_game.game.round.quest
	local duration = M.get_show_text_duration(self, text)
	local type_animation = "default"
	if is_first then
		type_animation = "top"
	end

	
	if storage_game.game.round.quest_type == "image" then
		duration = duration + 1
		msg.post("main:/loader_gui", "visible", {
			id = "quest_image",
			visible = true,
			type = hash("animated_close"),
			value = {
				color = color.cyan,
				type_animation = type_animation,
				title = storage_game.game.round.quest
			}
		})

		timer.delay(duration, false, function (self)
			msg.post("main:/loader_gui", "visible", {
				id = "quest_image",
				visible = false,
				type = hash("animated_close"),
			})
			if function_end then
				timer.delay(0.25, false, function_end)
			end
		end)

	elseif storage_game.game.round.quest_type == "music" then
		duration = self.duration_show or 10
		msg.post("main:/loader_gui", "visible", {id = "quest_music", 
			visible = true, 
			value = {
				title = storage_game.game.round.quest,
				duration = self.duration_show,
				color = color.cyan,
				type_animation = type_animation,
			}
		})

		timer.delay(duration, false, function (self)
			msg.post("main:/loader_gui", "visible", {
				id = "quest_music",
				visible = false,
				type = hash("animated_close"),
			})
			if function_end then
				timer.delay(0.25, false, function_end)
			end
		end)
	else
		msg.post("main:/loader_gui", "visible", {
			id = "main_title",
			visible = true,
			type = hash("animated_close"),
			value = {
				color = color.cyan,
				type_animation = type_animation,
				title = storage_game.game.round.quest
			}
		})

		timer.delay(duration, false, function (self)
			msg.post("main:/loader_gui", "visible", {
				id = "main_title",
				visible = false,
				type = hash("animated_close"),
			})
			if function_end then
				timer.delay(0.25, false, function_end)
			end
		end)
	end

	

	return duration
end

-- Открыто ли слово
function M.is_open_word(self)
	-- Проверяем остались ли закрытые буквы
	for i = 1, #storage_game.game.round.tablo do
		local item = storage_game.game.round.tablo[i]
		
		if not item.open then
			return false
		end
	end

	return true
end

-- Есть ли оберег
function M.is_obereg(self, player_id, is_game, is_reward)
	local player_id = player_id or "player"
	local is_game = is_game or true
	local player = game_core_gamers.get_player(self, player_id, game_content_wheel)

	if storage_game.game.round.type == "family" then
		is_reward = false

	else
		if is_reward == nil then
			is_reward = storage_sdk.stats.is_ads_reward
		else
			is_reward = is_reward
		end

	end

	if player.type == "bot" then
		is_reward = false
	end

	local artifact = game_content_artifact.get_item("try_1", player_id, is_game, is_reward)

	return not self.skip_obereg and (artifact.count > 0 or artifact.is_reward)
end

-- Показались все окна в реузльтатах игры
function M.result_all_showing(self, type)
	msg.post("main:/core_study", "event", {id = "result_all_showing", type = type})
end

return M