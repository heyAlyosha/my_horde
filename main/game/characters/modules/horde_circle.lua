-- Вращение орды
local M = {}

M.speed = 3.5 -- Скорость поворота 
M.rot = vmath.quat_rotation_z(3.141592653 * 2) 

function M.set(self, is_circle_horde)
	self.is_circle_horde = is_circle_horde
	if self.is_circle_horde then
		self.t_horde_circle = 0
		horde.set_animation_horde(self, "run")
	else
		
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