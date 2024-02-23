-- Функции
local M = {}

local gui_catalog = require "main.gui.modules.gui_catalog"
local gui_input = require "main.gui.modules.gui_input"
local gui_loader = require "main.gui.modules.gui_loader"
local game_content_artifact = require "main.game.content.game_content_artifact"
local game_content_wheel = require "main.game.content.game_content_wheel"
local gui_animate = require "main.gui.modules.gui_animate"
local color = require("color-lib.color")
local storage_game = require "main.game.storage.storage_game"
local game_core_gamers = require "main.game.core.game_core_gamers"
local gui_loyouts = require "main.gui.modules.gui_loyouts"
local gui_lang = require "main.lang.gui_lang"
local storage_player = require "main.storage.storage_player"

-- Вращение барабана
function M.rotate(self, end_position, game_wheel_render)
	-- Если уже вращается, не пропускаем
	if self.rotate then return false end

	-- Скорость
	local speed = 0.5
	-- Добавляем дополнительных круга для вращения
	local add_full_rotate = 3
	-- Находжим окончательную позицию для вращения
	local end_position = M.get_rotate(self) - end_position
	local all_rotate = add_full_rotate * 360 + end_position
	local duration = 5
	self.rotate = true

	-- Обновление табличики под барабаном
	self._rotate_timer_table = timer.delay(0.05, true, function (self)
		game_wheel_render.table(self)
	end)

	msg.post("/loader_gui", "set_status", {
		id = "all",
		from_id = self.id, 
		is_from_msg = false,
		type = "wheel_rotate",
		value = {
			step = "start",
		}
	})
	msg.post("game-room:/core_game", "event", {
		id = "wheel_rotate",
		value = {
			step = "start",
			sector_id = current_sector_id
		}
	})

	msg.post("game-room:/loader_gui", "set_status", {
		id = "game_wheel",
		type = "visible_aim",
		visible = false
	})

	-- 
	function end_rotate(self)
		-- Выставляем значение от нуля 
		self.rotate = nil

		timer.cancel(self._rotate_timer_table)

		game_wheel_render.table(self)
		local current_sector_id = M.get_sector_id(self)

		M.set_screen_position(self)

		local rotation_z = M.get_rotate(self, true)

		for i = 1, #self.sectors do
			local item = self.sectors[i]
			
		end

		storage_game.possible_aim_sectors = M.get_sectors_aim(self, 90, 270)

		-- Отправляем сообщения , что колесо остановилось
		msg.post("game-room:/core_game", "event", {
			id = "wheel_rotate",
			value = {
				step = "end",
				sector_id = current_sector_id
			}
		})
	end

	-- Вращаем
	gui.animate(self.nodes.wheel, "rotation.z", all_rotate, gui.EASING_INOUTCIRC, duration, 0.25, function (self)
		local rotation = gui.get_rotation(self.nodes.wheel)
		rotation.z = M.get_rotate(self, true)
		gui_loyouts.set_rotation(self, self.nodes.wheel, rotation)

		local current_sector = M.get_sector(self)
		M.to_center(self, current_sector, end_rotate)
	end)
end

-- Записываем экранные позиции во всех сектарах
function M.set_screen_position(self)
	for i, sector in ipairs(self.sectors) do
		game_content_wheel.sectors[i].screen_positions = game_content_wheel.sectors[i].screen_positions or {}
		game_content_wheel.sectors[i].screen_positions.object = gui.get_screen_position(self.sectors[i].nodes.object)
	end
end

-- Получение текщего поворота барабана
function M.get_rotate(self, clear)
	if clear then
		-- Получение поворота без лишних кругов
		local rotate = gui.get_rotation(self.nodes.wheel).z
		return rotate % 360
	else
		-- Обычное получение поворота
		return gui.get_rotation(self.nodes.wheel).z
	end
end

-- Получение текщего текущего сектора
function M.get_sector(self)
	local rotate = 360 - M.get_rotate(self, true)
	local index = math.ceil(rotate / self.angle_sector)
	return self.sectors[index]
end

-- Получение id текущего сектора
function M.get_sector_id(self)
	local rotate = 360 - M.get_rotate(self, true)
	local index = math.ceil(rotate / self.angle_sector)
	return index
end

-- Анимация докручивание колеса до центра сектора
function M.to_center(self, sector, function_end)
	local current_sector = M.get_sector(self)
	local rotate = 360 - current_sector.id * self.angle_sector + self.angle_sector / 2
	if rotate ~= (360 - M.get_rotate(self, true)) then
		gui.animate(self.nodes.wheel, "rotation.z", rotate, gui.EASING_LINEAR, 0.5, 0, function (self)
			gui_loyouts.set_rotation(self, self.nodes.wheel, rotate, "z")

			if function_end then
				function_end(self)
			end
		end)

	elseif function_end then
		function_end(self)

	end

	return true
end

-- Поворот прицела на процент
function M.rotate_aim(self, procent)
	local start_rotate, end_rotate = 90 + self.current_rotate, 270  
	local dif_rotate = end_rotate - start_rotate

	if procent > 1 then
		procent = 1
		--procent = procent / 100 
	end

	if procent <= 0 then
		procent = 0
	end

	self.rotate_aim = gui.get_rotation(self.nodes.aim)
	self.rotate_aim.z = start_rotate - self.current_rotate + dif_rotate * procent

	gui.set_rotation(self.nodes.aim, self.rotate_aim)

	-- Находим какие сектора загребает прицел
	local angle = gui.get_fill_angle(self.nodes.aim)

	local aim = M.get_aim(self)
	storage_game.aim_sectors = M.get_sectors_aim(self, aim.start_rotate, aim.end_rotate)

	return self.rotate_aim
end

--
function M.get_sectors_aim(self, start_aim, end_aim)
	local sectors_result = {}

	for i = 1, #self.sectors do
		local sector = self.sectors[i]
		local sector_center = M.get_rotate(self) + sector.center + self.angle_sector

		if (start_aim <= sector_center and end_aim >= sector_center) then
			sectors_result[#sectors_result + 1] = sector
			--gui.set_color(sector.nodes.wrap, color.red)
		else
			--gui.set_color(sector.nodes.wrap, color.white)
		end
	end

	return sectors_result
end

-- Получение информации по прицелу
function M.get_aim(self)
	local start_rotate = self.rotate_aim.z 
	local end_rotate = self.rotate_aim.z + self.current_rotate
	local center_rotate = self.rotate_aim.z - self.current_rotate / 2
	local random_rotate = math.random(start_rotate, end_rotate)

	--M.get_sectors_aim(self, start_rotate, end_rotate)

	return {
		start_rotate = start_rotate, end_rotate = end_rotate, center_rotate = center_rotate, random_rotate = random_rotate
	}
end

-- Анимация лучика света
function M.ray_object(self, sector, color_ray, function_end)
	local color_ray = color_ray or color.white 
	local node_ray = gui.clone(self.nodes.ray)

	-- Цвет
	gui.set_color(node_ray, color_ray)

	-- Устанавливаем луч на место объекта
	local screen_pos = gui.get_screen_position(sector.nodes.object_icon)
	local screen_pos_local =  gui.screen_to_local(node_ray, screen_pos)
	screen_pos_local.y = screen_pos_local.y - 10
	gui.set_position(node_ray,screen_pos_local)

	gui_animate.ray(self, node_ray, function (self)
		gui.delete_node(node_ray)

		if function_end then
			function_end(self)
		end
		
	end, 0.35, color_ray)
end

-- Фокусировка на колесе
function M.focus_wheel(self, visible, type, game_wheel_objects, orientation, function_end)
	self.visible_focus_wheel = visible
	local orientation = orientation or storage_player.orientation
	self.last_focus_wheel = {
		visible = visible,
		type = type,
		game_wheel_objects = game_wheel_objects
	}

	self.focus_wheel = {
		visible = visible,
		type = type
	}

	local focus_positions = {
		horisontal = {
			visible = vmath.vector3(960, 40, 0),
			bottom = vmath.vector3(960, 350, 0),
			top = vmath.vector3(960, 200, 0),
			scale = 1.2,
			default_scale = 1.1,
		},
		vertical = {
			visible = vmath.vector3(546, 92, 0),
			bottom = vmath.vector3(546, 592, 0),
			top = vmath.vector3(546, 492, 0),
			scale = 1.3,
			default_scale = 1.2,
		}
	}

	local positions = focus_positions[orientation]

	self._focus_wheel = self._focus_wheel or {}
	self._focus_wheel.position = self._focus_wheel.position or gui.get_position(self.nodes.wrap)
	self._focus_wheel.scale = positions.default_scale
	self._focus_wheel.scale_object = self._focus_wheel.scale_object or gui.get_scale(self.nodes.object)

	local duration = 0.25

	if not visible then
		gui.set_render_order(1)
		self.animate_focus_wheel = true
		-- Возвращаем на место
		msg.post("/loader_gui", "visible", {
			visible = false, 
			type = hash("animated_close"), 
			id = "bg", 
			parent_id = self.id
		})	
		gui.animate(self.nodes.wrap, "scale", positions.default_scale, gui.EASING_INOUTSINE, duration)
		gui.animate(self.nodes.wrap, "position", positions.visible, gui.EASING_INOUTSINE, duration)
		game_wheel_objects.scale_all(self, duration, self._focus_wheel.scale_object)

		self.last_focus_wheel = nil

	elseif type == "bottom" and not self.animate_focus_wheel then
		gui.set_render_order(3)
		self.animate_focus_wheel = true
		-- Если это фокусировка на нижней части барабана
		msg.post("/loader_gui", "visible", {
			visible = true, 
			id = "bg", 
			parent_id = self.id, 
			value = {order = 2, opacity = 0.75}
		})
		gui.animate(self.nodes.wrap, "scale", positions.scale, gui.EASING_INOUTSINE, duration)
		gui.animate(self.nodes.wrap, "position", positions.bottom, gui.EASING_INOUTSINE, duration)
		game_wheel_objects.scale_all(self, duration, self._focus_wheel.scale_object * 1.2)

	elseif type == "top" and not self.animate_focus_wheel then
		gui.set_render_order(3)
		self.animate_focus_wheel = true
		-- Если это фокусировка на верхней части барабана
		msg.post("/loader_gui", "visible", {
			visible = true, 
			id = "bg", 
			parent_id = self.id, 
			value = {order = 2, opacity = 0.75}
		})
		gui.animate(self.nodes.wrap, "scale", positions.scale, gui.EASING_INOUTSINE, duration)
		gui.animate(self.nodes.wrap, "position", positions.top , gui.EASING_INOUTSINE, duration)
		game_wheel_objects.scale_all(self, duration, self._focus_wheel.scale_object * 1.2)
	end

	--[[
	if self.timer_animate_focus then
		timer.cancel(self.timer_animate_focus)
		self.timer_animate_focus = nil
	end
	--]]

	self.timer_animate_focus = timer.delay(duration + 0.1, false, function (self)
		self.animate_focus_wheel = nil
		if function_end then
			function_end(self)
		end
	end)

end

-- Добавление артифакта и захват секторов
function M.add_artifact(self, sector_id, player_id, artifact_id, game_wheel_render, game_wheel_objects)
	local sector_artifact = game_content_wheel.get_item(self, sector_id)

	-- Если сектор уже захвачен
	if sector_artifact.catch then
		return false

	else
		-- Захватываем сектора и ставим артефакты
		local sector = self.sectors[sector_id]

		msg.post("main:/sound", "play", {sound_id = "game_result_open"})

		

		M.ray_object(self, sector, color_ray, function (self)
			M.catch(self, sector_id, player_id, artifact_id, function (self, sector, player, artifact)
				-- Еслди захват указываем, сколько очков
				local score
				if artifact.type == "catch" then
					score = artifact.value.score
				end

				if sector.id == sector_id then
					-- АРтефакт
					storage_game.wheel["sector_"..sector.id] = {player_id = player_id, artifact_id = artifact_id, score = score}
				else
					-- Сектор вокруг него (если сувениры)
					storage_game.wheel["sector_"..sector.id] = {player_id = player_id, artifact_id = nil, score = score}
				end

				for k, v in pairs(game_content_wheel.get_item(self, sector.id)) do
					sector[k] = v
				end

				game_wheel_render.item(self, sector)
				game_wheel_objects.update(self)
				game_wheel_objects.render_all(self)
				

				if self.add_scale_artifact then
					game_wheel_objects.scale_all(self, duration, vmath.vector3(self.add_scale_artifact))
				end

				-- Звёзды в миссии
				if player_id == "player" and storage_game.stars.type == "catch" then
					local sectors_player = 0
					for k, sector in pairs(storage_game.wheel) do
						if sector.player_id == "player" then
							sectors_player = sectors_player + 1
						end
					end

					local value = sectors_player / #game_content_wheel.sectors * 100

					local operation = "set"
					msg.post("main:/core_stars", "update", {
						value = value, operation = operation
					})
				end
			end)

			
		end)
	end
end

-- Функция захвата
function M.catch(self, sector_id, player_id, artifact_id, function_set)
	local artifact = game_content_artifact.get_item(artifact_id, player_id)
	local player = game_core_gamers.get_player(self, player_id)

	-- Какие ячейки отрисовывать 
	local ids = {}
	local start_id = sector_id
	local end_id = sector_id

	local sectors = 1
	if artifact and artifact.type == "catch" then
		sectors =  artifact.value.sectors
	end

	local sectors_count = (sectors - 1) / 2

	start_id = start_id - sectors_count
	end_id = end_id + sectors_count

	-- Удаляем все старые превьюшки
	for i = 1, #self.sectors do
		self.sectors[i].preview = nil

	end

	for i = start_id, end_id do
		local id = i
		if id < 1 then
			id = #self.sectors + id

		elseif id > #self.sectors then
			id = id - #self.sectors 
		end
		local sector = self.sectors[id]

		-- Заупскаем функцию записи
		if not sector.catch and function_set then
			function_set(self, sector, player, artifact)
		end
	end
end

return M