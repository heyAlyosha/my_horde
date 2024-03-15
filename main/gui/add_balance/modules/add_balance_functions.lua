-- функции для отрисовки анимированного добавления баланса
local M = {}

local storage_gui = require "main.storage.storage_gui"
local gui_animate = require "main.gui.modules.gui_animate" 

-- Функция генерации 1 элемента c дуговым падением
function M.add_elem_curve(self, type_valute, count, position_start, position_end, index, height_flight, random_height, random_width)
	local node = gui.clone(self.nodes.elem)
	local node_id = gui.get_id(node)
	local index = index or 1
	local add_values = {coins = 0, score = 0, rating = 0}
	local icon = 'icon_gold'

	if type_valute == 'score' then
		add_values.score = count
		icon = 'icon_score'
	else
		add_values.coins = count
		icon = 'icon_gold'
	end

	-- Место где спавнятся иконки
	local position_start = gui.screen_to_local(node, position_start)
	-- Место куда они падают
	local position_end = gui.screen_to_local(node, position_end)

	gui.set_color(node, vmath.vector4(1, 1, 1, 1))
	gui.set_enabled(node, true)
	gui.set_position(node, position_start)
	gui.play_flipbook(node, icon)

	-- Находим вектор  рандомного направления наверх
	math.randomseed(100000 * (socket.gettime() % 1))
	--[[
	if os.clock() == 0 then
		math.randomseed(index * position_start.x * position_start.y)
	else
		-- Не работает
		math.randomseed(os.clock() * index)
		math.randomseed(os.clock() * position_start.x * position_start.y)
	end
	--]]

	local random_height = random_height or 400
	local random_width = random_width or 100

	local random_position_end = vmath.vector3(
	position_end.x + math.random(-random_width/2, random_width/2), 
	position_end.y + math.random(-random_height/2, random_height/2), 
	position_end.z)

	-- Анимацию полёта по дуге
	-- Скорость полёта (100px / sec)
	local position_end = random_position_end
	local speed = math.random(10, 20) / 100
	local height = height_flight or 400
	local is_animate_aplha = false
	gui_animate.flight(self, node, position_start, position_end, height, speed, is_animate_aplha, function (self)
		timer.delay(0.25, false, function (self)
			gui.delete_node(node)
			M.add_elem(self, type_valute, gui.get_screen_position(node), count, {icon = icon})
		end)
	end)
end


-- Функция генерации 1 элемента для анимации
function M.add_elem(self, type, position_start, count, params)
	local params = params or {}
	local node = gui.clone(self.nodes.elem)
	local position_end = vmath.vector3()
	local icon 
	local duration = params.duration or 0.5
	local duration_show = duration * 0.15
	local duration_fade = duration * 0.15
	local add_values = {coins = 0, score = 0, xp = 0, resource = 0}

	local types_valute = {
		coins = {icon = "icon-gold-1"},
		xp = {icon = "game-icon-mutate"},
		resource = {icon = "game-icon-resource"},
	}

	add_values[type] = count
	icon = types_valute[type].icon
	print("storage_gui.interface", "position_"..type.."_screen")
	position_end = storage_gui.interface["position_"..type.."_screen"]

	--position_start = gui.screen_to_local(node, position_start)
	position_end = gui.screen_to_local(node, position_end)

	gui.set_rotation(node, vmath.vector3(0, 0, math.random(360)))
	gui.set_position(node, position_start)
	gui.play_flipbook(node, icon)
	gui.set_enabled(node, true)

	-- Анимация появления
	timer.delay(0, false, function (self)
		--gui.animate(node, 'color', vmath.vector4(1, 1, 1, 1), gui.EASING_OUTSINE, duration_show)
	end)

	gui.animate(node, 'position', position_end, gui.EASING_OUTSINE, duration, 0, function (self)
		gui.delete_node(node)

		-- Окончание 
		msg.post("main:/core_player", "balance", {
			operation = "add",
			values = add_values,
			animate = true,
		})
	end)

	timer.delay(duration - duration_fade, false, function (self)
		gui.animate(node, 'color', vmath.vector4(1, 1, 1, 0), gui.EASING_OUTSINE, duration_fade)
	end)
end

return M