-- Модуль для анимации
local M = {}

local gui_loyouts = require "main.gui.modules.gui_loyouts"
local sound_render = require "main.sound.modules.sound_render"
local gui_lang = require "main.lang.gui_lang"

-- Анимаци нажатия
function M.activate(self, node, function_after)
	local id = gui.get_id(node)

	if not self["animation_activate_"..id] then
		self["animation_activate_"..id] = true
		local scale = gui.get_scale(node)
		local time = 0.2
		gui.animate(node, "scale", scale * 0.8, gui.EASING_LINEAR, time, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)

		-- Запускаем функцию после анимации
		timer.delay(time * 2, false, function (self)
			if function_after then
				function_after(self)
			end

			self["animation_activate_"..id] = false
		end)

	end
end

-- Анимаци появления снизу
function M.show_bottom(self, node, function_after)
	local node_position = gui.get_position(node)
	local time = 0.2

	msg.post("main:/sound", "play", {
		sound_id = "popup_hidden", is_single = true
	})
	gui_loyouts.set_enabled(self, node, true)
	gui.set_position(node, vmath.vector3(node_position.x, node_position.y - gui.get_height(), node_position.z))
	gui.set_alpha(node, 0)

	gui.animate(node, "position.y", gui.get_position(node).y + gui.get_height(), gui.EASING_LINEAR, time)
	gui.animate(node, "color.w", 1, gui.EASING_LINEAR, time)

	timer.delay(time, false, function (self)
		if function_after then
			function_after(self)
		end
	end)
end

-- Анимаци скрытия вниз
function M.hidden_bottom(self, node, function_after)
	local time = 0.2
	msg.post("main:/sound", "play", {
		sound_id = "popup_hidden", is_single = true
	})

	gui.animate(node, "position.y", gui.get_position(node).y - gui.get_height(), gui.EASING_LINEAR, time)
	gui.animate(node, "color.w", 0, gui.EASING_LINEAR, time)

	timer.delay(time, false, function (self)
		if function_after then
			function_after(self)
		end
	end)
end

-- Анимаци скрытия в сторону
function M.hidden_side(self, node, duration, side, function_after)
	local duration = duration or 0.2
	local side = side or "left"
	
	msg.post("main:/sound", "play", {
		sound_id = "popup_hidden", is_single = true
	})

	if side == "left" then
		gui.animate(node, "position.x", gui.get_position(node).x - gui.get_width(), gui.EASING_LINEAR, duration)

	elseif side == "right" then
		gui.animate(node, "position.x", gui.get_position(node).x + gui.get_width(), gui.EASING_LINEAR, duration)

	end

	gui.animate(node, "color.w", 0, gui.EASING_LINEAR, duration)

	timer.delay(duration, false, function (self)
		if function_after then
			function_after(self)
		end
	end)
end


-- Функция анимированной установки звезды
function M.set_star(self, node, duration, delay, function_end_animation, is_active)
	if is_active == nil then
		is_active = true
	end

	local duration = duration or 0.25
	local delay = delay or 0

	local timer_delay = timer.delay(delay, false, function (self)
		if is_active then
			gui_loyouts.play_flipbook(self, node, "star_active")

		else
			gui_loyouts.play_flipbook(self, node, "star_default")

		end
	end)

	local animate = gui.animate(node, "scale", 1.3, gui.EASING_LINEAR, duration, delay, function (self)
		if function_end_animation then
			function_end_animation(self)
		end
	end, gui.PLAYBACK_ONCE_PINGPONG)

	return {
		to_end = function (self)
			timer.cancel(timer_delay)
			gui.cancel_animation(node, "scale")
			gui_loyouts.play_flipbook(self, node, "star_active")
			gui_loyouts.set_scale(self, node, vmath.vector3(1))
		end
	}
end

-- Функция анимированного появления элементов при выскакивании
function M.show_elem_popping(self, node, duration, delay, function_end_animation)
	local id = gui.get_id(node)
	self._show_elem_popping = self._show_elem_popping or {}
	self._show_elem_popping[id] = self._show_elem_popping[id] or  {}
	self._show_elem_popping[id].scale = self._show_elem_popping[id].scale or gui.get_scale(node)
	local duration = duration or 0.25
	local delay = delay or 0
	
	local animate

	gui.set_scale(node, vmath.vector3(0))
	gui_loyouts.set_enabled(self, node, true)

	timer.delay(delay, false, function (self)
		animate = gui.animate(node, "scale", self._show_elem_popping[id].scale * 1.2, gui.EASING_LINEAR, duration, 0, function (self)
			gui.animate(node, "scale", self._show_elem_popping[id].scale, gui.EASING_LINEAR, duration/2, 0, function (self)

				if function_end_animation then
					function_end_animation(self)
				end
			end)
		end)
	end)

	return {
		to_end = function (self)
			gui.cancel_animation(node, "scale")
			gui.set_scale(node, scale)
		end
	}
end

-- Бесконечная пульсация
function M.pulse_loop(self, node, delay)
	local id = gui.get_id(node)
	local delay = delay or 2

	self._pulse_loop = self._pulse_loop or {}
	self._pulse_loop[id] = self._pulse_loop[id] or false

	if self._pulse_loop[id] then
		return self._pulse_loop[id]
	end

	local timer_handle = timer.delay(delay, true, function (self)
		M.pulse(self, node, scale, 0.25, 0, function (self)
			M.pulse(self, node, scale, 0.25, 0)
		end)
	end)

	self._pulse_loop[id] = {
		timer_handle = timer_handle,
		stop = function (self)
			timer.cancel(timer_handle)
			self._pulse_loop[id] = nil
		end
	}

	return self._pulse_loop[id]
end

-- Анимация пульсирования
function M.pulse(self, node, scale, duration, delay, function_end_animation)
	local id = gui.get_id(node)

	self._pulse = self._pulse or {}
	self._pulse[id] = self._pulse[id] or {}
	self._pulse[id].scale_start = self._pulse[id].scale_start or gui.get_scale(node)

	local scale = scale or self._pulse[id].scale_start * 1.1
	local duration = duration or 0.25
	local delay = delay or 0
	

	if not self._pulse[id]['animate_pulse_'..id] then
		self._pulse[id]['animate_pulse_'..id] = true
		gui.animate(node, 'scale', scale, gui.EASING_LINEAR, duration, delay, function (self)
			self._pulse[id]['animate_pulse_'..id] = nil
			if function_end_animation then
				function_end_animation(self)
			end
		end, gui.PLAYBACK_ONCE_PINGPONG)

		return duration + delay
	else
		return false
	end
end

-- Анимация обновления числа через пульс
function M.pulse_update_count(self, node_wrap, node_text, duration, delay, color, sound, text_to_animate_up, function_end_animation, scale_wrap)
	local id = gui.get_id(node_wrap)

	self._pulse_update_count = self._pulse_update_count or {}
	self._pulse_update_count[id] = self._pulse_update_count[id] or {}
	self._pulse_update_count[id].scale = self._pulse_update_count[id].scale or gui.get_scale(node_wrap)

	local delay = delay or 0
	local duration = duration or 0.25
	local color = color or vmath.vector3(1, 1, 1, 1)
	local text = text_to_animate_up or false
	local sound = sound or false
	
	local scale_wrap = scale_wrap or self._pulse_update_count[id].scale * 1.1

	local duration_scale = duration * 0.5
	local duration_color = duration  * 0.5
	local duration_text = duration

	
	local scale_default = self._pulse_update_count[id].scale

	timer.delay(delay, false, function (self)
		gui.animate(node_wrap, 'scale', scale_wrap, gui.EASING_LINEAR, duration_scale, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)
		gui.animate(node_text, 'color', color, gui.EASING_LINEAR, duration_color, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)

		timer.delay(duration_color + delay, false, function (self)
			gui.animate(node_wrap, 'scale', scale_default, gui.EASING_LINEAR, duration_scale)
			gui.animate(node_text, 'color', vmath.vector3(1, 1, 1, 1), gui.EASING_LINEAR, duration_color)
		end)
		if text then
			-- Если есть текст, анимируем его полёт наверх
			local text_node_clone  = gui.clone(node_text)
			local text_node_clone_position = gui.get_position(text_node_clone)
			local text_node_clone_size = gui.get_size(text_node_clone)
			local text_node_clone_color = vmath.vector4(color.x, color.y, color.z, 0)
			gui.set_text(text_node_clone, text)
			gui.set_color(text_node_clone, color)

			-- запускаем анимацию и удаляем текст
			gui.animate(text_node_clone, 'position.y', text_node_clone_position.y + text_node_clone_size.y + 10, gui.EASING_LINEAR, duration_text)
			gui.animate(text_node_clone, 'color',  text_node_clone_color, gui.EASING_LINEAR, duration_text, 0, function (self)
				gui.delete_node(text_node_clone)

				if function_end_animation then
					function_end_animation(self)
				end
				return true
			end)
		else
			return true
		end
	end)
end

-- Анимация ореола 
function M.areol(self, name_template, speed_to_second, duration, function_end, scale)
	local node_areol_wrap, node_areol_big, node_areol_mini
	if type(name_template) == "string" then
		node_areol_wrap = gui.get_node(name_template.."/wrap")
		node_areol_big = gui.get_node(name_template.."/areol_big")
		node_areol_mini = gui.get_node(name_template.."/areol_mini")
	else
		node_areol_wrap = name_template.wrap
		node_areol_big = name_template.areol_big
		node_areol_mini = name_template.areol_mini
	end

	local id = gui.get_id(node_areol_wrap)

	self._areol = self._areol or {}
	self._areol[id] = self._areol[id] or {}
	if self._areol[id].stop then
		self._areol[id].stop(self)
	end
	local duration_show = 0.15
	local speed_to_second = speed_to_second or 45
	local duration = duration or 1
	local delay = duration
	local scale = scale or 1

	-- Уменьшаем
	gui_loyouts.set_scale(self, node_areol_wrap, vmath.vector3(0))
	gui_loyouts.set_enabled(self, node_areol_wrap, true)
	gui_loyouts.set_alpha(self, node_areol_wrap, 0)

	gui_loyouts.set_rotation(self, node_areol_big, vmath.vector3(0))
	gui_loyouts.set_rotation(self, node_areol_mini, vmath.vector3(0))

	-- Анимируем исчезновение
	local function stop(self)
		gui.animate(node_areol_wrap, 'scale', vmath.vector3(0), gui.EASING_LINEAR, duration_show, 0)
		gui.animate(node_areol_wrap, 'color.w', 0, gui.EASING_LINEAR, duration_show)
		gui.cancel_animation(node_areol_big, 'rotation.z')
		gui.cancel_animation(node_areol_mini, 'rotation.z')

		timer.delay(duration_show, false, function (self)
			gui_loyouts.set_scale(self, node_areol_wrap, vmath.vector3(0), property)
			gui_loyouts.set_alpha(self, node_areol_wrap, 0)
			gui_loyouts.set_rotation(self, node_areol_big, vmath.vector3(0))
			gui_loyouts.set_rotation(self, node_areol_mini, vmath.vector3(0))

			if self._areol[id].timer then
				timer.cancel(self._areol[id].timer)
				self._areol[id].timer = nil
			end

			if function_end then
				function_end(self)
			end
		end)
	end

	-- Анимируем появление
	gui.animate(node_areol_wrap, 'scale', vmath.vector3(scale), gui.EASING_OUTBACK, duration_show, 0, function (self)
		gui_loyouts.set_scale(self, node_areol_wrap, vmath.vector3(scale))
	end)
	gui.animate(node_areol_wrap, 'color.w', 1, gui.EASING_LINEAR, duration_show, 0, function (self)
		gui_loyouts.set_color(self, node_areol_wrap, 1, "w")
	end)

	--Анимируем вращение
	local rotate = 180
	local speed = 180/speed_to_second
	gui.animate(node_areol_big, 'rotation.z', rotate, gui.EASING_LINEAR, speed, 0, nil, gui.PLAYBACK_LOOP_FORWARD)
	gui.animate(node_areol_mini, 'rotation.z', -rotate, gui.EASING_LINEAR, speed / 2, 0, nil, gui.PLAYBACK_LOOP_FORWARD)

	if duration ~= 'loop' then
		self._areol[id].timer = timer.delay(delay - duration_show, false, function (self)
			stop(self)
		end)
	end

	--[[
	timer.delay(delay, false, function (self)
		if function_end then
			function_end(self)
		end
	end)
	--]]

	return  {
		stop = stop
	}
end

-- Анимация ореола 
function M.unlock(self, name_template, duration, function_end)
	local duration = duration or 0.5
	local node_wrap = gui.get_node(name_template.."/lock_wrap")
	local node_castle = gui.get_node(name_template.."/castle")
	local node_chain = gui.get_node(name_template.."/chain")
	local node_chain_part_1 = gui.get_node(name_template.."/chain_part_1")
	local node_chain_part_2 = gui.get_node(name_template.."/chain_part_2")
	local node_castle_part_1 = gui.get_node(name_template.."/castle_part_1")
	local node_castle_part_2 = gui.get_node(name_template.."/castle_part_2")
	local node_castle_part_3 = gui.get_node(name_template.."/castle_part_3")
	local name_template_aureol = name_template..'/aureol_template'
	local aureol_wrap =  gui.get_node(name_template_aureol..'/wrap')
	local duration_chain = 0.4
	local duration_castle = duration_chain

	-- АНИМАЦИЯ
	local delay = 0

	-- Анимирование замка
	delay = delay + 0.3
	M.pulse(self, node_castle, nil, 0.2, delay)

	msg.post("main:/sound", "play", {sound_id = "modal_top_3_2"})

	-- Анимирование разрушения блока
	delay = delay + 0.3
	timer.delay(delay, false, function (self)
		msg.post("main:/sound", "play", {sound_id = "zombie_death"})

		-- Анимируем разрушение замка
		gui.set_enabled(node_castle, false)
		gui.set_enabled(node_castle_part_1, true)
		gui.set_enabled(node_castle_part_2, true)
		gui.set_enabled(node_castle_part_3, true)
		-- Передвигаем
		local position_animate = vmath.vector3()
		gui.animate(node_castle_part_1, 'position.y', gui.get_position(node_castle_part_1).y + 50, gui.EASING_LINEAR, duration_chain)
		local position_castle_2 = gui.get_position(node_castle_part_2)
		position_animate.x = position_castle_2.x - 50
		position_animate.y = position_castle_2.y - 50
		position_animate.z = position_castle_2.z
		gui.animate(node_castle_part_2, 'position', position_animate, gui.EASING_LINEAR, duration_chain)
		local position_castle_3 = gui.get_position(node_castle_part_3)
		position_animate.x = position_castle_3.x + 50
		position_animate.y = position_castle_3.y - 50
		position_animate.z = position_castle_3.z
		gui.animate(node_castle_part_3, 'position', position_animate, gui.EASING_LINEAR, duration_chain)
		-- Исчезновение
		gui.animate(node_castle_part_1, 'color.w', 0, gui.EASING_LINEAR, duration_chain)
		gui.animate(node_castle_part_2, 'color.w', 0, gui.EASING_LINEAR, duration_chain)
		gui.animate(node_castle_part_3, 'color.w', 0, gui.EASING_LINEAR, duration_chain)

		timer.delay(duration_chain, false, function (self)
			gui.delete_node(node_castle_part_1)
			gui.delete_node(node_castle_part_2)
			gui.delete_node(node_castle_part_3)
		end)

		-- Анимируем разрушение цепи
		gui.set_enabled(node_chain, false)
		gui.set_enabled(node_chain_part_1, true)
		gui.set_enabled(node_chain_part_2, true)
		-- Передвигаем
		gui.animate(node_chain_part_1, 'position.x', gui.get_position(node_chain_part_1).x - 50, gui.EASING_LINEAR, duration_chain)
		gui.animate(node_chain_part_2, 'position.x', gui.get_position(node_chain_part_2).x + 50, gui.EASING_LINEAR, duration_chain)
		-- Переворачиваем
		gui.animate(node_chain_part_1, 'rotation.z', -15, gui.EASING_LINEAR, duration_chain)
		gui.animate(node_chain_part_2, 'rotation.z', 15, gui.EASING_LINEAR, duration_chain)
		-- Исчезновение
		gui.animate(node_chain_part_1, 'color.w', 0, gui.EASING_LINEAR, duration_chain)
		gui.animate(node_chain_part_2, 'color.w', 0, gui.EASING_LINEAR, duration_chain)

		timer.delay(duration_chain, false, function (self)
			gui.delete_node(node_chain_part_1)
			gui.delete_node(node_chain_part_2)

			gui_loyouts.set_enabled(self, node_wrap, false)
		end)
	end)

	delay = delay + duration_castle + (duration_castle - duration_chain)

	-- Свечение
	local scale_aureol = gui.get_scale(aureol_wrap)
	M.areol(self, name_template_aureol, nil, delay - 0.2, nil, scale_aureol.x)

	return delay
end

-- Анимаци луча света
function M.ray(self, name_template_or_node, function_end, duration)
	local duration = duration or 0.25
	local ray_node
	if type(name_template_or_node) == "string" then
		ray_node = gui.get_node(name_template_or_node .. '/ray')
	else
		ray_node = name_template_or_node
	end

	local id = gui.get_id(ray_node)
	self._ray_scales = self._ray_scales or {}
	self._ray_scales[id] = self._ray_scales[id] or gui.get_scale(ray_node)
	self._ray_scales[id] = self._ray_scales[id] or gui.get_scale(ray_node)

	gui.set_enabled(ray_node, true)
	gui.set_scale(ray_node, vmath.vector3(1, 0, 1))
	gui.set_alpha(ray_node, 0.2)

	gui.animate(ray_node, 'color.w', 1, gui.EASING_LINEAR, duration, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)
	gui.animate(ray_node, "scale.y", self._ray_scales[id].y, gui.EASING_LINEAR, duration, 0, function (self)
		if function_end then function_end(self) end
		gui.set_alpha(ray_node, 0.2)
	end, gui.PLAYBACK_ONCE_PINGPONG)
end

-- Анимация сундука
function M.gift(self, name_template, function_end)
	local name_template = name_template or "gift_current_template"
	local duration = duration or 1

	local nodes = {
		wrap = gui.get_node(name_template..'/wrap'),
		gift = gui.get_node(name_template..'/gift'),
		gift_gold = gui.get_node(name_template..'/gift_gold'),
	}

	local id = gui.get_id(nodes.wrap)

	self._gift = self._gift or {}
	self._gift[id] = self._gift[id] or {}
	self._gift[id].start_position = self._gift[id].start_position or gui.get_position(nodes.wrap)
	self._gift[id].start_rotation = self._gift[id].start_rotation or gui.get_rotation(nodes.wrap)
	self._gift[id].start_scale = self._gift[id].start_scale or gui.get_scale(nodes.gift)

	gui.play_flipbook(nodes.gift, "gift_1")

	M.areol(self, name_template.."/areola_template", speed_to_second, 100, nil, scale)
	gui.animate(nodes.gift, "scale", self._gift[id].start_scale * 1.1, gui.EASING_LINEAR, 0.25, 0, function (self)
	end)

	timer.delay(0.25, false, function (self)
		timer.delay(0, false, function (self)
			gui.play_flipbook(nodes.gift, "gift", function (self)
				-- Золотов сундуке
				gui.animate(nodes.gift_gold, "color.w", 1, gui.EASING_LINEAR, 0.15)

				timer.delay(0.25, false, function (self)
					if function_end then
						function_end(self)
					end
				end)
			end)
		end)
	end)
end

-- Анимация перелёта объектов
function M.flight(self, node, position_start, position_end, height, speed, is_animate_aplha, function_end)
	local height = height or 0
	local speed = speed or 0.25
	local duration = vmath.length(position_end - position_start) / 100 * speed
	local duration_fade = duration * 0.15

	-- Анимация исчезновения в конце
	if is_animate_aplha then
		timer.delay(duration - duration_fade, false, function (self)
			gui.animate(node, 'color', vmath.vector4(1, 1, 1, 0), gui.EASING_OUTSINE, duration_fade)
		end)
	end

	-- Добавляем дугу
	if height > 0 then
		gui.animate(node, 'position.y', position_end.y + height, gui.EASING_OUTQUAD, duration/2, 0, nil)
		timer.delay(duration/2, false, function (self)
			gui.animate(node, 'position.y', position_end.y, gui.EASING_INOUTQUAD, duration/2, 0, nil)
		end)
	else
		gui.animate(node, 'position.y', position_end.y, gui.EASING_OUTSINE, duration, 0, nil)
	end

	-- Перелёт по прямой
	gui.animate(node, 'position.x', position_end.x, gui.EASING_OUTSINE, duration, 0, function (self)
		if function_end then
			function_end(self)
		end
	end)
end

-- Анимация зачёркивания
function M.strikethrough(self, name_template, duration, delay)
	local duration = duration or 0.2
	local delay = delay or 0
	local nodes = {
		wrap = gui.get_node(name_template.."/wrap"),
		line_left = gui.get_node(name_template.."/line_left"),
		line_right = gui.get_node(name_template.."/line_right"),
	}

	gui_loyouts.set_enabled(self, nodes.wrap, true)

	gui.animate(nodes.line_left, "scale.x", 0, gui.EASING_LINEAR, 0)
	gui.animate(nodes.line_right, "scale.x", 0, gui.EASING_LINEAR, 0)

	timer.delay(delay, false, function (self)
		msg.post("main:/sound", "play", {sound_id = "switch_1"})
		gui.animate(nodes.line_left, "scale.x", 1, gui.EASING_LINEAR, duration, 0 , function (self)
			msg.post("main:/sound", "play", {sound_id = "switch_1"})
			gui.animate(nodes.line_right, "scale.x", 1, gui.EASING_LINEAR, duration)
		end)
	end)

	return delay + duration * 2
end

return M