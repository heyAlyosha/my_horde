-- Функции анимации
local M = {}

local catalog_rating_render = require "main.gui.catalog_rating.modules.catalog_rating_render"
local sound_render = require "main.sound.modules.sound_render"

-- наимация изменения позиции
function M.change_rating(self, start_index, end_index, function_end)
	self.current_index = start_index
	self.start_index = start_index
	self.end_index = end_index
	self.add_num = 1
	self.current_card = self.cards[self.current_index]
	delay = 0.5

	-- Определяем прибавлять или убавлять место
	if self.current_index <  self.end_index then
		self.add_num = 1
	else
		self.add_num = -1
	end

	-- скроллим до места игркоа
	catalog_rating_render.scroll_to_index(self, self.current_index, true)

	-- Начинаем анимацию передвижения
	timer.delay(delay, true, function (self, handle)
		self.next_index = self.current_index + self.add_num
		local next_card = self.cards[self.next_index]

		local current_node = self.current_card.nodes[hash("item_template/wrap")]
		local next_node = next_card.nodes[hash("item_template/wrap")]

		-- Ставим  элементы друг над другом для анимации перелёта
		gui.move_above(current_node,next_node)

		-- Узнаём позиции элементов, которые меняем местами
		local next_position = gui.get_position(next_node)
		local current_position = gui.get_position(current_node)		

		-- Обычный перенос
		-- Анимация переноса карточки игрока
		msg.post("main:/sound", "play", {sound_id = "animate_rating_change_place"})
		gui.animate(current_node, "position.y", next_position.y, gui.EASING_LINEAR, delay * 0.5)
		gui.animate(current_node, "scale", gui.get_scale(current_node)*1.1, gui.EASING_LINEAR, delay * 0.5, 0 , nil, gui.PLAYBACK_ONCE_PINGPONG)
		-- Анимация  карточки игрока, которого оттеснили
		gui.animate(next_node, "position.y", current_position.y, gui.EASING_LINEAR, delay * 0.5)

		catalog_rating_render.scroll_to_index(self, self.current_index + self.add_num)

		-- получаем следующий ранк для игрока
		local current_rank = next_card.rank
		local next_rank = self.current_card.rank
		-- Ставим новый ранк для игрока
		
		self.current_card.rank = current_rank
		next_card.rank = next_rank

		gui.set_text(self.current_card.nodes[hash("item_template/ranks")], self.current_card.rank)
		gui.set_text(next_card.nodes[hash("item_template/ranks")], next_rank)
		
		catalog_rating_render.render_title_and_icon(self, self.current_card)
		catalog_rating_render.render_title_and_icon(self, next_card)

		self.current_index = self.next_index

		-- Если пользователь встал на место, то заканчиваем анимацию
		if self.current_index == self.end_index then
			timer.cancel(handle)
			msg.post("main:/sound", "play", {sound_id = "rating_animate_changed_success"})
			
			if function_end then
				function_end()
			end
		end
	end)
end

return M