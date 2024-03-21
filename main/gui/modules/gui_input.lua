-- Модуль универсального управления кнопками гуишек
local M = {}

local druid = require("druid.druid")
local slider = require("druid.extended.slider")
local input = require("druid.extended.input")
local sound_render = require "main.sound.modules.sound_render"
local color = require("color-lib.color")
local storage_gui = require "main.storage.storage_gui"
local gui_manager = require "main.gui.modules.gui_manager"
local gui_input_render_focus = require "main.gui.modules.gui_input.gui_input_render_focus"
local gui_input_on_input = require "main.gui.modules.gui_input.gui_input_on_input"
local gui_input_type_input = require "main.gui.modules.gui_input.gui_input_type_input"
local gui_input_type_slider = require "main.gui.modules.gui_input.gui_input_type_slider"
local gui_input_type_switch = require "main.gui.modules.gui_input.gui_input_type_switch"
local gui_input_functions = require "main.gui.modules.gui_input.gui_input_functions"
local storage_player = require "main.storage.storage_player"

--[[
--Для работы требуется такой массив кнопок
self.btns = {
	{
		id = "close", -- id кнопки
		type = "btn", -- Тип кнопки
		section = "close", -- секция для управления стрелками по горизонтали
		node = self.nodes.btn_close, -- Нода всей кнопки
		node_title = self.nodes.btn_close_title,  -- Нода с заголовком кнопки
		icon = "Close_button_from_windows_" -- Картинка фона кнопки
	},
}

-- Текущая фокусировка на кнопку хранится в переменной
self.focus_btn_id
--]]

-- Отрисовка кнопок
function M.render_btns(self, btns)
	local btns = btns or self.btns or {}

	for i = 1, #btns do
		local btn = btns[i]
		gui_input_render_focus.render_focus_item(self, btn, btn.focus)
	end
end

-- Иницциализация элементов интерфейса
function M.init(self)
	self.btns_id = self.btns_id or {}

	druid.register("slider", slider)
	druid.register("input", input)

	self.btns_id = self.btns_id or {}

	for i = 1, #self.btns do
		local btn = self.btns[i]
		-- Устанавливаем ключи айдишники, чтобы было проще получть кнопки по id
		if btn.id then
			self.btns_id[btn.id] = btn
		end

		-- Инициализируем ползунок
		if btn.type == "slider" then
			gui_input_type_slider.init(self, btn)

		-- Инициализируем поле ввода
		elseif btn.type == "input" then
			gui_input_type_input.init(self, btn)

		-- Инициализируем перключатель
		elseif btn.type == "switch" then
			gui_input_type_switch.init(self, btn)
		end

	end
end

-- Блокируем кнопку
function M.set_disabled(self, btn, disable)
	btn.disabled = disable
	gui_input_render_focus.render_focus_item(self, btn, btn.focus)
end

-- ФОкус по id
function M.set_focus_id(self, id)
	for index, btn in ipairs(self.btns) do
		if btn.id == id then
			M.set_focus(self, index)
			return
		end
	end
end

-- Ставим фокус на элементе
function M.set_focus(self, index, function_post_focus, is_remove_other_focus)
	-- Если приходит сброс фокуса во время открытого уведомления - отключаем его
	self.not_remove_other_focus = self.not_remove_other_focus
	self.not_set_blocking_focus_component = self.not_set_blocking_focus_component

	-- Нужно ли очищать фокусы в других компонентах
	local is_remove_other_focus = is_remove_other_focus 
	if is_remove_other_focus == nil then
		is_remove_other_focus = true
	elseif is_remove_other_focus == false then
		self.not_set_blocking_focus_component = true
	end

	if self.focus_btn_id and self.focus_btn_id ~= index then
		-- Удаляем старый фокус на кнопке
		local btn = self.btns[self.focus_btn_id]
		if btn then
			btn.focus = false

			gui_input_render_focus.render_focus_item(self, btn, btn.focus)
			if btn.on_set_function then btn.on_set_function(self, btn, false) end
		end
	end

	if index and self.btns[index] then
		local id_component = msg.url().fragment

		storage_gui.focus_input_id_component = gui_manager.get_screen_id(msg.url())

		-- Ставим новый фокус на кнопке
		local btn = self.btns[index]
		btn.focus = true

		gui_input_render_focus.render_focus_item(self, btn, btn.focus)

		gui_input_functions.focus_input_component(self, id_component, index)
		msg.post(msg.url(), "acquire_input_focus")

		if function_post_focus then
			function_post_focus(self, index, btn)
		end
		if btn.on_set_function then btn.on_set_function(self, btn, true) end
	end

	--pprint("function_focus", self.focus_btn_id, index)
	self.focus_btn_id = index
end

local function function_focus_default(self, index, action_id, action, function_post_focus)
	if self.focus_btn_id ~= index then
		M.set_focus(self, index, function_post_focus)
	end
end

-- Это нажатие клавишь
function M.is_keys(self, action_id, action)
	return (action_id == hash("up") or action_id == hash("down") or action_id == hash("left") or action_id == hash("right") or action_id == hash("back") or action_id == hash("enter")) and action.pressed
end

-- Это клик или касание
function M.is_touch(self, action_id, action)
	return (action_id == hash("action") or action_id == hash("action_mouse")) and action.pressed
end

-- Это клик или касание
function M.is_type_input(self, type)
	return (action_id == hash("action") or action_id == hash("action_mouse")) and action.pressed
end

-- Обработка управления
function M.on_input(self, action_id, action, function_focus, function_activate, function_back, function_post_focus, is_modal)
	self._gui_input = self._gui_input or {}
	self._gui_input.is_modal = self.is_modal

	if not storage_gui.active_input then
		if (action_id == hash("up") or action_id == hash("down") or action_id == hash("left") or action_id == hash("right") or action_id == hash("enter")) then
			return 
		end
		--return 
	end

	-- Записываем какие типы управления доступны игроку
	if M.is_touch(self, action_id, action) then
		storage_player.input.touch = true

	elseif not action_id and action.x and action.y then
		storage_player.input.mouse = true

	elseif M.is_keys(self, action_id, action) then
		storage_player.input.keyboard = true

	end

	function_focus = function_focus or function_focus_default
	local id_component = msg.url().fragment

	-- Блокируем управление со всех компонентов, когда показывается уведомление
	if storage_gui.components_visible.notify and self.component_id ~= 'notify' and M.is_keys(self, action_id, action) then
		return
	end

	if (storage_gui.inventary_wrap.visible and (self.type_gui ~= "inventary")) and self.component_id ~= 'notify' then
		if id_component ~= hash("interface") and not self.is_modal then
			--return true
			return 
		end
		
	end

	if (storage_gui.focus_input_component ~= id_component)
		and M.is_keys(self, action_id, action) 
		and self.component_id ~= 'notify' 
	then
		return
	end

	-- Классические кнопки
	if action_id == hash("enter") and action.pressed then
		gui_input_on_input.enter(self, action_id, action, function_activate, function_post_focus)

	elseif action_id == hash("up") and action.pressed then
		gui_input_on_input.up(self, action_id, action, function_focus, function_post_focus)

	elseif action_id == hash("down") and action.pressed then
		gui_input_on_input.down(self, action_id, action, function_focus, function_post_focus)

	elseif action_id == hash("left") and action.pressed then
		gui_input_on_input.left(self, action_id, action, function_focus, function_post_focus)

	elseif action_id == hash("right") and action.pressed then
		gui_input_on_input.right(self, action_id, action, function_focus, function_post_focus)

	elseif action_id == hash("back") and action.pressed then
		gui_input_on_input.back(self, action_id, action, function_back, function_post_focus)

	elseif M.is_touch(self, action_id, action) and self.btns then
		gui_input_on_input.touch(self, action_id, action, function_activate, function_post_focus)

	elseif not action_id and action.x and action.y and self.btns then
		gui_input_on_input.move_mouse(self, action_id, action, function_focus, function_post_focus)
	end

	if self._gui_input.is_modal or self.is_modal then
		if M.is_touch(self, action_id, action) or (action.x and action.y) then
			if self.nodes.wrap then
				if gui.pick_node(self.nodes.wrap, action.x, action.y) then
					return true
				end
			else
				return true
			end
		elseif M.is_keys(self, action_id, action) then
			return true
		end

	end

	if not self.focus_btn_id and M.is_keys(self, action_id, action) then
		--M.set_focus(self, 1, function_post_focus, is_remove_other_focus)
	end

	--msg.post("main:/print", "print", {text = msg.url()})

	if M.is_keys(self, action_id, action) then
		--return true
	end
end

-- Обрабатываем удаление компонента из управления
function M.on_final(self, no_focus_last_component)
	local id_component = msg.url().fragment

	-- Если модальное окно, удаляем 
	for i = 1, #storage_gui.modals do
		local modal = storage_gui.modals[i]
		if modal.id == id_component then
			table.remove(storage_gui.modals, i)
			break
		end
	end

	if (self.is_modal or true) and not no_focus_last_component then
		local prev_component = storage_gui.modals[#storage_gui.modals]

		-- Ставим фокус на первый компонент после него
		if prev_component then
			local id_component_string = storage_gui.components_visible_hash_to_id[prev_component.focus_input_component]
			msg.post("/loader_gui", "focus", {
				id = id_component_string, -- id компонента в лоадер гуи
				focus = prev_component.focus_input_index_btn or 1 -- кнопка фокуса
			})
		end
	end 
end

-- ФОкус на последний компонент
function M.set_last_focus_component(self, id_component_current)
	for i, item in ipairs(storage_gui.modals) do
		if item.focus_input_component == id_component_current then
			if i >= 2 then
				local last_element = storage_gui.modals[i - 1]
				id_component_string = storage_gui.components_visible_hash_to_id[last_element.focus_input_component]

				msg.post("/loader_gui", "focus", {
					id = id_component_string, -- id компонента в лоадер гуи
					focus = last_element.focus_input_index_btn -- кнопка фокуса
				})

				--[[
				pprint(
				storage_gui.components_visible_hash_to_id
				,{
					id = id_component_string, -- id компонента в лоадер гуи
					focus = last_element.focus_input_index_btn -- кнопка фокуса
				})
				--]]


				return true
			else
				return false
			end
		end
	end
end

return M