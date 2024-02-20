-- Отрисовка
local M = {}

local color = require("color-lib.color")

-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local game_content_artifact = require "main.game.content.game_content_artifact"
local storage_game = require "main.game.storage.storage_game"
local gui_input = require "main.gui.modules.gui_input"
local game_family_shop_functions = require "main.gui.game_gui.game_family_shop.modules.game_family_shop_functions"
local gui_animate = require "main.gui.modules.gui_animate"
local timer_linear = require "main.modules.timer_linear"

-- Показываем форму
function M.show(self)
	self.player_index = game_family_shop_functions.get_player_index(self)

	-- Есть игрок
	self.player = storage_game.family.settings.players[self.player_index]

	gui_lang.set_text_upper(self, self.nodes.title, "_buy_player", "", " "..self.player_index)

	M.catalog(self)
	M.player(self)

	if game_family_shop_functions.get_player_index(self) then
		gui_lang.set_text_upper(self, self.nodes.btn_save_title, "_next")
	else
		gui_lang.set_text_upper(self, self.nodes.btn_save_title, "_play")
	end

	gui_input.set_focus(self, #self.btns, function_post_focus, is_remove_other_focus)
end

-- Отрисовка каталога
function M.catalog(self)
	local items = game_content_artifact.get_catalog(self)

	-- Удаляем товары без магазина
	for i = #items, 1, -1 do
		local item = items[i]

		if not item.shop_family then
			table.remove(items, i)
		elseif item.id == "try_1" then
			item.price_buy = 250
		end
	end

	for i, item in ipairs(items) do
		M.item(self, i, item)
	end

	-- Кнопка начала игры
	self.btns[#self.btns + 1] = {
		id = "play", 
		type = "btn", 
		section = "play", 
		node = self.nodes.btn_save, 
		node_wrap = self.nodes.btn_save, 
		node_title = self.nodes.btn_save_title, 
		icon = "button_default_green_",
	}

	gui_input.init(self)
end

-- Отрисовка карточки
function M.item(self, i, item)
	local nodes = {
		wrap = gui.get_node("item_"..i.."_template/wrap"),
		title = gui.get_node("item_"..i.."_template/title"),
		description = gui.get_node("item_"..i.."_template/description"),
		icon = gui.get_node("item_"..i.."_template/icon"),
		error = gui.get_node("item_"..i.."_template/error"),
		title_purchased = gui.get_node("item_"..i.."_template/title_purchased"),
		title_price = gui.get_node("item_"..i.."_template/title_price"),
		icon_price = gui.get_node("item_"..i.."_template/icon_price"),
		btn_wrap = gui.get_node("item_"..i.."_template/btn_template/btn_wrap"),
		btn_title = gui.get_node("item_"..i.."_template/btn_template/btn_title"),
	}
	gui_lang.set_text_upper(self, nodes.title, item.title_id_string)
	gui_lang.set_text_upper(self, nodes.description, item.description_mini_id_string)
	gui_loyouts.play_flipbook(self, nodes.icon, item.icon)
	gui_loyouts.play_flipbook(self, nodes.icon_price, "icon_gold")
	gui_loyouts.set_enabled(self, nodes.error, false)
	gui_loyouts.set_text(self, nodes.title_price, item.price_buy)
	gui_lang.set_text_upper(self, nodes.btn_title, "_buy")

	-- КОличество у игрока
	local count = game_family_shop_functions.get_prizes(self, item.id)
	gui_loyouts.set_text(self, nodes.title_purchased, count)

	local balance = game_family_shop_functions.get_balance(self)

	self.btns[i + 1] = {
		id = item.id, -- айдишник для активации кнопки
		type = "btn", 
		is_card = true,
		section = i,  -- Секция, если одинаоквая, то можно переключаться вправо-влево
		on_set_function = function (self, btn, focus)
			--gui_lang.set_text_upper(self, self.nodes.description, item.description_id_string, before_str, after_str)
		end, -- функция при изменении фокуса
		node = nodes.wrap, -- нода с иконкой, подставляется icon
		wrap_node = nodes.btn_wrap, --обёртка, подставляется wrap_icon
		node_title = nodes.btn_title, -- Текст, окрашивается в зелёный
		node_wrap_title = nodes.title, -- Текст заголовка секции вокруг кнопки, окрашивается в зелёный
		scroll = self.scroll,
		icon = "bg_modal_", 
		wrap_icon = "btn_ellipse_green_",
		disabled = balance < item.price_buy
	}

	--gui_input.set_disabled(self, self.btns[btns_index], balance < item.price_buy) 
	gui_input.render_btns(self, self.btns)

end

-- Отрисовка карточки игрока
function M.player(self)
	gui_loyouts.play_flipbook(self, self.nodes.player_avatar, self.player.avatar)
	gui_loyouts.set_text(self, self.nodes.player_name, self.player.name)

	local balance = game_family_shop_functions.get_balance(self)
	gui_loyouts.set_text(self, self.nodes.player_score, balance)
end

-- Смена игрока
function M.next_player(self)
	-- Fybvfwbz
	local duration = 0.1

	timer_linear.add(self, "next_player", 0, function (self)
		self.blocking = true
		gui.animate(self.nodes.wrap, "color.w", 0, gui.EASING_LINEAR, 0.1)
	end)


	timer_linear.add(self, "next_player", 0.1, function (self)
		M.show(self)
		gui.animate(self.nodes.wrap, "color.w", 1, gui.EASING_LINEAR, 0.1)
	end)

	timer_linear.add(self, "next_player", 0.1, function (self)
		self.blocking = nil
	end)
end

return M