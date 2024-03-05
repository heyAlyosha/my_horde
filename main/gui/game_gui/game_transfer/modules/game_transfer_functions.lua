-- функции для отрисовки анимированного добавления баланса
local M = {}

local storage_gui = require "main.storage.storage_gui"
local storage_player = require "main.storage.storage_player"
local gui_animate = require "main.gui.modules.gui_animate" 
local camera = require "orthographic.camera"

-- Функция генерации 1 элемента c дуговым падением
function M.add_elem_curve(self, type_valute, count, index, where, to, message, function_end)
	local node = gui.clone(self.nodes.elem)
	local node_id = gui.get_id(node)
	local index = index or 1
	local add_values = {coins = 0, score = 0, rating = 0}
	local icon = 'icon_score'

	gui.set_scale(node, vmath.vector3(storage_player.zoom))

	local position_where_start
	if where.type == "object" then
		position_where_start = gui.screen_to_local(node, where.position)
	else
		position_where_start = camera.world_to_screen(camera_id, where.position, gui.ADJUST_FIT)
	end

	if type_valute == 'score' then
		add_values.score = count
		icon = 'icon_score'
	else
		add_values.coins = count
		icon = 'icon_gold'
	end

	for k, v in pairs(add_values) do
		add_values[k] = -v
	end

	msg.post("game-room:/core_game", "event", {
		id = "transfer", 
		count = add_values,
		where = where
	})

	-- Место где спавнятся иконки
	local position_start = position_where_start
	-- Место куда они падают (центр барабана)
	local position_end = gui.screen_to_local(node, storage_gui.data.game.position_wheel)

	gui.set_color(node, vmath.vector4(1, 1, 1, 1))
	gui.set_enabled(node, true)
	gui.set_position(node, position_start)
	gui.play_flipbook(node, icon)

	-- Находим вектор  рандомного направления наверх
	math.randomseed(os.clock() * index)
	math.randomseed(os.clock() * position_start.x * position_start.y)

	local random_position_end = vmath.vector3(
	position_end.x + math.random(-150, 150), 
	position_end.y + math.random(-50, 50), 
	position_end.z)

	-- Скорость полёта (100px / sec)
	local position_end = random_position_end
	local speed = 0.05
	local height = 100
	local is_animate_aplha = false

	gui_animate.flight(self, node, position_start, position_end, height, speed, is_animate_aplha, function (self)
		timer.delay(0.15, false, function (self)
			if to then
				gui.delete_node(node)
				M.add_elem(self, type_valute, gui.get_screen_position(node), to, count, message, {icon = icon})
			else
				timer.delay(0.25, false, function (self)
					gui.delete_node(node)
				end)
			end
		end)
	end)
end


-- Функция генерации 1 элемента для анимации
function M.add_elem(self, type, position_start, to, count, message, params)
	local params = params or {}
	local node = gui.clone(self.nodes.elem)
	local icon 
	local duration = params.duration or 0.5
	local duration_show = duration * 0.15
	local duration_fade = duration * 0.15
	local add_values = {coins = nil, score = nil, rating = nil}

	gui.set_scale(node, vmath.vector3(storage_player.zoom))

	if type == 'score' then
		add_values.score = count or 0
		icon = params.icon or 'icon_score'
	else
		add_values.coins = count or 0
		icon = params.icon or 'icon_gold'
	end

	local position_start = gui.screen_to_local(node, position_start)
	local position_end = camera.world_to_screen(camera_id, to.position, gui.ADJUST_FIT)

	gui.set_rotation(node, vmath.vector3(0, 0, math.random(360)))
	gui.set_position(node, position_start)
	gui.play_flipbook(node, icon)
	gui.set_enabled(node, true)

	-- Анимация появления
	local is_animate_aplha = true
	local speed = 0.05
	gui_animate.flight(self, node, position_start, position_end, height, speed, is_animate_aplha, function (self)
		gui.delete_node(node)

		msg.post("game-room:/core_game", "event", {
			id = "transfer", 
			count = add_values,
			to = to
		})
	end)
end

return M