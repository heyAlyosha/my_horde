-- Фнкции
local M = {}

function M.on_message(self, message_id, message, sender)
	if message_id == hash("add_horde") then
		-- Добавляем зомбика в орду
		local url = go_controller.url_object(sender)
		self.zombies[go_controller.url_to_key(url)] = nil

		local skin_id = message.skin_id or self.skin_id or 0
		local human_id = message.human_id or 0
		horde.add_zombie_horde(self, skin_id, human_id, message.position_from)

		if self.animation_horde == "run" then
			local zombie = self.horde[#self.horde]
			horde.set_animation_item(self, zombie, self.animation_horde)
		end
	end
end

-- Выпадение предметов (кроме трофея)
function M.spawn_items(self)
	local items = {
		{size_horde = 0, coins = 1, xp = 3,},
		{size_horde = 5, coins = 2, xp = 5,},
		{size_horde = 20, coins = 3, xp = 10,},
		{size_horde = 40, coins = 4, xp = 20,},
		{size_horde = 80, coins = 7, xp = 30,},
		{size_horde = 100, coins = 10, xp = 50,}
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
		items_functions.spawn_trophy(self)
	end

	horde.killing_all(self)
	go.delete()
end



return M