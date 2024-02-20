-- Отрисовка победы в окне результатов игры
local M = {}

local druid = require("druid.druid")
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local storage_game = require "main.game.storage.storage_game"
local gui_animate = require "main.gui.modules.gui_animate"
local gui_manager = require "main.gui.modules.gui_manager"
local gui_render = require "main.gui.modules.gui_render"
local gui_text = require "main.gui.modules.gui_text"
local gui_size = require 'main.gui.modules.gui_size'
local color = require "color-lib.color"
local timer_linear = require "main.modules.timer_linear"

-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

-- Отрисовка
function M.all(self)
	self.player_win_id = storage_game.game.result.player_win_id
	self.blocking_btn = true

	for i, player in ipairs(storage_game.family.settings.players) do
		if player.id == self.player_win_id then
			self.player = player
		end
	end

	gui_lang.set_text_upper(self, self.nodes.title, "_result_game", before_str, after_str)
	gui_lang.set_text_upper(self, self.nodes.win_title, "_winer", before_str, after_str)
	gui_lang.set_text_upper(self, self.nodes.rating_title, "_rating_gamers", before_str, after_str)

	gui_loyouts.play_flipbook(self, self.nodes.win_player_avatar, self.player.avatar)
	gui_loyouts.set_text(self, self.nodes.win_player_name, self.player.name)

	M.rating(self)

	gui_loyouts.set_enabled(self, self.nodes.title_wrap, false)
	gui_loyouts.set_enabled(self, self.nodes.wrap_win, false)
	gui_loyouts.set_enabled(self, self.nodes.wrap_players, false)
	gui_loyouts.set_enabled(self, self.nodes.btns_win, false)

	M.animate_visible(self)
end

-- Отрисовываем рейтинг
function M.rating(self)
	self.positions_rating = {}

	table.sort(storage_game.family.rating, function (a, b)
		if  a.score > b.score then
			return true
		end
		return false
	end)

	for i, item in ipairs(storage_game.family.rating) do
		local nodes = {
			wrap = gui.get_node("rating_item_"..i.."_template/wrap"),
			wins = gui.get_node("rating_item_"..i.."_template/ranks"),
			avatar = gui.get_node("rating_item_"..i.."_template/avatar_img"),
			title = gui.get_node("rating_item_"..i.."_template/title"),
			score = gui.get_node("rating_item_"..i.."_template/title_price")
		}
		item.nodes = nodes

		gui_loyouts.set_text(self, nodes.title, item.name)
		gui_loyouts.set_text(self, nodes.wins, item.wins)
		gui_loyouts.set_text(self, nodes.score, item.score)
		gui_loyouts.play_flipbook(self, nodes.avatar, item.avatar)

		self.positions_rating[i] = gui.get_position(nodes.wrap)
	end
end

-- Анимация рейтинг
function M.animate_visible(self)
	timer_linear.add(self, "result", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, self.nodes.title_wrap, duration, delay, function_end_animation)
	end)

	timer_linear.add(self, "result", 0.25, function (self)
		gui_animate.show_elem_popping(self, self.nodes.wrap_win, duration, delay, function_end_animation)
	end)

	timer_linear.add(self, "result", 0.25, function (self)
		gui_animate.pulse(self, self.nodes.wrap_win, scale, duration, delay, function_end_animation)
	end)

	timer_linear.add(self, "result", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "modal_top_3_2"})
		gui_animate.areol(self, "areol_template", speed_to_second, "loop", function_end, vmath.vector3(0.4))
	end)

	timer_linear.add(self, "result", 0.5, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
		gui_animate.show_elem_popping(self, self.nodes.wrap_players, duration, delay, function_end_animation)
		
	end)

	timer_linear.add(self, "result", 0.75, function (self)
		M.animate_add_score(self)

		if self.change_rating then
			-- Если рейтинг изменился, запускаем анимацию
			timer_linear.add(self, "rating", 0.75, function (self)
				for i, item in ipairs(storage_game.family.rating) do
					local position = self.positions_rating[i]

					gui.animate(item.nodes.wrap, "position", position, gui.EASING_LINEAR, 0.2)
				end
				msg.post("main:/sound", "play", { sound_id = "popup_hidden"})
			end)
			

		end

		timer_linear.add(self, "rating", 0.5, function (self)
			msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
			gui_animate.show_elem_popping(self, self.nodes.btns_win, duration, delay, function_end_animation)
			
			
		end)

		timer_linear.add(self, "rating", 0.25, function (self)
			gui_input.set_focus(self, 3)
			gui_animate.pulse_loop(self, self.btns[3].node, delay)
			self.blocking_btn = nil
		end)

	end)

end

-- Анимация прибавления очков победителю
function M.animate_add_score(self)
	-- Добавляем очки победителю
	for i, item in ipairs(storage_game.family.rating) do
		if item.player_id == self.player_win_id then
			storage_game.family.rating[i].score = storage_game.family.rating[i].score + storage_game.game.result.score
			storage_game.family.rating[i].wins = storage_game.family.rating[i].wins + 1

			msg.post("main:/sound", "play", {sound_id = "add_gold_1"})
			local node_wrap = item.nodes.wrap
			local node_text = item.nodes.score
			local color_text = color.lime
			local delay = 0.0001
			local duration = 1
			local sound
			local new_text = storage_game.family.rating[i].score
			local wins = storage_game.family.rating[i].wins
			local scale_wrap = 1.5
			gui_loyouts.set_text(self, item.nodes.score, new_text)
			gui_loyouts.set_text(self, item.nodes.wins, wins)
			gui_animate.pulse_update_count(self, node_text, node_text, duration, delay, color_text, sound, new_text, function (self)
				
			end, scale_wrap)

			break
		end
	end

	-- Сортируме рейтинг после изменения
	self.old_rating = {storage_game.family.rating[1].player_id, storage_game.family.rating[2].player_id, storage_game.family.rating[3].player_id}
	table.sort(storage_game.family.rating, function (a, b)
		if  a.score > b.score then
			return true
		end
		return false
	end)

	self.new_rating = {storage_game.family.rating[1].player_id, storage_game.family.rating[2].player_id, storage_game.family.rating[3].player_id}

	-- Смотрим изменился ли рейтинг
	self.change_rating = self.old_rating[1] ~= self.new_rating[1] or self.old_rating[2] ~= self.new_rating[2] or self.old_rating[3] ~= self.new_rating[3]

	
end

return M