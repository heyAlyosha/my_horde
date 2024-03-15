-- работа с предметами
local M = {}

-- Спавн предметов
function M.spawn(self)
	if self.spawn_items or self.command == hash("player") then
		return true
	end 
	self.spawn_items = true 
	-- Спавн монет 
	if self.spawn_coins then
		for i = 1, self.spawn_coins do
			msg.post(storage_game.map.url_script, "add_item", {
				position = go.get_position(),
				type_valute = hash("coin"),
				count = 1,
				value = 0, -- Данные для влаюты
			})
		end
	end

	-- Спавн мусора 
	if self.spawn_trash then
		for i = 1, self.spawn_trash do
			msg.post(storage_game.map.url_script, "add_item", {
				position = go.get_position(),
				type_valute = hash("trash"),
				count = 1,
				value = 0, -- Данные для влаюты
			})
		end
	end

	-- Спавн опыта (мутации) 
	if self.spawn_xp then
		for i = 1, self.spawn_xp do
			msg.post(storage_game.map.url_script, "add_item", {
				position = go.get_position(),
				type_valute = hash("xp"),
				count = 1,
				value = 0, -- Данные для влаюты
			})
		end
	end

	-- Спавн трофеев 
	if self.spawn_trophy then
		for i = 1, self.spawn_trophy do
			msg.post(storage_game.map.url_script, "add_item", {
				position = go.get_position(),
				type_valute = hash("trophy"),
				count = 1,
				value = 0, -- Данные для влаюты
			})
		end
	end

	-- Спавн звёзд 
	if self.spawn_star then
		for i = 1, self.spawn_star do
			msg.post(storage_game.map.url_script, "add_item", {
				position = go.get_position(),
				type_valute = hash("star"),
				count = 1,
				value = 0, -- Данные для влаюты
			})
		end
	end
end

return M