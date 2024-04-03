-- Анимации для блока с результатами
local M = {}

local gui_size = require 'main.gui.modules.gui_size'
local gui_animate = require "main.gui.modules.gui_animate"
local timer_linear = require "main.modules.timer_linear"
local gui_integer = require "main.gui.modules.gui_integer"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local live_update_atlas = require "main.game.live_update.atlas.live_update_atlas"
local gui_size = require "main.gui.modules.gui_size"

-- Анимация появления призов
function M.animate_prizes(self, node_prize, node_wrap, node_more, max_prizes, delay, params, data)
	local params = {margin = 0, duration = 0.2, delay = 0.35}
	local add_score = 150
	local interval_add_score = 0.1

	-- Формируем таблицу с призами
	local prizes = data.prizes
	table.insert(prizes, 1, {id = 'score', count = data.score})
	local more_count = 0
	local delay = delay

	for i = 1, 9 do
		gui_loyouts.set_enabled(self, gui.get_node("item_"..i.."_template/wrap"), false)
	end

	for i, prize in ipairs(prizes) do
		if i > max_prizes then
			
			more_count = more_count + prize.count
		else
			local nodes = {
				wrap = gui.get_node("item_"..i.."_template/wrap"),
				count = gui.get_node("item_"..i.."_template/count"),
				prize_img = gui.get_node("item_"..i.."_template/prize_img"),
				img_size = gui.get_node("item_"..i.."_template/img_size"),
				loader_img = gui.get_node("item_"..i.."_template/loader_icon_template/loader_icon"),
			}

			local node_prize_wrap = nodes.wrap
			local horisontal_params = gui_size.get_center_horisontal_list(self, node_wrap, node_prize_wrap, params.margin)

			-- Подставляем данные
			gui_loyouts.set_text(self, nodes.count, prize.count)

			if prize.id == 'score' then
				gui_loyouts.set_texture(self, nodes.prize_img, 'gui')
				gui_loyouts.play_flipbook(self, nodes.prize_img, "icon_score")
				local node_wrap = nodes.img_size
				gui_size.play_flipbook_ratio(self, nodes.prize_img, node_wrap, "icon_score", width, height, not_loyouts)

				gui_loyouts.set_enabled(self, node_prize_wrap, false)
				timer_linear.add(self, "result_single", params.delay, function (self)
					msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
					gui_animate.show_elem_popping(self, node_prize_wrap, params.duration, delay, function (self)
						gui_loyouts.set_enabled(self, node_prize_wrap, true)
					end)

				end)

				-- Перечисляем игроку очки
				local count_score = prize.count

				gui_integer.to_parts(self, prize.count, add_score, function (self, value)
					timer_linear.add(self, "result_single", interval_add_score, function (self)
						msg.post("/loader_gui", "set_status", {
							id = "add_balance",
							type = "score",
							start_position = gui.get_screen_position(node_prize_wrap),
							value = value
						})
						msg.post("main:/sound", "play", {sound_id = "game_result_leaders_1"})
					end)
				end)

			else
				local prize_content = game_content_prize.get_prize(prize.id)
				if not prize_content then
					break
				end

				local node_img = nodes.prize_img
				local node_loader = nodes.loader_img
				local atlas_id =  "prizes_mini" 
				
				live_update_atlas.render_loader_gui(self, node_img, node_loader, atlas_id, function (self)
					gui_loyouts.set_texture(self, nodes.prize_img, atlas_id)
					local node_wrap = nodes.img_size
					gui_size.play_flipbook_ratio(self, nodes.prize_img, node_wrap, prize_content.icon, width, height, not_loyouts)
				end)
				

				local function_end_animation = value

				-- Анимация сдвига элементов под новый приз
				self['position_wrap_'..i] = vmath.vector3(horisontal_params.position_wrap.x, horisontal_params.position_wrap.y, horisontal_params.position_wrap.z)

				self.index_elem = 1

				timer_linear.add(self, "result_single", params.delay, function (self)
					self.index_elem = self.index_elem + 1
					local current_position = self['position_wrap_'..self.index_elem]
					if current_position then
						current_position.x = current_position.x - 40
						gui.animate(node_wrap, 'position.x', current_position.x, gui.EASING_LINEAR, params.duration, 0, function (self)
							gui_loyouts.set_position(self, node_wrap, current_position.x, "x")
							gui_loyouts.set_enabled(self, node_wrap, true)
						end)
					end
				end)

				gui_loyouts.set_enabled(self, node_prize_wrap, false)
				timer_linear.add(self, "result_single", 0, function (self)
					msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})
					gui_animate.show_elem_popping(self, node_prize_wrap, params.duration, delay, function (self)
						gui_loyouts.set_enabled(self, node_prize_wrap, true)
					end)

				end)

			end

			gui_loyouts.set_position(self, node_prize_wrap, horisontal_params.start_position)
		end
	end

	-- Пауза

	-- Отрисовываем оставшиеся призы
	local more_text = lang_core.get_text(self, "_more_prizes", before_str, after_str, {more_count = more_count})

	--gui.set_enabled(node_more, false)
	if more_count > 0 then
		gui_loyouts.set_text(self, node_more, more_text)
		gui_loyouts.set_enabled(self, node_more, false)
		timer_linear.add(self, "result_single", params.duration * 2, function (self)
			msg.post("main:/sound", "play", {sound_id = "game_result_open"})
			gui_animate.show_elem_popping(self, node_more, params.duration, delay, function (self)
				gui_loyouts.set_enabled(self, node_more, true)
			end)
		end)
	else
		gui_loyouts.set_enabled(self, node_more, false)
	end

	return delay
end

-- Анимация плашки компании при прохождении
function M.animate_company_success(self, template_name_company, template_name_aureol, duration)
	local node_company = gui.get_node(template_name_company..'/wrap')
	local node_icon = gui.get_node(template_name_company..'/success_icon_template/success_wrap')
	local delay = 0
	local duration = duration or 3

	-- Появляется плашка с компанией
	gui.set_enabled(node_company, false)
	timer_linear.add(self, "result_single", 0.25, function (self)
		msg.post("main:/sound", "play", {sound_id = "game_result_trophys_1"})

		duration = duration - 0.25
		gui_animate.show_elem_popping(self, node_company, 0.25, 0)
		
	end)

	timer_linear.add(self, "result_single", 0.25, function (self)
		-- Увеличиваем
		msg.post("main:/sound", "play", {sound_id = "modal_top_3_2"})
		gui.animate(node_company, 'scale', vmath.vector3(1.2), gui.EASING_LINEAR, 0.1)
		gui_animate.areol(self, template_name_aureol, speed_to_second, duration - 1, nil, 1.3)
	end)
	

	-- устанавливаем галочку, что пройдено
	gui.set_enabled(node_icon, false)
	timer_linear.add(self, "result_single", 0.5, function (self)
		gui_animate.show_elem_popping(self, node_icon, 0.25, 0)
	end)

	timer_linear.add(self, "result_single", 1.5, function (self)
		gui.cancel_animation(node_company, "scale")
		gui.set_scale(node_company, vmath.vector3(1.2))
		gui.animate(node_company, 'scale', vmath.vector3(1), gui.EASING_LINEAR, 0.25)
	end)

	return delay
end
return M