-- Функции
local M = {}

local gui_scale = require "main.gui.modules.gui_scale"
local color = require("color-lib.color")
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local gui_text = require "main.gui.modules.gui_text"


local game_content_reward = require "main.game.content.game_content_reward"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

-- Показываем
function M.visible(self, type, data)
	local reward_setting = game_content_reward.rewards.visit
	local reward = {coins = 0, score = 0}
	local day = data.day

	-- Заголовок
	local title = lang_core.get_text(self, "_title_reward_days", before_str, after_str, {days = day})
	gui_loyouts.set_text(self, self.nodes.title, title)

	-- Отрисовываем предыдущй сундук
	-- Если это первый день
	if day <= 1 then
		gui_loyouts.set_enabled(self, self.nodes.prev_gift.wrap, false)
	else
		local day_prev = day - 1
		reward.coins = reward_setting.coins * day_prev
		reward.score = reward_setting.score * day_prev

		gui_loyouts.set_text(self, self.nodes.prev_gift.day, "День "..day_prev)
		gui_loyouts.set_rich_text(self, self.nodes.prev_gift.title,  ""..reward.coins .. "<img=gui:icon_gold,40/>  "..reward.score .. "<img=gui:icon_score,40/>")
	end

	-- Отрисовываем следующий сундук
	local day_next = day + 1

	reward.coins = reward_setting.coins * day_next
	reward.score = reward_setting.score * day_next

	gui_loyouts.set_text(self, self.nodes.next_gift.day, "День "..day_next)
	gui_loyouts.set_rich_text(self, self.nodes.next_gift.title, ""..reward.coins .. "<img=gui:icon_gold,40/>  "..reward.score .. "<img=gui:icon_score,40/>")

	-- Отрисовываем текущий сундук
	reward.coins = reward_setting.coins * day
	reward.score = reward_setting.score * day
	-- Выставляем элементы на начало
	-- Ставим
	gui_loyouts.set_rich_text(self, self.nodes.current_gift.title, "<color=lime>+"..reward.coins .. "<img=gui:icon_gold,40/>  +"..reward.score .. "<img=gui:icon_score,40/></color>")
	gui_loyouts.set_text(self, self.nodes.current_gift.day, "День "..day)

	-- Начинаем анимацию 
	local delay = 0
	-- Анимация сундука
	timer.delay(0.5, false, function (self)
		msg.post("main:/sound", "play", {sound_id = "modal_top_3_2"})
		gui_animate.gift(self, name_template, function (self)
			-- Выпадает куча из сундука
			msg.post("main:/sound", "play", {sound_id = "sold_bulb_1"})

			local end_position = gui.get_screen_position(self.nodes.gift_target)

			msg.post("/loader_gui", "set_status", {
				id = "add_balance",
				type = "stack", -- Обычный перелёт или куча
				setting_stack = {
					score = reward.score,
					coins = reward.coins,
					end_position = end_position,
					height_flight = 200,
					random_height = 50,
					random_width = 400,
					animate_stack = true
				}, -- Настройки для кучи
				start_position = gui.get_screen_position(self.nodes.respawn),
				value = 0
			})

			-- Анимация кнопки и награды под сандуком
			--[[
			gui_animate.show_elem_popping(self, self.nodes.current_gift.title, 0.25, 2.5, function (self)
				gui_animate.show_elem_popping(self, self.nodes.btn_confirm, 0.25, 0.25, function (self)
					self.disabled = false
					gui_input.set_focus(self, 1)

					timer.delay(7.5, false, function (self)
						M.hidden(self)
					end)
				end)
			end)
			]]--

		end, duration)
	end)
	
end

-- Функция закрытия
function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = "modal_reward_visit",
			visible = false,
			type = hash("animated_close")
		})
	end)
end
	
return M