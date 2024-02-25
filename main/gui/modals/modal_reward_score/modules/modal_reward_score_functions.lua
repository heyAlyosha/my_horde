-- Функции
local M = {}

local gui_scale = require "main.gui.modules.gui_scale"
local color = require("color-lib.color")
local gui_input = require "main.gui.modules.gui_input"
local gui_animate = require "main.gui.modules.gui_animate"
-- Адаптирвоанный интерфейс
local gui_loyouts = require "main.gui.modules.gui_loyouts"
-- Переводы
local gui_lang = require "main.lang.gui_lang"
local lang_core = require "main.lang.lang_core"

-- Функция когда меняется сектор
function M.change_sector(self, procent)
	-- Если меняется сектор
	local index_sector = gui_scale.get_sector(self, self.sectors, procent)
	if not index_sector then
		return
	end

	-- Получаем активный центр
	self.active_sector = self.sectors[index_sector]

	-- Меняем цвет активного сектора
	gui_loyouts.set_color(self, self.active_sector.node, color.lime)
	if self.last_active_sector then
		gui_loyouts.set_color(self, self.last_active_sector.node, color.white)
	end
	self.last_active_sector = self.active_sector

	-- Изменяем цвет
	gui_loyouts.set_color(self, self.nodes.count, self.active_sector.color)
	gui_loyouts.set_text(self, self.nodes.count, math.floor(self.trofey * self.active_sector.ratio))
	gui.animate(self.nodes.wrap_count, "scale", vmath.vector3(self.active_sector.scale), gui.EASING_LINEAR, 0.1)
end

-- Функция когда игрок останавливает каретку на шкале
function M.stop(self, procent)
	-- Блокируем всё управление
	--self.disabled = true
end

-- Функция когда игрок останавливает каретку на шкале
function M.hidden(self)
	gui_animate.hidden_bottom(self, self.nodes.wrap, function (self)
		msg.post("/loader_gui", "visible", {
			id = "modal_reward_score",
			visible = false,
		})
	end)
end

-- Показываем
function M.visible(self, score)
	self.trofey = score or 0
	gui_loyouts.set_text(self, self.nodes.count, '+'..self.trofey)
	gui_loyouts.set_text(self, self.nodes.old_count, self.trofey)

	self.scale = gui_scale.start(self, "scale_template", 1.5, M.change_sector, M.stop)

	timer.delay(0.1, false, function(self)
		gui_input.set_focus(self, 2)
		self.animate_btn = gui_animate.pulse_loop(self, self.btns[2].node, 2)
	end)
end

-- Остановка каретки
function M.stop(self, procent)

	if self.btns[2].disabled then
		return
	end

	if self.animate_btn then
		self.animate_btn.stop(self)
		self.animate_btn = nil
	end

	gui_input.set_disabled(self, self.btns[2], true)
	msg.post("main:/core_reward", "get_reward", {
		type = "score_round",
		score = tonumber(gui.get_text(self.nodes.count)),
		player_id = "player",
	})

	
end

-- Функция успешного просмотра рекламы
function M.success(self, type)
	msg.post("main:/sound", "play", {sound_id = "modal_top_3_2"})
	msg.post("main:/sound", "play", {sound_id = "popup_show"})
	gui.move_above(self.nodes.wrap_areola, self.nodes.wrap_scale)
	gui.move_above(self.nodes.wrap_count, self.nodes.wrap_areola)

	self.success_score = tonumber(gui.get_text(self.nodes.count))

	local delay = 0
	timer.delay(delay, false, function (self)
		
		gui.animate(self.nodes.wrap_count, "position.x", 0, gui.EASING_INOUTSINE, 0.25)
		gui.animate(self.nodes.wrap_old_count, "position.x", 0, gui.EASING_INOUTSINE, 0.25)
		gui.animate(self.nodes.wrap_old_count, "color.w", 0, gui.EASING_LINEAR, 0.25)
		gui.animate(self.nodes.arrow, "color.w", 0, gui.EASING_LINEAR, 0.25)

		timer.delay(0.25, false, function (self)
			gui_loyouts.set_position(self, self.nodes.wrap_count, 0, "x")
			gui_loyouts.set_position(self, self.nodes.wrap_old_count, 0, "x")

			gui_loyouts.set_alpha(self, self.nodes.wrap_old_count, 0)
			gui_loyouts.set_alpha(self, self.nodes.arrow, 0)

		end)
	end)

	delay = delay + 0.25
	timer.delay(delay, false, function (self)
		gui.animate(self.nodes.wrap_count, 'scale', vmath.vector3(1.3), gui.EASING_INOUTSINE, 0.25)
		gui_animate.areol(self, 'areola_template', speed_to_second, 2, function (self)
			delay = delay + 2.5

			timer.delay(0.1, false, function (self)
				M.hidden(self)
			end)

		end)
	end)
end
	
return M