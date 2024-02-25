-- Атаки персонажей
local M = {}

--Запуск атаки
function M.attack(self)
	if not storage_game.go_urls[self.message.other_id] then
		return false
	end
	local url_object = self.message.other_id
	self.type_bullet = hash("bullet_hit")

	-- Место спавна пули
	local position = go.get_position()
	-- Поворачиваем пулю в нужное управление
	local rot = vmath.normalize(position - go.get_position(url_object))
	local angle = math.atan2(rot.y, rot.x)
	local rotation = vmath.quat_rotation_z(angle) 

	-- Свойства пули
	local properties = {
		command = self.command,
		damage = self.damage,
		damage_count_object = 5,
		type = hash("hit"),
		parent = msg.url()
	}

	-- Место спавна пули
	local position = go.get_position()
	local position_to = go.get_position(url_object)
	local dir = position_to - position
	-- Поворачиваем пулю в нужное управление
	local rot, angle, rotation
	if vmath.length(dir) > 0 then
		rot = vmath.normalize(dir)
		angle = math.atan2(rot.y, rot.x)
		rotation = vmath.quat_rotation_z(angle)
	else
		rot = vmath.vector3(1, 0, 0)
		rotation = vmath.quat_rotation_z(math.atan2(rot.y, rot.x))
	end
	print(rotation)
	factory.create("#bullet_hit_factory", position, rotation, properties)

	sprite.set_hflip("#body", rot.x < 0)
	character_animations.play(self, "attack")

	return true
end

return M