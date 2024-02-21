-- Орда
local M = {}

M.start_radius = 15
M.start_angle = 35
M.add_step_radius = 15
M.add_step_angle = -20
M.interval_zombie = 18

-- Позиции для орды
M.positions = {}

function M.get_angle_radius(radius, row)
	-- Стартовая точка
	local point_start_radius = vmath.vector3(0)
	point_start_radius.y = point_start_radius.y + radius + M.add_step_radius * (row - 1)

	-- Следующая точка с заданным
	local point_next_radius = vmath.vector3(point_start_radius.x + M.interval_zombie, point_start_radius.y, 0)

	-- Угол между этими векторами
	local ans = math.acos(vmath.dot(point_start_radius, point_next_radius) / (vmath.length(point_start_radius) * vmath.length(point_next_radius)))
	return math.deg(ans)
end

-- Получение позиции для расположения зомбика
function M.get_position(self, сenter_position, index_to_horde)
	if M.positions[index_to_horde] then
		-- Если есть кешированный результат
		return сenter_position + M.positions[index_to_horde]
	else
		local center = vmath.vector3(0)
		local radius = M.start_radius 
		local interval = 15
		local current_angle = 0
		local row = 1
		local add_angle

		-- Точки вокруг
		for i = 1, index_to_horde do
			-- Находим угол
			if not add_angle then
				add_angle = M.get_angle_radius(radius, row)
			end

			if current_angle > 360 then
				current_angle = 0
				row = row + 1
				add_angle = M.get_angle_radius(radius, row)
			end

			local point_item = vmath.vector3(0)
			point_item.y = point_item.y + radius + M.add_step_radius * 0.7 * (row - 1)

			local dir = center - point_item
			current_angle = current_angle + add_angle

			x = dir.x*math.cos(math.rad(current_angle)) - dir.y*math.sin(math.rad(current_angle))
			y = dir.y*math.cos(math.rad(current_angle)) + dir.x*math.sin(math.rad(current_angle))
			M.positions[i] = vmath.vector3(x, y, 0)

			
			print("current_angle:", i, current_angle)
		end

		return сenter_position + M.positions[index_to_horde]

		--[[
		-- Центр круга
		self.center = vmath.vector3(0, 0, 0)
		-- Радиус
		self.radius = 15 -- <2>
		-- Скорость
		self.speed = 10 -- <3>
		-- Прошедшее время
		self.t = 0 -- <4>

		for i = 1, index_to_horde do
			--print(math.sin(i * self.speed), math.cos(i * self.speed))
			local dx = math.sin(i * self.speed) * self.radius -- <6>
			local dy = math.cos(i * self.speed) * self.radius
			local pos = vmath.vector3() -- <7>
			pos.x = self.center.x + dx -- <8>
			pos.y = self.center.y + dy
			--go.set_position(pos) -- <9>
			M.positions[i] = pos
		end
		--]]

		--[[
		for i = 0, index_to_horde do
			local dx = math.sin((i - 1) * M.interval_zombie) * (M.start_radius + M.add_step_radius * step)
			local dy = math.cos((i - 1) * M.interval_zombie) * (M.start_radius + M.add_step_radius * step)
			print("Horde position:", i, dx, dy)
		end
		--]]
	end
end

return M