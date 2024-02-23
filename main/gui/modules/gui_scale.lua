-- работа с текстом в гуи
local M = {}

local richtext = require "richtext.richtext"
local color = require "richtext.color"

-- Отрисовка шкалы
function M.start(self, name_template, speed_caret, function_change, function_stop)
	local nodes = {
		wrap = gui.get_node(name_template.."/wrap"),
		caret = gui.get_node(name_template.."/caret"),
		scale = gui.get_node(name_template.."/scale")
	}

	local function_change = function_change or function (self, procent)
		print("Procent:", procent)
	end

	local function_stop = function_stop or function (self, procent)
		print("Stop:", procent)
	end

	-- За сколько секунд проходить
	local speed_caret = speed_caret or 0.5

	-- Находим стартовые позиции
	self._scale = self._scale or {}
	self._scale.position_caret = self._scale.position_caret or gui.get_position(nodes.caret)
	self._scale.position_scale = self._scale.position_scale or gui.get_position(nodes.scale)
	self._scale.size_scale = self._scale.size_scale or gui.get_size(nodes.scale)
	self._scale.start_position = self._scale.start_position or self._scale.position_caret.x
	self._scale.end_position = self._scale.end_position or self._scale.size_scale.x + self._scale.position_scale.x * 2
	self._scale.width = self._scale.end_position - self._scale.start_position

	if self._scale.timer then
		timer.cancel(self._scale.timer)
		self._scale.timer = nil
	end

	gui.set_position(nodes.caret, self._scale.position_caret)
	gui.cancel_animation(nodes.caret, "position.x")

	gui.animate(nodes.caret, "position.x", self._scale.end_position, gui.EASING_LINEAR, speed_caret, 0 , nil, gui.PLAYBACK_LOOP_PINGPONG)

	self._scale.timer = timer.delay(0.01, true, function (self)
		local current_position = gui.get_position(nodes.caret)
		local procent = current_position.x / self._scale.width 
		function_change(self, procent)
	end)

	-- Возвращаем функцию остановки
	return {
		stop = function (self)
			timer.cancel(self._scale.timer)
			gui.cancel_animation(nodes.caret, "position.x")
			local current_position = gui.get_position(nodes.caret)
			local procent = current_position.x / self._scale.width 
			function_stop(self, procent)
		end
	}
end

-- ищем сектор, на который указывает каретка
function M.get_sector(self, sectors, procent)
	if not self.sectors_line then
		-- Выстраиваем сектора, чтобы легче искать
		self.sectors_line = {}

		local min = 0
		local max = 0
		for i = 1, #sectors do
			local item = sectors[i]

			max = min + item.width_procent
			self.sectors_line[i] = {id = i, item = item, min = min, max = max}
			min = max
		end
	end
	local procent = procent * 100

	-- находим указанный сектор
	for i, item in ipairs(self.sectors_line) do
		if procent >= item.min  and procent <= item.max then
			if self.current_sector ~= item.id then

				self.current_sector = item.id
				return self.current_sector
			end
			break
		end
	end
end

return M