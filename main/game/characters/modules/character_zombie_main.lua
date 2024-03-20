-- Фнкции
local M = {}

-- Добавление атакующего зомбика
function M.add_zombie_attack(self, horde_index, position, target, message)
	local position = position or go.get_position(item.url)

	if horde_index and self.horde[horde_index] then
		-- Из орды
		local item = self.horde[horde_index]

		-- Удаляем зомбика из орды
		table.remove(self.horde, horde_index)
		go.delete(item.url)

		local properties = {
			command = self.command,
			skin_id = item.skin_id,
			human_id = item.human_id,
			parent = msg.url(go.get_id()),
			target = target
		}
		local go_id = factory.create("#zombie_factory", position, rotation, properties)
		local url = msg.url(go_id)
		local url_key = go_controller.url_to_key(url)
		self.zombies[url_key] = {
			id = go_id,
			url = url,
			url_script = msg.url(nil, go_id, "script"),
			url_sprite = msg.url(nil, go_id, "body"),
			skin_id = item.skin_id,
			human_id = item.human_id,
		}

	else
		-- Из сообщения
		local properties = {
			command = self.command,
			skin_id = message.skin_id or self.skin_id,
			human_id = message.human_id or 0,
			parent = msg.url(go.get_id()),
			target = target
		}
		local go_id = factory.create("#zombie_factory", position, rotation, properties)
		local url = msg.url(go_id)
		local url_key = go_controller.url_to_key(url)
		self.zombies[url_key] = {
			id = go_id,
			url = url,
			url_script = msg.url(nil, go_id, "script"),
			url_sprite = msg.url(nil, go_id, "body"),
			skin_id = message.skin_id or self.skin_id,
			human_id = message.human_id or 0,
		}
	end

	character_zombie_main.change_horde(self)
end

-- Добавление анимированных кружащихся зомбиков
function M.add_zombie_animation(self, type_from_zombie, key, index)
	self.animation_zombies = self.animation_zombies or {}

	local human_id, skin_id, position

	if type_from_zombie == "horde" then
		local item = self.horde[key]
		human_id = item.human_id
		skin_id = item.skin_id
		position = go.get_position(item.url)

		-- Удаляем зомбика из орды
		if item then
			table.remove(self.horde, key)
		end
		go.delete(item.url)
		
	elseif type_from_zombie == "zombie_attack" then
		local item = self.zombies[key]
		human_id = item.human_id
		skin_id = item.skin_id
		position = go.get_position(item.url)

		-- Удаляем зомбика из массива зомбика
		self.zombies[key] = nil
		go.delete(item.url)
	end

	position = position or go.get_position()
	local properties = {
		index = index, 
		parent = msg.url(),
		human_id = human_id,
		skin_id = skin_id,
	}

	local url = msg.url(factory.create("#zombie_animation_horde_factory", position, rotation, properties))
	pprint(url)
	table.insert(self.animation_zombies, {
		url = url,
		skin_id = skin_id,
		human_id = human_id,
		texture = go.get(msg.url(url.socket, url.path, "body"), "texture0")
	})
end

-- Отслеживание изменений в орде
function M.change_horde(self)
	self.horde_count_current =  #self.horde
	local max_index = self.horde_count_current
	if max_index < 1 then
		max_index = 1
	end
	-- Позиция для добавления зомбиков
	self.target_add_horde = horde.get_position(self, go.get_position(), max_index)

	local dist_max_horde = vmath.length(self.target_add_horde - self.target_add_horde)

	self.visible_horde = self.visible_horde_min + dist_max_horde
	self.distantion_visible = self.distantion_attack + dist_max_horde

	if self.hp_bar and self.hp_bar[hash("/count")] then
		local url = msg.url(self.hp_bar[hash("/count")])
		local url_label = msg.url(url.socket, url.path, "count_horde")
		label.set_text(url_label, self.horde_count_current)
	end
end

return M