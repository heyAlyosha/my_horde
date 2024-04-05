-- Атаки персонажей
local M = {}

--Дамаг по зомби
function M.damage_zombie(self, message)
	-- Получили урон
	local damage = message.damage or 0
	self.from_id_object = message.from_id_object 
	self.live = self.live - damage

	if self.type_object ~= hash("zombie_dynamic") then
		live_bar.create(self)
		live_bar.set_hp(self, self.live, self.max_live)
	end

	character_animations.damage(self, message.parent)

	if self.live <= 0 then
		local position = go.get_position()
		position.y = position.y + go.get("#body", "size").y / 2

		msg.post(storage_game.map.url_script, "effect", {
			position = position,
			animation_id = hash("effect_zombie_death"), 
			timer_delete = 3
		})
		items_functions.spawn(self)
		go.delete()
	else
		pprint(go.get_id())
		character_animations.aging_zombie(self)
	end
end

-- Дамаг по зомби
function M.damage_zombie_horde(self, damage)
	local damage = damage or self.damage_for_collision

	self.live = self.live - damage

	character_animations.damage_zombie_horde(self)

	if self.live <= 0 then
		msg.post(self.parent, "kill_zombie", {url_zombie = msg.url()})
	else
		character_animations.aging_zombie(self)
	end
end

-- Дамаг человечка
function M.damage_human(self, message)
	-- Получили урон
	local damage = message.damage or 0
	self.from_id_object = message.from_id_object 
	self.live = self.live - damage

	character_animations.damage_human(self, message.parent)

	--live_bar.create(self)
	--live_bar.set_hp(self, self.live, self.max_live)

	if self.live <= 0 then
		local position = go.get_position()
		position.y = position.y + go.get("#body", "size").y / 2

		msg.post(storage_game.map.url_script, "effect", {
			position = position,
			animation_id = hash("effect_infection"), 
			timer_delete = 0
		})
		items_functions.spawn(self)

		-- Генерируем зомбиков
		if not self.add_zombie then
			self.add_zombie = true
			local url_zombie = message.parent
			local type_object = go.get(url_zombie, "type_object")
			if type_object == hash("zombie_main") then
				msg.post(url_zombie, "create_zombie", {
					human_id = self.human_id, position = go.get_position()
				})
			elseif type_object == hash("zombie_dynamic") then
				local parent = go.get(url_zombie, "parent")
				msg.post(parent, "create_zombie", {
					human_id = self.human_id, position = go.get_position()
				})
			end
		end

		go.delete()
	end
end

--Дамаг по зомби
function M.damage_soldier(self, message)
	-- Получили урон
	local damage = message.damage or 0
	self.from_id_object = message.from_id_object 
	self.live = self.live - damage

	live_bar.create(self)
	live_bar.set_hp(self, self.live, self.max_live)

	character_animations.damage(self, message.parent)

	if self.live <= 0 then
		local position = go.get_position()
		position.y = position.y + go.get("#body", "size").y / 2

		msg.post(storage_game.map.url_script, "effect", {
			position = position,
			animation_id = hash("effect_infection"), 
			timer_delete = 0
		})
		items_functions.spawn(self)

		go.delete()

		-- Генерируем зомбиков
		local url_zombie = message.parent
		local type_object = go.get(url_zombie, "type_object")
		if type_object == hash("zombie_main") then
			msg.post(url_zombie, "create_zombie", {
				human_id = self.human_id, position = go.get_position()
			})
		elseif type_object == hash("zombie_dynamic") then
			local parent = go.get(url_zombie, "parent")
			msg.post(parent, "create_zombie", {
				human_id = self.human_id, position = go.get_position()
			})
		end
	end
end

return M