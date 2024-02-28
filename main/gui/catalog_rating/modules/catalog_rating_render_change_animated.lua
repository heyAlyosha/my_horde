-- Модуль отрисовки обычного типа рейтинга
local M = {}

local api_core_rating = require "main.core.api.api_core_rating"
local catalog_rating_render = require "main.gui.catalog_rating.modules.catalog_rating_render"
local game_content_text = require "main.game.content.game_content_text"
local gui_loader = require "main.gui.modules.gui_loader"
local gui_input = require "main.gui.modules.gui_input"
local storage_gui = require "main.storage.storage_gui"
local catalog_rating_animate = require "main.gui.catalog_rating.modules.catalog_rating_animate"
local catalog_rating_render_default = require "main.gui.catalog_rating.modules.catalog_rating_render_default"
local nakama = require "nakama.nakama"
local sound_render = require "main.sound.modules.sound_render"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local online_image = require "main.online.online_image"
local data_handler = require "main.data.data_handler"

function M.start(self, type_default_rating)
	-- Заголовок
	gui_lang.set_text_upper(self, self.nodes.title, "_your_place_top")

	-- В рейтинге с имзенением места игрока табы не нужны
	gui_loyouts.set_enabled(self, self.nodes.wrap_tabs, false)

	-- Включаем лоадер
	gui_loader.visible(true, node_wrap, node_icon, node_body, self)

	if not storage_gui.old_personal_rating then
		msg.post("/loader_gui", "visible", {
			id = "catalog_rating",
			visible = false
		})
	else
		data_handler.get_rating_personal(self, handler, count, function (self, err, result)
			if err then
				msg.post("/loader_gui", "visible", {
					id = "catalog_rating",
					visible = false
				})
			else
				self.new_rating = result
				M.render(self, self.type_default_rating)
			end
		end)
	end
end

-- Функция создания массива из старого и нового рейтинга с игроком
function M.generated_rating(self, old_rating, new_rating)
	local all_rating = {}
	-- Находим первый и последние элементы нового массива
	local first_elem_old = old_rating[1]
	local last_elem_old = old_rating[#old_rating]

	-- Создадим массив для кэша мест
	local old_ranks = {}
	for i = 1, #old_rating do
		local item = old_rating[i]
		old_ranks[item.rank] = i
	end

	-- Начинаем переносить новый рейтинг в старый рейтинг
	for i = #new_rating, 1, -1 do
		local new_item = new_rating[i]
		new_item.is_new = true

		-- Соединяем массивы
		if old_ranks[new_item.rank] then
			-- Если в старом рейтинге уже есть такое место
			-- Сливаем его
			local index_old_rating = old_ranks[new_item.rank]
			local old_item = old_rating[index_old_rating]

			if old_item.is_user and new_item.is_user then
				-- Если это место игрока заменяем их, но помечаем, что игрок старый
				new_item.is_new = false
				old_rating[index_old_rating] = new_item

			elseif old_item.is_user and not new_item.is_user then
				-- Если на старом месте игрок, а на новом нет, то оставлем старого игрока

			else
				-- Во всех остальных случаях просто заменяем
				old_rating[index_old_rating] = new_item
			end
		else
			-- Добавляем в конец массива
			old_rating[#old_rating + 1] = new_item
		end
	end

	-- Сортируем по ранку
	table.sort(old_rating, function (a, b) return (a.rank < b.rank) end)

	-- Ещё раз прочёсываем массив, находим новое и старое место игрока
	local old_gamer_index = false
	local new_gamer_index = false
	local new_gamer_item = false
	local index = 1

	while index <= #old_rating do
		local item = old_rating[index];

		if not item then
			-- Если после удаления позиции игрока стало меньше элмеентов в массиве, 
			-- то это послдений несуществующий
			break

		elseif item.is_user and item.is_new then
			-- Если это новая позиция игрока в рейтинге, то удаляем её и записываем позицию в таблице
			new_gamer_item = item
			new_gamer_index = index
			table.remove(old_rating, index)
			index = index - 1

		elseif item.is_user and not item.is_new then
			-- Если это старая позиция в рейтинге игрока, записываем её
			old_gamer_index = index
			

		elseif new_gamer_index then
			-- Если новая позиция пользователя уже была, смещаем рейтинг на 1 
			item.rank = item.rank - 1

		end

		index = index + 1
	end

	-- Сортируем по ранку
	return old_gamer_index, new_gamer_index, new_gamer_item, old_rating
end

-- Отрисовка рейтинга 
function M.render(self)
	-- Получаем данные для игроков
	local rating_users = {}
	nakama.sync(function ()
		local scroll_to_user = false
		local old_gamer_index, new_gamer_index, new_gamer_item, rating_users =  M.generated_rating(self, storage_gui.old_personal_rating, self.new_rating)
		local old_user_index = false
		local new_user_index = false
		-- Ищем старое и новое место игрока
		for i = 1, #rating_users do
			local item = rating_users[i]

			if item.is_user and item.is_new then
				new_user_index = i
			elseif item.is_user and not item.is_new then
				old_user_index = i
			end
		end

		-- Не отрисовываем новое место игрока
		--[[
		local not_render = {}
		-- Нужно ли сдвигать
		local not_render_shift = false
		
		if new_user_index and old_user_index then
			local dif = old_user_index - new_user_index
			if dif ~= 1 and dif ~= -1 then
				--table.insert(not_render, new_user_index)
				not_render_shift = true
			end
			table.insert(not_render, new_user_index)
		end
		--]]

		-- Генерируем карточки каталога
		local params = {
			margin = 5,
			node_for_clone = self.nodes.node_for_clone,
			node_catalog_view = self.nodes.catalog_view,
			node_catalog_content = self.nodes.catalog_content,
			node_catalog_input = self.nodes.catalog_input,
			node_scroll = self.nodes.catalog,
			node_scroll_wrap = self.nodes.scroll_wrap,
			node_scroll_caret = self.nodes.scroll_caret,
			not_render = not_render,
			not_render_shift = true
		}

		self.cards = catalog_rating_render.create_catalog(self, self.id_catalog, rating_users, params)

		-- Снимаем кнопки
		for i = 1, #self.cards do
			local item = self.cards[i]

			item.avatar_node = item.nodes[hash("item_template/avatar_img")]
			item.node = item.nodes[hash("item_template/wrap")]
			item.avatar_url = item.avatar_url
		end

		-- Начинаем анимировать
		if not new_gamer_index then
			-- Если игрок остался на прежнем месте
			-- скроллим до него
			catalog_rating_render.scroll_to_index(self, old_user_index, true)
			gui_loader.visible(false, node_wrap, node_icon, node_body, self)

			-- Анимация пульсирования карточки игрока на месте
			local current_node = self.cards[old_user_index].nodes[hash("item_template/wrap")]
			msg.post("main:/sound", "play", {sound_id = "animate_rating_change_place"})
			gui.animate(current_node, "scale", gui.get_scale(current_node)*1.1, gui.EASING_LINEAR, 0.25, 0.5 , nil, gui.PLAYBACK_ONCE_PINGPONG)

			-- Закрываем рейтинг через некоторое время
			timer.delay(3, false, function (self)
				msg.post("/loader_gui", "visible", {
					id = "catalog_rating",
					visible = false,
					type = hash("animated_close"),
					value = {
						type_rating = 'change_animated'
					}
				})
			end)
		else
			-- Если игрок изменился в рейтинге
			-- Начинаем анимацию
			gui_loader.visible(false, node_wrap, node_icon, node_body, self)

			catalog_rating_animate.change_rating(self, old_gamer_index, new_gamer_index, function (self)
				-- После завершения анимации закрываем
				timer.delay(1, false, function (self)
					msg.post("/loader_gui", "visible", {
						id = "catalog_rating",
						visible = false,
						type = hash("animated_close"),
						value = {
							type_rating = 'change_animated'
						}
					})
				end)
			end)
		end

		M.render_avatars(self)
		self["scroll_"..self.id_catalog].on_scroll:subscribe(function(_, point)
			M.render_avatars(self)
		end)

		gui_input.set_focus(self, 1)
	end)
end

-- Отрисовка аватарок у видимых элементов
function M.render_avatars(self)
	
	for i = 1, #self.cards do
		local item = self.cards[i]
		if item.avatar_url and not item.render_avatar and self["scroll_"..self.id_catalog]:is_node_in_view(item.node) then

			online_image.set_texture(self, item.avatar_node, item.avatar_url)
			item.render_avatar = true
		end
	end
end


return M