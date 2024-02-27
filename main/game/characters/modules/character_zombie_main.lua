-- Фнкции
local M = {}

-- Добавление атакующего зомбика
function M.add_zombie_attack(self, horde_index, position, target)
	local item = self.horde[horde_index]
	local position = position or go.get_position(item.url)

	if item then
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

		self.target_add_horde = horde.get_position(self, go.get_position(), #self.horde)
	end
end

return M