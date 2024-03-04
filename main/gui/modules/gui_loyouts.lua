-- Сохранение динамических свойств при смене лаяутов
local M = {}

local gui_text = require "main.gui.modules.gui_text"


-- Запись изменения в хранилище
local function set_storage(self, node, type_operation, value)
	local id = gui.get_id(node)

	--pprint("set_storage", )

	self._gui_loyouts = self._gui_loyouts or {}
	self._gui_loyouts[id] = self._gui_loyouts[id] or {}
	self._gui_loyouts[id][type_operation] = {
		node = node, value = value
	}

	return id, type, self._gui_loyouts[id][type_operation]
end

M.gui_old_functions = {}

-- Сообщения
function M.on_message(self, message_id, message)
	if message_id == hash("layout_changed") then
		self._gui_loyouts = self._gui_loyouts or {}

		-- Сначала важные
		for id, operations in pairs(self._gui_loyouts) do
			for name_operation, item in pairs(operations) do
				--pprint(name_operation, item.node, item.value)
				if name_operation  == "set_texture" then
					M.get_function(self, name_operation, item.node, item.value)
				end
			end
		end

		--self._gui_loyouts = self._gui_loyouts or {}
		-- Перерисовываем динамические свойства
		for id, operations in pairs(self._gui_loyouts) do
			for name_operation, item in pairs(operations) do
				--pprint(name_operation, item.node, item.value)
				M.get_function(self, name_operation, item.node, item.value)
			end
		end
	end
end

--Замена всех базовых функций гуи на модульные (Не работает)
--[[
function M.replace_all_gui_functions(self)
	M.self[msg.url()] = 
	for key, item in pairs(gui) do
		-- Если есть такая функция в модуле заменяем её
		if M[key] then
			-- Записываем базовую функцию гуи в массив
			M.gui_old_functions[key] = gui[key]
			-- Заменяем
			gui[key] = M[key]
		end
	end
end
]]--

-- Вызов функции гуи
function M.get_function(self, name, node, value)
	if name == "set_rich_text" then
		return gui_text.set_text_formatted(self, node, value)
	end
	if M.gui_old_functions[name] then
		return M.gui_old_functions[name](node, value)
	else
		return gui[name](node, value)
	end
end


-- Изменения нод
function M.set_position(self, node, value, property)
	-- Если есть уточнение какое свойство
	if property then
		local value_node = gui.get_position(node)
		value_node[property] = value
		value = value_node
	end

	M.get_function(self, "set_position", node, value)
	return set_storage(self, node, "set_position", value)
end

function M.set_size(self, node, value, property)
	-- Если есть уточнение какое свойство
	if property then
		local value_node = gui.get_size(node)
		value_node[property] = value
		value = value_node
	end

	M.get_function(self, "set_size", node, value)
	return set_storage(self, node, "set_size", value)
end

function M.set_rotation(self, node, value, property)
	-- Если есть уточнение какое свойство
	if property then
		local value_node = gui.get_rotation(node)
		value_node[property] = value
		value = value_node
	end

	M.get_function(self, "set_rotation", node, value)
	return set_storage(self, node, "set_rotation", value)
end

function M.set_scale(self, node, value, property)
	-- Если есть уточнение какое свойство
	if property then
		local value_node = gui.get_scale(node)
		value_node[property] = value
		value = value_node
	end

	M.get_function(self, "set_scale", node, value)
	return set_storage(self, node, "set_scale", value)
end

function M.set_color(self, node, value, property)
	-- Если есть уточнение какое свойство
	if property then
		local value_node = gui.get_color(node)
		value_node[property] = value
		value = value_node
	end
	M.get_function(self, "set_color", node, value)
	return set_storage(self, node, "set_color", value)
end

function M.set_alpha(self, node, value)
	M.get_function(self, "set_alpha", node, value)
	return set_storage(self, node, "set_alpha", value)
end

function M.set_text(self, node, value)
	M.get_function(self, "set_text", node, value)
	return set_storage(self, node, "set_text", value)
end

function M.set_druid_text(self, node, value)
	M.get_function(self, "set_text", node, value)
	return set_storage(self, node, "set_text", value)
end

function M.set_rich_text(self, node, value)
	local nodes = M.get_function(self, "set_rich_text", node, value)
	set_storage(self, node, "set_rich_text", value)
	return nodes
end

function M.set_texture(self, node, value)
	M.get_function(self,  "set_texture", node, value)
	return set_storage(self, node, "set_texture", value)
end

function M.play_flipbook(self, node, value)
	M.get_function(self, "play_flipbook", node, value)
	return set_storage(self, node, "play_flipbook", value)
end

function M.set_fill_angle(self, node, value)
	M.get_function(self, "set_fill_angle", node, value)
	return set_storage(self,  node, "set_fill_angle", value)
end

function M.set_enabled(self, node, value)
	M.get_function(self, "set_enabled", node, value)
	return set_storage(self, node, "set_enabled", value)
end

function M.set_blend_mode(self, node, value)
	M.get_function(self, "set_blend_mode", node, value)
	return set_storage(self, node, "set_blend_mode", value)
end

function M.set_clipping_mode(self, node, value)
	M.get_function(self, "set_clipping_mode", node, value)
	return set_storage(self, node, "set_clipping_mode", value)
end

function M.set_layer(self, node, value)
	M.get_function(self, "set_layer", node, value)
	return set_storage(self, node, "set_layer", value)
end

return M