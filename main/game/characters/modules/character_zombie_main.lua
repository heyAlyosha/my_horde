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

-- Отслеживание изменений в орде
function M.change_horde(self)
	local max_index = #self.horde
	if max_index < 1 then
		max_index = 1
	end
	-- Позиция для добавления зомбиков
	self.target_add_horde = horde.get_position(self, go.get_position(), max_index)

	local dist_max_horde = vmath.length(self.target_add_horde - self.target_add_horde)

	self.visible_horde = self.visible_horde_min + dist_max_horde
	self.distantion_visible = self.distantion_attack + dist_max_horde
end

return M