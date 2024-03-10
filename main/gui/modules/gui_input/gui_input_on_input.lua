-- Обработка событий устройств клавиш или мышки
local M = {}

local color = require("color-lib.color")
local sound_render = require "main.sound.modules.sound_render"
local gui_input_type_slider = require "main.gui.modules.gui_input.gui_input_type_slider"

-- нажатие на enter
function M.enter(self, action_id, action, function_activate)
	if self.focus_btn_id then
		local btn = self.btns[self.focus_btn_id]

		-- если это обычная кнопка - активируем её
		if btn.type == "btn" then
			function_activate(self, self.focus_btn_id, action_id, action)

		-- Если это полее ввода, фокусируемся на него для ввода текста
		elseif btn.type == "input" then
			btn.input:select()

			-- Переключатель
		elseif btn.type == "switch" then
			msg.post("main:/sound", "play", {sound_id = "switch_1"})
			btn.set(self, not btn.value)
		end
	end
end

-- Нажатие на тсрелку вверх
function M.up(self, action_id, action, function_focus, function_post_focus)
	if not self.focus_btn_id then
		sound_render.play("focus_main_menu")
		function_focus(self, 1, action_id, action, function_post_focus)

	elseif self.focus_btn_id <= 1 then
		sound_render.play("block_nav")

	else
		local btn = self.btns[self.focus_btn_id]
		if btn.section then
			-- Если у кнопки есть секция
			for i = self.focus_btn_id, 1, -1 do
				local item = self.btns[i]
				if item.section ~= btn.section then
					sound_render.play("focus_main_menu")
					function_focus(self, i, action_id, action, function_post_focus)
					break
				end

				if i == 1 then
					sound_render.play("block_nav")
				end
			end
		else
			-- Если у кнопки нет секция
			--sound_render.play("focus_main_menu")
			function_focus(self, self.focus_btn_id - 1, action_id, action, function_post_focus)
		end
	end
end

-- Нажатие на тсрелку вниз
function M.down(self, action_id, action, function_focus, function_post_focus)
	sound_render.play("focus_main_menu")
	if not self.focus_btn_id then
		sound_render.play("focus_main_menu")
		function_focus(self, 1, action_id, action, function_post_focus)
	elseif self.focus_btn_id >= #self.btns then
		sound_render.play("block_nav")
	else
		local btn = self.btns[self.focus_btn_id]
		if btn.section then
			-- Если у кнопки есть секция
			for i = self.focus_btn_id, #self.btns do
				local item = self.btns[i]

				if item.section ~= btn.section then
					sound_render.play("focus_main_menu")
					function_focus(self, i, action_id, action, function_post_focus)
					break

				end

				if i == #self.btns then
					sound_render.play("block_nav")
				end
			end
		else
			-- Если у кнопки нет секции
			sound_render.play("focus_main_menu")
			function_focus(self, self.focus_btn_id + 1, action_id, action, function_post_focus)
		end
	end
end

-- Нажатие на тсрелку влево
function M.left(self, action_id, action, function_focus, function_post_focus)
	if self.focus_btn_id and self.btns[self.focus_btn_id].type == "slider" then
		local btn = self.btns[self.focus_btn_id]
		gui_input_type_slider.left_or_right(self, btn, action_id)

	elseif not self.focus_btn_id then
		sound_render.play("focus_main_menu")
		function_focus(self, 1, action_id, action, function_post_focus)

	elseif self.focus_btn_id <= 1 then
		sound_render.play("block_nav")

	else
		local btn = self.btns[self.focus_btn_id]

		local prev_btn = self.btns[self.focus_btn_id - 1]
		if btn.section == prev_btn.section then
			sound_render.play("focus_main_menu")
			function_focus(self, self.focus_btn_id - 1, action_id, action, function_post_focus)
		else
			-- Если у кнопки нет секция
			sound_render.play("block_nav")
		end
	end
end

-- Вправо
function M.right(self, action_id, action, function_focus, function_post_focus)
	-- Если это ползунок
	if self.focus_btn_id and self.btns[self.focus_btn_id].type == "slider" then
		local btn = self.btns[self.focus_btn_id]
		gui_input_type_slider.left_or_right(self, btn, action_id)
	
	elseif not self.focus_btn_id then
		sound_render.play("focus_main_menu")
		function_focus(self, 1, action_id, action, function_post_focus)
	elseif self.focus_btn_id >= #self.btns then
		sound_render.play("block_nav")
		
	else
		local btn = self.btns[self.focus_btn_id]
		local next_btn = self.btns[self.focus_btn_id + 1]
		if btn.section == next_btn.section then
			sound_render.play("focus_main_menu")
			function_focus(self, self.focus_btn_id + 1, action_id, action, function_post_focus)
		else
			-- Если у кнопки нет секция
			sound_render.play("block_nav")
		end
	end
end

-- Вернуться назад/закрыть
function M.back(self, action_id, action, function_back)
	function_back(self)
end

-- Касания или клик
function M.touch(self, action_id, action, function_activate)
	for i, btn in ipairs(self.btns) do
		if btn.type == "btn" then
			local node = btn.node or btn.wrap_node or btn.node_bg
			if gui.pick_node(node, action.x, action.y) then
				if btn.scroll and not btn.scroll:is_node_in_view(node) then
					break
				end

				function_activate(self, i, action_id, action)
				break
			end

		elseif btn.type == "switch" then
			local node = btn.nodes.line
			if gui.pick_node(node, action.x, action.y) then
				msg.post("main:/sound", "play", {sound_id = "switch_1"})
				btn.set(self, not btn.value)
			end
		end
	end
end

-- Движения мышью
function M.move_mouse(self, action_id, action, function_focus, function_post_focus)
	local function_post_focus = nil
	for i, btn in ipairs(self.btns) do
		-- Наведение на кнопку или контейнер-обёртку
		if btn.type == "btn" or btn.type == "wrap" then
			local node = btn.node or btn.wrap_node or btn.node_bg
			if gui.pick_node(node, action.x, action.y) then
				if btn.scroll and not btn.scroll:is_node_in_view(btn.node) then
					break
				end

				if self.focus_btn_id ~= i then
					sound_render.play("focus_main_menu")
				end
				function_focus(self, i, action_id, action, function_post_focus)
				break
			end

		elseif btn.type == "text" then
			local focus
			for i_node = 1, #btn.nodes do
				local node = btn.nodes[i_node]
				if gui.pick_node(node, action.x, action.y) then
					if self.focus_btn_id ~= i then
						sound_render.play("focus_main_menu")
					end

					focus = i
					function_focus(self, i, action_id, action, function_post_focus)
				end
			end

			if focus then
				break
			end

		elseif btn.type == "input" then
			local node = btn.nodes.input_wrap
			if gui.pick_node(node, action.x, action.y) then
				if self.focus_btn_id ~= i then
					sound_render.play("focus_main_menu")
				end
				function_focus(self, i, action_id, action, function_post_focus)
				break
			end

		elseif btn.type == "slider" then
			if gui.pick_node(btn.nodes.circle, action.x, action.y) or gui.pick_node(btn.nodes.line, action.x, action.y) then
				if self.focus_btn_id ~= i then
					sound_render.play("focus_main_menu")
				end
				function_focus(self, i, action_id, action, function_post_focus)
				break
			end

		elseif btn.type == "switch" then
			if gui.pick_node(btn.nodes.line, action.x, action.y) then
				if self.focus_btn_id ~= i then
					sound_render.play("focus_main_menu")
				end
				function_focus(self, i, action_id, action, function_post_focus)
				break
			end
		end

		if i == #self.btns then
			function_focus(self, nil, action_id, action, function_post_focus)
		end
	end
end

return M