-- таймеры для функций сос кипом
local M = {}

-- Добавление функции по таймеру для скипа
function M.add(self, id, add_delay, function_timer, delay)
	local id = id or "default"
	self._timer_linear = self._timer_linear or {}
	self._timer_linear[id] = self._timer_linear[id] or {}
	self._timer_linear[id].delay = self._timer_linear[id].delay or delay or 0

	local timer_linear_item = self._timer_linear[id]
	timer_linear_item.delay = timer_linear_item.delay or 0
	timer_linear_item.items = timer_linear_item.items or {}

	timer_linear_item.delay = timer_linear_item.delay + add_delay

	-- Добавляем функцию
	local handle = timer.delay(timer_linear_item.delay, false, function (self, handle)
		timer_linear_item.items[1].function_timer(self, data)
		table.remove(timer_linear_item.items, 1)

		if #timer_linear_item.items == 0 then
			M.skip(self, id)
		end
	end)

	local item = {
		handle = handle,
		function_timer = function_timer,
		delay = timer_linear_item.delay,
	}

	timer_linear_item.items[#timer_linear_item.items + 1] = item
end

-- Пропуск всех анимаций
function M.skip(self, id)
	if self._timer_linear and self._timer_linear[id] and self._timer_linear[id].items then
		for i, item in ipairs(self._timer_linear[id].items) do
			timer.cancel(item.handle)
			item.function_timer(self, data)
			
		end

		self._timer_linear[id].items = nil
		self._timer_linear[id] = nil
	end
end

-- Продолжается ли таймер
function M.is_delay(self, id)
	return self._timer_linear and self._timer_linear[id] and self._timer_linear[id].items and #self._timer_linear[id].items > 0
end

-- Получить id всех текущих анимаций
function M.get_ids(self)
	local result = {}
	self._timer_linear = self._timer_linear or {}

	for key, item in pairs(self._timer_linear) do
		result[#result + 1] = key
	end

	return result
end

-- Ловим управление на скип
function M.on_input(self, action_id, action)
	if (action_id == hash("enter") or action_id == hash("back") or action_id == hash("action") or action_id == hash("action_mouse")) and action.pressed then
		local timers_linear = M.get_ids(self)
		if #timers_linear >= 1 then
			for i, id in ipairs(timers_linear) do
				M.skip(self, id)
			end
			return true
		end

		return false
	end
end

return M