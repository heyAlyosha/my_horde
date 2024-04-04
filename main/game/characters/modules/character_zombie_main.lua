-- Фнкции
local M = {}

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

	local dist_max_horde = vmath.length(go.get_position() - self.target_add_horde)

	zone_infection.update_size(self, dist_max_horde)

	self.visible_horde = self.visible_horde_min + dist_max_horde
	self.distantion_visible = dist_max_horde

	self.size_horde = self.horde_count_current
	for k, v in pairs(self.zombies) do
		self.size_horde = self.size_horde + 1
	end

	-- Запоминаем рекорд размера орды
	self.max_size_horde = self.max_size_horde or 0
	if self.size_horde > self.max_size_horde then
		self.max_size_horde = self.size_horde
	end

	if self.hp_bar and self.hp_bar[hash("/count")] then
		local url = msg.url(self.hp_bar[hash("/count")])
		local url_label = msg.url(url.socket, url.path, "count_horde")
		if self.horde_count_current < 1 then
			msg.post(url_label, "disable")
		else
			msg.post(url_label, "enable")
		end
		label.set_text(url_label, self.size_horde .. "/" ..self.max_horde)
	end
end

-- Выпадение предметов (кроме трофея)
function M.spawn_items(self)
	local items = {
		{size_horde = 0, coins = 1, xp = 3,},
		{size_horde = 5, coins = 3, xp = 5,},
		{size_horde = 20, coins = 5, xp = 10,},
		{size_horde = 40, coins = 7, xp = 20,},
		{size_horde = 80, coins = 10, xp = 30,},
		{size_horde = 100, coins = 15, xp = 50,}
	}

	self.max_size_horde = self.max_size_horde or 0
	for i = #items, 1, -1 do
		local item = items[i]
		if self.max_size_horde >= item.size_horde then
			if self.spawn_coins == 0 then
				self.spawn_coins = item.coins
			end

			if self.spawn_xp == 0 then
				self.spawn_xp = item.xp
			end
			break
		end
	end

	

	items_functions.spawn(self)
end

function M.killing(self, is_player)
	local position = go.get_position()
	position.y = position.y + go.get("#body", "size").y / 2

	msg.post(storage_game.map.url_script, "effect", {
		position = position,
		animation_id = hash("effect_zombie_death"), 
		timer_delete = 3
	})
	if not is_player then
		M.spawn_items(self)
		--items_functions.spawn_trophy(self)
	end

	horde.killing_all(self)
	go.delete()
end



return M