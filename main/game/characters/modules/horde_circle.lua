-- Вращение орды
local M = {}

M.speed = 1 -- Скорость поворота 
M.speed_max = 0.6
M.speed_min = 2
M.speed_row = 0.3

M.rot = vmath.quat_rotation_z(3.141592653 * 2)

function M.set(self, is_circle_horde, handle)
	self.is_circle_horde = is_circle_horde
	if self.is_circle_horde then
		self.t_horde_circle = 0
		horde.set_animation_horde(self, "run")

		local delay = 2
		character_animations.play(self, "win")
		msg.post(storage_game.map.url_script, "effect", {
			position = go.get_position(),
			scale = vmath.vector3(1),
			animation_id = hash("thunderstorm"),
			timer_delete = delay,
			animate = true,
			shake = false, -- Тряска камеры при эффекте
		})
		self.move_stop = true
		timer.delay(delay, false, function (self)
			self.move_stop = false
			if handle then
				handle(self)
			end
		end)
	else
		self.t_horde_circle = 0
		horde.set_animation_horde(self, "default")
		if self.command == hash("player") then
			horde.move_horde_player(self)
		else
			horde.set_animation_horde(self, "run")
		end
	end
end

-- Обновление вращающейся орды
function M.player_update(self, dt)
	self.center = go.get_position()
	self.t_horde_circle = self.t_horde_circle or 0 
	self.t_horde_circle = self.t_horde_circle + dt
	local hordes_count = #self.horde
	if hordes_count < 1 then
		return
	end
	local row = horde.positions[hordes_count].row
	local speed = M.speed_max + row * M.speed_row
	if speed > M.speed_min then
		speed = M.speed_min 
	end
	local rot = vmath.quat_rotation_z(3.141592653 * self.t_horde_circle / speed ) 

	for i = 1, hordes_count do
		zombie = self.horde[i]
		local vec = horde.positions[i].vector
		local position_to = vmath.rotate(rot, vec) + self.center
		local position_current = go.get_position(zombie.url)
		local dir = position_to - position_current
		local len = vmath.length(dir)
		if len > 5 then
			-- Если зомбик далеко
			local speed = 100
			local input = vmath.normalize(dir)
			local movement = input * speed * dt
			position_to = position_current + movement
		end
		sprite.set_hflip(zombie.url_sprite, dir.x < 0)
		position_functions.go_set_perspective_z(position_to, zombie.url)
	end

end

return M