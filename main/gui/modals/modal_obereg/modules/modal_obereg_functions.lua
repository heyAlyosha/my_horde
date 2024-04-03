-- Функции
local M = {}

local gui_scale = require "main.gui.modules.gui_scale"
local color = require("color-lib.color")
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
local gui_text = require "main.gui.modules.gui_text"


local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"
local gui_loyouts = require "main.gui.modules.gui_loyouts"

-- Показываем
function M.visible(self, type, data)
	-- Фон
	msg.post("/loader_gui", "visible", {
		id = "bg",
		visible = true,
		parent_id = self.id,
		type = hash("animated_close"),
	})

	local player_id = data.player_id
	local is_game = data.is_game
	local is_reward = data.is_reward

	self.type = type
	self.player_id = player_id
	self.is_game = is_game

	local animate_btn 

	local text

	-- Типы использования оберега
	if self.type == "skipping" then
		-- Пропуск хода
		self.content = lang_core.get_text(self, self.types.skipping, before_str, after_str, values)

	elseif self.type == "bankrupt" then
		-- Cектор банкрот
		self.content = lang_core.get_text(self, self.types.bankrupt, before_str, after_str, {score = data.score})

	elseif self.type == "trap" then
		-- Капкан 
		self.trap = game_content_artifact.get_item(data.trap_id, player_id, is_game, is_reward)
		local values = {score = self.trap.value.score}

		-- Пропускает ли ход капкан
		if self.trap.value.skipping then
			self.content = lang_core.get_text(self, self.types.trap_skip, before_str, after_str, values)

		else
			self.content = lang_core.get_text(self, self.types.trap_default, before_str, after_str, values)

		end

	end

	-- Определяем сколько оберегов осталось
	self.obereg = game_content_artifact.get_item("try_1", player_id, is_game, is_reward)

	if self.obereg.count > 0 then
		-- Есть обереги
		gui_loyouts.set_text(self, self.nodes.count, self.obereg.count)

		-- Добавляем кнопку
		table.insert(self.btns, 1, self.btn_confirm)

		gui_loyouts.set_enabled(self, self.nodes.btn_reward, false)
		gui_loyouts.set_enabled(self, self.nodes.btn_confirm, true)

		timer.delay(0.1, false, function(self)
			gui_input.set_focus(self, 1)
		end)

		animate_btn = true

	elseif self.obereg.is_reward then
		-- Есть за рекламу
		gui_loyouts.set_text(self, self.nodes.count, self.obereg.is_reward)
		gui_loyouts.set_color(self, self.nodes.count, color.magenta)

		--Добавляем текст просмотр рекламы
		self.content = lang_core.get_text(self, "_obereg_reward", self.content .. "<br/> <color=magenta>", "</color>", values)

		-- Добавляем кнопку
		table.insert(self.btns, 1, self.btn_reward)

		-- Прячем другую 
		gui_loyouts.set_enabled(self, self.nodes.btn_confirm, false)
		gui_loyouts.set_enabled(self, self.nodes.btn_reward, true)

		timer.delay(0.1, false, function(self)
			gui_input.set_focus(self, 1)
		end)

		animate_btn = true

	else
		-- Нет оберегов
		gui_loyouts.set_text(self, self.nodes.count, "0")

		-- Добавляем кнопку
		table.insert(self.btns, 1, self.btn_confirm)
		gui_loyouts.set_enabled(self, self.nodes.btn_reward, false)
		gui_input.set_disabled(self, self.btns[1], true)

		timer.delay(0.1, false, function(self)
			gui_input.set_focus(self, 2)
		end)

		animate_btn = false
	end

	-- Анимация кнопки
	if animate_btn then
		self.animate_btn = gui_animate.pulse_loop(self, self.btns[1].node, 2)
	end

	gui_loyouts.set_text(self, self.nodes.content, "")
	gui_text.set_text_formatted(self, self.nodes.content, self.content)
end

-- Использование оберега
function M.success(self)
	msg.post("main:/sound", "play", {sound_id = "activate_btn"})

	if self.obereg.count < 1 and self.obereg.is_reward then
		-- Оберег за вознаграждение
		msg.post("main:/core_reward", "get_reward", {type = "artifact", id = "try_1", player_id = self.player_id, is_game = self.is_game})
		return
	end

	self.disabled = true
	gui.move_above(self.nodes.wrap_image, self.nodes.wrap_areola)

	local delay = 0  
	timer.delay(delay, false, function (self)
		msg.post("main:/sound", "play", {sound_id = "popup_show"})

		gui.animate(self.nodes.wrap_object, "position", vmath.vector3(0), gui.EASING_LINEAR, 0.25)
		gui.animate(self.nodes.count, "color.w", 0, gui.EASING_LINEAR, 0.25)
		gui.animate(self.nodes.content, "color.w", 0, gui.EASING_LINEAR, 0.25)
		gui.animate(self.nodes.wrap_btns, "color.w", 0, gui.EASING_LINEAR, 0.25)

		timer.delay(0.25, false, function (self)
			gui_loyouts.set_alpha(self, self.nodes.count, 0)
			gui_loyouts.set_alpha(self, self.nodes.content, 0)
			gui_loyouts.set_alpha(self, self.nodes.wrap_btns, 0)

			gui_loyouts.set_position(self, self.nodes.wrap_object, vmath.vector3(0))
		end)
	end)

	delay = delay + 0.25
	timer.delay(delay, false, function (self)
		msg.post("main:/sound", "play", {sound_id = "modal_top_3_2"})

		gui.animate(self.nodes.wrap_object, 'scale', vmath.vector3(1.3), gui.EASING_INOUTSINE, 0.25, 0, function (self)
			gui_loyouts.set_scale(self, self.nodes.wrap_object, vmath.vector3(1.3))
		end)

		gui_animate.areol(self, 'areola_template', speed_to_second, 2, function (self)
			delay = delay + 2.5

			timer.delay(0.1, false, function (self)
				self.success = true
				msg.post("/loader_gui", "visible", {
					id = "modal_obereg",
					visible = false,
					type = hash("animated_close")
				})
			end)
		end)
	end)
end

return M