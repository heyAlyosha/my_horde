-- Вращение орды
local M = {}

M.speed = 2 -- Скорость поворота 
M.rot = vmath.quat_rotation_z(3.141592653 * 2) 

function M.set(self, is_circle_horde, handle)
	self.is_circle_horde = is_circle_horde
	if self.is_circle_horde then
		self.t_horde_circle = 0
		horde.set_animation_horde(self, "run")

		local delay = 1
		character_animations.play(self, "win")
		self.move_stop = true
		timer.delay(delay, false, function (self)
			self.move_stop = false
		end)
	else
		self.t_horde_circle = 0
		horde.set_animation_horde(self, "default")
		horde.move_horde_player(self)
	end
end

-- Обновление вращающейся орды
function M.player_update(self, dt)
	self.center = go.get_position()
	self.t_horde_circle = self.t_horde_circle or 0 
	self.t_horde_circle = self.t_horde_circle + dt
	local rot = vmath.quat_rotation_z(3.141592653 * self.t_horde_circle / M.speed ) 

	for i = 1, #self.horde do
		zombie = self.horde[i]
		local vec = horde.positions[i].vector
		local pos = vmath.rotate(rot, vec) + self.center
		sprite.set_hflip(zombie.url_sprite, pos.x < go.get_position(zombie.url).x)

		position_functions.go_set_perspective_z(pos, zombie.url) -- <9>
	end

end

return M