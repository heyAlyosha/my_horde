-- Атаки персонажей
local M = {}

--Запуск атаки
function M.attack(self, url_object)
	local url_object = url_object or msg.url(self.message.other_id)

	if not go_controller.is_object(url_object) then
		return false
	end

	-- Типы атак
	if self.attack_type == hash("bullet") then
		self.fire_queue = self.fire_queue or 1
		local add_time = 0
		M.attack_bullet(self, url_object)
		for i = 1, self.fire_queue - 1 do
			add_time = add_time + 0.2
			timer.delay(add_time, false, function (self)
				M.attack_bullet(self, url_object)
			end)
		end
		return true
	else
		return M.attack_hit(self, url_object)
	end
end

-- Дальний бой
function M.attack_bullet(self, url_object)
	self.type_bullet = hash("bullet_default")

	-- Место спавна пули
	local position = go.get_position()
	position.y = position.y + go.get("#body", "size").y / 2 * go.get("#body", "scale").y
	-- Поворачиваем пулю в нужное направление
	
	local rot = vmath.normalize(position - go.get_position(url_object))
	local angle = math.atan2(rot.y, rot.x)
	local rotation = vmath.quat_rotation_z(angle) 

	-- Свойства пули
	local properties = {
		command = self.command,
		damage = self.damage,
		damage_count_object = 1,
		parent = msg.url(),
	}

	-- Место спавна пули
	local position = go.get_position()
	position.y = position.y + go.get("#body", "size").y / 2
	local position_to = go.get_position(url_object)
	local dir = position_to - position
	-- Поворачиваем пулю в нужное направление
	local rot, angle, rotation
	if vmath.length(dir) > 0 then
		rot = vmath.normalize(dir)
		angle = math.atan2(rot.y, rot.x)
		rotation = vmath.quat_rotation_z(angle)
	else
		rot = vmath.vector3(1, 0, 0)
		rotation = vmath.quat_rotation_z(math.atan2(rot.y, rot.x))
	end
	properties.dir = dir

	-- Эффект выстрела
	if dir.x > 0 then
		particlefx.play("#shot_right")
	else
		particlefx.play("#shot_left")
	end
	
	factory.create("#bullet_factory", position, rotation, properties)

	sprite.set_hflip("#body", rot.x < 0)
	character_animations.play(self, "attack")

	return true
end

-- Ближний бой
function M.attack_hit(self, url_object)
	self.type_bullet = hash("bullet_hit")

	-- Место спавна пули
	local position = go.get_position()
	position.y = position.y + go.get("#body", "size").y / 2 * go.get("#body", "scale").y

	local position_to =  go.get_position(url_object)
	local url_body_to = msg.url(url_object.socket, url_object.path, "body")
	position_to.y = position_to.y + go.get(url_body_to, "size").y / 2 * go.get(url_body_to, "scale").y

	-- Поворачиваем пулю в нужное управление
	local rot = vmath.normalize(position - position_to)
	local angle = math.atan2(rot.y, rot.x)
	local rotation = vmath.quat_rotation_z(angle) 

	-- Свойства пули
	local properties = {
		command = self.command,
		damage = self.damage,
		damage_count_object = 5,
		type = hash("hit"),
		parent = msg.url(),
		visible_attack = self.visible_attack
	}

	-- Место спавна пули
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
	factory.create("#bullet_factory", position, rotation, properties)

	sprite.set_hflip("#body", rot.x < 0)
	character_animations.play(self, "attack")

	return true
end

return M