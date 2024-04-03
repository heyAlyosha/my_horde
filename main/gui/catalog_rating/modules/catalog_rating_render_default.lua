-- Модуль отрисовки обычного типа рейтинга
local M = {}

local api_core_rating = require "main.core.api.api_core_rating"
local catalog_rating_render = require "main.gui.catalog_rating.modules.catalog_rating_render"

local gui_loader = require "main.gui.modules.gui_loader"
local gui_input = require "main.gui.modules.gui_input"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local nakama = require "nakama.nakama"
local storage_player = require "main.storage.storage_player"
local nakama_api_rating = require "main.online.nakama.api.nakama_api_rating"
local api_player = require "main.game.api.api_player"
local online_image = require "main.online.online_image"
local storage_sdk = require "main.storage.storage_sdk"

function M.start(self, type_default_rating)
	-- Тип обычного рейтинга
	self.type_default_rating = self.type_default_rating or "top"

	-- Типы рейтинга
	self.types_default_rating = {
		top = {id_string = "_top_best_gamers"},
		personal = {id_string = "_my_place_top"},
		sdk = {id_string = "_top_gamers_yandex_game"},
	}
	
	-- Если это обычный рейтинг, то добавляем кнопки-табы с типами рейтинга
	gui.set_enabled(self.nodes.wrap_tabs, true)
	self.btns[2] = {id = "top", type = "btn", section = "tabs", node = self.nodes.btn_top_type_rating, wrap_node = self.nodes.btn_top_type_rating,  node_title = self.nodes.btn_top_type_rating_title,  icon = "main_menu_btn_", wrap_icon = 'main_menu_btn_', node_bg = self.nodes.btn_top_type_rating}
	self.btns[3] = {id = "personal", type = "btn", section = "tabs",  node = self.nodes.btn_personal_type_rating,  wrap_node = self.nodes.btn_personal_type_rating,  node_title = self.nodes.btn_personal_type_rating_title,  icon = "main_menu_btn_",  wrap_icon = 'main_menu_btn_', node_bg = self.nodes.btn_personal_type_rating}
	--self.btns[4] = {id = "sdk", type = "btn", section = "tabs",  node = self.nodes.btn_yandex_type_rating, wrap_node = self.nodes.btn_yandex_type_rating, node_title = self.nodes.btn_yandex_type_rating_title, icon = "main_menu_btn_", wrap_icon = 'main_menu_btn_', node_bg = self.nodes.btn_yandex_type_rating}

	-- Текст в кнопках
	gui_lang.set_text(self, self.nodes.btn_top_type_rating_title, "_best_players")
	gui_lang.set_text(self, self.nodes.btn_personal_type_rating_title, "_my_place")
	gui_lang.set_text(self, self.nodes.btn_yandex_type_rating_title, "_top_yandex_game")

	M.render(self, self.type_default_rating)
end

function M.render_cards(self, type_default_rating)
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
	}
	self.cards = catalog_rating_render.create_catalog(self, self.id_catalog, self.rating_users, params)

	gui_loyouts.set_enabled(self, self.nodes.catalog_content, true)
	-- Снимаем кнопки
	for i = 1, #self.cards do
		local item = self.cards[i]

		local btn = {
			id = i.."_"..item.id, 
			type = "btn", 
			section = "card_"..item.cols, 
			node = item.nodes[hash("item_template/wrap")],
			node_title = item.nodes[hash("item_template/title")],
			wrap_node = item.nodes[hash("item_template/wrap")],
			avatar_node = item.nodes[hash("item_template/avatar_img")],
			avatar_url = item.avatar_url,
			icon = "btn_ellipse_green_",
			wrap_icon = "bg_modal_",
			is_item = true,
			is_card = true,
			scroll = self["scroll_"..self.id_catalog],
		}

		table.insert(self.btns, btn)
	end

	-- Смотрим, нужно ли пролистывать каталог к элементу игрока или нет
	if self.scroll_to_user then
		self.user_i, self.user_item = catalog_rating_render.scroll_to_user(self, self.id_catalog, self.rating_users)
		--gui_input.set_focus(self, user_i + 4)
		gui_input.set_focus(self, 3)

	elseif self.type_default_rating == "top" then
		gui_input.set_focus(self, 2)

	elseif self.type_default_rating == "sdk" then
		gui_input.set_focus(self, 4)

	else
		gui_input.set_focus(self, 4)

	end

	M.render_avatars(self)

	self["scroll_"..self.id_catalog].on_scroll:subscribe(function(_, point)
		M.render_avatars(self)
	end)

	-- Убираем лоадер
	gui_loader.visible(false, nil, nil, nil, self)
end

-- Отрисовка обычного рейтинга
function M.render(self, type_default_rating)
	-- Получаем статичный контент для отрисовки
	self.type_default_rating = type_default_rating
	self.content_rating = self.types_default_rating[self.type_default_rating]

	-- Заголовок
	gui_lang.set_text_upper(self, self.nodes.title, self.content_rating.id_string)

	-- Включаем лоадер
	gui_loader.visible(true, nil, nil, nil, self)

	-- Получаем данные для игроков
	self.rating_users = {}
	-- Обновляем рейтинг игрока
	local update_inteface = true
	api_player.get_rating(self, update_inteface, nakama_sync)

	self.scroll_to_user = false
	if self.type_default_rating == "top" then
		api_core_rating.get_rating_top(self, count, function (self, err, result)
			if err then
				catalog_rating_render.error(self, err)

			else
				self.rating_users = result
				M.render_cards(self, self.type_default_rating)

			end
		end)

	elseif self.type_default_rating == "personal" then
		api_core_rating.get_rating_gamer(self, count, function (self, err, result)
			if err then
				catalog_rating_render.error(self, err)

			else
				self.rating_users = result
				self.scroll_to_user = true
				M.render_cards(self, self.type_default_rating)

			end

		end)

	elseif self.type_default_rating == "sdk" then
		api_core_rating.get_rating_sdk(self, count, function (self, err, rating_users)
			self.rating_users = rating_users
			M.render_cards(self, self.type_default_rating)
		end)

		return
	end
	
end

-- Отрисовка аватарок у видимых элементов
function M.render_avatars(self)
	for i = 1, #self.btns do
		local btn = self.btns[i]
		
		if btn.avatar_url and not btn.render_avatar and self["scroll_"..self.id_catalog]:is_node_in_view(btn.node) then
			online_image.set_texture(self, btn.avatar_node, btn.avatar_url)
			btn.render_avatar = true
		end
	end
end

return M