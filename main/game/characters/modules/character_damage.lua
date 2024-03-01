-- Атаки персонажей
local M = {}

--Дамаг по зомби
function M.damage_zombie(self, message)
	-- Получили урон
	local damage = message.damage or 0
	self.from_id_object = message.from_id_object 
	self.live = self.live - damage

	label.set_text("#label", self.live .. "/"..self.max_live)

	character_animations.damage(self, message.parent)

	if self.live <= 0 then
		local position = go.get_position()
		position.y = position.y + go.get("#body", "size").y / 2

		msg.post(storage_game.map.url_script, "effect", {
			position = position,
			animation_id = hash("effect_zombie_death"), 
			timer_delete = 3
		})
		go.delete()
	end
end

-- Дамаг человечка
function M.damage_human(self, message)
	-- Получили урон
	local damage = message.damage or 0
	self.from_id_object = message.from_id_object 
	self.live = self.live - damage

	if self.live <= 0 then
		local position = go.get_position()
		position.y = position.y + go.get("#body", "size").y / 2

		msg.post(storage_game.map.url_script, "effect", {
			position = position,
			animation_id = hash("effect_infection"), 
			timer_delete = 0
		})
		go.delete()
	end
end

return M